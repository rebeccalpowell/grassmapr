#' Map C4 and C3 proportion of grasses
#'
#' Wrapper function to map proportion of grasses with C4 and C3
#'   photosynthetic pathway.
#'
#' @param temp.stack Raster* object. Each layer corresponds to a
#'   different temporal window (e.g., month) for a temperature climate variable.
#'   Object may be single or multi-layer.
#' @param precip.stack Raster* object. Each layer corresponds to a different
#'   temporal window (e.g., month) for a precipitation climate variable. Object
#'   may be single or multi-layer.
#' @param C4.threshold Numeric. Threshold value (lower-bound inclusive) for
#'   C4 climate temperature.
#' @param GS.threshold Numeric. Threshold value (lower-bound inclusive) for
#'   Growing Season temperature.
#' @param precip.threshold Numeric. Threshold value (lower-bound inclusive) for
#'   Growing Season precipitation.
#' @param filename Character. Optional output root filename passed to
#'   \code{writeRaster}, default output file type is GeoTiff. If not specified,
#'   output is written to a temporary file.
#' @param ... Other arguments passed to \code{writeRaster}.
#' @return RasterBrick. Layer[[1]] corresponds to percent of grasses with C4
#'   photosynthetic pathway, Layer[[2]] corresponods to percent of grasses with
#'   C3 photosynthetic pathway.
#' @export
#' @examples \donttest{# Load data for example
#' data(temp_NA)  # mean monthly temperature (deg. C)
#' data(prec_NA)  # mean monthly precipitation (mm)
#'
#' # Specify climate thresholds
#' C4_temp <- 22    # mean monthly temperature >= 22 deg. C
#' GS_temp <- 5     # mean monthly temperature >= 5 deg. C
#' GS_prec <- 25    # mean monthly precipitation >= 25 mm
#'
#' # Predict percent of grasses by photosynthetic pathway.
#' grass_map <- map_grass_pathway(temp.stack = temp_NA,
#'                                precip.stack = prec_NA,
#'                                C4.threshold = C4_temp,
#'                                GS.threshold = GS_temp,
#'                                precip.threshold = GS_prec)
#'
#' # Plot C4 and C3 grass layers.
#' plot(grass_map)
#' }
#' @seealso \link[grassmapr]{mask_climate}, \link[grassmapr]{calc_C4_ratio},
#' \link[grassmapr]{calc_pft_cover}.
#'
#'
map_grass_pathway <- function(temp.stack, precip.stack, C4.threshold,
  GS.threshold, precip.threshold, filename = "", ...) {

  # Error check: same extent, grid, projection for all input layers
  compareRaster(temp.stack, precip.stack, stopiffalse = TRUE, showwarning = TRUE)

  # Error check: Climate stacks have same number of layers.
  if(nlayers(temp.stack) != nlayers(precip.stack)){
    stop("Climate stacks have different number of layers")
  }

  # Generate monthly C4 climate masks
  C4_masks <- intersect_masks(mask_grids(temp.stack, C4.threshold),
    mask_grids(precip.stack, precip.threshold))

  # Generate monthly Growing Season (GS) climate masks
  GS_masks <- intersect_masks(mask_grids(temp.stack, GS.threshold),
    mask_grids(precip.stack, precip.threshold))

  # Calculate C4 herbaceous proportion based on C4 climate
  C4_ratio <- overlay(
    calc(C4_masks, fun = sum),
    calc(GS_masks, fun = sum),
    fun = function(x, y) {ifelse(y == 0, 0, x/y)})

  # Calculate PFT vegetation cover layers (C4 grass, C3 grass)
  # Step 1: Initialize vegetation cover as "all-herbaceous world."

  # Herbaceous cover = 100% for all pixels that meet growing season thresholds
  # at least one month of the year.

  null_grass <- overlay(setValues(C4_ratio, 100),
    (count_months(GS_masks) != 0), fun = "*")

  # Step 2: Calculate C4 herbaceous layer.
  C4_grass <- overlay(null_grass, C4_ratio, fun = "*")

  # Step 3: Calculate C3 herbaceous layer.
  C3_grass <- overlay(null_grass, C4_ratio, fun = function(x, y) {
    return(x*(1.0-y))})

  # Step 4: Create brick of grass layers.
  grass_cover <- brick(C4_grass, C3_grass)
  names(grass_cover) <- c("C4_grass", "C3_grass")

  # Note that when writing raster to file format other than *Rda, the band
  # names are lost.  Consider writing a header file at the same time, to
  # record the band names.

  if(filename != "") {
    outfile <- paste0(trim(filename), ".tif")
    writeRaster(grass_cover, outfile, format = "GTiff", datatype = "FLT4S",
      overwrite = TRUE)
  } else {
    return(grass_cover)
  }

  # Clean up
  rm(C4_masks, GS_masks, C4_ratio, null_grass, C4_grass, C3_grass)
}

