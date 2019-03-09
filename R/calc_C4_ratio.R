#' Predict C4 Ratio for Grasses
#'
#' Calculates the proportion of grasses with C4 photosynthetic pathway based on
#'   climate data (and, optionally, vegetation "greenness" weights). Output
#'   layer represents the C4 proportion of grasses in each grid cell, based on
#'   ratio of C4-favorable months to growing-season months.
#'
#' @param C4.mask Raster* object. Each layer represents C4 climate mask for
#'   given temporal window, may be result of  \code{intersect_masks}. Must have
#'   same number of layers as \code{GS.mask}.
#' @param GS.mask Raster* object. Each layer represents growing season climate
#'   mask for given temporal window, may be result of \code{intersect_masks}.
#'   Must have same number of layers as \code{C4.mask}.
#' @param veg.index Raster* object. Optional layers to weight C4 grass
#'   proportion based on vegetation "greenness" metric (e.g., a vegetation
#'   index). Must match temporal window and number of layers as \code{C4.mask}
#'   and \code{GS.mask}.
#' @param filename Character. Optional output root filename passed to
#'   \code{writeRaster}, default output file type is GeoTiff. If not specified,
#'   output is written to a temporary file.
#' @param ... Other arguments passed to \code{writeRaster}.
#' @return Raster layer. Proportion of grasses with C4 photosynthetic pathway.
#' @export
#' @examples \donttest{# Calculate C4 ratio for North America, based on climate data only
#'
#' # C4 and Growing Season (GS) climate masks are results of mask_climate()
#' C4_ratio <- calc_C4_ratio(C4_mask, GS_mask)
#'
#' # Calculate C4 ratio, based on climate and monthly vegetation greenness
#'
#' # Load monthly vegetation index for North America
#' data(ndvi_NA)
#' C4_ratio_vi <- calc_C4_ratio(C4_mask, GS_mask, veg.index = ndvi_NA)
#'
#' # Plot climate-based C4 vegetation ratio
#' plot(C4_ratio)
#' }
#' @seealso \link[grassmapr]{intersect_masks}, \link[grassmapr]{count_months}, \link[raster]{overlay}.
#'
calc_C4_ratio <- function(C4.mask, GS.mask, veg.index = NULL,
  filename = "", ...) {

  # If no veg.index provided, set weight to 1.
  #   If veg.index provided, convert all negative values to zero.

  if(is.null(veg.index)) {
    veg.index <- setValues(C4.mask[[1]], 1)
  } else {
    veg.index[veg.index < 0] <- 0
  }

  # Error check: same extent, grid, projection for all input layers
  compareRaster(C4.mask, GS.mask, veg.index,
    stopiffalse = TRUE, showwarning = TRUE)

  # Error check: Climate stacks have same number of layers.

  if(nlayers(C4.mask) != nlayers(GS.mask)){
    stop("Climate masks have different number of layers")
  }

  # Error check: VI stack provided has same number of layers as climate stacks,
  #   else equals one (dummy layer)

  if(!(nlayers(veg.index) == nlayers(C4.mask)) & !(nlayers(veg.index) == 1)) {
    stop("Vegetation index has incorrect number of layers")
  }

  if(filename != "") {
    outfile <- paste0(trim(filename), ".tif")
    C4_ratio <- overlay(
      calc(overlay(veg.index, C4.mask, fun = "*"), fun = sum),
      calc(overlay(veg.index, GS.mask, fun = "*"), fun = sum),
      fun = function(x, y) {ifelse(y == 0, 0, x/y)},
      filename = outfile, format = "GTiff", overwrite = TRUE)
  } else {
    C4_ratio <- overlay(
      calc(overlay(veg.index, C4.mask, fun = "*"), fun = sum),
      calc(overlay(veg.index, GS.mask, fun = "*"), fun = sum),
      fun = function(x, y) {ifelse(y == 0, 0, x/y)})
    return(C4_ratio)
  }
}

