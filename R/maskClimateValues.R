#' Mask climate Raster values Based on Single Parameter
#'
#' This function builds monthly climate masks based on a user-specified
#' threshold for a single climate parameter (e.g., precipitation, temperature,
#' etc.). Grid cells greater than threshold are masked.
#' @param climate.stack Raster* object. Monthly values for a single climate
#' variable. Object may be single or multi-layer.
#' @param threshold Numeric. Threshold value for a single climate variable.
#' @param filename Character. Output base filename (optional). User should not specify extension.  Default output file is GeoTiff.
#' @param ...
#'
#' @return RasterBrick. One output mask layer for each input data layer. Output file format is GeoTiff with unsigned integer data type.
#' @export
#'
#' @examples
#'

maskClimateValues <- function(climate.stack, threshold, filename = '', ...) {

# Function masks data values > threshold for gridded climate data
# Output is a rasterStack, nl = nlayers of the input rasterStack

  if (filename != '') {
    outfile <- paste0(trim(filename), '.tif')
    climate_mask <- reclassify(climate.stack,
      c(-Inf,threshold,0, threshold,Inf,1),
      outfile, datatype = 'INT1U', overwrite = TRUE)
  } else {
    climate_mask <- reclassify(climate.stack,
      c(-Inf,threshold,0, threshold,Inf,1))
  }

  return(climate_mask)
}



