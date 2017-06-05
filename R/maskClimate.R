#' Mask climate Raster values
#'
#' This function builds monthly climate masks based on a user-specified
#' threshold for a single climate parameter (e.g., precipitation, temperature,
#' etc.).
#' @param climate.stack Raster* object. Monthly values for a single climate
#' variable. Object may be single or multi-layer.
#' @param threshold Numeric. Threshold value for a single climate variable.
#' @param filename Character. Output base filename (required for large files).
#' @param ...
#'
#' @return RasterBrick. One output mask layer for each input data layer. Output file format is GeoTiff with unsigned integer data type.
#' @export
#'
#' @examples
#'

maskClimate <- function(climate.stack, threshold, filename = '', ...) {
  # Function to mask data values >= threshold for gridded climate data

  filename <- trim(filename)

  # Create output rasterBrick to match dimensions of input climate layer(s)
  out <- brick(climate.stack, nl=nlayers(climate.stack), values=FALSE)

  # Error check: If output filename not specified by user, test whether input
  # file can be processed in memory.

  big <- ! canProcessInMemory(out, 3)
  if (big & filename == '') {
    stop("File size too big to process in memory.
      Please provide output filename.")
  }

  # If file name provide, write to disk; else process in memory.

  if (filename != '') {
    outfile <- paste0(filename, '.tif')
    out <- writeStart(out, outfile, datatype = 'INT2S', overwrite = TRUE)
    todisk <- TRUE
  } else {
    vv <- matrix(ncol=nrow(out[[1]]), nrow=ncol(out[[1]]))
    todisk <- FALSE
  }

  # Mask pixels with value >= threshold.

  if (todisk) {
    for (i in 1:nrow(out)) {
      v <- getValues(climate.stack, i)
      v <- ifelse(v >= threshold, 1, 0)
      out <- writeValues(out, v, i)
      }
    out <- writeStop(out)
  } else {
      for (k in 1:nlayers(out)) {
        for (i in 1:nrow(out)) {
          v <- getValues(climate.stack[[k]], i)
          v <- ifelse(v >= threshold, 1, 0)
          vv[, i] <- v
          }
          out <- setValues(out, as.vector(vv), layer = k)
      }
    }

  # Output is a rasterStack, nl = nl of the input rasterStack
  return(out)
}
