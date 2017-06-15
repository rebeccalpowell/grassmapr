#' Count Number of C4 Months in Climate Mask Layers
#'
#' @param C4.mask Raster* object. Mask of grid cells that meet C4 climate requirements. Object should be  multi-layer (i.e., multi-date).
#' @param filename Character. Output base filename (required for large files).
#' @param ...
#'
#' @return RasterLayer. Pixel values correspond to number of months C4 climate requirements are met.
#' @export
#'
#' @examples
#'


countC4Months <- function(C4.mask, filename = '', ...) {

  # Function sums grid cells in a multi-layer Raster* object that meet
  # C4 climate criteria. Output is a rasterLayer.

  filename = trim(filename)

  # Error check: If output filename not specified by user, test whether input
  # file can be processed in memory.

  big <- ! canProcessInMemory(C4.mask, 4)
  if (big & filename == '') {
    filename <- rasterTmpFile()
  }

  # If file name provided, write to disk; else process in memory.

  if(filename != '') {
    outfile <- paste0(filename, '.tif')
    C4_count <- overlay(C4.mask, fun = function(x) {return(sum(x))},
      filename = outfile,
      datatype = 'INT1U',
      overwrite = TRUE)
  } else {
    C4_count <- sum(C4.mask)
  }
  return(C4_count)
  }


