#' Count Number of Months in Climate Mask Layers
#'
#' Generates raster layer of counts corresponding to number of times (usually
#'   months) each grid cell satisfies climate criteria, e.g., growing-season or
#'   C4 climate.
#'
#' @param climate.mask Raster* object. Mask of grid cells that meet climate
#'   parameters, may be result of  \code{intersect_masks} or \code{mask_grids}.
#'   Object should be  multi-layer (i.e., multi-date).
#' @param filename Character. Optional output root filename passed to
#'   \code{writeRaster}, default output file type is GeoTiff. If not specified,
#'   output is written to a temporary file.
#' @param ... Other arguments passed to \code{writeRaster}.
#' @return RasterLayer. Values correspond to number of months (or other temporal
#'   unit) that grid cell meets minimum climate parameters.
#' @export
#' @examples \donttest{# Count number of months each grid cell meets C4 climate criteria
#' C4_month_total <- count_months(C4_mask)
#'
#' # Plot monthly totals
#' plot(C4_month_total)
#' }
#' @seealso \link[grassmapr]{mask_grids}, \link[grassmapr]{intersect_masks},
#'   \link{sum}.
#'
count_months <- function(climate.mask, filename = "", ...) {

  # Function sums grid cells in a multi-layer Raster* object that meet
  # climate criteria. Output is a rasterLayer.

  # If file name provided, write to disk; else process in memory/temp files.

  if(filename != "") {
    outfile <- paste0(trim(filename), ".tif")
    month_count <- overlay(climate.mask, fun = function(x) {return(sum(x))},
      filename = outfile,
      format = "GTiff",
      datatype = "INT1U",
      overwrite = TRUE)
  } else {
    month_count <- sum(climate.mask)
    return(month_count)
    }
  }


