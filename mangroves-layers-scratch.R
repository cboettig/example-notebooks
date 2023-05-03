library(tidyverse)
library(tmap)
library(terra)
library(sf)
library(stars)
library(fasterize)
library(spData)

india <- spData::world |> filter(name_long == "India")
box <- st_bbox(india)

kba_url <- "https://minio.carlboettiger.info/iucn/KBAsGlobal_2023_March_01_Criteria_TriggerSpecies.zip"
kba_path <- "/KBAsGlobal_2023_March_01_Criteria_TriggerSpecies/KBAsGlobal_2023_March_01_POL.shp"
vsi <- paste0("/vsizip//vsicurl/", kba_url, kba_path)

vect(vsi) |> crop(vect(india)) |> terra::writeVector("kba.json", overwrite=TRUE)

minio::mc("cp gbif_richness.tif nvme/biodiversity/gbif_richness.tif")

minio::mc("cp kba.json nvme/biodiversity/india_kba.json")

minio::mc("cp srilanka_kba.json nvme/biodiversity/srilanka_kba.json")
minio::mc("cp srilanka_mangroves2015.json nvme/biodiversity/srilanka_mangroves2015.json")


minio::mc("cp -r gbif_richness nvme/biodiversity/")



files <- paste0("GMW_v3_", c(2015:2017, 2019,2020))

to_cog <- function(f, url="https://datadownload-production.s3.amazonaws.com/") {
  vector <- sf::read_sf(glue::glue("/vsizip//vsicurl/{url}", f, ".zip"))

  # really should consider cropping this to India and then maybe doing higher res
  # stars is much slower, but may get better RAM use
  # st_grid <- st_as_stars(st_bbox(vector), nx = 100, ny = 50, values = NA_real_)
  # st_mammals_raster <- stars::st_rasterize(vector,  st_grid, fun="sum")

  # fasterize uses old raster template, but is *much* faster
  grid <- raster::raster(resolution = 0.01, crs="epsg:4326") # 0.5 deg grid in lat-long
  fast_raster <- fasterize::fasterize(vector, grid, fun="sum")
  terra::rast(fast_raster) |>
    terra::writeRaster(paste0(f, ".tif"), overwrite=TRUE)
}

purrr::map(files, to_cog)


# to_cog("MAMMALS", url="https://minio.carlboettiger.info/iucn/")
# to_cog("REPTILES", url="https://minio.carlboettiger.info/iucn/")
# to_cog("amphibians", url="https://minio.carlboettiger.info/iucn/")

cmd <- paste("cp", fs::dir_ls(".", glob="GMW*.tif"), "nvme/biodiversity/")
map(cmd, minio::mc)





mammals <- rast("/vsicurl/https://minio.carlboettiger.info/biodiversity/MAMMALS.tif")
plot(mammals)


mammals_vec <- vect("/vsizip//vsicurl/https://minio.carlboettiger.info/iucn/MAMMALS.zip")
plot(mammals)

reptiles <- rast("https://minio.carlboettiger.info/biodiversity/REPTILES.tif")
plot(reptiles)

reef_fish <- read_sf("/vsizip//vsicurl/https://minio.carlboettiger.info/iucn/WRASSES_PARROTFISHES.zip")

amphibians <- rast("https://minio.carlboettiger.info/biodiversity/amphibians.tif")
plot(amphibians)

library(sf)
library(stars)

"https://minio.carlboettiger.info/biodiversity/GMW_v3_2015.tif"
"https://minio.carlboettiger.info/biodiversity/GMW_v3_2015.zip"

kba_url <- "https://minio.carlboettiger.info/iucn/KBAsGlobal_2023_March_01_Criteria_TriggerSpecies.zip"
kba_path <- "/KBAsGlobal_2023_March_01_Criteria_TriggerSpecies/KBAsGlobal_2023_March_01_POL.shp"
#download.file(kba_url, basename(kba_url))
#zip::unzip(basename(kba_url))


kbas <- sf::read_sf(paste0("/vsizip//vsicurl/", kba_url, kba_path))

