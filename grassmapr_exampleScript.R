# grassmapr: Example Script to Generate North America isoscape

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
C4_masks <- mask_climate(temp.stack = temp_NA,
  temp.threshold = C4_temp,
  precip.stack = prec_NA,
  precip.threshold = GS_prec)

# Generate monthly Growing Season (GS) climate masks
GS_masks <- mask_climate(temp.stack = temp_NA,
  temp.threshold = GS_temp,
  precip.stack = prec_NA,
  precip.threshold = GS_prec)


# Optional - count number of months that satisfy each climate criteria
GS_month_total <- count_months(GS_masks)
C4_month_total <- count_months(C4_masks)

# Plot C4 month total, GS month total
par(mfrow = c(1,2))
plot(C4_month_total)
plot(GS_month_total)

# Calculate C4 herbaceous proportion based on C4 climate only
C4_ratio <- calc_C4_ratio(C4_masks, GS_masks)

# Plot C4 herbaceous proportion [i.e., predicted C4 ratio of grasses, based on climate]
par(mfrow = c(1,1))
plot(C4_ratio)

# [Optionally] - Load monthly NDVI layers
data(ndvi_NA)

# Calculate C4 ratio based on C4 climate AND vegetation productivity
C4_ratio_vi <- calc_C4_ratio(C4_masks, GS_masks, veg.index = ndvi_NA)

# Compare two predictions of C4 ratio
par(mfrow = c(1,2))
plot(C4_ratio)
plot(C4_ratio_vi)

# Load non-grass vegetation layers
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
pft_cover <- calc_pft_cover(C4.ratio = C4_ratio,
                            GS.mask = GS_masks,
                            veg.layers = veg_layers,
                            C4.flag = C4_flag,
                            herb.flag = herb_flag)

# Plote PFT cover layers (%C4 herbaceous, %C3 herbaceous, %woody)
plot(pft_cover)

# d13C endmember vector for PFT layers from the literature
d13C_emb <- c(-12.5, -26.7, -27.0) # C4 herb, C3 herb, Woody

# Apply mixing model to generate d13C isoscape
d13C_iso <- calc_del13C(pft_cover, d13C_emb)

# Standard deviations of d13C endmember means from the literature
d13C_std <- c(1.1, 2.3, 1.7) # C4 herb, C3 herb, Woody

# Calculate weighted standard deviation of mean d13C values
d13C_iso_std <- calc_del13C(pft_cover, d13C_std)

# Plot d13C isoscape and standard deviation layers
par(mfrow = c(1, 2))
plot(d13C_iso, main = "Mean Vegetation d13C \n(per mil)",
  xlab = "longitude", ylab = "latitude",
  zlim = c(-27, -12))
plot(d13C_iso_std, main = "Std. Dev. d13C \n(per mil)",
  xlab = "longitude", ylab = "latitude",
  zlim = c(1.0, 2.4))

# Remove intermediate raster objects
rm(woody_NA, cropC3_NA, cropC4_NA)
rm(C4_ratio, C4_ratio_vi, veg_layers, pft_cover)



