#' Generate Climate Masks Based on Two Parameters NEED NEW HEADING
#'
#' Wraper script to generate climate masks based on two climate parameters,
#'   for example growing-season mask or C4 climate mask. Grid cells
#'   reclassified as 1 satisify both temperature and precipitation criteria,
#'   grid cells classified as 0 fail to satisify criteria for at least one
#'   variable.
#'
#' @param temp.stack Raster* object. Each layer corresponds to a
#'   different temporal window (e.g., month) for a temperature climate variable.
#'   Object may be single or multi-layer.
#' @param temp.threshold Numeric. Threshold value (lower-bound) for temperature
#'   variable.
#' @param precip.stack Raster* object. Each layer corresponds to a
#'   different temporal window (e.g., month) for a precipitation climate variable.
#'   Object may be single or multi-layer.
#' @param precip.threshold Numeric. Threshold value (lower-bound) for
#'   precipitation variable.
#' @param filename Character. Optional output root filename passed to
#'   \code{writeRaster}, default output file type is GeoTiff. If not specified,
#'   output is written to a temporary file.
#' @param ... Other arguments passed to \code{writeRaster}.
#' @return RasterBrick. One output mask layer for each input layer. If filename
#'   is specified, output file format is GeoTiff with unsigned integer data
#'   type.
#' @export
#' @examples \donttest{# Load data for example
#' data(temp_NA)
#' data(precip_NA)
#'
#' # Specify Growing Season (GS) thresholds
#' gs_temp <- 5   # mean monthly temperature >= 5 deg. C
#' gs_prec <- 25  # mean monthly precipitation >= 25 mm
#'
#' # Generate monthly masks of grid cells that satisfy GS-climate criteria
#' GS_masks <- mask_climate(temp_NA, gs_temp, precip_NA, gs_precip)
#'
#' #Plot monthly growing-season masks
#' plot(GS_masks)
#' }
#' @seealso \link[grassmapr]{mask_grids}, \link[grassmapr]{intersect_masks},
#' \link[raster]{overlay}.
#'
mask_climate <- function(temp.stack, temp.threshold, precip.stack,
  precip.threshold, filename = "", ...) {

  # Function masks grid cells that meet C4 or GS climate criteria.
  # Output is a rasterStack, nl = nlayers of the input rasterStack.

  # Error check: same extent, grid, projection for all input layers
  compareRaster(temp.stack, precip.stack, stopiffalse = TRUE, showwarning = TRUE)

  # Error check: Climate stacks have same number of layers.
  if(nlayers(temp.stack) != nlayers(precip.stack)){
    stop("Climate stacks have different number of layers")
  }

  # If file name provided, write to disk; else process in memory/temp file.
  if(filename != "") {
    outfile <- paste0(trim(filename), ".tif")
    climate_mask <- intersect_mask(mask_grids(temp.stack, temp.threshold),
        mask_grids(precip.stack, precip.threshold),
        filename = outfile,
        format = "GTiff",
        datatype = "INT1U",
        overwrite = TRUE)
  } else {
    climate_mask <- intersect_mask(mask_grids(temp.stack, temp.threshold),
      mask_grids(precip.stack, precip.threshold))
    return(climate_mask)
  }
}



