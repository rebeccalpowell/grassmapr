#' Monthly MODIS NDVI for Colorado
#'
#' Monthly MODIS Normalized Difference Vegetation Index (NDVI) for Colorado in
#'   2001 aggregated to 10' spatial resolution.
#'
#' @docType data
#' @usage data(COMonthlyNDVI)
#' @format An object of class \code{"RasterBrick"}, layers correspond to months;
#'   see \code{\link[raster]{Raster-class}}.
#' @keywords datasets
#' @references Solano R, \emph{et al.} 2010. MODIS vegetation index user's guide
#'   (MOD13 Series). Version 2.0 (Collection 5). Vegetation Index and Phenology
#'   Lab, The University of Arizona, Tucson, Arizona, USA.
#'   \url{http://vip.arizona.edu}
#' @source \emph{MOD13A3: MODIS Vegetation Indices Monthly L3 Global 1km}. USGS
#'   Land Processes Distributed Active Archive Center:
#'   \url{https://lpdaac.usgs.gov}
#' @examples
#' # Read in the data
#' data(COMonthlyNDVI)
#' \donttest{
#' # Plot all data layers
#' plot(COMonthlyNDVI)}
#' \donttest{
#' # Plot layer 3 only
#' plot(COMonthlyNDVI[[3]])}
#'
"COMonthlyNDVI"
