#' grassmapr: A package to map C3/C4 grass distribution and model d13C isoscape
#'
#' \pkg{grassmapr} provides functions (1) to predict C3 and C4 grass cover;
#'   optionally, provides functions to integrate other vegetation layers (e.g.,
#'   \% woody cover) and (2) to generate stable carbon (d13C) isoscapes for
#'   terrestrial vegetation.
#'
#' @docType package
#'
#' @name grassmapr
#'
#' @author Sydney M. Firmin, Rebecca L. Powell, Daniel M. Griffith
#'
#' \emph{Maintainer:} Rebecca L. Powell <\email{rpowell8@du.edu}>
#'
#' @section
#' \strong{1. Mapping C3/C4 grass distribution}:
#'
#' To predict and map the C3/C4 distribution of grasses, the following functions
#'   should be applied sequentially. Minimum inputs required are gridded climate
#'   data for temperature and precipitation. Each function returns a new Raster*
#'   object:
#'
#' \tabular{lll}{
#'   \code{maskClimateVals} \tab .... \tab To create climate masks based on
#'     single variable\cr
#'   \code{combineMasks} \tab .... \tab To intersect climate masks (two
#'     variables)\cr
#'   \code{calcC4Ratio} \tab .... \tab To predict the C4 grass ratio of each
#'     grid cell\cr
#' }
#'
#' @section
#' \strong{2. Modeling d13C isoscape for terrestrial vegetation}:
#'
#' User may optionally incorporate other vegetation layers (e.g., \% woody
#'   cover, \% crop cover, etc.), and/or apply a simple mixing model applying
#'   d13C endmembers for each plant functional type, based on relative cover:
#'
#' \tabular{lll}{
#'   \code{calcPFTCover} \tab .... \tab To incorporate non-grass vegetation
#'     layers\cr
#'   \code{calcDel13C} \tab .... \tab To generate stable carbon isoscape\cr
#' }
#'
#' @references Still CJ, \emph{et al.} 2003. Global
#'   distribution of C3 and C4 vegetation: carbon cycle implcations.
#'   \emph{Global Biogeochemical Cycles} 17:1006.
#'
#' Still CJ and Powell RL. 2010. Continental-scale distributions of vegetation
#'   stable carbon isotope ratios. In: West JB, \emph{et al.} (Eds).
#'   \emph{Isoscapes: understanding movement, pattern, and process on earth
#'   through isotope mapping}. Dordrecht: Springer.
#'
#' Powell RL, Yoo EH, and Still CJ. 2012. Vegetation and soil carbon-13
#'   isoscapes for South America: integrating remote sensing and ecosystem
#'   isotope measurements. \emph{Ecosphere} 3:109.
#'
#'
NULL
