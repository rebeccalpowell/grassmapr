# grassmapr test script

data("COMeanTmp")
data("COMeanPre")

precip_mask <- maskClimateValues(COMeanPre, 25)
C4_temp_mask <- maskClimateValues(COMeanTmp, 22)
GS_temp_mask <- maskClimateValues(COMeanTmp, 5)

plot(precip_mask)
plot(C4_temp_mask)
plot(GS_temp_mask)

GS_mask <- combineMasks(GS_temp_mask, precip_mask)
C4_mask <- combineMasks(C4_temp_mask, precip_mask)

# Optional - count number of months that satisfy each climate criteria
GS_month_total <- countMonths(GS_mask)
C4_month_total <- countMonths(C4_mask)

rm(COMeanPre, COMeanTmp)
rm(precip_mask, C4_temp_mask, GS_temp_mask)

data("COMonthlyNDVI")

# C4 ratio based on C4 climate only
C4_ratio <- calcC4Ratio(C4_mask, GS_mask)
#OR C4 ratio based on C4 climate AND vegetation productivity
C4_ratio_vi <- calcC4Ratio(C4_mask, GS_mask, veg.index = COMonthlyNDVI)

rm(GS_mask, C4_mask, COMonthlyNDVI)

data("COHerb")
data("COWoody")
data("COC3Crop")
data("COC4Crop")

# Resample (downsample) C4_ratio to match finer resolution of vegetation layers
C4_ratio_rs <- resample(x = C4_ratio, y = COHerb, method = "ngb")

# Create raster stack of 'other' vegetation layers (non-grassy-world)
veg_layers <- stack(COC4Crop, COC3Crop, COWoody)
C4_flag <- c(1, 0, 0)
herb_flag <- c(1, 1, 0)


pft_cover <- calcPFTCover(C4_ratio_rs, veg_layers, C4_flag, herb_flag,
  scale = 100)


d13C <- c(-12.5, -26.7, -27.0)
d13C_iso <- calcDel13C(pft_cover, d13C, scale = 100)

### need one more function for error term ###
