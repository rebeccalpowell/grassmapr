#' Count Number of Months in Climate Mask Layers
#'
#' @param climate.mask Raster* object. Mask of grid cells that meet climate requirements. Object should be  multi-layer (i.e., multi-date).
#' @param filename Character. Output base filename (required for large files).
#' @param ...
#'
#' @return RasterLayer. Pixel values correspond to number of months that climate requirements are met.
#' @export
#'
#' @examples
#'


countMonths <- function(climate.mask, filename = '', ...) {

  # Function sums grid cells in a multi-layer Raster* object that meet
  # climate criteria. Output is a rasterLayer.

  # If file name provided, write to disk; else process in memory/temp files.

  if(filename != '') {
    outfile <- paste0(trim(filename), '.tif')
    month_count <- overlay(climate.mask, fun = function(x) {return(sum(x))},
      filename = outfile,
      datatype = 'INT1U',
      overwrite = TRUE)
  } else {
    month_count <- sum(climate.mask)
  }
  return(month_count)
  }


