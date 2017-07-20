#' Calculate Plant Functional Type Cover Layers
#'
#' Generates plant functional type (PFT) cover layers, starting with an inital
#'   assumption of 100\% "grassy world". If other vegetation cover layers are
#'   provided by the user, total grass cover is adjusted by (1) subtracting the
#'   sum of the other vegetation layers from 100\% grass cover, and (2)
#'   partitioning the remaining percent grass cover into C3 and C4 components by
#'   multiplying by the C4 grass ratio (result of \code{calcC4Ratio}). If C3/C4
#'   crop cover layers are provided, each is added to the respective C3/C4 grass
#'   cover layers.
#'
#' @param C4.ratio RasterLayer. C4 ratio of grass cover, result of
#'   \code{calcC4Ratio}.
#' @param veg.layers Raster* object. Each layer corresponds to non-herbaceous
#'   cover or agriculatural crop layers.
#' @param C4.flag Numeric. Vector with length equal to number of layers in
#'   \code{veg.layers} object, with C4 vegetation flag = 1,  C3 vegetation flag
#'   = 0.
#' @param herb.flag Numeric. Vector with length equal to number of layers in
#'   \code{veg.layers} object, with herbaceous vegetation flag = 1, woody
#'   vegetation flag = 0.
#' @param scale Numeric. Scale factor for vegetation cover. Default value = 100.
#' @param filename Character. Optional output root filename passed to
#'   \code{writeRaster}, default output file type is GeoTiff. If not specified,
#'   output is written to a temporary file.
#' @param ... Other arguments passed to \code{writeRaster}.
#' @return RasterBrick. Layers correspond to percent vegetation cover, stacked
#'   in the following order: Layer 1 = C4 herbaceous, Layer 2 = C3 herbaceous,
#'   Layer 3, Layer 4, ... = additional vegetation layers provided by user.
#' @export
#' @examples # Load additional vegetation cover layers to use in this example
#' data(COWoody)  # percent woody vegetation cover in Colorado
#' data(COC3Crop) # percent C3 crop cover in Colorado
#' data(COC4Crop) # percent C4 crop cover in Colorado
#' \donttest{
#' # Downsample C4_ratio layer to match spatial resolution of other layers
#' C4_ratio_rs <- resample(x = C4_ratio, y = COWoody, method = 'ngb')
#'
#' # Create raster stack of other (non-grassy) vegetation layers
#' veg_layers <- stack(COC4Crop, COC3Crop, COWoody)
#'
#' # Indicate layers that correspond to C4 vegetation
#' C4_flag <- c(1, 0, 0)
#' # Indicate layers that correspond to herbaceous vegetation
#' herb_flag <- c(1, 1, 0)
#'
#' # Generate PFT vegetation cover brick
#' pft_cover <- calcPFTCover(C4_ratio_rs, veg_layers, C4_flag, herb_flag)
#'
#' # Plot PFT vegetation cover layers
#' plot(pft_cover)
#' }
#' @seealso \link[grassmapr]{calcC4Ratio}, \link[raster]{overlay}.
#'
calcPFTCover <- function(C4.ratio, veg.layers = NULL, C4.flag = NULL,
  herb.flag = NULL, scale = 100, filename = '', ...) {

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

  # Error check: Length of herb.flag vector equals length of C4.flag
    if(!is.null(herb.flag)) {
      if(length(herb.flag) != length(C4.flag)){
        stop("Length of herb.flag vector not equal to C4.flag vector")
      }
    }
  }

  # Step 1. Initialize vegetation cover as "all-herbaceous world."
  #   Herbaceous cover = 100% for all pixels.
    null_herb <- setValues(C4.ratio, scale)

  # Step 2. Adjust for real world vegetation; subtract each vegetation layer
  #  from "all-herbaceous world" template.
  if(!is.null(veg.layers)) {
    null_herb <- overlay(null_herb, overlay(veg.layers, fun = "sum"),
      fun = "-", forcefun = TRUE)
  }

  # Step 3. Calculate C4 herbaceous layer:
  #   (i) multiply adjusted herbaceous layer by C4.ratio,
  #  (ii) add all vegetation layers with flags (C4 = 1 & Herb = 1)
  #   Repeat for C3 herbaceous layer.
  C4herb_index <- which((C4.flag == 1) & (herb.flag == 1))
  if(length(C4herb_index) != 0) {
    C4_herb <- overlay(overlay(null_herb, C4.ratio, fun = "*"),
      overlay(veg.layers[[C4herb_index]], fun = "sum"),
      fun = "sum")
  } else {
    C4_herb <- overlay(null_herb, C4.ratio, fun = "*")
  }

  C3herb_index <- which((C4.flag == 0) & (herb.flag == 1))
  if(length(C3herb_index) != 0) {
    C3_herb <- overlay(overlay(null_herb, C4.ratio, fun = function(x,y) {
      return(x*(1.0-y))}), overlay(veg.layers[[C3herb_index]], fun = "sum"),
      fun = "sum")
  } else {
    C3_herb <- overlay(null_herb, C4.ratio, fun = function(x,y){
      return(x*(1.0-y))})
  }

  rm(null_herb, C4herb_index, C3herb_index)

  # Step 4: Create brick of vegetation PFT cover; add in non-herbaceous layers
  woody_index <- which((herb.flag == 0))
  if(length(woody_index) != 0) {
    pft_cover <- brick(C4_herb, C3_herb, veg.layers[[woody_index]])
    names(pft_cover) <- c("C4_herb", "C3_herb", names(veg.layers[[woody_index]]))
  } else {
    pft_cover <- brick(C4_herb, C3_herb)
    names(pft_cover) <- c("C4_herb", "C3_herb")
  }

  # Write to file or output to memory
  #  Could insert error check for float data (i.e., scale.factor == 1)
  #  and insert additional step to convert to integer

  # Note that when writing raster to file format other than *Rda, the band
  #  names are lost.  Consider writing a header file at the same time, to
  #  record the band names.

  if(filename != '') {
    outfile <- paste0(trim(filename), '.tif')
    writeRaster(pft_cover, outfile, datatype = 'INT2U', overwrite = TRUE)
  } else {
    return(pft_cover)
  }

  # Clean up
  rm(C4_herb, C3_herb, woody_index, outfile)
}
