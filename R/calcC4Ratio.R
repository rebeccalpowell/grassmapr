#' Predict C4 Ratio for Grasses
#'
#' Calculates the percent of grasses with C4 photosynthetic pathway. Output
#'   layer represents percent C4 vegetation in each grid cell, assuming 100\%
#'   "grassy world".
#'
#' @param C4.mask Raster* object. Each layer represents C4 climate mask for
#'   given temporal window, may be result of \code{combineMasks}. Must have same
#'   number of layers as \code{GS.mask}.
#' @param GS.mask Raster* object. Each layer represents growing season climate
#'   mask for given temporal window, may be result of \code{combineMasks}. Must
#'   have same number of layers as \code{C4.mask}.
#' @param veg.index Raster* object. Optional layers to quantify vegetation
#'   "greenness" (e.g., a vegetation index). Must match temporal window and
#'   number of layers as \code{C4.mask} and \code{GS.mask}.
#' @param filename Character. Optional output root filename passed to
#'   \code{writeRaster}, default output file type is GeoTiff. If not specified,
#'   output is written to a temporary file.
#' @param ... Other arguments passed to \code{writeRaster}.
#' @return Raster layer. Percent of grasses with C4 photosynthetic pathway.
#'   Percent C4 cover, assuming 100\% herbaceous vegetation cover.
#' @export
#' @examples \donttest{# Calculate C4 ratio in Colorado, based on climate data only
#' C4_ratio <- calcC4Ratio(C4_mask, GS_mask)}
#' \donttest{
#' # Calculate C4 ratio, based on climate and monthly vegetation productivity
#' data("COMonthlyNDVI") # Load monthly vegetation index for Colorado
#' C4_ratio_vi <- calcC4Ratio(C4_mask, GS_mask, veg.index = COMonthlyNDVI)}
#'
#' # Plot climate-based C4 vegetation ratio
#' plot(C4_ratio)
#' @seealso \link[grassmapr]{combineMasks}, \link[raster]{overlay}.
#'
calcC4Ratio <- function(C4.mask, GS.mask, veg.index = NULL,
  filename = '', ...) {

  # If no veg.index provided, set weight to 1.

  if(is.null(veg.index)) {
    veg.index <- setValues(C4.mask[[1]], 1)
  }

  # Error check: same extent, grid, projection for all input layers
  compareRaster(C4.mask, GS.mask, veg.index,
    stopiffalse = TRUE, showwarning = TRUE)

  # Error check: Climate stacks have same number of layers.

  if(nlayers(C4.mask) != nlayers(GS.mask)){
    stop("Climate masks have different number of layers")
  }

  # Error check: VI stack provided has same number of layers as climate stacks,
  # else equals one (dummy layer)

  if(!(nlayers(veg.index) == nlayers(C4.mask)) & !(nlayers(veg.index) == 1)) {
    stop("Vegetation index has incorrect number of layers")
  }

  if(filename != '') {
    outfile <- paste0(trim(filename), '.tif')
    C4_ratio <- overlay(
      calc(overlay(veg.index, C4.mask, fun = "*"), fun = sum),
      calc(overlay(veg.index, GS.mask, fun = "*"), fun = sum),
      fun = function(x, y) {ifelse(y == 0, 0, x/y)},
      filename = outfile, overwrite = TRUE)
  } else {
    C4_ratio <- overlay(
      calc(overlay(veg.index, C4.mask, fun = "*"), fun = sum),
      calc(overlay(veg.index, GS.mask, fun = "*"), fun = sum),
      fun = function(x, y) {ifelse(y == 0, 0, x/y)})
    return(C4_ratio)
  }
}

