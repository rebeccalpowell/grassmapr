# grassmapr: Example Script - North America [Save to File]

# Set working directory
setwd("...")


# STEP 1: Generate monthly climate masks

# Load North America climate data
data(temp_NA)   # mean monthly temperature (deg. C)
data(prec_NA)   # mean monthly precipitation totals (mm)

# Set a C4 temperature threshold based on the COT model (>= 22 deg. C)
C4_temp <- 22
# Set a growing season temperature threshold (>= 5 deg. C)
GS_temp <- 5
# Set a minimum precipitation threshold (>= 25 mm)
GS_prec <- 25

# Generate monthly C4 climate masks
mask_climate_2(temp.stack = temp_NA,
  temp.threshold = C4_temp,
  precip.stack = prec_NA,
  precip.threshold = GS_prec,
  filename = "./C4_masks")

# Generate monthly Growing Season (GS) climate masks
mask_climate_2(temp.stack = temp_NA,
  temp.threshold = GS_temp,
  precip.stack = prec_NA,
  precip.threshold = GS_prec,
  filename = "./GS_masks")

C4_masks <- brick("./C4_masks.tif")
plot(C4_masks)

GS_masks <- brick("./GS_masks.tif")
plot(GS_masks)

# [Optionally] - Count number of months that satisfy each climate criteria
count_months_2(GS_masks, "./GS_total")
count_months_2(C4_masks, "./C4_total")

GS_total <- raster("./GS_total.tif")
C4_total <- raster("./C4_total.tif")

# Plot C4 month total, GS month total
par(mfrow = c(1,2))
plot(GS_total)
plot(C4_total)


# STEP 2: Predict C4 grass proportion

# Calculate C4 herbaceous proportion based on C4 climate only
calc_C4_ratio_2(C4_masks, GS_masks, filename = "./C4_ratio")

# Plot C4 herbaceous proportion [i.e., predicted C4 ratio of grasses, based on climate]
C4_ratio <- raster("./C4_ratio.tif")
par(mfrow = c(1,1))
plot(C4_ratio)

# [Optionally] - Load monthly NDVI layers
data(ndvi_NA)

# Calculate C4 ratio based on C4 climate AND vegetation productivity
calc_C4_ratio_2(C4_masks, GS_masks, veg.index = ndvi_NA,
  filename = "./C4_ratio_vi")

# Compare two predictions of C4 ratio
C4_ratio_vi <- raster("./C4_ratio_vi.tif")
par(mfrow = c(1,2))
plot(C4_ratio)
plot(C4_ratio_vi)


# STEP 3: Calculate plant functional type (PFT) cover layers

# [Optionally] - Load non-grass vegetation layers
data(woody_NA)  # woody cover (%)
data(cropC3_NA) # C3 crop cover (%)
data(cropC4_NA) # C4 crop cover (%)

# Create raster stack of non-grass vegetation layers
veg_layers <- stack(woody_NA, cropC3_NA, cropC4_NA)

# Plot non-grass vegetation layers
plot(veg_layers)

#Indicate layers that correspond to C4 vegetation
C4_flag <- c(0, 0, 1)

# Indicate layers that correspond to herbaceous vegetation
herb_flag <- c(0, 1, 1)

# Generate PFT vegetation cover brick (C4 grass, C3 grass, woody)
calc_pft_cover(C4.ratio = C4_ratio,
                GS.mask = GS_masks,
                veg.layers = veg_layers,
                C4.flag = C4_flag,
                herb.flag = herb_flag,
                filename = "./pft_cover")

# Plot PFT cover layers (%C4 herbaceous, %C3 herbaceous, %woody)
pft_cover <- brick("./pft_cover.tif")
plot(pft_cover)


# STEP 4: Apply simple mixing model to predict d13C isoscape

# d13C endmember vector for PFT layers from the literature
d13C_emb <- c(-12.5, -26.7, -27.0) # C4 herb, C3 herb, Woody

# Apply mixing model to generate d13C isoscape
calc_del13C_2(pft_cover, d13C_emb, filename = "./d13C_iso")

# Standard deviations of d13C endmember means from the literature
d13C_emb_std <- c(1.1, 2.3, 1.7) # C4 herb, C3 herb, Woody

# Calculate weighted standard deviation of mean d13C values
calc_del13C_2(pft_cover, d13C_emb_std, filename = "./d13C_std")

# Plot d13C isoscape and standard deviation layers
d13C_iso <- raster("d13C_iso.tif")
d13C_std <- raster("d13C_std.tif")
par(mfrow = c(1, 2))
plot(d13C_iso, main = "Mean Vegetation d13C \n(per mil)",
  xlab = "longitude", ylab = "latitude",
  zlim = c(-27, -12))
plot(d13C_std, main = "Std. Dev. d13C \n(per mil)",
  xlab = "longitude", ylab = "latitude",
  zlim = c(1.0, 2.4))

# Remove intermediate raster objects
rm(C4_masks, GS_masks, C4_ratio, pft_cover)v



