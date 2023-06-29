library(magick)
library(MetBrewer)
library(colorspace)
library(ggplot2)
library(glue)
library(stringr)

img <- image_read("images/final_plot.png")

colors <- met.brewer("Greek")
swatchplot(colors)

text_color <- darken(colors[2], .25)
swatchplot(text_color)

annot <- glue("This map shows population density of Poland. ",
              "Population estimates are bucketed into 400 meter ",
              "hexagons.") |>
  str_wrap(45)

img |> 
  image_crop(gravity = "center",
             geometry = "6000x3500+0-150") |> 
  image_annotate("Poland Population Density",
                 gravity = "northwest",
                 location = "+200+100",
                 color = text_color,
                 size = 200,
                 weight = 700,
                 font = "Berkeley Mono") |> 
  image_annotate(annot,
                 gravity = "northeast",
                 location = "+200+100",
                 color = text_color,
                 size = 75,
                 font = "Berkeley Mono") |> 
  image_annotate(glue("Graphic by Atakan Zengin (atakanzen.com) | ",
                      "Data: Kontur Population (Released 2022-06-30)"),
                 gravity = "south",
                 location = "+0+100",
                 font = "Berkeley Mono",
                 color = alpha(text_color, .5),
                 size = 70) |> 
  image_write("images/titled_final_plot.png")
