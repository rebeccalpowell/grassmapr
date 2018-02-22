#' Wrapper Function to Calculate d13C isoscape
#'
#' This is a wrapper function that can calculate an isoscape based on a simple mixing model to percent vegetation cover
#'   based on user input data and parameters. At minimum a user must provide a temperature and precipitation data.
#'   The temporal grain and window as well as spatial grain and extent of all input data (climate, vegetation cover,
#'   vegetation index) must match one another. These inputs would result in a natural herbaceous only isoscape. Users
#'   can provide woody vegetation data, cultivated vegetation data (crops) and custom crossover thresholds and isotopic endmembers.
#'   If the users chooses to include crop data, the user must provide and specify a percent c3 crop layer and a percent c4 crop layer.
#'   Default values for crossover thresholds and isotopic endmembers are listed below.
#' @param temp.stack Raster* object. Each layer corresponds to a
#'  different temporal window (e.g., month) for a single temperature variable.
#'  Object may be single or multi-layer.
#' @param ppt.stack Raster* object. Each layer corresponds to a
#'  different temporal window (e.g., month) for a single temperature variable.
#'  Object may be single or multi-layer.
#' @param c4.threshold Numeric. Threshold value (lower-bound) for C4 dominance.
#' @param gs.threshold Numeric. Threshold value (lower-bound) of temperature
#'  for active growing season.
#' @param ppt.threshold Numeric. Threshold value (lower-bound) of precipitation
#'  for active growing season.
#' @param woody RasterLayer. A per-pixel percentage of woody vegetation cover.
#' @param c3.crop RasterLayer. A per-pixel percentage of cultivated C3 herbaceous vegetation.
#' @param c4.crop RasterLayer. A per-pixel percentage of cultivated c4 herbaceous vegetation.
#' @param veg.scale Numeric. Scale factor for vegetation cover. Default value = 100.
#' @param veg.index Raster* object. Each layer corresponds to a different
#' temporal window and should match the temporal window and resolution of the climate stacks.
#' @param filename Character. Optional output root filename passed to
#'   \code{wric4.teRaster}, default output file type is GeoTiff. If not specified,
#'   output is written to a temporary file.
#' @param ... Other arguments passed to \code{writeRaster}.
#' @return RasterBrick. Layers correspond to the generated (Layer 1) isoscape and (Layer 2) standard deviation layer.
#' @export
#' @examples
#' # Climate data for Colorado to use in this example
#' data(COMeanPre)  # mean monthly precipitation (mm)
#' data(COMeanTmp)  # mean monthly temperature (deg. C)
#' \donttest{
#' # Estimate C3/C4 herbaceous layers in 100\% grassy world using default thresholds.
#' herbaceous <- isoscape(COMeanTemp, COMeanPre))}
#'
#' @seealso \link[grassmapr]{calcDel13C}, \link[raster]{reclassify}.
#'

