import pandas as pd
import ast

file1 = r'$PATH/VTD2016-Shape_final_dataframe.csv'
data1 = pd.read_csv(file1)
file2 = r'$PATH/embedding.txt'
data2 = pd.read_csv(file2)
neighbors = data1['NEIGHBORS']

for i in range(len(data2)):
    newn = data2['N=2876'][i]
    str_len = len(str(i))+2
    neighbors.loc[i] = '['+newn[str_len:-3]+']'

data1['NEIGHBORS'] = neighbors
data1.columns
myFile = open('$PATH/mcmc_ready.csv', 'w')
data1.to_csv(myFile, encoding='utf-8', index=False)