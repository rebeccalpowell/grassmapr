# map_grass_pathway: Wrapper script to predict C4/C3 grass proportions
# Example Script [Save output to File]


# Set working directory
setwd("...")

# Load required R libraries
library(raster)
library(rgdal)
library(grassmapr)


# Load data for example
data(temp_NA)  # mean monthly temperature (deg. C)
data(prec_NA)  # mean monthly precipitation (mm)

# Specify climate thresholds
C4_temp <- 22    # mean monthly temperature >= 22 deg. C
GS_temp <- 5     # mean monthly temperature >= 5 deg. C
GS_prec <- 25    # mean monthly precipitation >= 25 mm

# Predict percent of grasses by photosynthetic pathway.
map_grass_pathway(temp.stack = temp_NA,
                  precip.stack = prec_NA,
                  C4.threshold = C4_temp,
                  GS.threshold = GS_temp,
                  precip.threshold = GS_prec,
                  filename = "./grass_map")

# Plot C4 and C3 grass layers.
grass_map <- brick("./grass_map.tif")
names(grass_map) <- c("C4.proportion", "C3.proportion")
par(mfrow = c(1,2))
plot(grass_map)
