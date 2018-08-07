#cython: boundscheck=False
import random
import numpy as np
cimport numpy as np
from numpy cimport ndarray
import pandas as pd
# from libc.stdlib cimport rand, RAND_MAX
from libc.stdlib cimport rand
import ast

cdef bint pop_checker(int target_precinct,
                int new_district,
                double [:,:] precinct_np,
                int [:] stats_vec,
                int [:] district_pop,
                double lower_pop,
                double upper_pop):
    district_pop[int(precinct_np[2,target_precinct-1])] = district_pop[int(precinct_np[2,target_precinct-1])]-int(precinct_np[0,target_precinct-1])
    district_pop[new_district] = district_pop[new_district] + int(precinct_np[0,target_precinct-1])
    pop_check = True
    # print(target_precinct,new_district, stats_vec[3]/stats_vec[2]*(1-pop_tolerance),np.asarray(district_pop),\
    # 	stats_vec[3]/stats_vec[2]*(1+pop_tolerance))
    for i in range(0,sizeof(stats_vec[2])):
        if lower_pop>district_pop[i] or district_pop[i]>upper_pop:
            pop_check = False

    district_pop[int(precinct_np[2,target_precinct-1])] = district_pop[int(precinct_np[2,target_precinct-1])]+int(precinct_np[0,target_precinct-1])
    district_pop[new_district] = district_pop[new_district] - int(precinct_np[0,target_precinct-1])
    return pop_check
    ### The following code is for if the code is written strictly in c++.
    ## return std::all_of(pop_of_each_district.begin(), pop_of_each_district.end(), [](int i){return stats_vec[3]/stats_vec[2]*(1-stats_vec[5])<i;}) and \
    ## 		std::all_of(pop_of_each_district.begin(), pop_of_each_district.end(), [](int i ){return i<stats_vec[3]/stats_vec[2]*(1+stats_vec[5]);})
    ### The following code is for if the code is written strictly in python.
    ## return all(stats_vec[3]/stats_vec[2]*(1-stats_vec[5])<pop_of_each_district) and \
            ## all(pop_of_each_district<stats_vec[3]/stats_vec[2]*(1+stats_vec[5]))

cdef bint connected_checker(int target_precinct,
                      int new_district,
                      object [:] neighbors_set,
                      double [:,:] precinct_np):
    # A vertex v is a cut vertex (or articulation point) if and only if a DFS
    # with v as the root has more than one child. 
    # Run DFS. Stop immediately if a second child is found. This will
    # take O(V+E). 
    
    #Write algorithm that will do DFS on the neighborhood of a precinct
    return True

