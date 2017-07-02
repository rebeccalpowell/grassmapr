#' Calculate C4 Ratio for Grasses
#'
#' @param C4.mask Raster* object of C4 climate masks.
#' @param GS.mask Raster* object of Growing Season climate masks.
#' @param veg.index Raster* object of vegetation index ("greenness") values, corresponding to same temporal units as C4.mask and GS.mask
#' @param filename Output root filename.
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
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

