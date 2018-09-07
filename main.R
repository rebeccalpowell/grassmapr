# grassmapr: Example Script - North America

# Load North America climate data
data(temp_NA) # mean monthly temperature (deg. C)
data(precip_NA) # mean monthly precipitation (mm)

# Set a C4 temperature threshold based on the COT model (>= 22 deg. C)
C4_temp <- 22
# Set a growing season temperature threshold (>= 5 deg. C)
GS_temp <- 5
# Set a precipitation threshold (>= 25 mm)
min_prec <- 25

# Generate Growing Season (GS) climate masks
GS_masks <- combineMasks(GS_temp_mask, precip_mask)
# Generate C4 climate masks
C4_masks <- combineMasks(C4_temp_mask, precip_mask)

# Generate Growing Season (GS) climate masks
GS_masks <- mask_climate(temp.stack = temp_NA,
  temp.threshold = GS_temp,
  precip.stack = precip_NA,
  precip.threshold = min_prec)

# Generate C4 climate masks
C4_masks <- mask_climate(temp.stack = temp_NA,
  temp.threshold = C4_temp,
  precip.stack = precip_NA,
  precip.threshold = min_prec)

# Optional - count number of months that satisfy each climate criteria
GS_month_total <- countMonths(GS_masks)
C4_month_total <- countMonths(C4_masks)

# Remove intermediate raster objects
rm(precip_NA, temp_NA)

# Load monthly NDVI layers
data(ndvi_NA)

# Calculate C4 ratio based on C4 climate only
C4_ratio <- calc_C4_ratio(C4_masks, GS_masks)

#OR Calculate C4 ratio based on C4 climate AND vegetation productivity
C4_ratio_vi <- calc_C4_ratio(C4_masks, GS_masks, veg.index = ndvi_NA)

# Remove intermediate raster objects
rm(GS_masks, C4_masks, ndvi_NA)

# Load non-grass vegetation layers
data(woody_NA)
data(cropC3_NA)
data(cropC4_NA)

# Create raster stack of other (non-grassy) vegetation layers
veg_layers <- stack(woody_NA, cropC3_NA, cropC4_NA)

#Indicate layers that correspond to C4 vegetation
C4_flag <- c(0, 0, 1)

# Indicate layers that correspond to herbaceous vegetation
herb_flag <- c(0, 1, 1)

# Generate PFT vegetation cover brick (C4 grass, C3 grass, woody)
pft_cover <- calc_pft_cover(C4.ratio = C4_ratio,
                            GS.mask = GS_masks,
                            veg.layers = veg_layers,
                            C4.flag = C4_flag,
                            herb.flag = herb_flag)

# d13C endmember vector for PFT layers from the literature
d13C_emb <- c(-12.5, -26.7, -27.0) # C4 herb, C3 herb, Woody

# Apply mixing model to generate d13C isoscape
d13C_iso <- calc_del13C(pft_cover, d13C_emb)

# Standard deviations of d13C endmember means from the literature
d13C_std <- c(1.1, 2.3, 1.7) # C4 herb, C3 herb, Woody

# Calculate weighted standard deviation of mean d13C values
d13C_iso_std <- calc_del13C(pft_cover, d13C_std)

# Plot d13C isoscape and standard deviation layers
par(mfrow = c(1,2))
plot(d13C_iso, main = "Mean Vegetation d13C \n(per mil)",
  xlab = "longitude", ylab = "latitude")
plot(d13C_iso_std, main = "Std. Dev. d13C \n(per mil)",
  xlab = "longitude", ylab = "latitude")

# Remove intermediate raster objects
rm(woody_NA, cropC3_NA, cropC4_NA)
rm(C4_ratio, C4_ratio_vi, veg_layers, pft_cover)