cpdef bint simply_connected_checker(int target_precinct,
                             int new_district,
                             int [:,:] boundary_precincts,
                             object [:] neighbors_set,
                             double [:,:] precinct_np,
                             int [:] stats_vec):
    return True
    #test this before running
    cdef np.ndarray local_neighbors
    cdef np.ndarray check1
    cdef np.ndarray check2
    cdef np.ndarray position_record1
    cdef np.ndarray position_record2

    local_neighbors = neighbors_set[target_precinct]
    check1 = [True,True,True,True]
    check2 = [True,True,True,True]
    position_record1 = [0,0]
    position_record2 = [0,0]
    for nhbr in range(len(local_neighbors)):
        if int(precinct_np[2,local_neighbors[nhbr]])==int(precinct_np[2,target_precinct]) and check1[0]:
            position_record1[0] = nhbr
            check1[0]=False
        if int(precinct_np[2,local_neighbors[nhbr]])!=int(precinct_np[2,target_precinct]) and check1[1] and check1[0]==False:
            check1[1]=False
        if int(precinct_np[2,local_neighbors[nhbr]])==int(precinct_np[2,target_precinct]) and check1[1]==False and check1[2]:
            check1[2]=False
        if int(precinct_np[2,local_neighbors[nhbr]])!=int(precinct_np[2,target_precinct]) and check1[2]==False and check1[3]:
            position_record1[1] = nhbr-1
            check1[3]=False
        if int(precinct_np[2,local_neighbors[nhbr]])==int(precinct_np[2,target_precinct]) and check1[3]==False:
            return False
        if int(precinct_np[2,local_neighbors[nhbr]])==new_district and check2[0]:
            position_record2[0] = nhbr
            check2[0]=False
        if int(precinct_np[2,local_neighbors[nhbr]])!=new_district and check2[1] and check2[0]==False:
            check2[1]=False
        if int(precinct_np[2,local_neighbors[nhbr]])==new_district and check2[1]==False and check2[2]:
            check2[2]=False
        if (int(precinct_np[2,local_neighbors[nhbr]])!=new_district or len(local_neighbors)-1==nhbr) and check2[2]==False and check2[3]:
            position_record2[1] = nhbr-1
            check2[3]=False
        if int(precinct_np[2,local_neighbors[nhbr]])==new_district and check2[3]==False :
            return False
    
    # Check if there is only one group of old or new district or if there is a wrap around.
    if check1[2]==True or \
            (position_record1[0]==precinct_np[2,target_precinct] and position_record1[1]==precinct_np[2,target_precinct]):
        if check2[2]==True or \
                (position_record2[0]==precinct_np[2,target_precinct] and position_record2[1]==precinct_np[2,target_precinct]):
            return True
    else:
        return False



    # cdef bint graph_simply_connected
    # cdef np.ndarray precincts_adj_to_boundary
    # cdef np.ndarray districts_of_neighboring_precincts
    # cdef np.ndarray proposed_districting = precinct_np[2].copy()
    # cdef int old_district = proposed_districting[target_precinct-1]
    # proposed_districting[target_precinct-1] = new_district

    # # Set a variable that will tell us if the graph is simply connected.
    # graph_simply_connected = True
    # for district in [old_district,new_district]:
    #     # Build array of the precincts adjacent to the boundary of district. The precinct number is 
    #     # actually one less than the actually precinct number.
    #     precincts_adj_to_boundary = boundary_precincts[boundary_precincts[:,1]==district].T[0]-1
    #     districts_of_neighboring_precincts = np.unique(precinct_np[2,precincts_adj_to_boundary])
    #     # Remove from districts_of_neighboring_precincts the districts that are the current district 
    #     # being investigated. We are only interested in the districts that surround the district in question.
    #     if (len(districts_of_neighboring_precincts)==1) \
    #             and (not any(((boundary_precincts == (stats_vec[4],district)).all(axis=1)))):
    #         graph_simply_connected = False
    #         print('Districts for precincts: ',precinct_np[2])
    #         print('Is the graph simply connected? ',boundary_precincts[boundary_precincts[:,1]==district].T[0]-1)
    # return graph_simply_connected

cdef bint compact_checker(int target_precinct,
                        int new_district,
                        double [:,:] precinct_np):
    # target_precinct will be the precinct that will change to a new district.
    # I believe this can be done all at once with the connected checker.
    return True

cdef bint county_checker(int target_precinct,
                    int new_district,
                    double [:,:] precinct_np):
    # target_precinct will be the precinct that will change to a new district.
    return True

cdef bint demographic_checker(int target_precinct,
                        int new_district,
                        double [:,:] precinct_np):
    # target_precinct will be the precinct that will change to a new district.
    return True

cdef bint districting_checker(int rand_precinct,\
                        int [:,:] boundary_precincts,\
                        object [:] neighbors_set,\
                        double [:,:] precinct_np,\
                        int [:] stats_vec,\
                        int [:] district_pop,\
                        double lower_pop,\
                        double upper_pop):
    cdef int target_precinct, new_district
    target_precinct = boundary_precincts[rand_precinct,0]
    new_district = boundary_precincts[rand_precinct,1]
    # print(pop_checker(target_precinct,new_district,precinct_np,stats_vec,district_pop,lower_pop,upper_pop),target_precinct,new_district,pop_tolerance)
    # print(simply_connected_checker(target_precinct,new_district,boundary_precincts,neighbors_set,precinct_np,stats_vec))
            # and simply_connected_checker(target_precinct,new_district,\
            #     boundary_precincts,neighbors_set,precinct_np,stats_vec) \
    if pop_checker(target_precinct,new_district,precinct_np,stats_vec,district_pop,lower_pop,upper_pop) \
            and connected_checker(target_precinct,new_district,neighbors_set,precinct_np)\
            and simply_connected_checker(target_precinct,new_district,\
                boundary_precincts,neighbors_set,precinct_np,stats_vec) \
            and compact_checker(target_precinct,new_district,precinct_np) \
            and county_checker(target_precinct,new_district,precinct_np) \
            and demographic_checker(target_precinct,new_district,precinct_np):
        return True
    else:
        return False

