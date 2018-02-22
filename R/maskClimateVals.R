#' Mask Climate Grids Based on Single Parameter
#'
#' Builds climate masks based on a user-specified threshold for a single climate
#'   parameter (e.g., precipitation, temperature). Grid cells greater than or
#'   equal to threshold are reclassified as 1, values less than thershold as 0.
#'
#' @param climate.stack Raster* object. Each layer corresponds to a
#'   different temporal window (e.g., month) for a single climate variable.
#'   Object may be single or multi-layer.
#' @param threshold Numeric. Threshold value (lower-bound) for a single climate
#'   variable.
#' @param filename Character. Optional output root filename passed to
#'   \code{writeRaster}, default output file type is GeoTiff. If not specified,
#'   output is written to a temporary file.
#' @param ... Other arguments passed to \code{writeRaster}.
#' @return RasterBrick. One output mask layer for each input data layer. If
#'   filename is specified, output file format is GeoTiff with unsigned integer
#'   data type.
#' @export
#' @examples
#' # Climate data for Colorado to use in this example
#' data(COMeanPre)  # mean monthly precipitation (mm)
#' data(COMeanTmp)  # mean monthly temperature (deg. C)
#' \donttest{
#' # Mask precipitation values >= 25 mm
#' precip_mask <- maskClimateVals(COMeanPre, 25)}
#' \donttest{
#' # Mask temperature values >= 5 deg. C in Colorado
#' GS_temp_mask <- maskClimateVals(COMeanTmp, 5)}
#' \donttest{
#' # Mask temperature values >= 22 deg. C in Colorado
#' C4_temp_mask <- maskClimateVals(COMeanTmp, 22)}
#'
#' # Plot monthly growing season temperature masks
#' plot(GS_temp_mask)
#'
#' # Plot C4 temperature mask for July only
#' plot(C4_temp_mask[[7]])
#' @seealso \link[grassmapr]{combineMasks}, \link[raster]{reclassify}.
#'
maskClimateVals <- function(climate.stack, threshold, filename = "", ...) {

# Function masks data values >= threshold for gridded climate data
# Output is a rasterStack, nl = nlayers of the input rasterStack

  if (filename != "") {
    outfile <- paste0(trim(filename), ".tif")
    climate_mask <- reclassify(climate.stack,
      c(-Inf,threshold,0, threshold,Inf,1),
      outfile, format = "GTiff", datatype = "INT1U",
      overwrite = TRUE)
  } else {
    climate_mask <- reclassify(climate.stack,
      c(-Inf,threshold,0, threshold,Inf,1))
    return(climate_mask)
  }
}