isoscape <- function(temp.stack, ppt.stack, c4.threshold=22, gs.threshold=5,
                     ppt.threshold=25, woody=NULL, c3.crop=NULL, c4.crop=NULL, veg.scale=100, veg.index=NULL,
                     c3.endmember=-26.7, c4.endmember=-12.5, woody.endmember=-27.2, c3.sd=2.3,
                     c4.sd=1.1, woody.sd=2.5, filename = '', ...){

  # C4 temperature mask (>= 22 deg. C)
  C4_temp_mask <- maskClimateVals(temp.stack, c4.threshold)
  # Growing season temperature mask (>= 5 deg. C)
  GS_temp_mask <- maskClimateVals(temp.stack, gs.threshold)
  #Growing season precipitation mask (>= 25 mm)
  precip_mask <- maskClimateVals(ppt.stack, ppt.threshold)
  # Generate Growing Season (GS) climate masks
  GS_mask <- combineMasks(GS_temp_mask, precip_mask)
  # Generate C4 climate masks
  C4_mask <- combineMasks(C4_temp_mask, precip_mask)
  # Remove intermediate raster objects
  rm(precip_mask, C4_temp_mask, GS_temp_mask)
  # Calculate C4 ratio based on C4 climate (OPTIONAL vegetation productivity)
  C4_ratio <- calcC4Ratio(C4_mask, GS_mask, veg.index)
  # Remove intermediate raster objects
  rm(GS_mask, C4_mask)


  if(is.null(woody)){

    if(is.null(c3.crop)){
      # calculate PFT Cover
      pft_cover <- calcPFTCover(C4_ratio, scale =veg.scale)
      # d13C endmember vector for PFT layers from the literature
      d13C_emb <- c(c4.endmember, c3.endmember) # C4 herb, C3 herb, Woody
      # Apply mixing model to generate d13C isoscape
      d13C_iso <- calcDel13C(pft_cover, d13C_emb)
      # Standard deviations of d13C endmember means from the literature
      d13C_std <- c(c4.sd, c3.sd) # C4 herb, C3 herb, Woody
      # Calculate weighted standard deviation of mean d13C values
      d13C_iso_std <- calcDel13C(pft_cover, d13C_std)


    }else{

      # Create raster stack of other (non-grassy) vegetation layers
      veg_layers <- stack(c4.crop, c3.crop)
      #Indicate layers that correspond to C4 vegetation
      C4_flag <- c(1, 0)
      # Indicate layers that correspond to herbaceous vegetation
      herb_flag <- c(1, 1)
      # Generate PFT vegetation cover brick
      pft_cover <- calcPFTCover(C4_ratio, veg_layers, C4_flag, herb_flag, scale = veg.scale)
      # d13C endmember vector for PFT layers from the literature
      d13C_emb <- c(c4.endmember, c3.endmember) # C4 herb, C3 herb, Woody
      # Apply mixing model to generate d13C isoscape
      d13C_iso <- calcDel13C(pft_cover, d13C_emb)
      # Standard deviations of d13C endmember means from the literature
      d13C_std <- c(c4.sd, c3.sd) # C4 herb, C3 herb, Woody
      # Calculate weighted standard deviation of mean d13C values
      d13C_iso_std <- calcDel13C(pft_cover, d13C_std)

  }}else{

    if(is.null(c3.crop)){

      # Create raster stack of other (non-grassy) vegetation layers
      veg_layers <- stack(woody)
      #Indicate layers that correspond to C4 vegetation
      C4_flag <- c(0)
      # Indicate layers that correspond to herbaceous vegetation
      herb_flag <- c(0)
      # Generate PFT vegetation cover brick
      pft_cover <- calcPFTCover(C4_ratio, veg_layers, C4_flag, herb_flag, scale = veg.scale)
      # d13C endmember vector for PFT layers from the literature
      d13C_emb <- c(c4.endmember, c3.endmember, woody.endmember) # C4 herb, C3 herb, Woody
      # Apply mixing model to generate d13C isoscape
      d13C_iso <- calcDel13C(pft_cover, d13C_emb)
      # Standard deviations of d13C endmember means from the literature
      d13C_std <- c(c4.sd, c3.sd, woody.sd) # C4 herb, C3 herb, Woody
      # Calculate weighted standard deviation of mean d13C values
      d13C_iso_std <- calcDel13C(pft_cover, d13C_std)

    }else{


      # Create raster stack of other (non-grassy) vegetation layers
      veg_layers <- stack(c4.crop, c3.crop, woody)
      #Indicate layers that correspond to C4 vegetation
      C4_flag <- c(1, 0, 0)
      # Indicate layers that correspond to herbaceous vegetation
      herb_flag <- c(1, 1, 0)
      # Generate PFT vegetation cover brick
      pft_cover <- calcPFTCover(C4_ratio, veg_layers, C4_flag, herb_flag, scale = veg.scale)
      # d13C endmember vector for PFT layers from the literature
      d13C_emb <- c(c4.endmember, c3.endmember, woody.endmember) # C4 herb, C3 herb, Woody
      # Apply mixing model to generate d13C isoscape
      d13C_iso <- calcDel13C(pft_cover, d13C_emb)
      # Standard deviations of d13C endmember means from the literature
      d13C_std <- c(c4.sd, c3.sd, woody.sd) # C4 herb, C3 herb, Woody
      # Calculate weighted standard deviation of mean d13C values
      d13C_iso_std <- calcDel13C(pft_cover, d13C_std)}}


    # stack isoscape and standard deviation layer to an output
    output <- stack(d13C_iso, d13C_iso_std)

    if (filename != '') {
      writeRaster(output, filename, ...)
      }

    ##return isoscape
    return(output)}







