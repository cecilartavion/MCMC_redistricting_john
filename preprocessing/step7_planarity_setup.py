import pandas as pd
#import networkx as nx
import ast
import numpy as np
import csv
import ast

file = r'$PATH/VTD2016-Shape_final_dataframe.csv'
data = pd.read_csv(file)
neighbors = data['NEIGHBORS']

#G = nx.Graph()
#G.add_nodes_from(list(range(len(neighbors))))

output = [''] * (len(neighbors)+1)
output[0] = 'N='+str(len(neighbors))

for i in range(len(neighbors)):
    one_nbhd = ast.literal_eval(neighbors[i])
    output[i+1] = str(i)+': '
    for j in range(len(one_nbhd)):
        if j!=len(one_nbhd)-1:
            output[i+1] = output[i+1] + str(one_nbhd[j]) + ' '
        else:
            output[i+1] = output[i+1] + str(one_nbhd[j]) + ' -1'
        
output
myFile = open('$PATH/planarity_precincts_GA_2016.csv', 'w')
with myFile:
    
    for line in output:
        myFile.write(line+'\n')
     
print("Writing complete")
