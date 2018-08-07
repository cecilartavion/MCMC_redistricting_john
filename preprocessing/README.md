#Preprocessing

To preprocess the data, there are many steps to take and much of it depends 
on which refinement is being used: precinct level or census block level.

##Notes
The files labeled step1_blah are for preprocessing at the precinct level while the files labeled step1_blah_2 are at the census block level. 

Whenever a path would be using my local address, I have replaced it with $PATH.

##Explanation of the various steps

Step0: In Georgia, there were some precincts with no identifying information. Later, I discovered that there was no voting information for these precincts as well. To be able to put these precincts into the MCMC algorithm, I decided to merge some of the precincts together that were identified as together based on previous and current election and shapefile information. 
