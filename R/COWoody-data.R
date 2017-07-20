#' Percent woody cover for Colorado
#'
#' Gridded percent woody cover layer for Colorado in the year 2001 at 5' spatial
#'   resolution. Derived from MODIS Vegetation Continuous Fields tree cover
#'   layer, adjusted for shrub cover using MODIS IGBP Land-Cover Classification,
#'   following rules described in Powell \emph{et al.} 2012.
#'
#' @docType data
#' @usage data(COWoody)
#' @format An object of class \code{"RasterLayer"}; see
#'   \code{\link[raster]{Raster-class}}.
#' @keywords datasets
#' @references Friedl MA, \emph{et al.} 2010. MODIS Collection 5 global land
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
#' data(COWoody)
#' \donttest{
#' # Plot data layer
#' plot(COWoody)}
#'
"COWoody"