cdef change_state(int[:,:] bound_precincts,
                 object [:] neighbors_set,
                 double[:,:] precinct_np,
                 int[:] stats_vec,
                 int[:] district_pop,
                 double lower_pop,
                 double upper_pop):
    cdef int ndw,x,outside_precinct_ix
    # #TODO: Check to see whether or not outside_precinct_ix is needed.
    # cdef np.ndarray boundary_precincts = np.array([[1,2],[1,3],[2,1],[2,3],[3,3],[4,3],[5,2],[6,2],[7,2],\
    #                       [9,1],[9,2],[11,1],[12,3],[14,2],[14,4],\
    #                       [15,1],[15,4],[18,1],[18,2],[20,1],[20,2],[20,3],[20,4]], dtype = np.int32)
    # cdef int boundary_precincts[23][2]
    # boundary_precincts = [[1,2],[1,3],[2,1],[2,3],[3,3],[4,3],[5,2],[6,2],[7,2],[9,1],[9,2],[11,1],[12,3],[14,2],[14,4],[15,1],[15,4],[18,1],[18,2],[20,1],[20,2],[20,3],[20,4]]
    # outside_precinct_ix = binarySearch(bound_precincts[:][0],0,sizeof(bound_precincts))
    outside_precinct_ix = stats_vec[1]
    # Randomly pick one of the boundary precinct pairs (not including the border of the state)
    x = np.random.randint(0, outside_precinct_ix)
    # print(x)
    # print(outside_precinct_ix)
    # #TODO: We need to randomize on the number of neighbors of x.
    # #TODO: Need to exclude the last precinct representing the outside region of the state.
    # x = np.random.randint(0, len(bound_precincts[:outside_precinct_ix]))
    # # If we would end up with less than the correct number of districts, stop.
    # cdef int temp_districting[len(precinct_np[2])]

    for i in range(5,len(stats_vec)):
        # If there are 0 precincts in district bound_precincts[x,1] then do not switch, instead return.
        if stats_vec[5+bound_precincts[x,1]]-1 < 1:
            return 
    
    if districting_checker(x,bound_precincts,neighbors_set,precinct_np,stats_vec,district_pop,lower_pop,upper_pop):
        # The following three lines make the switch for the chosen precinct
        # from one district to the other identified district.
        # print('all data: ',np.asarray(bound_precincts),np.asarray(district_pop),np.asarray(bound_precincts[x]),\
        	    # np.asarray(district_pop[int(precinct_np[2,bound_precincts[x,0]-1])]),np.asarray(precinct_np[0,bound_precincts[x,0]]))
        district_pop[int(precinct_np[2,bound_precincts[x,0]-1])] = district_pop[int(precinct_np[2,int(bound_precincts[x,0])-1])]-\
                                                                        int(precinct_np[0,int(bound_precincts[x,0])-1])
        # district_pop[bound_precincts[x,1]] = district_pop[bound_precincts[x,1]] + int(precinct_np[0,bound_precincts[x,0]-1])
        # bound_precincts[x,1], precinct_np[2,bound_precincts[x,0]-1] = int(precinct_np[2,bound_precincts[x,0]-1]), \
        #                                                                     bound_precincts[x,1]
        # district_pop[precinct_np[2,bound_precincts[x,0]-1]] = district_pop[precinct_np[2,bound_precincts[x,0]-1]]-\
        #                                                         precinct_np[0,bound_precincts[x,0]-1]
        # district_pop[bound_precincts[x,1]] = district_pop[bound_precincts[x,1]] + precinct_np[0,bound_precincts[x,0]-1]
        # print('stats: ',np.asarray(bound_precincts),np.asarray(district_pop),np.asarray(bound_precincts[x]))
        ndw = num_districts_won(precinct_np[2]) #TODO: Record the number of districts won
        return #set new districting and new boundary precincts and num of successes
    else:
        return #revert to previous districting

