import geopandas as gpd
import pysal as ps 
import numpy as np
import os

#Read in the spacial dataframe for the precicnts.
data = gpd.read_file('$PATH/VTD2016-Shape_step_4.shp')
#Read in the spacial data frame for the census blocks.
census_data = gpd.read_file('$PATH/census_blocks_race_pop_vap_GA.shp')

#Set index for the precincts that intestect in their polygons. 
spatial_index = census_data.sindex

#Drop ST_BORDER so that we can recalculate it.
data2 = data.drop('ST_BORDER',1)

#Temporarily save dataframe so that we can immediately download it and use it to find the rook neighborhood.
data.to_file(driver = 'ESRI Shapefile', filename= "$PATH/VTD2016-Shape_step_4_1.shp")
#Construct rook neighborhood of spacial dataframe.
w = ps.rook_from_shapefile('$PATH/VTD2016-Shape_step_4_1.shp')

#Create columns that will be used in throughout the rest of the process.
data2['AREA'] = np.nan
data2['PERIMETER'] = np.nan
data2['ST_BORDER'] = np.nan
data2['N_LENGTH'] = np.nan
data2['N_LENGTH'] = data2['N_LENGTH'].astype('object')
data2['NEIGHBORS'] = np.nan
data2['NEIGHBORS'] = data2['NEIGHBORS'].astype('object')


#Reset the index in case it has changed. 
data2 = data2.reset_index()
data2['INDEX'] = data2.index

data2.columns

#We now fill all of the newly created columns.
for index1, row in data2.iterrows():
    # Update the value in 'area' column with area information at index
    data2.loc[index1, 'AREA'] = row['geometry'].area
    data2.loc[index1, 'PERIMETER'] = row['geometry'].length
    
    bound_length = []
    poly1 = data2['geometry'][index1]
    nbrs = []
    
    #Sum up intersection length to get the length of border shared by the current
    # polygon called poly1 and its neighbors.
    for i in w.neighbors[index1]:
        poly2 = data2['geometry'][i]
        intersection = poly1.intersection(poly2)
        bound_length.append(intersection.length)
        nbrs.append(data2.loc[i]['INDEX'])
    #This creates a list of entries corresponding to the boundary lengths.
    data2.at[index1,'N_LENGTH'] = bound_length
    #This creates a list of the entries corresponding to the order of the 
    # lengths in the list in N_LENGTH and to the neighbors of index1. 
    data2.at[index1,'NEIGHBORS'] = nbrs #data2.loc[w.neighbors[index1]]['INDEX'].values
    
    if row['geometry'].length*0.9999999> sum(bound_length):
        data2.loc[index1, 'ST_BORDER'] = 1
    else: 
        data2.loc[index1, 'ST_BORDER'] = 0

#Turn the numbers in ST_BORDER into integers
data2['ST_BORDER'] = data2['ST_BORDER'].astype('int')
#Since geopandas has problems exporting columns with lists, we split the
# NEIGHBORS and N_LENGTH data to send as csv separately.
to_port = data2[['ID_3','NEIGHBORS','N_LENGTH']]
data2 = data2.drop('NEIGHBORS',1)
data2 = data2.drop('N_LENGTH',1)
path = '$PATH/'
to_port.to_csv(os.path.join(path,r'VTD2016-Shape_step_5_1.csv'))
data2.to_file(driver = 'ESRI Shapefile', \
              filename= "$PATH/VTD2016-Shape_step_5.shp")
