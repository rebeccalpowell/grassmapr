PFTmasks <- function(tempmask, precipmask, c4.threshold = NULL,
  biomass.weight = NULL, filename = '', ...) {

# create growing season sum layer

  big <- ! canProcessInMemory(tempmask, 4)

  if (big) {

    masks <- overlay(precipmask, tempmask, fun=function(x,y) {return(x*y)},
      filename = rasterTmpFile(prefix='msks'))

    if(nlayers(precipmask) == 1) {

     # divides growing season layer into c3, c4 and mixed mask layers based on
     # ratios of total temporal window

      m_C3 <- c(-Inf, 0, 1, 0, as.integer(nlayers(precipmask)) + 1, 0)
      rcl_C3 <- matrix(m_C3, ncol=3, byrow = TRUE)
      m_C4 <- c(-Inf, 0, 0, 1, as.integer(nlayers(precipmask)) + 1, 1)
      rcl_C4 <- matrix(m_C4, ncol=3, byrow = TRUE)

      c3mask <- reclassify(masks, rcl_C3, update=FALSE,
        filename = rasterTmpFile(prefix='C31msks'))
      c4mask <- reclassify(masks, rcl_C4, update=FALSE,
        filename = rasterTmpFile(prefix='C41msks'))

      out <- stack(c3mask, c4mask)
      names(out) <- c("C3", "C4")

    } else {

      # sum raster layer

      gs_sum <- overlay(masks, fun=sum,
        filename = rasterTmpFile(prefix='gssum'))

      if(is.null(c4.threshold)) {

      # divide growing season layer into c3, c4 and mixed mask layers based on
      # ratios of total temporal window

        m_C3 <- c(-Inf, 0, 1, 0, as.integer(nlayers(precipmask)) + 1, 0)
        rcl_C3 <- matrix(m_C3, ncol=3, byrow = TRUE)
        m_C4 <- c(0, as.integer((nlayers(precipmask)/2)+0.5), 0,
          as.integer((nlayers(precipmask)/2)+0.5), nlayers(precipmask)+1, 1)
        rcl_C4 <- matrix(m_C4, ncol=3, byrow = TRUE)
        m_mixed <- c(1, as.integer((nlayers(precipmask)/2)+0.5), 1,
          as.integer((nlayers(precipmask)/2)+0.5), nlayers(precipmask)+1, 0)
        rcl_mixed <- matrix(m_mixed, ncol=3, byrow = TRUE)

        c3mask <- reclassify(gs_sum, rcl_C3, update=FALSE,
          filename = rasterTmpFile(prefix='c3msks'))
        c4mask <- reclassify(gs_sum, rcl_C4, update=FALSE,
          filename = rasterTmpFile(prefix='c4msks'))
        mixedmask <- reclassify(gs_sum, rcl_mixed, update=FALSE,
          filename = rasterTmpFile(prefix='mxmsk'))

      } else {

      # divide growing season layer into c3, c4 and mixed mask layers based on
      # ratios of total temporal window

        m_C3 <- c(-Inf, 0, 1, 0, as.integer(nlayers(precipmask)) + 1, 0)
        rcl_C3 <- matrix(m_C3, ncol=3, byrow = TRUE)
        m_C4 <- c(0, as.integer(c4.threshold*nlayers(precipmask)+0.5), 0,
          as.integer(c4.threshold*nlayers(precipmask)+0.5),
          nlayers(precipmask)+1, 1)
        rcl_C4 <- matrix(m_C4, ncol=3, byrow = TRUE)
        m_mixed <- c(1, as.integer(c4.threshold*nlayers(precipmask)+0.5), 1,
          as.integer(c4.threshold*nlayers(precipmask)+0.5),
          nlayers(precipmask)+1, 0)
        rcl_mixed <- matrix(m_mixed, ncol=3, byrow = TRUE)

        c3mask <- reclassify(gs_sum, rcl_C3, update=FALSE,
          filename = rasterTmpFile(prefix='rcl3'))
        c4mask <- reclassify(gs_sum, rcl_C4, update=FALSE,
          filename = rasterTmpFile(prefix='rcl4'))
        mixedmask <- reclassify(gs_sum, rcl_mixed, update=FALSE,
          filename = rasterTmpFile(prefix = 'rclm'))

      }

      if(is.null(biomass.weight)) {

      # if no weight layer, mixed grasslands are simply divided by the number
      # of months of c3/c4 dominance

        c4_biomass.weight_tmp <- masks
        GS_biomass.weight_tmp <- precipmask

      } else {

      # if weight layer is provided, then it is first recalssified to remove
      # negative values

        biomass.weight.cr <- reclassify(biomass.weight, matrix(c(-Inf, 0, 0),
          ncol=3, byrow = TRUE), update=FALSE, include.lowest=TRUE,
          filename = rasterTmpFile(prefix = 'bmw'))

      # multiply Each monthly mask by biomass.weight ratio

        c4_biomass.weight_tmp <- overlay(biomass.weight.cr, masks,
          fun=function(x, y) {return(x*y)}, filename = rasterTmpFile())
        GS_biomass.weight_tmp <- overlay(biomass.weight.cr, precipmask,
          fun=function(x, y) {return(x*y)}, filename = rasterTmpFile())
      }

      # sum each of the biomass.weight values to create a single layer for each

      C4_biomass.weight_sum <- overlay(c4_biomass.weight_tmp, fun=sum,
        filename = rasterTmpFile(prefix = 'c4bmw'))
      GS_biomass.weight_sum <- overlay(GS_biomass.weight_tmp, fun=sum,
        filename = rasterTmpFile(prefix = 'gsbmw'))

      # set 0 to NA for each layer

      rcl_NA <- matrix(c(0, NA), ncol=2)
      C4_biomass.weight_sum <- reclassify(C4_biomass.weight_sum, rcl_NA,
        filename = rasterTmpFile(prefix = 'rc4bmw'))
      GS_biomass.weight_sum <- reclassify(GS_biomass.weight_sum, rcl_NA,
        filename = rasterTmpFile(prefix = 'rgsbmw'))

      # create a C4 ratio to Growing Season
      biomass.weight_ratio <- overlay(C4_biomass.weight_sum,
        GS_biomass.weight_sum, fun=function(x, y){(x/y)},
        filename = rasterTmpFile(prefix = 'bmwr'))

      rcl_0 <- matrix(c(NA, 0), ncol=2)
      biomass.weight_ratio <- reclassify(biomass.weight_ratio,
        rcl_0, right= NA, filename = rasterTmpFile(prefix = 'bmwrr'))

      out <- stack(c3mask, c4mask, mixedmask, biomass.weight_ratio)
      names(out) <- c("C3", "C4", "mixed", "mixed.ratio")
    }

  } else {

    masks <- overlay(precipmask, tempmask, fun=function(x,y) {return(x*y)})

    if(nlayers(precipmask) == 1) {

    # divide growing season layer into c3, c4 and mixed mask layers based on
    # ratios of total temporal window
      m_C3 <- c(-Inf, 0, 1, 0, as.integer(nlayers(precipmask)) + 1, 0)
      rcl_C3 <- matrix(m_C3, ncol=3, byrow = TRUE)
      m_C4 <- c(-Inf, 0, 0, 1, as.integer(nlayers(precipmask)) + 1, 1)
      rcl_C4 <- matrix(m_C4, ncol=3, byrow = TRUE)

      c3mask <- reclassify(masks, rcl_C3, update=FALSE)
      c4mask <- reclassify(masks, rcl_C4, update=FALSE)

      out <- stack(c3mask, c4mask)
      names(out) <- c("C3", "C4")

    } else {

      # sum raster layer

      gs_sum <- overlay(masks, fun=sum)

      if(is.null(c4.threshold)){

      # divide growing season layer into c3, c4 and mixed mask layers based on
      # ratios of total temporal window

        m_C3 <- c(-Inf, 0, 1, 0, as.integer(nlayers(precipmask)) + 1, 0)
        rcl_C3 <- matrix(m_C3, ncol=3, byrow = TRUE)
        m_C4 <- c(0, as.integer((nlayers(precipmask)/2)+0.5), 0,
          as.integer((nlayers(precipmask)/2)+0.5), nlayers(precipmask)+1, 1)
        rcl_C4 <- matrix(m_C4, ncol=3, byrow = TRUE)
        m_mixed <- c(1, as.integer((nlayers(precipmask)/2)+0.5), 1,
          as.integer((nlayers(precipmask)/2)+0.5), nlayers(precipmask)+1, 0)
        rcl_mixed <- matrix(m_mixed, ncol=3, byrow = TRUE)

        c3mask <- reclassify(gs_sum, rcl_C3, update=FALSE)
        c4mask <- reclassify(gs_sum, rcl_C4, update=FALSE)
        mixedmask <- reclassify(gs_sum, rcl_mixed, update=FALSE)

      } else {

      # divide growing season layer into c3, c4 and mixed mask layers based on
      # ratios of total temporal window

        m_C3 <- c(-Inf, 0, 1, 0, as.integer(nlayers(precipmask)) + 1, 0)
        rcl_C3 <- matrix(m_C3, ncol=3, byrow = TRUE)
        m_C4 <- c(0, as.integer(c4.threshold*nlayers(precipmask)+0.5), 0,
          as.integer(c4.threshold*nlayers(precipmask)+0.5),
          nlayers(precipmask)+1, 1)
        rcl_C4 <- matrix(m_C4, ncol=3, byrow = TRUE)
        m_mixed <- c(1, as.integer(c4.threshold*nlayers(precipmask)+0.5), 1,
          as.integer(c4.threshold*nlayers(precipmask)+0.5),
          nlayers(precipmask)+1, 0)
        rcl_mixed <- matrix(m_mixed, ncol=3, byrow = TRUE)

        c3mask <- reclassify(gs_sum, rcl_C3, update=FALSE)
        c4mask <- reclassify(gs_sum, rcl_C4, update=FALSE)
        mixedmask <- reclassify(gs_sum, rcl_mixed, update=FALSE)

      }

      if(is.null(biomass.weight)) {

      # if no weight layer, mixed grasslands are simply divided by the number
      # of months of c3/c4 dominance

        c4_biomass.weight_tmp <- masks
        GS_biomass.weight_tmp <- precipmask

      } else {

      # if weight layer is provided, then it is first recalssified to remove
      # negative values

        biomass.weight.cr <- reclassify(biomass.weight, matrix(c(-Inf, 0, 0),
          ncol=3, byrow = TRUE), update=FALSE, include.lowest=TRUE)

      # multiply Each monthly mask by biomass.weight ratio

        c4_biomass.weight_tmp <- overlay(biomass.weight.cr, masks,
          fun=function(x, y) {return(x*y)})
        GS_biomass.weight_tmp <- overlay(biomass.weight.cr, precipmask,
          fun=function(x, y) {return(x*y)})
      }

      # sum each of the biomass.weight values to create a single layer for each

      C4_biomass.weight_sum <- overlay(c4_biomass.weight_tmp, fun=sum)
      GS_biomass.weight_sum <- overlay(GS_biomass.weight_tmp, fun=sum)

      # set 0 to NA for each layer

      rcl_NA <- matrix(c(0, NA), ncol=2)
      C4_biomass.weight_sum <- reclassify(C4_biomass.weight_sum, rcl_NA)
      GS_biomass.weight_sum <- reclassify(GS_biomass.weight_sum, rcl_NA)

      # create a C4 ratio to Growing Season

      biomass.weight_ratio <- overlay(C4_biomass.weight_sum,
        GS_biomass.weight_sum, fun=function(x, y){(x/y)})

      rcl_0 <- matrix(c(NA, 0), ncol=2)
      biomass.weight_ratio <- reclassify(biomass.weight_ratio, rcl_0, right= NA)

      out <- stack(c3mask, c4mask, mixedmask, biomass.weight_ratio)
      names(out) <- c("C3", "C4", "mixed", "mixed.ratio")
    }


  }


  if (filename != '') {
    writeRaster(out, filename, ...)
  }
  return(out)
}
