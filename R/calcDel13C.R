#' Calculate d13C isoscape
#'
#' @param pft.cover RasterBrick. Percent plant functional type cover; each layer corresponds to different d13C endmember value.
#' @param d13C Numeric vector. Endmember values that correspond to each pft.cover layer.
#' @param scale Integer. Scale factor (maximum cover value). Default is 100.
#' @param filename Character. Optional output root filename.
#' @param ...
#'
#' @return Raster Layer. Mean vegetation d13C.
#' @export
#'
#' @examples
#'
#'

# Calculates d13C isoscape, given input vegetation percent cover by plant
#   functional type and vector array of endmember values.

calcDel13C <- function(pft.cover, d13C, scale = 100, filename = '', ...) {

  if(filename != '') {
    outfile <- paste0(trim(filename), '.tif')
    overlay(calc(pft.cover, function(x) x*d13C/scale), fun = "sum",
      outfile, datatype = 'INT2U', overwrite = TRUE)
  } else {
    d13C_iso <- overlay(calc(pft.cover, function(x) x*d13C/scale), fun = "sum")
    return(d13C_iso)
  }
}

