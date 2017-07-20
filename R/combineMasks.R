#' Generate Climate Masks Based on Two Parameters
#'
#' Intersects temperature and precipitation climate masks into a single mask
#'   layer, for example identifying grid cells that correspond to growing-season
#'   climate criteria or C4 climate criteria. Grid cells reclassified as 1
#'   satisify both temperature and precipitation criteria, grid cells classified
#'   as 0 fail to satisify criteria for at least one variable.
#'
#' @param temp.mask Raster* object. Mask of grid cells that meet minimum
#'   temperature threshold, may be result of \code{maskClimateVals}. Object may
#'   be single or multi-layer.
#' @param precip.mask Raster* object. Mask of grid cells that meet minimum
#'   precipitation threshold, may be result of \code{maskClimateVals}. Object
#'   may be single or multi-layer.
#' @param filename Character. Optional output root filename passed to
#'   \code{writeRaster}, default output file type is GeoTiff. If not specified,
#'   output is written to a temporary file.
#' @param ... Other arguments passed to \code{writeRaster}.
#' @return RasterBrick. One output mask layer for each input layer. If filename
#'   is specified, output file format is GeoTiff with unsigned integer data
#'   type.
#' @export
#' @examples
#' \donttest{# Generate masks of grid cells satisfying monthly C4-climate criteria
#' C4_mask <- combineMasks(C4_temp_mask, precip_mask)}
#' \donttest{
#' # Generate masks of grid cells that satisfying monthly growing-season climate criteria
#' GS_mask <- combineMasks(GS_temp_mask, precip_mask)
#'
#' #Plot monthly growing-season masks
#' plot(GS_mask)}
#' @seealso \link[grassmapr]{maskClimateVals}, \link[raster]{overlay}.
#'
combineMasks <- function(temp.mask, precip.mask, filename = '', ...) {

  # Function masks grid cells that meet C4 or GS climate criteria.
  # Output is a rasterStack, nl = nlayers of the input rasterStack.

  # Error check: same extent, grid, projection for all input layers
  compareRaster(temp.mask, precip.mask, stopiffalse = TRUE, showwarning = TRUE)

  # Error check: Climate stacks have same number of layers.
  if(nlayers(temp.mask) != nlayers(precip.mask)){
    stop("Climate masks have different number of layers")
  }

  # If file name provided, write to disk; else process in memory/temp file.
  if(filename != '') {
    outfile <- paste0(trim(filename), '.tif')
    combined_mask <- overlay(temp.mask, precip.mask,
        fun = function(x, y) {return(x*y)},
        filename = outfile,
        datatype = 'INT1U',
        overwrite = TRUE)
  } else {
    combined_mask <- overlay(temp.mask, precip.mask,
      fun = function(x, y) {return(x*y)})
    return(combined_mask)
  }
}



