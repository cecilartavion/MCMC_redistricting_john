library(sf)
library(sp)
library(raster)
library(rgeos)
library(rgdal)
library(maptools)
library(spdep)
library(plyr)
library(rlist)

#Set working directory
setwd("$PATH")

#Read in precinct shapefile. dsn will choose the folder where all of the files live.
precinct_2016 <- readOGR(dsn="VTD2016-Shape",layer="VTD2016-Shape_step_1")

#Read in congressional districts shapefile. 
cong_2012 <- readOGR(dsn="georgia_congressional_dist_2012",layer="CONGPROP2")

#Generate the intersection of the precincts and the congressional districts
prec_w_dist <- intersect(precinct_2016,cong_2012)

#Write file to shapefile
writeOGR(obj = prec_w_dist, dsn="VTD2016-Shape", layer = "VTD2016-Shape_step_2", driver = "ESRI Shapefile")

