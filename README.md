
<!-- README.md is generated from README.Rmd. Please edit that file -->
grassmapr
=========

The `grassmapr` package has two related objectives: (i) to predict the spatial distribution of terrestrial C<sub>3</sub> and C<sub>4</sub> grass cover – using input climate layers and crossover temperature – and (ii) to model plant stable carbon (*δ*<sup>13</sup>C) *isoscapes* by applying isotopic endmembers to plant functional type cover layers. The user may optionally include other (i.e., non-grass) vegetation layers (e.g., % woody cover, % crop, etc.).

Background
----------

The primary driver of *δ*<sup>13</sup>C spatial variation in terrestrial plant tissue is the greater isotopic fractionation in C<sub>3</sub> plants compared to C<sub>4</sub> plants. The physiologically based crossover temperature model explains the turnover from C<sub>3</sub> to C<sub>4</sub> plants along gradients of temperature (Ehleringer et al. 1997, Collatz et al. 1998, Still et al. 2003).

The `grassmapr` package combines the crossover temperature model with gridded climate and land-cover data to predict the relative abundance of C<sub>3</sub> and C<sub>4</sub> vegetation distribution. Isotopic endmember values are then applied to map plant *δ*<sup>13</sup>C, resulting in a spatially continuous representation, or isoscape. These layers are useful for understanding grass biogeography (e.g., Powell et al. 2012, Griffith et al. 2015) and for studies seeking to identify the movement of animals (e.g., Hobson 1999, Bowen & West 2008).

Note that *δ*<sup>13</sup>C also varies with photosynthetic subtype in C<sub>4</sub> plants and with rainfall and water availability in woody C<sub>3</sub> plants (Cerling & Harris 1999, Diefendorf et al. 2010, Kohn 2010). Currently, `grassmapr` functions neglect these secondary sources of spatial variation.

Installation
------------

The `grassmapr` package is hosted on GitHub. You can install the latest released version using `devtools`<sup>1</sup>:

``` r
install.packages("devtools")
devtools::install_github(repo = "rebeccalpowell/grassmapr")
```

Example usage
-------------

For a detailed guide to using `grassmapr`, see the vignette included with package installation. For a commented script, see `grassmapr_exampleScript.R` and/or `grassmapr_exampleScript_tofile.R` in the main-level folder.

Data included in these examples are installed with the `grassmapr` package.

License
-------

The `grassmapr` package is free and open source software; you may redistribute and/or modify it under the terms of the GNU General Public License, version 3, as published by the Free Software Foundation.

This package is distributed without any warranty, without even the implied warranty of merchantability or fitness for a particular purpose. See the GNU General Public License for more details.

A copy of the GNU General Public License, version 3, is available at <https://www.r-project.org/Licenses/GPL-3>

Citation
--------

To cite package `grassmapr` in publications, use:

Powell, R. L. et al. 2019. grassmapr, an R package to predict C<sub>3</sub>/C<sub>4</sub> grass distributions and model terrestrial *δ*<sup>13</sup>C isoscapes. – Ecography *in review*.

References
----------

Bowen, G. J. and West, J. B. 2008. Isotope landscapes for terrestrial migration research. – In: Hobson, K. A. and Wassenaar, L. I. (eds.), Tracking Animal Migration with Stable Isotopes. Academic, pp. 79-105.

Cerling, T. E. and Harris, J. M. 1999. Carbon isotope fractionation between diet and bioapatite in ungulate mammals and implications for ecological and paleoecological studies. – Oecologia 120: 347-363.

Collatz, G. J. et al. 1998. Effects of climate and atmospheric CO<sub>2</sub> partial pressure on the global distribution of C<sub>4</sub> grasses: present, past, and future. – Oecologia 114: 441-454.

Diefendorf, A. F. et al. 2010. Global patterns in leaf *δ*<sup>13</sup>C discrimination and implications for studies of past and future climate. – Proc. Natl. Acad. Sci. 107: 5738–43.

Ehleringer, J. R. et al. 1997. C<sub>4</sub> photosynthesis, atmospheric CO<sub>2</sub>, and climate. – Oecologia 112: 285-299.

Griffith, D. M. et al. 2015. Biogeographically distinct controls on C<sub>3</sub> and C<sub>4</sub> grass distributions: merging community and physiological ecology. – Global Ecol. Biogeogr. 24: 304-313.

Hobson, K. A. 1999. Tracing origins and migration of wildlife using stable isotopes: a review. – Oecologia 120: 314-326.

Kohn, Matthew J. 2010. Carbon isotope compositions of terrestrial C<sub>3</sub> plants as indicators of (paleo) ecology and (paleo) climate. – Proc. Natl. Acad. Sci. 107: 19691–19695.

Powell, R. L. et al. 2012. Vegetation and soil carbon-13 isoscapes for South America: integrating remote sensing and ecosystem isotope measurements. – Ecosphere 3: 109.

Still, C. J. et al. 2003. Global distribution of C<sub>3</sub> and C<sub>4</sub> vegetation: carbon cycle implications. – Global Biogeochem. Cycles 17: 1006.

------------------------------------------------------------------------

<sup>1</sup> Package `devtools` is available from GitHub: <https://github.com/r-lib/devtools>, or from CRAN: <https://cran.r-project.org/web/packages/devtools/index.html>
