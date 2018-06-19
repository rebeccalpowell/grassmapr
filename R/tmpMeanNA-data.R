#' Mean Monthly Temperature Grid for North America
#'
#' Gridded climatology of 1961-1990 monthly mean temperature (in deg. C) at 10'
#'   spatial resolution. Climatic Research Unit, High-Resolution Gridded
#'   Dataset.
#'
#' @docType data
#' @usage data(tmpMeanNA)
#' @format An object of class \code{"RasterBrick"}, layers correspond to months;
#'    see \code{\link[raster]{Raster-class}}.
#' @keywords datasets
#' @references New M, \emph{et al.} 2002. A high-resolution data set of surface
#' #'   climate over global land areas. \emph{Climate Research} 21:1-25.
#' @source \emph{CRU CL v.2.0}. Climatic Research Unit, University of East
#'   Anglia: \url{http://www.cru.uea.ac.uk/data/}
#' @examples
#' # Read in the data
#' data(tmpMeanNA)
#' \donttest{
#' # Plot all data layers
#' plot(tmpMeanNA)}
#' \donttest{
#' # Plot layer 3 only
#' plot(tmpMeanNA[[3]])}
#'
"tmpMeanNA"
