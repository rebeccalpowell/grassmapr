#' Mask C4 climate Based on Temperature and Precipitation masks
#'
#' @param temp.mask Raster* object. Mask of grid cells that meet C4 temperature threshold. Object may be single or multi-layer.
#' @param precip.mask Raster* object. Mask of grid cells that meet minimum precipitation threshold. Object may be single or multi-layer.
#' @param file.name Character. Output base filename (highly recommended for large files).
#' @param ...
#'
#' @return RasterBrick. One output mask layer indicating C4 climate for each input layer. Output file format is GeoTiff with unsigned integer data type.
#' @export
#'
#' @examples
#'


maskC4Climate <- function(temp.mask, precip.mask, filename = '', ...) {

  # Function masks grid cells that meet C4 climate criteria.
  # Output is a rasterStack, nl = nlayers of the input rasterStack.

  out <- brick(temp.mask, values = FALSE)
  big <- ! canProcessInMemory(out, 4)
  filename = trim(filename)

  # If output filename not specified by user, test whether input file can be
  # processed in memory.

  if (big & filename == '') {
    filename <- rasterTmpFile()
  }

  # If file name provided, write to disk; else process in memory.

  if(filename != '') {
    outfile <- paste0(filename, '.tif')
    C4_mask <- overlay(temp.mask, precip.mask,
        fun = function(x, y) {return(x*y)},
        filename = outfile,
        datatype = 'INT1U',
        overwrite = TRUE)
  } else {
    C4_mask <- overlay(temp.mask, precip.mask,
      fun = function(x, y) {return(x*y)})
  }

  return(C4_mask)
}



