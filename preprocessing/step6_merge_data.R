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

#Read in shapefile for precincts
precinct_2016_near_final <- readOGR(dsn="georgia_precincts_2016",layer="VTD2016-Shape_step_5")
# precinct_2016_near_final <- readOGR(dsn="VTD2016-Shape",layer="VTD2016-Shape_step_5")
#Read in csv for the list of lists for precincts
dat = read.csv("georgia_precincts_2016/VTD2016-Shape_step_5_1.csv", header = TRUE)
# dat = read.csv("VTD2016-Shape/VTD2016-Shape_step_5_1.csv", header = TRUE)
dat <- dat[2:4]
dat <- as(dat,"data.frame")
#Set new shapefile to which we will merge the data from the csv.
precinct_2016_near_final@data <- data.frame(precinct_2016_near_final@data,dat[match(precinct_2016_near_final@data[,"ID_3"],dat[,"ID_3"]),])


#Set the projection.
precinct_2016_near_final_3 <- precinct_2016_near_final
# precinct_2016_near_final_3 <- spTransform(precinct_2016_near_final_2,CRS("+proj=longlat +ellps=GRS80 +no_defs"))

#Delte some unnecessary columns.
drops <- c('COUNTY_NAM', 'PRECINCT_I', 'PRECINCT_N','ID_3.1')
precinct_2016_near_final_3 <- precinct_2016_near_final_3[,!(names(precinct_2016_near_final_3) %in% drops)]

names(precinct_2016_near_final_3)[names(precinct_2016_near_final_3) == 'VAPPOP3'] <- 'VAPPOP'
names(precinct_2016_near_final_3)[names(precinct_2016_near_final_3) == 'INDEX_1'] <- 'IDX'

#Find the neighborhood of each vertex in the precinct file. Create new neighborhoods for this 
#shapefile. This will help build the neighbor hood column for the final shapefile.
nbs <- poly2nb(as(precinct_2016_near_final_3, "SpatialPolygons"), queen = FALSE)
#Create a matrix where each row and column is a precinct in the shapefile. 
#There is a 1 if they are adjacent and 0 otherwise.
mat <- nb2mat(nbs, style="B")
colnames(mat) <- rownames(mat)

#This is the final check for holes. If there are any holes, handle them on a case-by-case basis.
poly_index_for_holes_2 <- which(rowSums(mat)==1)
#Create a list of the indices that will be removes since they are on the border of the state.
remove <- c(poly_index_for_holes_2[which(precinct_2016_near_final_3[poly_index_for_holes_2[],]$ST_BORDER==1)]) 
# precinct_2016_no_multiparts_2[remove[2],]$ID_3
# plot(precinct_2016_no_multiparts[remove,])
# We remove all of the indices of the "holes" that are actually precincts on the border of the state.
poly_index_for_holes_2 <- poly_index_for_holes_2[! poly_index_for_holes_2 %in% remove]
poly_index_for_holes_2

#Write the final precinct file with all of the necessary information.
writeOGR(obj = precinct_2016_near_final_3, dsn="georgia_precincts_2016", layer = "VTD2016-Shape_final", driver = "ESRI Shapefile")

write.csv(precinct_2016_near_final_3@data, file = 'georgia_precincts_2016\\VTD2016-Shape_final_dataframe.csv', row.names = FALSE)


