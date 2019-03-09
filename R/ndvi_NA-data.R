#' Mean Monthly NDVI for North America
#'
#' Mean monthly MODIS Normalized Difference Vegetation Index (NDVI) for North
#'   America for the year 2001, aggregated to 10' spatial resolution.
#'
#' @docType data
#' @usage data(ndvi_NA)
#' @format An object of class \code{"RasterBrick"}, layers correspond to months;
#'   see \code{\linkS4class{Raster}}.
#' @keywords datasets
#' @references Didan, K. 2015. MOD13A3 MODIS/Terra Vegetation Indices Monthly L3
#'   Global 1km SIN Grid V006 [Data set]. NASA EOSDIS Land Processes DAAC.
#'   doi: 10.5067/MODIS/MOD13A3.006.
#'
#' Solano R, \emph{et al.} 2010. MODIS vegetation index user's guide
#'   (MOD13 Series). Version 2.0 (Collection 5). Vegetation Index and Phenology
#'   Lab, The University of Arizona, Tucson, Arizona, USA.
#'   \url{http://vip.arizona.edu}
#' @source \emph{MOD13A3: MODIS Vegetation Indices Monthly V006}. USGS
#'   Land Processes Distributed Active Archive Center:
#'   \url{https://lpdaac.usgs.gov}
#' @examples
#' \donttest{
#' # Read in the data
#' data(ndvi_NA)
#'
#' # Plot all data layers
#' plot(ndvi_NA)
#'
#' # Plot NDVI layer for July 2001
#' plot(ndvi_NA[[7]])
#' }
#'
"ndvi_NA"
