#' Mask climate Raster values Based on Single Parameter
#'
#' This function builds monthly climate masks based on a user-specified
#' threshold for a single climate parameter (e.g., precipitation, temperature,
#' etc.). Grid cells greater than threshold are masked.
#' @param climate.stack Raster* object. Monthly values for a single climate
#' variable. Object may be single or multi-layer.
#' @param threshold Numeric. Threshold value for a single climate variable.
#' @param filename Character. Output base filename (optional). User should not specify extension.  Default output file is GeoTiff.
#' @param ...
#'
#' @return RasterBrick. One output mask layer for each input data layer. Output file format is GeoTiff with unsigned integer data type.
#' @export
#'
#' @examples
#'

maskClimateVals <- function(climate.stack, threshold, filename = '', ...) {

  # Function masks data values > threshold for gridded climate data
  # Output is a rasterStack, nl = nlayers of the input rasterStack

  # Create output rasterBrick to match dimensions of input climate layer(s)
  out <- brick(climate.stack, values = FALSE)
  big <- ! canProcessInMemory(out, 3)
  filename <- trim(filename)

  # If output filename not specified by user, test whether input file can be
  # processed in memory.

  if (big & filename == '') {
    filename <- rasterTmpFile()
  }

  # If file name provided, write to disk; else process in memory.

  if (filename != '') {
    outfile <- paste0(filename, '.tif')
    out <- writeStart(out, outfile, datatype = 'INT1U', overwrite = TRUE)
    todisk <- TRUE
  } else {
    vv <- matrix((1:(ncell(out)*nlayers(out))), ncol = nlayers(out))
    todisk <- FALSE
  }

  # Determine appropriate block size, and initialize progress bar.
  bs <- blockSize(out)
  pb <- pbCreate(bs$n)

  # Mask pixels with value >= threshold.

  if (todisk) {
    for (i in 1:bs$n) {
      v <- getValues(climate.stack, row = bs$row[i], nrows = bs$nrows[i])
      v <- ifelse(v >= threshold, 1, 0)
      out <- writeValues(out, v, bs$row[i])
      pbStep(pb, i)
    }
    out <- writeStop(out)
  } else {
    for (i in 1:bs$n) {
      v <- getValues(climate.stack, row = bs$row[i], nrows = bs$nrows[i])
      v <- ifelse(v >= threshold, 1, 0)
      rstart <- (bs$row[i]-1)*ncol(out)+1
      rend <- (bs$row[i]+bs$nrows[i]-1)*ncol(out)
      vv[(rstart:rend), ] <- matrix(v, ncol = nlayers(out))
    }
      out <- setValues(out, as.vector(vv))
  }

  pbClose(pb)
  return(out)
}



