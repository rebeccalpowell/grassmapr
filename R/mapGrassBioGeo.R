#' Wrapper Function to Predict C3/C4 Ratio for Grasses
#'
#' Wrapper function that calculates the percent of grasses with C3 and C4 photosynthetic pathway. Output
#'  layers represent percent C3 and C4 vegetation in each grild cell, respectively,
#'  assuming 100\% "grassy world".
#'
#' @param temp.stack Raster* object. Each layer corresponds to a
#'  different temporal window (e.g., month) for a single temperature variable.
#'  Object may be single or multi-layer.
#' @param ppt.stack Raster* object. Each layer corresponds to a
#'  different temporal window (e.g., month) for a single temperature variable.
#'  Object may be single or multi-layer.
#' @param c4.threshold Numeric. Threshold value (lower-bound) for C4 dominance.
#' @param gs.threshold Numeric. Threshold value (lower-bound) of temperature
#'  for active growing season.
#' @param ppt.threshold Numeric. Threshold value (lower-bound) of precipitation
#'  for active growing season.
#' @param veg.index Raster* object. Each layer corresponds to a different
#' temporal window and should match the temporal window and resolution of the climate stacks.
#' @param filename Character. Optional output root filename passed to
#'   \code{wric4.teRaster}, default output file type is GeoTiff. If not specified,
#'   output is written to a temporary file.
#' @param ... Other arguments passed to \code{writeRaster}.
#' @return RasterBrick. The first layer is percent C4 herbaceous assuming 100\% grassy world.
#'  The second layer is percent C3 herbaceous assuming 100\% grassy world.
#' @export
#' @examples
#' # Climate data for Colorado to use in this example
#' data(COMeanPre)  # mean monthly precipitation (mm)
#' data(COMeanTmp)  # mean monthly temperature (deg. C)
#' \donttest{
#' # Estimate C3/C4 herbaceous layers in 100\% grassy world using default thresholds.
#' herbaceous <- grassBioGeo(COMeanTemp, COMeanPre))}
#'
#' # Plot monthly growing season temperature masks
#' plot(GS_temp_mask)
#'
#' @seealso \link[grassmapr]{combineMasks}, \link[raster]{reclassify}.
#'
grassBioGeo <- function(temp.stack, ppt.stack, c4.threshold=22, gs.threshold=5,
                         ppt.threshold=25, veg.index=NULL, filename = '', ...){

  # C4 temperature mask (>= 22 deg. C)
  C4_temp_mask <- maskClimateVals(temp.stack, c4.threshold)

  # Growing season temperature mask (>= 5 deg. C)
  GS_temp_mask <- maskClimateVals(temp.stack, gs.threshold)

  #Growing season precipitation mask (>= 25 mm)
  precip_mask <- maskClimateVals(ppt.stack, ppt.threshold)


  # Generate Growing Season (GS) climate masks
  GS_mask <- combineMasks(GS_temp_mask, precip_mask)
  # Generate C4 climate masks
  C4_mask <- combineMasks(C4_temp_mask, precip_mask)

  # Remove intermediate raster objects
  rm(precip_mask, C4_temp_mask, GS_temp_mask)

  # Calculate C4 ratio based on C4 climate (OPTIONAL vegetation productivity)
  c4_ratio <- calcC4Ratio(C4_mask, GS_mask, veg.index)

  # Generate PFT vegetation cover brick
  output <- calcPFTCover(c4_ratio)

  names(output) <- c('Percent C4 Herbaceous', 'Percent C3 Herbaceous')

  if (filename != '') {
    writeRaster(output, filename, ...)
  }
  ##return isoscapes
  return(output)
}

