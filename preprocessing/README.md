#Preprocessing

To preprocess the data, there are many steps to take and much of it depends 
on which refinement is being used: precinct level or census block level.

##Notes
The files labeled step1_blah are for preprocessing at the precinct level while the files labeled step1_blah_2 are at the census block level. 

Whenever a path would be using my local address, I have replaced it with $PATH.

##Explanation of the various steps for precinct level data

Step 0: In Georgia, there were some precincts with no identifying information. Later, I discovered that there was no voting information for these precincts as well. To be able to put these precincts into the MCMC algorithm, I decided to merge some of the precincts together that were identified as together based on previous and current election and shapefile information. The data in this file are my notes about how to merge the precincts.

Step 1: This code was run in python. The various steps mark the switch between python and R in order to take advantage of the various geospatial tools in the two languages. In this step, we merge the precincts together that were mentioned in Step 0. Additionally, we create a new column of data in the precinct shapefile for the number of people who are considered voting age population (18 or older). 
This was done by adding a proportion of the voting age population (VAP) from a census block to a precinct it lies within based on the proportion of the area of the census block to the area of intersection between the census block and the precinct. 

Step 2: Since the precinct files and the congressional district files for the state of Georgia were both made by the same legislative committee, intersection the two shapefiles did not produce any polygonal slivers. But there were some congressional districts that did not line up with the precincts. So we used the intersection funtion to create new precincts by splitting them up to follow the congressional district lines. 

Step 3: First we split off all multiparts from precincts so that we are either dealing with a single polygon precinct or a precinct with hole(s). After splitting the precincts up, we identfy which precincts are on the border of the state, share the VAP, total population, and the demographics for each precinct before the split with its respective pieces based on land area. We split the number of votes for the Republication candidate, Democrat candidate, and Libertarian candidate into pieces to share with its respective precinct pieces based on the VAP of each precinct vs the VAP of the piece. 

Step 4: This is the most computational intensive step. First, we enumerate all holes in the entire shapefile. 
Then we aggregate all of the holes with the precincts that contain the holes. At the same time, we sum together the VAP, total population, vote totals, and demographic numbers for each precinct and its hole.
Finally, we run through the geometry to ensure there are no slivers between any of the precincts due to errors when originally making the shpaefile. 

Step 5: From here on out, the shapefiles will not be changed. In this step, we calculate all of the statistics we need for the MCMC algorithm such as:
area, perimeter, whether or not the precinct is on the state border, length of the perimeter shared with each neighbor, and list of all the neighbors to that precinct.

Step 6: Due to complications with having a list in some entry in a data frame, we merged all of the neighbor and length data in R. 

Step 7: This step sets up a file of the neighborhoods for each precinct and puts it into a file so that the Boyer-Myrvold algorithm for planar embedding can be used to generate a planar embedding. 

Step 8: This step merges the neighborhood data from the planar embedding back into the file. At this point, we are ready to use the MCMC algorithm. 
