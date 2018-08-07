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

#Function that will tell us TRUE if there are no FALSE besides the first element
# and will tell us FALSE if there are more than two FALSE.
more_than_one_false <- function(x){
  if (length(unlist(x))==1){
    return(FALSE)
  }
  test_vec <- x[-1]
  return(all(test_vec))
}

precinct_2016_no_multiparts_2 <- readOGR(dsn="georgia_precincts_2016",layer="VTD2016-Shape_step_3")
# precinct_2016_no_multiparts_2 <- readOGR(dsn="VTD2016-Shape",layer="VTD2016-Shape_step_3")
precinct_2016_no_multiparts_2.df <- as(precinct_2016_no_multiparts_2,"data.frame")

#Find the neighborhood of each vertex in the precinct file. Create new neighborhoods for this 
#shapefile. This will help build the neighbor hood column for the final shapefile.
nbs_2 <- poly2nb(as(precinct_2016_no_multiparts_2, "SpatialPolygons"), queen = FALSE)
#Create a matrix where each row and column is a precinct in the shapefile. 
#There is a 1 if they are adjacent and 0 otherwise.
mat_2 <- nb2mat(nbs_2, style="B")
colnames(mat_2) <- rownames(mat_2)

#The indices that have exactly one neighbor and are not on the border of the state are holes.
#This next command finds all of the indices of such holes. If there are holes that have a
# larger neighborhood, we will have to identify them by hand and handle them individually
# at the end of this procedure. We must run a final check for such situations.
poly_index_for_holes_2 <- which(rowSums(mat_2)==1)
#Create a list of the indices that will be removes since they are on the border of the state.
remove <- c(poly_index_for_holes_2[which(precinct_2016_no_multiparts_2[poly_index_for_holes_2[],]$ST_BORDER==1)]) 
# We remove all of the indices of the "holes" that are actually precincts on the border of the state.
poly_index_for_holes_2 <- poly_index_for_holes_2[! poly_index_for_holes_2 %in% remove]

#Merging holes with corresponding neighbors of holes 
#First create a temporary data frame of the main shapefile.
temp_df <- precinct_2016_no_multiparts_2.df
#Turning the following columns into numerics will allow the following columns to be combined
# when we aggregate the data. 
# temp_df$ID <- as.numeric(as.character( temp_df$ID )) #Turn Area column into numeric
temp_df$VAPPOP3 <- as.numeric(as.character( temp_df$VAPPOP3 )) #Turn VAP column into numeric
temp_df$TOTALPOP <- as.numeric(as.character( temp_df$TOTALPOP )) #Turn Population column into numeric
temp_df$RACEPOP <- as.numeric(as.character( temp_df$RACEPOP )) #Turn Race Population column into numeric
temp_df$REPUB_VOTE <- as.numeric(as.character( temp_df$REPUB_VOTE )) #Turn Votes for Republican candidate column into numeric
temp_df$DEM_VOTE <- as.numeric(as.character( temp_df$DEM_VOTE )) #Turn Votes for Democratic Candidate column into numeric
temp_df$LIB_VOTE <- as.numeric(as.character( temp_df$LIB_VOTE )) #Turn Votes for Libertarian Candidate column into numeric
#Now we create the temporary shapefile from the main shapefile.
temp_df.union <- precinct_2016_no_multiparts_2
temp_polys_nums_with_holes_2 <- poly_index_for_holes_2

