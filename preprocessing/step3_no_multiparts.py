import pandas as pd
import geopandas as gpd
import pysal as ps 
import numpy as np
#from rtree import index


#Read in the spacial dataframe for the precicnts.
data = gpd.read_file('$PATH/VTD2016-Shape_step_2.shp')
#Read in the spacial data frame for the census blocks.
census_data = gpd.read_file('$PATH/census_blocks_race_pop_vap_GA.shp')

#If needed, rename the columns to be the correct column names. This may happen
# when saving files in R.
data.rename(columns={'VAPPO': 'VAPPOP'}, inplace=True)

#Function that will turn multiparts into single parts. Code is courtesy of a 
# comment made by Philipp Schwarz. 
def multi2single(gpdf):
    gpdf_singlepoly = gpdf[gpdf.geometry.type == 'Polygon']
    gpdf_multipoly = gpdf[gpdf.geometry.type == 'MultiPolygon']

    for i, row in gpdf_multipoly.iterrows():
        Series_geometries = pd.Series(row.geometry)
        df = pd.concat([gpd.GeoDataFrame(row, crs=gpdf_multipoly.crs).T]*len(Series_geometries), ignore_index=True)
        df['geometry']  = Series_geometries
        gpdf_singlepoly = pd.concat([gpdf_singlepoly, df])

    gpdf_singlepoly.reset_index(inplace=True, drop=True)
    return gpdf_singlepoly

#Split all multiparts into single parts.
data2 = multi2single(data)

#Set index for the precincts that intestect in their polygons. 
spatial_index = census_data.sindex

#Temporarily save dataframe so that we can immediately download it and use it to find the rook neighborhood.
data2.to_file(driver = 'ESRI Shapefile', filename= "$PATH/VTD2016-Shape_step_2_1.shp")
#Construct rook neighborhood of spacial dataframe.
w = ps.rook_from_shapefile('$PATH/VTD2016-Shape_step_2_1.shp')

#Create columns that will be used in throughout the rest of the process.
data2['VAPPOP3'] = np.nan
data2['ST_BORDER'] = np.nan
data2['TOTALPOP'] = np.nan
data2['RACEPOP'] = np.nan
data2['ID_3'] = np.nan
newid = 0

len(data)
len(data2)
for index1, row in data2.iterrows():
    #Set new ID number based on the pieces from multiparts and the intersection
    # with the congressional districts.
    data2.loc[index1, 'ID_3'] = str(data2.loc[index1, 'ID_1'])+'_'+str(newid)
    
    bound_length = []
    poly1 = data2['geometry'][index1]
    
    #Sum up intersection length to get the length of border shared by the current
    # polygon called poly1 and its neighbors.
    for i in w.neighbors[index1]:
        poly2 = data2['geometry'][i]
        intersection = poly1.intersection(poly2)
        #Find boundary length between poly1 and poly2.
        bound_length.append(intersection.length)
    #If the length of the boundary is NOT almost exactly the same as the length of 
    # the sum of the boundary (that is to account for rounding errors) then
    # the precinct is on the border of the state. Otherwise it is not on the
    # border of the state.
    if row['geometry'].length*0.9999999> sum(bound_length):
        data2.loc[index1, 'ST_BORDER'] = 1
    else: 
        data2.loc[index1, 'ST_BORDER'] = 0
    
    #We split the RACEPOP and TOTALPOP based on area assuming that people are 
    # uniformly spread throughout each precinct.
    possible_matches_index = list(spatial_index.intersection(data2['geometry'][index1].bounds))    
    possible_matches = census_data.iloc[possible_matches_index]
    precise_matches = possible_matches[possible_matches.intersects(data2['geometry'][index1])]
    #To prevent from calculating the ratios of areas between the census blocks 
    # and the precincts, we make the following calculation.
    area_ratios = pd.Series([(((precise_matches.loc[entry]['geometry'])\
                                .intersection(data2['geometry'][index1]))\
                                .area/ precise_matches.loc[entry]['geometry'].area) \
                                for entry in precise_matches.index])
    
    #By multiplying the area_rations by the VAPPOP, TOTALPOP, or RACEPOP, we 
    # are splitting these three quantities into their respective fractional 
    # amounts based on the percent of area of the census block in the precinct's
    # geometry.
    data2.loc[index1,'VAPPOP3'] = sum(precise_matches.loc[precise_matches.index]['VAPPOP'].values*area_ratios.values)
    data2.loc[index1,'TOTALPOP'] = sum(precise_matches.loc[precise_matches.index]['TOTALPOP'].values*area_ratios.values)
    data2.loc[index1,'RACEPOP'] = sum(precise_matches.loc[precise_matches.index]['RACEPOP'].values*area_ratios.values)

    #Split Republican, Democrat, and Libertarian votes based on new VAPPOP numbers.
    #If the VAPPOP is 0, don't make this calculation since we will be dividing 
    # by 0 if we continue.
    if data2.loc[index1,'VAPPOP'] != 0:
        data2.loc[index1,'REPUB_VOTE'] = data2.loc[index1,'REPUB_VOTE']* \
                                    data2.loc[index1,'VAPPOP3']/data2.loc[index1,'VAPPOP']
        data2.loc[index1,'DEM_VOTE'] = data2.loc[index1,'DEM_VOTE']* \
                                    data2.loc[index1,'VAPPOP3']/data2.loc[index1,'VAPPOP']
        data2.loc[index1,'LIB_VOTE'] = data2.loc[index1,'LIB_VOTE']* \
                                    data2.loc[index1,'VAPPOP3']/data2.loc[index1,'VAPPOP']
    #If we were to divide by 0, print a warning. Don't set any new numbers since
    # having 0 VAPPOP should mean we have 0 votes for Republicans, Democrats,
    # and Libertarians.
    if data2.loc[index1,'VAPPOP'] == 0 and (data2.loc[index1,'LIB_VOTE'] != 0 or \
               data2.loc[index1,'REPUB_VOTE'] or data2.loc[index1,'DEM_VOTE']):
        print('Warning: There are votes counted yet there are no people who can vote. ', data2.loc[index1,'PRECINCT_N'])
    
    newid += 1


########################################
########################################
########################################
########################################
#To ensure the values were calculated correctly, sum up the VAPPOP3. In Georgia,
# there should be a little more than 7 million voting age population. 
########################################
########################################
########################################

#Turn the numbers in ST_BORDER into integers
data2['ST_BORDER'] = data2['ST_BORDER'].astype('int')

data2.to_file(driver = 'ESRI Shapefile', \
              filename= "$PATH/VTD2016-Shape_step_3.shp")
