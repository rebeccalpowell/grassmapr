#' Percent C4 Crop Cover for North America
#'
#' Gridded percent C4 crop cover layer for North America in the year 2000,
#'   aggregated to 10' spatial resolution. Integrates geographic distribution of
#'   global agricultural lands (Ramankutty et al. 2008) with distribution
#'   of crop types (Monfreda et al. 2008), following rules described in Powell
#'   et al. 2012.
#'
#' @docType data
#' @usage data(cropC4_NA)
#' @format An object of class \code{"RasterLayer"}; see
#'   \code{\linkS4class{Raster}}.
#' @keywords datasets
#' @references Monfreda, C. et al. 2008. Farming the planet: 2. Geographic
#'   distribution of crop areas, yields, physiological types, and net primary
#'   production in the year 2000. -- Global Biogeochemical Cycles 22:GB1022.
#'
#' Powell, R. L. et al. 2012. Vegetation and soil carbon-13 isoscapes for South
#'   America: integrating remote sensing and ecosystem isotope measurements. --
#'   Ecosphere 3:109.
#'
#' Ramankutty, N. et al. 2008. Farming the planet: 1. Geographic distribution of
#'   global agricultural lands in the year 2000. -- Global Biogeochemical Cycles
#'   22:GB1003.
#' @source \emph{Cropland and Pasture Area in 2000} and \emph{Harvest Area and
#'   Yield for 175 Crops}. EarthStat.org: Global Landscapes Initiative,
#'   University of Minnesota Institute on the Environment and Ramankutty Lab,
#'   University of British Columbia, Vancouver: \url{http://www.earthstat.org/}
#' @examples
#' # Read in the data
#' data(cropC4_NA)
#' \donttest{
#' # Plot data layer
#' plot(cropC4_NA)}
#'
"cropC4_NA"