#For each of the precincts that contains a hole, merge the hole with the precinct that contains the hole.
while (length(temp_polys_nums_with_holes_2) > 0){
  #Find the neighborhood of each precinct in the current main shapefile.
  nbs_temp <- poly2nb(as(temp_df.union, "SpatialPolygons"), queen = FALSE)
  #Create the matrix where a 1 in row x and column says that precinct x is adjacent to precinct y.
  mat_temp <- nb2mat(nbs_temp, style="B")
  #Create set of indices for the precincts that are the holes of some precinct.
  poly_index_for_holes_temp <- which(rowSums(mat_temp)==1)
  #Remove precinctson the border of the state.
  remove <- c(poly_index_for_holes_temp[which(temp_df.union[poly_index_for_holes_temp[],]$ST_BORDER==1)]) 
  if (length(remove)>0){
    poly_index_for_holes_temp = poly_index_for_holes_temp[! poly_index_for_holes_temp %in% remove]
  }
  if (length(poly_index_for_holes_temp)==0){
    print("Finished removing holes!")
    break
  }
  #We create the index set for the precincts that have holes. 
  neighbors_of_holes_temp <- which(mat_temp[poly_index_for_holes_temp[1],]==1)
  #We set the ID for the precinct in the hole to be the same as the ID for the precinct that has the hole. 
  temp_df$ID_3[poly_index_for_holes_temp[1]] <- temp_df$ID_3[neighbors_of_holes_temp]
  # merge_column indicates which rows are going to be merged. 
  merge_column <- seq(1,dim(temp_df)[1],1)
  merge_column[neighbors_of_holes_temp] <- poly_index_for_holes_temp[1]
  # temp_df.id gives the intervals for which each of the entries in the data frame belong.
  # This will help determine which precincts to merge in the next command.
  temp_df.id <- cut(merge_column, breaks = 0:max(merge_column))
  #The shapefile with the first precinct index in poly_index_holes_temp and its corresponding hole merged.
  temp_df.union_2 <- unionSpatialPolygons(temp_df.union,temp_df.id)
  
  #Aggregate the data together by summing the area and population together while not changing the ID.
  temp_df.agg <- aggregate(temp_df[,c("VAPPOP3","TOTALPOP","RACEPOP","REPUB_VOTE","DEM_VOTE","LIB_VOTE")], list(temp_df.id,temp_df$ID_3), sum)
  #Change the column names.
  colnames(temp_df.agg) <- c("Group.1","ID_3","VAPPOP3","TOTALPOP","RACEPOP","REPUB_VOTE","DEM_VOTE","LIB_VOTE")
  #Change the row names.
  row.names(temp_df.agg) <- temp_df.agg$Group.1
  #Create the full shapefile for the new precincts with one of the holes merged with its corresponding precinct
  # with a hole.
  temp_df.shp.agg <- SpatialPolygonsDataFrame(temp_df.union_2,data.frame(temp_df.agg)) 
  
  #############################
  #############################
  #############################
  #Is is possible that we can turn a precinct on the border to a 0?
  #############################
  #############################
  #############################
  #Make temperary data frame so that we can merge the remaining columns together with the corresponding data. 
  smaller_temp_df <- temp_df[-(poly_index_for_holes_temp[1]),]
  temp_sub_df <- smaller_temp_df[,c('DISTRICT','ST_BORDER','ID_3','PRECINCT_I','PRECINCT_N','COUNTY','COUNTY_NAM')]
  # if (temp_df[neighbors_of_holes_temp,'ST_BORDER']==1 || temp_df[poly_index_for_holes_temp[1],'ST_BORDER']==1){
  #   temp_sub_df[poly_index_for_holes_temp[1],'ST_BORDER'] = 1
  # }
  #Join the missing columns with the new main shapefile.
  temp_df.shp.agg@data <- data.frame(temp_df.shp.agg@data,temp_sub_df[match(temp_df.shp.agg@data[,"ID_3"],temp_sub_df[,"ID_3"]),])
  
  #Reform new dataframe so that the columns are in the correct order.
  temp_df.shp.agg <- temp_df.shp.agg[,c('VAPPOP3','TOTALPOP','RACEPOP','REPUB_VOTE','DEM_VOTE','LIB_VOTE','DISTRICT','ST_BORDER','ID_3','PRECINCT_I','PRECINCT_N','COUNTY','COUNTY_NAM')]
  #Construct the temp_df.union shapefile again so we can do the next iteration of the for loop.
  temp_df.union <- temp_df.shp.agg
  #Construct the temp_df data frame again so we can do the next iteration of the for loop.
  temp_df <- as(temp_df.union,"data.frame")
  
  #Change row names to be properly indexed.
  row.names(temp_df.union@data) <- 1:dim(temp_df.union)[1]
  row.names(temp_df.union) <- row.names(temp_df.union@data)
  
  #Print where we are currently in the while loop.
  print(dim(temp_df)[1])
  
  #The next block of code is for the express purposes of determining if we have any multiparts that somehow 
  # snuck into the shapefile and to ensure the while loop will end. 
  temp_poly_with_holes_2 <- sapply( sapply( temp_df.union@polygons, slot , "Polygons" ) ,function(x) sapply(x , slot , "hole" ))
  print("Number of precincts with holes")
  print(length(temp_polys_nums_with_holes_2))
  temp_polys_nums_with_holes_2 <- which(sapply(temp_poly_with_holes_2, function(x) any(x)))
  # length(temp_polys_nums_with_holes_2)
  # temp_polys_nums_with_holes_2
  temp_polys_2 <- sapply( temp_df.union@polygons, slot , "Polygons" )
  temp_polys_with_multiparts_and_holes_2 <- which(sapply(temp_polys_2, function(x) length(x)>1))
  temp_polys_with_only_holes_2 <- which(sapply(temp_poly_with_holes_2, function(x) more_than_one_false(x)))
  #By set subtracting the index of the precincts withs holes from the set of precincts with
  # multiparts or holes, we are left with only the precincts with multiparts and possibly a hole.
  #This contains the precincts that are multiparts only in precinct_2016_no_multiparts
  print("Number of precincts with multiparts")
  print(length(setdiff(temp_polys_with_multiparts_and_holes_2,temp_polys_with_only_holes_2)))
  #If there is a multipart, stop immediately so we can diagnose the problem. 
  if (length(setdiff(temp_polys_with_multiparts_and_holes_2,temp_polys_nums_with_holes_2))>0){
    print("There is a multipart in the shapefile when there should be none.")
    print(temp_df.union[c(setdiff(temp_polys_with_multiparts_and_holes_2,temp_polys_nums_with_holes_2)),])
    print(plot(temp_df.union[c(setdiff(temp_polys_with_multiparts_and_holes_2,temp_polys_nums_with_holes_2)),]))
    # print(jic)
    break
  }
}

