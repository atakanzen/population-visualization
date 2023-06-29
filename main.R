library(sf)
library(tidyverse)
library(stars)
library(MetBrewer)
library(colorspace)
library(rayshader)



poland <- st_read("data/kontur_population_PL_20220630.gpkg")

bb <- st_bbox(poland)

bottom_left <- st_point(c(bb[['xmin']], bb[['ymin']])) |>
  st_sfc(crs = st_crs(poland))

bottom_right <- st_point(c(bb[['xmax']], bb[['ymin']])) |>
  st_sfc(crs = st_crs(poland))

# Plot Poland, bottom left and bottom right points

poland |>
  ggplot() +
  geom_sf() +
  geom_sf(data = bottom_left) +
  geom_sf(data = bottom_right)


# Calculate width and height for aspect ratio

width <- st_distance(bottom_left, bottom_right)

top_left <- st_point(c(bb[['xmin']], bb[['ymax']])) |>
  st_sfc(crs = st_crs(poland))

height <- st_distance(bottom_left, top_left)

# Setting aspect ratio

if (width > height) {
  w_ratio <- 1
  h_ratio <- height / width
} else {
  h_ratio <- 1
  w_ratio <- width / height
}


# Converting to raster for next step conversion to matrix


size <- 2000

poland_rast <- st_rasterize(poland, 
                            nx = floor(size * w_ratio),
                            ny = floor(size * h_ratio))

# Matrix

mat <- matrix(poland_rast$population,
              nrow = floor(size * w_ratio),
              ncol = floor(size * h_ratio))

# color palette

c1 <- met.brewer('Greek', direction = -1)
swatchplot(c1)


texture <- grDevices::colorRampPalette(c1, bias = 1)(256)
swatchplot(texture)

# 3D Plot

rgl::close3d()


mat |> 
  height_shade(texture = texture) |> 
  plot_3d(heightmap = mat, 
          windowsize = 800,
          zscale = 100 / 3, 
          solid = FALSE,
          shadowdepth = 0,
          theta = 0,
          phi = 25,
          zoom = 0.66,
          background = "#FFE9B4")


render_camera(theta = -2, phi = 25, zoom = .63)

outfile <- "images/final_plot.png"

{
  start_time <- Sys.time()
  cat(crayon::cyan(start_time), "\n")
  if (!file.exists(outfile)) {
    png::writePNG(matrix(1), target = outfile)
  }
  render_highquality(
    filename = outfile,
    interactive = FALSE,
    lightdirection = 280,
    lightaltitude = c(20, 80),
    lightcolor = c(c1[2], "white"),
    lightintensity = c(600, 100),
    samples = 450,
    width = 6000,
    height = 6000
  )
  end_time <- Sys.time()
  diff <- end_time - start_time
  cat(crayon::cyan(diff), "\n")
}


