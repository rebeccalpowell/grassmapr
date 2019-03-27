#' Calculate d13C isoscape
#'
#' Applies simple mixing model to percent vegetation cover layers. User provides
#'   d13C endmember values for each plant functional type layer. Function may
#'   also be applied to other endmember statistics, such as, endmember standard
#'   deviation.
#'
#' @param pft.cover RasterBrick. Percent cover for each plant functional type,
#'   may be result of \code{calc_pft_cover}.
#' @param d13C.embs Numeric. Vector of length equal to number of layers in
#'   \code{pft.cover}. Values correspond to d13C endmembers for each
#'   \code{pft.cover} vegetation type.
#' @param scale.factor Numeric. Scale factor for vegetation cover values.
#'   Default value = 100.
#' @param filename Character. Optional output root filename passed to
#'   \code{writeRaster}, default output file type is GeoTiff. If not specified,
#'   output is written to a temporary file.
#' @param ... Other arguments passed to \code{writeRaster}.
#' @return RasterLayer. Values correspond to mean vegetation d13C (per mil) for
#'   each grid cell.
#' @export
#' @examples \donttest{# Generate d13C isoscape based on static endmembers:
#'
#' # User provides PFT layer stack; may be output of calc_pft_cover()
#' # In this example, pft_cover stack includes: C4 herb, C3 herb, woody layers
#'
#' # Vector of d13C endmembers
#' d13C_emb <- c(-12.5, -26.7, -27.0)    # C4 herb, C3 herb, woody
#'
#' # Apply mixing model using input PFT vegetation layers
#' d13C_iso <- calc_del13C(pft_cover, d13C_emb)
#'
#' # Plot d13C isoscape
#' plot(d13C_iso)
#'
#' # Calculate weighted standard deviation of mean d13C value:
#'
#' # Vector of (2x) d13C endmember std. dev. for each vegetation layer
#' d13C_emb_std <- c(2.2, 4.6, 3.4)      # C4 herb, C3 herb, woody
#'
#' # Apply mixing model using input PFT vegetation layers
#' d13C_iso_std <- calc_del13C(pft_cover, d13C_std)
#'
#' # Plot standard deviation layer
#' plot(d13C_iso_std)
#' }
#' @seealso \link[grassmapr]{calc_pft_cover}, \link[grassmapr]{calc_C4_ratio},
#'   \link[raster]{overlay}.
#'
calc_del13C <- function(pft.cover, d13C.embs, scale.factor = 100,
  filename = "", ...) {

  # Calculates d13C isoscape, given input vegetation percent cover by plant
  #   functional type and vector array of endmember values.

  # Error check: Length of C4.flag vector equals nlayers for veg.layers stack
  if(length(d13C.embs) != nlayers(pft.cover)) {
    stop("Length of d13C.embs vector does not equal nlayers in pft.cover")
  }

  # Core function
  d13C_iso <- overlay(calc(pft.cover, function(x) x*d13C.embs/scale.factor),
    fun = "sum")

  if(filename != "") {
    outfile <- paste0(trim(filename), ".tif")
    writeRaster(d13C_iso, filename = outfile, format = "GTiff",
      overwrite = TRUE)
  } else {
    return(d13C_iso)
  }
}