# Make new main shapefile. This will be the main shapefile that we export.
precinct_2016_2 <- temp_df.union
# Make new main data frame.
precinct_2016_2.df <- temp_df


#The following for loop will remove all of the slivers that remain.
poly_with_holes_3 <- sapply( sapply( precinct_2016_2@polygons, slot , "Polygons" ) ,function(x) sapply(x , slot , "hole" ))
polys_nums_with_holes_3 <- which(sapply(poly_with_holes_3, function(x) any(x)))
while (length(polys_nums_with_holes_3)>0){
  test_poly <- precinct_2016_2[polys_nums_with_holes_3[1],]
  #ring will give the outside rings of each polygon with no hole. 
  ring = SpatialPolygons(
    list(
      Polygons(
        list(
          test_poly@polygons[[1]]@Polygons[[1]]
        ),
        ID=1)))
  unholed <- SpatialPolygonsDataFrame(ring, data = test_poly@data, match.ID = FALSE)
  proj4string(unholed) <- CRS("+proj=longlat +ellps=GRS80 +no_defs")
  precinct_2016_2 <- rbind(precinct_2016_2[-polys_nums_with_holes_3[1],],unholed)
  precinct_2016_2.df <- as(precinct_2016_2,"data.frame")
  #If there is only one polygon left, it means that that is the one polygon that is on the coast of 
  # Georgia that actually does not have any hole.
  tryCatch({
    poly_with_holes_3 <- sapply( sapply( precinct_2016_2@polygons, slot , "Polygons" ) ,function(x) sapply(x , slot , "hole" ))
  }, error = function(e) {
    break
  })
  polys_nums_with_holes_3 <- which(sapply(poly_with_holes_3, function(x) any(x)))
  print(polys_nums_with_holes_3)
}

#In case the projection was lost in all of this, reset the projection to the below projection.
precinct_2016_2 <- spTransform(precinct_2016_2,CRS("+proj=longlat +ellps=GRS80 +no_defs"))

writeOGR(obj = precinct_2016_2, dsn="VTD2016-Shape", layer = "VTD2016-Shape_step_4", driver = "ESRI Shapefile")

