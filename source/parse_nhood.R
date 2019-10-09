# purpose
# This script takes a single shapefile with 88 features and saves each feature 
# as an individual .geojson file to support community mapping efforts.

# dependencies
library(dplyr)     # data wrangling
library(gateway)   # st. louis data
library(here)      # file path management
library(purrr)     # iteration
library(sf)        # spatial tools
library(stringr)   # string manipulation

# prepare data
## download neighborhood boundaries
nhood <- gw_get_data(data = "Neighborhoods", class = "sf")

## re-project to WGS 1984
nhood <- st_transform(nhood, crs = 4326)

## remove columns
nhood <- select(nhood, NHD_NUM, NHD_NAME)

## store vector of neighborhood IDs
ids <- nhood$NHD_NUM

# define function for subsetting and writing single neighborhood files
parse_nhood <- function(.data, id){
  
  # subset to identified neighborhood
  working <- filter(.data, NHD_NUM == id)
  
  # create filename
  filename <- str_replace_all(working$NHD_NAME[1], pattern = "[\\s-/]", replacement = "_")
  filename <- paste0(filename, ".geojson")
  
  # write to data
  st_write(working, dsn = here("data", filename), driver = "GeoJSON", delete_dsn = TRUE)
  
}

# save all neighborhoods individually by iterating over the vector of id numbers,
# passing ids individually to the function that was defined above
ids %>%
  unlist() %>%
  map(~ parse_nhood(nhood, id = .x))
