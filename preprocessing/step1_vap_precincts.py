import geopandas as gpd
import numpy as np
import pandas as pd
import copy

#Read in the spacial dataframe for the precicnts.
data = gpd.read_file('$PATH/vote_data_precinct_shapefile.shp')
#Read in the spacial data frame for the census blocks.
census_data = gpd.read_file('$PATH/census_blocks_race_pop_vap_GA.shp')
#Set index for the precincts that intestect in their polygons. 
spatial_index = census_data.sindex

#Create new column for the Voting Age Population (VAP).  
data['VAPPOP'] = np.nan

#For each overlapping census block and precinct, give the proportion of the VAPPOP to 
#the precinct based on area that the two regions share.
for index,row in data.iterrows():
    possible_matches_index = list(spatial_index.intersection(data['geometry'][index].bounds))    
    possible_matches = census_data.iloc[possible_matches_index]
    precise_matches = possible_matches[possible_matches.intersects(data['geometry'][index])]
    data.loc[index,'VAPPOP'] = sum([(((precise_matches.loc[entry]['geometry'])\
                                .intersection(data['geometry'][index]))\
                                .area/ precise_matches.loc[entry]['geometry'].area)*\
                                precise_matches.loc[entry]['VAPPOP'] \
                                for entry in precise_matches.index])

data2 = data.copy()

#We next handle the cases where there is no voting data for a polygon. In these cases
# we simply join it with a corresponding precinct based on the location of the precinct
# and the precinct name. The process of determining which precincts would be joined 
# together was all done manually by looking at the district name field and the 
# geometry of previous years of precinct shapefiles.
join_pairs = [[3997520,3997357],[4003142,3991090],[4709417,4734904],[871733,3990992],\
              [871733,3997407],[3997020,3990963],[852706,3968345],[4003204,3991150],\
              [3968384, 3968368],[3957473,3974745],[4762570,4814928],[4741789,4741755],\
              [3997020,3997440],[4008313,4020087],[4008363,4020109],[4008313,4008264],\
              [785250,836257],[5106106,5106079],[4768363,4768447],[4529414,4032199],\
              [4230927,4224033],[4571434,4566585],[4566788,4566678],[3126604,3211992],\
              [3282654,3361971],[450457,459883],[450457,436099],[450457,272969],\
              [276794,276857],[276896,441779],[276896,441734],[441823,441887],\
              [679836,450580]]
test = 0
for x in range(len(join_pairs)):
    polygon1 = data2.loc[data2['ID']==join_pairs[x][0]]
    polygon2 = data2.loc[data2['ID']==join_pairs[x][1]]
    polygon2.at[polygon2.index.values.tolist()[0],'ID'] = join_pairs[x][0]
    polygons = gpd.GeoDataFrame( pd.concat( [polygon1,polygon2], ignore_index=True) )
    polygons = polygons.dissolve(by = 'ID')
    polygons['ID'] = join_pairs[x][0]
    #Add the voting age populations together.
    polygons['VAPPOP'] = polygons['VAPPOP'].values + polygon2['VAPPOP'].values
    polygons1 = copy.deepcopy(polygons)
    data2 = data2.drop(data2[data2['ID']==join_pairs[x][0]].index)
    data2 = data2.drop(data2[data2['ID']==join_pairs[x][1]].index)
    data2 = gpd.GeoDataFrame( pd.concat( [data2,polygons1], ignore_index=True) )
    print(test)
    test += 1




data2.crs = data.crs
data2.to_file(driver = 'ESRI Shapefile', \
              filename= "$PATH/VTD2016-Shape_step_1.shp")
