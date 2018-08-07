# MCMC_redistricting_john

This folder contains all of my work to clean up data as well as run an MCMC algorithm to create more redistrictings of the congressional districts. 

The folder titled MCMC_program runs the Markov chain Monte Carlo algorithm that will take one census block or precinct and switch it from one district to another district. At this time, the program is nearly complete. There is a pointer error on lines 209-213 that I have been unable to fix. The code for the state of Georgia at the precinct level is also in this folder. 

The folder titled preprocessing contains programs using python and R to build a shapefile of the precinct data that is ready for use in the MCMC algorithm. Once the voting data is merged with the shapefile and the census data is merged with the census block shapefile, these programs can be used. Microsoft Access was used to merge the census data with the census block shapefile. SQL and python were used together to merge the voting data with the precinct shapefile. 

Tom Gonzalez helped with merge the voting data with the precinct data. He also helped parse together the method of which to merge the census data with the census block shapefile. 
