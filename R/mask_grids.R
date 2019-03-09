#' Mask Grids Based on Single Parameter
#'
#' Builds mask(s) based on a user-specified threshold for a single
#'   variable (e.g., mean precipitation or temperature). Grid cells
#'   greater than or equal to threshold value are reclassified as 1, values less
#'   than the threshold as 0. May be applied to a stack of grids (e.g.,
#'   multi-date climate layers).
#'
#' @param climate.stack Raster* object. Each layer corresponds to a
#'   different temporal window (e.g., month) for a single climate variable.
#'   Object may be single or multi-layer.
#' @param threshold Numeric. Threshold value (lower-bound, inclusive) for a
#'   single climate variable.
#' @param filename Character. Optional output root filename passed to
#'   \code{writeRaster}, default output file type is GeoTiff. If not specified,
#'   output is written to a temporary file.
#' @param ... Other arguments passed to \code{writeRaster}.
#' @return RasterBrick. One output mask layer for each input data layer. If
#'   filename is specified, output file format is GeoTiff with unsigned integer
#'   data type.
#' @export
#' @examples \donttest{# Climate data for North America to use in this example
#' data(precip_NA)  # mean monthly precipitation (mm)
#' data(temp_NA)    # mean monthly temperature (deg. C)
#'
#' # Mask grid cells that meet minimum monthly precipitation values (>= 25 mm)
#' #   for vegetation growth
#' precip_mask <- mask_grids(precip_NA, 25)
#'
#' # Mask grid cells that meet min. monthly growing season temperature (>= 5 deg. C)
#' GS_temp_mask <- mask_grids(temp_NA, 5)
#'
#' # Mask grid cells that meet min. monthly C4 temperature (>= 22 deg. C)
#' C4_temp_mask <- mask_grids(temp_NA, 22)
#'
#' # Plot monthly growing season temperature masks
#' plot(GS_temp_mask)
#'
#' # Plot C4 temperature mask for July only
#' plot(C4_temp_mask[[7]])
#' }
#' @seealso \link[grassmapr]{intersect_masks}, \link[raster]{reclassify}.
#'
mask_grids <- function(climate.stack, threshold, filename = "", ...) {

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



