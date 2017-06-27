calcC4Fraction <- function(C4.mask, GS.mask, veg.index = NULL,
  filename = '', ...) {

  if(is.null(veg.index)) {
    veg.index <- setValues(raster(C4.mask[[1]], 1))
  }

  # Error check: same extent, grid, projection for all input layers
  compareRaster(C4.mask, GS.mask, veg.index,
    stopiffalse = TRUE, showwarning = TRUE)

  # Error check: Climate stacks have same number of layers.

  if(nlayers(C4.mask) != nlayers(GS.mask)){
    stop("Climate masks have different number of layers")
  }

  # Error check: VI stack provided has same number of layers as climate stacks,
  # else equals one (dummy layer)

  if((nlayers(veg.index) != nlayers(C4.mask)) | (nlayers(veg.index) != 1)) {
    stop("Vegetation index has incorrect number of layers")
  }

  if(filename != '') {
    outfile <- paste0(trim(filename), '.tif')
    C4_herb_percent <- overlay(C4.mask, GS.mask, veg.index,
      fun = function(x, y, z) {return(sum(x*z)/sum(y*z))},
      filename = outfile,
      datatype = 'INT1U',
      overwrite = TRUE)
  } else {
      C4_herb_percent <- overlay(C4.mask, GS.mask, veg.index,
      fun = function(x, y, z) {return(sum(x*z)/sum(y*z))})
    }

  return(C4_herb_percent)
}
