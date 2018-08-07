#!/usr/bin/env python
# -*- coding: utf-8 -*-

# check_npl.py---

# Copyright (C) 2018 John Asplund <jasplund@daltonstate.edu>

# Author: John Asplund <jasplund@daltonstate.edu

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
# Note that this program is to be run using Python 3.6 or higher.

'''
Run Markov Chain Monte Carlo (random walk) on the districtings of any state
----------------------

This program is designed to run a Markov chain Monte Carlo algorithm on
any set of data provided from a state. The goal of this program is to 
sample the redistricting sample space as it is too large to exhaustively 
build. The data that must be provided are: demographics for each precinct, 
population for each precinct, precinct number, the set of neighbors for each 
precinct, perimeter of each precinct, area of each precinct, vote totals for 
candidate A for each precinct, vote totals for candidate B for each precinct, 
the designation for the county the precinct currently resides, and the 
designation for the district the precinct currently resides. 
'''

import random
#import matplotlib.pyplot as plt
import pandas as pd
#import pysal as ps
#from functools import reduce
import numpy as np
import time
#import copy
import MCMC_cy_ver3

#def build_initial_districting():
#    return [1,2,2,2,3,3,3,3,3,3,3,1,1,1,2,3,2,4,1,0] #The last precinct is the exterior of the state.
# print(timeit.timeit('''
if __name__ == "__main__":
    start_time = time.time()
    num_runs = 2**20
    # num_runs = 2**22
    pop_tolerance = 0.1
    # # TODO: Have pro gram find precinct population from file. 
    # precinct_df = pd.DataFrame({'Population': [1000,1100,1050,1025,1025,950,750,550,\
    #                                            600,500,400,1010,990,1000,1075,925,1000,5500,950], \
    #                             'Precinct_Neighborhood': [[2,9,12,14,19],[1,3,7,9,14,15],\
    #                                                       [2,4,7,15,17,20],[3,5,6,7,20],[4,6,20],\
    #                                                       [4,5,7,8,10,20],[2,3,4,6,8,9],[6,7,9,10],\
    #                                                       [1,2,7,8,10,11],[6,8,9,11,16,20],\
    #                                                       [1,9,10,12,16,20],[1,11,13,19,20],\
    #                                                       [12,14,19,20],[1,2,15,18,20],[2,3,14,17,18,20],\
    #                                                       [10,11,20],[3,15,20],[14,15,20],[1,12,13]],\
    #                             'County': [1,6,6,9,13,13,10,13,11,12,15,3,4,5,8,15,6,16,3],\
    #                             'District': [1,2,2,2,3,3,3,3,3,3,3,1,1,1,2,3,2,4,1]})
    # neighbors_set = np.array([[2,9,12,14,19],[1,3,7,9,14,15],\
    #                           [2,4,7,15,17,20],[3,5,6,7,20],[4,6,20],\
    #                           [4,5,7,8,10,20],[2,3,4,6,8,9],[6,7,9,10],\
    #                           [1,2,7,8,10,11],[6,8,9,11,16,20],\
    #                           [1,9,10,12,16,20],[1,11,13,19,20],\
    #                           [12,14,19,20],[1,2,15,18,20],[2,3,14,17,18,20],\
    #                           [10,11,20],[3,15,20],[14,15,20],[1,12,13]], object)
    num_districts = 14 # TODO: Automate this value.
    # The first row is population, the second is counties, the third is districts,
    # and the fourth row has a 1 for the precincts that are on the boundary of the 
    # state and 0 otherwise.
    # precinct_np = np.array([[1000,1100,1050,1025,1025,950,750,550,\
    #                          600,500,400,1010,990,1000,1075,925,1000,5500,950,0], \
    #                         [1,6,6,9,13,13,10,13,11,12,15,3,4,5,8,15,6,16,3,0],\
    #                         [1,2,2,2,3,3,3,3,3,3,3,1,1,1,2,3,2,4,1,0],\
    #                         [0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,1,0,0]], dtype = np.int32) 
    total_pop = 9687636.93
    # init_districting = precinct_np[2]
    #TODO: automate picking outside_precinct
    outside_precinct=15 #This is the precinct representing the outside region of the state.
    '''
    The next vector contains a lot of important contants:
    * Number of precincts (without outside precinct)
    * Number of boundary precincts before we add the outside precinct
    * Number of districts
    * Total population
    * ouside precinct number
    * pop tollerance
    '''
    # stats_vec = np.array([19,19,num_districts,total_pop,outside_precinct,pop_tolerance], dtype = np.int32)
    random.seed(9001)

    MCMC_cy_ver3.markov_chain(num_runs,num_districts,total_pop,outside_precinct,pop_tolerance)
    print('--- %s seconds ---' % (time.time() - start_time))
    #run analysis on the initial districting vs the set of all districtings.

#To cythonize code, type 
#python3 setup.py build_ext --inplace
#To run python code, type 
#python3 MCMC_main_cy.py
