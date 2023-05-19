library(sf)
library(dplyr)
library(terra)
library(tmap)
tmap_options(check.and.fix = TRUE)
#library(minio)
#mc_alias_set("nvme", "", "", endpoint="minio.carlboettiger.info")
#mc("ls nvme/biodiversity")


Sys.setenv("AWS_S3_ENDPOINT"="minio.carlboettiger.info")
Sys.setenv("AWS_VIRTUAL_HOSTING"="FALSE")
Sys.setenv("AWS_NO_SIGN_REQUEST"="YES") # anonymous, or provide keys

india <- spData::world |> filter(name_long == "India")

sf_use_s2(FALSE) 
PAs <- sf::read_sf("/vsis3/biodiversity/World-Protected-Areas-May2023.gdb")
PAs |> st_crop(india) |> plot()

#Ecoregions2017.zip

ex <- sf::read_sf("/vsizip//vsis3/biodiversity/Ecoregions2017.zip")
tm_shape(ex) + tm_polygons("BIOME_NAME")


plot(ex, "BIOME_NAME")

base <- "https://minio.carlboettiger.info/biodiversity/"
pa_gdb <- paste0("/vsis3/",base, "World-Protected-Areas-May2023.gdb")
sf::st_layers(pa_gdb)
PAs <- sf::st_read(pa_gdb)

# Carbon Layers
# https://doi.org/10.5281/zenodo.4091028
# test <- sf::st_read("BOTW.fgb")
sf::st_write(test, "BOTW.parquet", driver="Parquet")

layers <- sf::st_layers("/vsicurl/https://minio.carlboettiger.info/iucn/birds/BOTW.gdb")

# data.frame: 11,188 species
taxa <- sf::st_read("/vsicurl/https://minio.carlboettiger.info/iucn/birds/BOTW.gdb", "Taxonomic_checklist")
taxa |> count(RL_Category)

birds <- sf::st_read("/vsicurl/https://minio.carlboettiger.info/iucn/birds/BOTW.gdb", "All_Species")
birds
birds |> st_write("BOTW.parquet", driver="Parquet")
birds |> filter(RL_Category)
loc <- spData::world |> dplyr::filter(name_long == "Sri Lanka")

birds |> st_crop(loc) |> st_write("BOTW.parquet", driver="Parquet")
