#' Mask C4 or GS climate Based on Temperature and Precipitation masks
#'
#' @param temp.mask Raster* object. Mask of grid cells that meet C4 (or GS) temperature threshold. Object may be single or multi-layer.
#' @param precip.mask Raster* object. Mask of grid cells that meet minimum precipitation threshold. Object may be single or multi-layer.
#' @param file.name Character. Output base filename (highly recommended for large files).
#' @param ...
#'
#' @return RasterBrick. One output mask layer indicating C4 climate for each input layer. Output file format is GeoTiff with unsigned integer data type.
#' @export
#'
#' @examples
#'


combineMasks <- function(temp.mask, precip.mask, filename = '', ...) {

  # Function masks grid cells that meet C4 (or GS) climate criteria.
  # Output is a rasterStack, nl = nlayers of the input rasterStack.


  # Error check: same extent, grid, projection for all input layers
  compareRaster(C4.mask, GS.mask, stopiffalse = TRUE, showwarning = TRUE)

  # Error check: Climate stacks have same number of layers.

  if(nlayers(C4.mask) != nlayers(GS.mask)){
    stop("Climate masks have different number of layers")
  }

  # If file name provided, write to disk; else process in memory/temp file.

  if(filename != '') {
    outfile <- paste0(trim(filename), '.tif')
    combined_mask <- overlay(temp.mask, precip.mask,
        fun = function(x, y) {return(x*y)},
        filename = outfile,
        datatype = 'INT1U',
        overwrite = TRUE)
  } else {
    combined_mask <- overlay(temp.mask, precip.mask,
      fun = function(x, y) {return(x*y)})
    return(combined_mask)
  }
}



