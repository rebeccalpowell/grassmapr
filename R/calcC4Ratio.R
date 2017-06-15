#' Calculate C4 Ratio for Natural Grassland
#'
#' @param C4months.count RasterLayer. Number of months that grid cell meets C4 climate criteria.
#' @param GSmonths.count RasterLayer. Number of months that grid cell meets growing season climate criteria.
#' @param C4.threshold Numeric [Integer]. Grid cell classified as 100% C4 climate if meets minimum number of months that grid cell meets C4 climate criteria.
#' @param biomass.weight Numeric [Ratio]. TO BE CONTINUED.
#' @param filename Character.  Output base filename (highly recommended for large files). User should not specify extension. Default output file is GeoTiff.
#' @param ...
#'
#' @return RasterLayer. Pixel values correspond to annual percent C4 grasses.
#' @export
#'
#' @examples
#'
#'

calcC4Ratio <- function(C4months.count, GSmonths.count, C4.threshold = NULL,
  biomass.weight = NULL, filename = '', ...) {

  # Function sums grid cells in a multi-layer Raster* object that meet
  # C4 climate criteria. Output is a rasterLayer.

  filename = trim(filename)

  # Error check: If output filename not specified by user, test whether input
  # file can be processed in memory.

  big <- ! canProcessInMemory(C4months.count, 3)
  if (big & filename == '') {
    filename <- rasterTmpFile()
  }

  # If file name provided, write to disk; else process in memory.

  if(filename != '') {
    outfile <- paste0(filename, '.tif')
    C4_ratio <- overlay(C4.mask, fun = function(x) {return(sum(x))},
      filename = outfile,
      datatype = 'INT1U',
      overwrite = TRUE)
  } else {
    C4_ratio <- sum(C4.mask)
  }
  return(C4_ratio)
}