cdef int num_districts_won(double[:] districting):
    # TODO: Use voting results and districts to calculate the number votes won by Democrats.
    return 0

# Tell Cython to turn off the costly wrap around when x[-1] is called which has negative indices. 
# @cython.wraparound(False) 
# Tells Cython to turn off the costly check that array indices stay within their bounds
# @cython.boundscheck(False) 
cpdef markov_chain(int n,
                int num_districts,
                int total_pop,
                int outside_precinct,
                double pop_tolerance):
    cdef int i,ndw,num_success,num_precincts_dist_1,num_precincts_dist_2,num_precincts_dist_3,num_precincts_dist_4
    file1 = '/home/cecil2/Downloads/georgia_precincts_2016/georgia_precincts_2016/mcmc_ready.csv'
    data1 = pd.read_csv(file1)
#    [1,2,2,2,3,3,3,3,3,3,3,1,1,1,2,3,2,4,1,0]
#    num_precincts_dist_1 = 5
#    num_precincts_dist_2 = 5
#    num_precincts_dist_3 = 8
#    num_precincts_dist_4 = 1
    districts = data1['DISTRICT']
    num_precincts_dist_1 = len(districts[districts==1])
    num_precincts_dist_2 = len(districts[districts==2])
    num_precincts_dist_3 = len(districts[districts==3])
    num_precincts_dist_4 = len(districts[districts==4])
    num_precincts_dist_5 = len(districts[districts==5])
    num_precincts_dist_6 = len(districts[districts==6])
    num_precincts_dist_7 = len(districts[districts==7])
    num_precincts_dist_8 = len(districts[districts==8])
    num_precincts_dist_9 = len(districts[districts==9])
    num_precincts_dist_10 = len(districts[districts==10])
    num_precincts_dist_11 = len(districts[districts==11])
    num_precincts_dist_12 = len(districts[districts==12])
    num_precincts_dist_13 = len(districts[districts==13])
    num_precincts_dist_14 = len(districts[districts==14])
#    # cdef int neighbors_set[][]
    neighbors_set = np.array(range(len(data1['NEIGHBORS'])),dtype = object)
    for i in range(len(data1['NEIGHBORS'])):
        one_nbhd = np.array(ast.literal_eval(data1['NEIGHBORS'][i]))
        neighbors_set[i] = one_nbhd
#    neighbors_set = np.array([[2,9,12,14,19],[1,3,7,9,14,15],\
#                              [2,4,7,15,17,20],[3,5,6,7,20],[4,6,20],\
#                              [4,5,7,8,10,20],[2,3,4,6,8,9],[6,7,9,10],\
#                              [1,2,7,8,10,11],[6,8,9,11,16,20],\
#                              [1,9,10,12,16,20],[1,11,13,19,20],\
#                              [12,14,19,20],[1,2,15,18,20],[2,3,14,17,18,20],\
#                              [10,11,20],[3,15,20],[14,15,20],[1,12,13]],dtype = object)
    
    cdef object [:] neighbors_set_c = neighbors_set

    bound_precincts = []

    for i in range(len(neighbors_set)):
        for j in range(len(neighbors_set[i])):
            if int(data1.at[i,'DISTRICT']) != int(data1.at[neighbors_set[i][j],'DISTRICT']):
                bound_precincts.append([i,int(data1.at[neighbors_set[i][j],'DISTRICT'])])

    bound_precincts = np.array(bound_precincts,dtype=np.int32)
