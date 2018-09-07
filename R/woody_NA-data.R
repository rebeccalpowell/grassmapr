#' Percent woody cover for North America
#'
#' Gridded percent tree crown layer for North America in the year 2001,
#'   aggregated to 10' spatial resolution. Derived from the MODIS/Terra
#'   Vegetation Continuous Fields (v006) tree cover layer, following rules
#'   described in Powell \emph{et al.} 2012.
#'
#' @docType data
#' @usage data(woody_NA)
#' @format An object of class \code{"RasterLayer"}; see
#'   \code{\linkS4class{Raster}}.
#' @keywords datasets
#' @references Dimiceli, C, \emph{et al.} 2015. MOD44B MODIS/Terra Vegetation
#'   Continuous Fields Yearly L3 Global 250m SIN Grid V006 [Data set]. NASA
#'   EOSDIS Land Processes DAAC. doi: 10.5067/MODIS/MOD44B.006
#'
#' Friedl MA, \emph{et al.} 2010. MODIS Collection 5 global land
#'   cover: Algorighm refinements and characterization of new datasets.
#'   \emph{Remote Sensing of Environment} 114:168-182.
#'
#' Hansen MC, \emph{et al.} 2003. Global percent tree cover at a spatial
#'   resolution of 500 meters: first results of the MODIS vegetation continuous
#'   fields algorithm. \emph{Earth Interactions} 7:10.
#'
#' Powell RL, Yoo EH, and Still CJ. 2012. Vegetation and soil carbon-13
#'   isoscapes for South America: integrating remote sensing and ecosystem
#'   isotope measurements. \emph{Ecosphere} 3:109.
#'
#' @source \emph{MODIS Vegetation Continuous Fields}. Global Land Cover Facility,
#'   University of Maryland: \url{http://glcf.umd.edu/data/vcf/}
#'
#' @examples
#' # Read in the data
#' data(woody_NA)
#' \donttest{
#' # Plot data layer
#' plot(woody_NA)}
#'
"woody_NA"
