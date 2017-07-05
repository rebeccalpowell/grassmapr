#' Calculate Plant Functional Type Layers
#'
#' @param C4.ratio Raster layer. Grid cells correcpond to the C4 ratio of herbaceous cover
#' @param veg.layers Raster* object. Each layer corresponds to non-herbaceous cover or agriculatural crop layers
#' @param scale.factor Numeric. Scale factor that represents maximum percent cover
#' @param C4.flag Numeric. Vector corresponding to nlayers of veg.layers object. 1 = C4 vegetation layer, 0 = C3 vegetation layer.
#' @param herb.flag Numeric. Vector corresponding to nlayers of veg.layers object. 1 = herbaceous vegetation layer, 0 = woody vegetation layer.
#' @param filename Character. Output root filename.
#' @param ...
#'
#' @return Raster brick. Layers correspond to percent vegetation cover. Layer 1 - C4 herbaceous, Layer 2 - C3 herbaceous, Layer 3 ... - other vegetation layers provided by user.
#' @export
#'
#' @examples
#'

# Function to calculate vegetation cover, starting with "100% grass world,"
#  incorporates other vegetation layers, and adjusts grass layers for crops.

calcPFTCover <- function(C4.ratio, veg.layers = NULL, scale.factor = 100,
  C4.flag = NULL, herb.flag = NULL, filename = '', ...) {

  # Error check: same extent, grid, projection for all input raster layers
  if(!is.null(veg.layers)) {
    compareRaster(C4.ratio, veg.layers, stopiffalse = TRUE, showwarning = TRUE)
  }

  # Error check: Length of C4.flag vector equals nlayers for veg.layers stack
  if(length(C4.flag) != nlayers(veg.layers)){
    stop("Length of C4.flag vector does not match number of veg.layers")
  }

  # Error check: Length of herb.flag vector equals length of C4.flag
  if(length(herb.flag) != length(C4.flag)){
    stop("Length of herb.flag vector does not equal length of C4.flag vector")
  }

  # Step 1. Initialize vegetation cover as "all-herbaceous world."
  #   Herbaceous cover = 100% for all pixels.

  herb_layer <- setValues(C4.ratio, scale.factor)

  # Step 2. Adjust for real world vegetation; subtract each vegetation layer
  #  from "all-herbaceous world" template.

  if(!is.null(veg.layers)) {
    nonherb_veg <- overlay(veg_layers, fun = "sum")
    herb_layer <- overlay(herb_layer, nonherb_veg, fun = "-", forcefun = TRUE)
  }

  # Step 3. Calculate C4 herbaceous layer:
  #   (i) multiply adjusted herbaceous layer by C4_ratio,
  #  (ii) add all vegetation layers with flags (C4 = 1 & Herb = 1)
  #   Repeat for C3 herbaceous layer.

  C4_nat_herb <- overlay(herb_layer, C4.ratio, fun = "*")
  C3_nat_herb <- overlay(herb_layer, C4.ratio, fun = function(x,y){
    return(x*(1-y))
    })
  rm(nonherb_veg, herb_layer, C4.ratio)

  C4herb_index <- which((C4.flag == 1) & (herb.flag == 1))
  if(length(C4herb_index) != 0) {
    for (i in 1:length(C4herb_index)) {
      C4_herb <- overlay(C4_nat_herb, veg.layers[[i]], fun = "+",
        forcefun = TRUE)
    }
  }

  C3herb_index <- which((C4.flag == 0) & (herb.flag == 1))
  if(length(C3herb_index) != 0) {
    for (i in 1:length(C3herb_index)) {
      C3_herb <- overlay(C3_nat_herb, veg.layers[[i]], fun = "+",
        forcefun = TRUE)
    }
  }

  #### Could add a C4woody_index option here ####
  rm(C4herb_index, C3herb_index, C4_nat_herb, C3_nat_herb)

  # Step 4: Create brick of vegetation PFT cover; add in non-herbaceous layers

  woody_index <- which((herb.flag == 0))
  if(length(woody_index) != 0) {
    pft_cover <- brick(C4_herb, C3_herb, veg.layers[[woody_index]])
    names(pft_cover) <- c("C4_herb", "C3_herb",
      names(veg.layers[[woody_index]]))
  } else {
    pft_cover <- brick(C4_herb, C3_herb)
    names(pft_cover) <- c("C4_herb", "C3_herb")
  }

  # Write to file or output to memory
  #  Could insert error check for float data (i.e., scale.factor == 1)
  #  and insert additional step to convert to integer

  # Note that when writing raster to file format other than *Rda, the band
  #  names are lost.  Consider writing a header file at the same time, to
  #  record the band names.

  if(filename != '') {
    outfile <- paste0(trim(filename), '.tif')
    writeRaster(pft_cover, outfile, datatype = 'INT2U', overwrite = TRUE)
    } else {
      return(pft_cover)
  }

  # Clean up
  rm(C4_herb, C3_herb, woody_index, veg.layers, herb.flag, C4.flag)
}