#    bound_precincts = np.array([[1,2],[1,3],[2,1],[2,3],[3,3],[4,3],[5,2],[6,2],[7,2],\
#                          [9,1],[9,2],[11,1],[12,3],[14,2],[14,4],\
#                          [15,1],[15,4],[18,1],[18,2],[20,1],[20,2],[20,3],[20,4]],dtype = np.int32)
    cdef int [:,:] bound_precincts_c = bound_precincts

    '''
    The next vector contains a lot of important contants:
    * Number of precincts (without outside precinct)
    * Number of boundary precincts on all districs before we add the outside precinct
    * Number of districts
    * Total population
    * ouside precinct number
    * Number of precincts in district 1
    * Number of precincts in district 2
    * and so on.
    '''
    
    stats_vec = np.array([len(data1),len(bound_precincts),num_districts,total_pop,outside_precinct,\
                            num_precincts_dist_1,\
                            num_precincts_dist_2,\
                            num_precincts_dist_3,\
                            num_precincts_dist_4,\
                            num_precincts_dist_5,\
                            num_precincts_dist_6,\
                            num_precincts_dist_7,\
                            num_precincts_dist_8,\
                            num_precincts_dist_9,\
                            num_precincts_dist_10,\
                            num_precincts_dist_11,\
                            num_precincts_dist_12,\
                            num_precincts_dist_13,\
                            num_precincts_dist_14,\
                            ], dtype = np.int32)
    cdef int [:] stats_vec_c = stats_vec

    # Bounds for the population based on pop_tolerance.\
    # TODO: Turn all ints into memory view?
    lower_pop = stats_vec[3]/stats_vec[2]*(1-pop_tolerance)
    upper_pop = stats_vec[3]/stats_vec[2]*(1+pop_tolerance)
    '''
    The next vector contains a lot of important contants:
    * population of each precinct 
    * county number for each precinct
    * district for each of the precincts
    * 1 if precinct that are on the boundary of the state and 0 otherwise.
    * population of the predominant race of each precinct
    * area of each precinct
    * number of votes for the republican candidate
    * number of votes for the democratic candidate
    '''
    precinct_np = np.array([data1['TOTALPOP'],data1['COUNTY'],\
                            data1['DISTRICT'],data1['ST_BORDER'],\
                            data1['RACEPOP'],data1['AREA'],\
                            data1['REPUB_VOTE'],data1['DEM_VOTE']])
#    precinct_np = np.array([[1000,1100,1050,1025,1025,950,750,550,600,500,400,1010,990,1000,1075,925,1000,5500,950,0], \
#                            [1,6,6,9,13,13,10,13,11,12,15,3,4,5,8,15,6,16,3,0],\
#                            [1,2,2,2,3,3,3,3,3,3,3,1,1,1,2,3,2,4,1,0],\
#                            [0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,1,0,0]],dtype = np.int32)
    cdef double [:,:] precinct_np_c = precinct_np

    district_pop = np.zeros(stats_vec[2], dtype = np.int32)
    for i in range(stats_vec[0]):
        district_pop[int(precinct_np_c[2,i])-1] += int(precinct_np_c[0,i])
    cdef int[:] district_pop_c = district_pop
    # # cdef np.ndarray[int, mode='c', ndim = 2] boundary_precincts
    # cdef int bound_precincts[23][2]
    
    ndw = num_districts_won(precinct_np_c[2]) #TODO: Record the initial districting
    for i in range(n):
        change_state(bound_precincts_c,neighbors_set_c,precinct_np_c, stats_vec_c, district_pop_c,lower_pop,upper_pop) 
        # print(i)
        # if (i%2**15)==0:
        #     print(i)
        # pass
    pass
    # What is faster: adding the new number of districts won to an array or
    # passing the number of districts won to a file?

# cdef build_initial_boundary_precincts():
    
#     # Display the districts that each precinct on the boundary is adjacent to.
#     # Build dataframe with the precinct as the first entry and district as the second entry.
#     # Precinct 20 is the border of the state.
#     # cdef np.ndarray boundary_precincts = np.array([[1,2],[1,3],[2,1],[2,3],[3,3],[4,3],[5,2],[6,2],[7,2],\
#     #                       [9,1],[9,2],[11,1],[12,3],[14,2],[14,4],\
#     #                       [15,1],[15,4],[18,1],[18,2],[20,1],[20,2],[20,3],[20,4]], dtype = np.int32)
#     cdef int bound_precincts[23][2]
#     bound_precincts[:] = 
#     return bound_precincts