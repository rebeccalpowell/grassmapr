#' Generate Climate Masks Based on Two Parameters
#'
#' Generates climate masks based on two climate variables, typically temperature
#'   and precipitation. Grid cells that satisfy both criteria are reclassified
#'   as 1; else, grid cells are reclassified as 0. Climate threshold values are
#'   lower bound inclusive.
#'
#' @param temp.stack Raster* object. Each layer corresponds to a
#'   different temporal window (e.g., month) for a temperature climate variable.
#'   Object may be single or multi-layer.
#' @param temp.threshold Numeric. Threshold value (lower-bound inclusive) for
#'   temperature variable.
#' @param precip.stack Raster* object. Each layer corresponds to a
#'   different temporal window (e.g., month) for a precipitation climate variable.
#'   Object may be single or multi-layer.
#' @param precip.threshold Numeric. Threshold value (lower-bound inclusive) for
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
#' data(temp_NA)    # mean monthly temperature (deg. C)
#' data(precip_NA)  # mean monthly precipitation (mm)
#'
#' # Specify Growing Season (GS) thresholds
#' gs_temp <- 5     # mean monthly temperature >= 5 deg. C
#' gs_prec <- 25    # mean monthly precipitation >= 25 mm
#'
#' # Generate stack of monthly growing season masks
#' GS_masks <- mask_climate(temp_NA, gs_temp, precip_NA, gs_precip)
#'
#' # Plot monthly growing-season masks
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
    climate_mask <- intersect_masks(mask_grids(temp.stack, temp.threshold),
        mask_grids(precip.stack, precip.threshold),
        filename = outfile,
        format = "GTiff",
        datatype = "INT1U",
        overwrite = TRUE)
  } else {
    climate_mask <- intersect_masks(mask_grids(temp.stack, temp.threshold),
      mask_grids(precip.stack, precip.threshold))
    return(climate_mask)
  }
}



