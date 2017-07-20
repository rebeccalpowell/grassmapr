#' Percent C3 Crop Cover for Colorado
#'
#' Gridded percent C3 crop cover layer for Colorado in the year 2000 at 5'
#'   spatial resolution. Integrates geographic distribution of global
#'   agricultural lands (Ramankutty \emph{et al.} 2008) with distribution of
#'   crop types (Monfreda \emph{et al.} 2008), following rules described in
#'   Powell \emph{et al.} 2012.
#'
#' @docType data
#' @usage data(COC3Crop)
#' @format An object of class \code{"RasterLayer"}; see
#'   \code{\link[raster]{Raster-class}}.
#' @keywords datasets
#' @references Monfreda C, Ramankutty N, and Foley JA. 2008. Farming the planet:
#'   2. Geographic distribution of crop areas, yields, physiological types, and
#'   net primary production in the year 2000. \emph{Global Biogeochemical
#'   Cycles} 22:GB1022.
#'
#' Powell RL, Yoo EH, and Still CJ. 2012. Vegetation and soil carbon-13
#'   isoscapes for South America: integrating remote sensing and ecosystem
#'   isotope measurements. \emph{Ecosphere} 3:109.
#'
#' Ramankutty N., Evan AT, Monfreda C., and Foley JA. 2008. Farming the planet:
#'   1. Geographic distribution of global agricultural lands in the year 2000.
#'   \emph{Global Biogeochemical Cycles} 22:GB1003.
#' @source \emph{Cropland and Pasture Area in 2000} and \emph{Harvest Area and
#'   Yield for 175 Crops}. EarthStat.org: Global Landscapes Initiative,
#'   University of Minnesota Institute on the Environment and Ramankutty Lab,
#'   University of British Columbia, Vancouver: \url{http://www.earthstat.org/}
#' @examples
#' # Read in the data
#' data(COC3Crop)
#' \donttest{
#' # Plot data layer
#' plot(COC3Crop)}
#'
"COC3Crop"
