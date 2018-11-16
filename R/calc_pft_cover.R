#' Calculate Plant Functional Type Cover Layers
#'
#' Generates plant functional type (PFT) cover layers, starting with an inital
#'   assumption of 100\% "grassy world." If additional vegetation cover layers
#'   are provided by the user, total grass cover is adjusted by (1) subtracting
#'   the sum of the other vegetation layers from 100\% grass cover, and (2)
#'   partitioning the remaining percent grass cover into C3 and C4 components by
#'   multiplying by the C4 grass ratio (result of \code{calc_C4_ratio}). If C3/C4
#'   crop cover layers are provided, the user may add these to respective C3/C4
#'   grass cover layers.
#'
#' @param C4.ratio RasterLayer. C4 ratio of grass cover, result of
#'   \code{calc_C4_ratio}.
#' @param GS.mask RasterBrick. Monthly mask of grid cells that meet growing
#'   season criteria, result of \code{mask_grids}  and \code{intersect_masks}.
#' @param veg.layers Raster* object. Each layer corresponds to non-herbaceous
#'   cover or agriculatural crop layers. Default value = NULL.
#' @param C4.flag Numeric. Vector with length equal to number of layers in
#'   \code{veg.layers} object, with C4 vegetation flag = 1, C3 vegetation flag
#'   = 0. Default value = NULL
#' @param herb.flag Numeric. Vector with length equal to number of layers in
#'   \code{veg.layers} object, with herbaceous vegetation flag = 1, woody
#'   vegetation flag = 0. Default value = NULL.
#' @param sale.factor Numeric. Scale factor for vegetation cover. Default value
#'   = 100.
#' @param veg.weight Logical. User may optionally specify to weight layers in
#'   \code{veg.layers} so that total vegetation per pixel is constrained to
#'   100\%. Default value = FALSE.
#' @param filename Character. Optional output root filename passed to
#'   \code{writeRaster}, default output file type is GeoTiff. If not specified,
#'   output is written to a temporary file.
#' @param ... Other arguments passed to \code{writeRaster}.
#' @return RasterBrick. Each layer corresponds to percent vegetation cover;
#'   stack layers are ordered as follows - Layer[[1]]: C4 herbaceous, Layer[[2]]:
#'   C3 herbaceous, Layer[[3]], ...: optional vegetation layer[s] provided by
#'   user. C4/C3 herbaceous layers may combine C4/C3 grass + C4/C3 crop cover,
#'   if specified by user.
#' @export
#' @examples # Load additional vegetation cover layers for North America to use
#'   in this example
#' data(woody_NA)    # percent woody vegetation cover
#' data(cropC3_NA)   # percent C3 crop cover
#' data(cropC4_NA)   # percent C4 crop cover
#' \donttest{
#' # Create raster stack of other (non-grassy) vegetation layers
#' veg_layers <- stack(cropC4_NA, cropC3_NA, woody_NA)
#'
#' # Vector to flag layers that correspond to C4 vegetation
#' C4_flag <- c(1, 0, 0)
#'
#' # Vector to flag layers that correspond to herbaceous vegetation
#' herb_flag <- c(1, 1, 0)
#'
#' # Generate plant functional type (PFT) vegetation layers
#' C4_ratio <- calc_C4_ratio(C4_mask, GS_mask)
#' pft_cover <- calc_pft_cover(C4_ratio, veg_layers, C4_flag, herb_flag)
#'
#' # Plot PFT vegetation cover layers
#' plot(pft_cover)
#' }
#' @seealso \link[grassmapr]{calc_C4_ratio}, \link[grassmapr]{count_months},
#' \link[raster]{overlay}.
#'
calc_pft_cover <- function(C4.ratio, GS.mask, veg.layers = NULL, C4.flag = NULL,
  herb.flag = NULL, scale.factor = 100, veg.weight = FALSE, filename = "", ...) {

  # Function to calculate vegetation cover, starting with "100% grass world,"
  #  incorporates other vegetation layers, and adjusts grass layers for crops.

  # Error check: same extent, grid, projection for all input raster layers
  if(!is.null(veg.layers)) {
    compareRaster(C4.ratio, veg.layers, stopiffalse = TRUE, showwarning = TRUE)
  }

  # Error check: Length of C4.flag vector equals nlayers for veg.layers stack
  if(!is.null(C4.flag)) {
    if(length(C4.flag) != nlayers(veg.layers)) {
      stop("Length of C4.flag vector does not match number of veg.layers")
    }
  }

  # Error check: Length of herb.flag vector equals length of C4.flag
    if(!is.null(herb.flag)) {
      if(length(herb.flag) != length(C4.flag)){
        stop("Length of herb.flag vector not equal to C4.flag vector")
      }
    }

  # Error check: Sum of veg.layer values constrained to 100%
    if(!is.null(veg.layers) & isFALSE(veg.weight))  {
      veg_sum <- overlay(veg.layers, fun = "sum")
      if(as.integer(maxValue(veg_sum)) > scale.factor) {
      stop("      User-provided vegetation layers have not been harmonized.
        Total vegetation cover excedes 100% for one or more pixels.
        User may set function parameter veg.weight=TRUE to normalize veg.layers.
        This will constrain per-pixel values to 100%.")
      }
    }

  # Step 1. Initialize vegetation cover as "all-herbaceous world."
  #   Herbaceous cover = 100% for all pixels that meet growing season thresholds
  #     for at least one month of the year.

    null_herb <- overlay(setValues(C4.ratio, scale.factor),
      (count_months(GS.mask) != 0), fun = "*")

  # Step 2. Adjust for real world vegetation; subtract sum of vegetation layers
  #  from "all-herbaceous world" template.
  if(!is.null(veg.layers)) {

    # Mask vegeteation layers based on growing season threshold
    veg_layers <- overlay(veg.layers,
      (count_months(GS.mask) != 0), fun = "*")

    if(isFALSE(veg.weight)) {
      # Vegetation layers are harmonized (per-pixel values <= scale factor)
      null_herb <- overlay(overlay(veg_layers, fun = "sum"),
        null_herb, fun = "diff")
    } else {
      # Normalize vegetation layers so per-pixel sum <= specified scale.factor)
      # NOTE - THIS STEP IS NOT RECOMMENDED
      veg_rescale <- overlay(veg_layers, fun = "sum")
      veg_rescale[veg_rescale <= scale.factor] <- 1
      veg_rescale[veg_rescale != 1] <-
        veg_rescale[veg_rescale != 1]*(1/scale.factor)
      veg_layers <-  overlay(veg_layers, veg_rescale, fun = "/")

      null_herb <- overlay(overlay(veg_layers, fun = "sum"),
        null_herb, fun = "diff")
    }
  }

  # Step 3. Calculate C4 herbaceous layer:
  #   (i) multiply adjusted herbaceous layer by C4.ratio,
  #  (ii) add all vegetation layers with flags (C4 = 1 & Herb = 1)
  #   Repeat for C3 herbaceous layer.
  C4_herb_index <- which((C4.flag == 1) & (herb.flag == 1))
  if(length(C4_herb_index) != 0) {
    C4_herb <- overlay(overlay(null_herb, C4.ratio, fun = "*"),
      overlay(veg_layers[[C4_herb_index]], fun = "sum"),
      fun = "sum")
  } else {
    C4_herb <- overlay(null_herb, C4.ratio, fun = "*")
  }

  C3_herb_index <- which((C4.flag == 0) & (herb.flag == 1))
  if(length(C3_herb_index) != 0) {
    C3_herb <- overlay(overlay(null_herb, C4.ratio, fun = function(x,y) {
      return(x*(1.0-y))}), overlay(veg_layers[[C3_herb_index]],
        fun = "sum"), fun = "sum")
  } else {
    C3_herb <- overlay(null_herb, C4.ratio, fun = function(x,y){
      return(x*(1.0-y))})
  }

  rm(null_herb, C4_herb_index, C3_herb_index)

  # Step 4: Create brick of vegetation PFT cover; add in non-herbaceous layers
  woody_index <- which((herb.flag == 0))
  if(length(woody_index) != 0) {
    pft_cover <- brick(C4_herb, C3_herb, veg_layers[[woody_index]])
    names(pft_cover) <- c("C4_herb", "C3_herb", names(veg.layers[[woody_index]]))
  } else {
    pft_cover <- brick(C4_herb, C3_herb)
    names(pft_cover) <- c("C4_herb", "C3_herb")
  }

  # Note that when writing raster to file format other than *Rda, the band
  #  names are lost.  Consider writing a header file at the same time, to
  #  record the band names.

  if(filename != "") {
    outfile <- paste0(trim(filename), ".tif")
    writeRaster(pft_cover, outfile, format = "GTiff", datatype = "FLT4S",
      overwrite = TRUE)
  } else {
    return(pft_cover)
  }

  # Clean up
  rm(C4_herb, C3_herb, woody_index, outfile)
}
