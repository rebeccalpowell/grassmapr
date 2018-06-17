# grassmapr: Example Script - COlorado

# Load climate data
data(COMeanTmp) # mean monthly temperature (deg. C)
data(COMeanPre) # mean monthly precipitation (mm)

# Growing season precipitation mask (>= 25 mm)
precip_mask <- maskClimateVals(COMeanPre, 25)
# Growing season temperature mask (>= 5 deg. C)
GS_temp_mask <- maskClimateVals(COMeanTmp, 5)
# C4 temperature mask (>= 22 deg. C)
C4_temp_mask <- maskClimateVals(COMeanTmp, 22)

# Generate Growing Season (GS) climate masks
GS_mask <- combineMasks(GS_temp_mask, precip_mask)
# Generate C4 climate masks
C4_mask <- combineMasks(C4_temp_mask, precip_mask)

# Optional - count number of months that satisfy each climate criteria
GS_month_total <- countMonths(GS_mask)
C4_month_total <- countMonths(C4_mask)

# Remove intermediate raster objects
rm(COMeanPre, COMeanTmp)
rm(precip_mask, C4_temp_mask, GS_temp_mask)

# Load monthly NDVI layers
data(COMonthlyNDVI)

# Calculate C4 ratio based on C4 climate only
C4_ratio <- calcC4Ratio(C4_mask, GS_mask)

#OR Calculate C4 ratio based on C4 climate AND vegetation productivity
C4_ratio_vi <- calcC4Ratio(C4_mask, GS_mask, veg.index = COMonthlyNDVI)

# Remove intermediate raster objects
rm(GS_mask, C4_mask, COMonthlyNDVI)

# Load non-grass vegetation layers
data(COWoody)
data(COC3Crop)
data(COC4Crop)

# Downsample C4_ratio to match finer resolution of vegetation layers
C4_ratio_rs <- resample(x = C4_ratio, y = COWoody, method = "ngb")

# Create raster stack of other (non-grassy) vegetation layers
veg_layers <- stack(COC4Crop, COC3Crop, COWoody)

#Indicate layers that correspond to C4 vegetation
C4_flag <- c(1, 0, 0)

# Indicate layers that correspond to herbaceous vegetation
herb_flag <- c(1, 1, 0)

# Generate PFT vegetation cover brick
pft_cover <- calcPFTCover(C4_ratio_rs, veg_layers, C4_flag, herb_flag)

# d13C endmember vector for PFT layers from the literature
d13C_emb <- c(-12.5, -26.7, -27.0) # C4 herb, C3 herb, Woody

# Apply mixing model to generate d13C isoscape
d13C_iso <- calcDel13C(pft_cover, d13C_emb)

# Standard deviations of d13C endmember means from the literature
d13C_std <- c(1.1, 2.3, 1.7) # C4 herb, C3 herb, Woody

# Calculate weighted standard deviation of mean d13C values
d13C_iso_std <- calcDel13C(pft_cover, d13C_std)

# Plot d13C isoscape and standard deviation layers
par(mfrow = c(1,2))
plot(d13C_iso, main = "Mean Vegetation d13C \n(per mil)",
  xlab = "longitude", ylab = "latitude")
plot(d13C_iso_std, main = "Std. Dev. d13C \n(per mil)",
  xlab = "longitude", ylab = "latitude")

# Remove intermediate raster objects
rm(COWoody, COC3Crop, COC4Crop)
rm(C4_ratio, C4_ratio_rs, veg_layers, pft_cover)



