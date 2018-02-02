# -*- coding: utf-8 -*-
"""
Created on Sun Jan  14 23:35:32 2018

@author: Sanata

I clean a census PDF table from Benin's 2016 census. 
The dataset is missing identifiers and administrative labels, 
with irregular formating due to conversion from PDF to CSV.

"""

import pandas as pd
import matplotlib.pyplot as plt

# import data 
popdem = pd.read_csv('census-villages-2013.csv', sep=',',
                      encoding='latin-1', 
                      converters={1: lambda x: x.replace(" ", ""), 
                                  2: lambda x: x.replace(" ", ""), 
                                  3: lambda x: x.replace(" ", ""), 
                                  4: lambda x: x.replace(" ", "")})                                                                     

popdem.info()
popdem.head()
    
colnames = list(popdem) #convert numeric
popdem[colnames[1:6]] = popdem[colnames[1:6]].apply(pd.to_numeric, errors='coerce')

popdem.info()
popdem.head()

popdem['village'] = popdem['village'].str.strip() #strip whitespace from char variable

#delete null village values (empty lines from original PDF table format) 
empty_loc = popdem.index.values[ popdem['village'] == "" ].tolist()
popdem.drop(empty_loc, inplace=True)



# define functions
def getlocstr(df, col, strg):
    """
    Returns index of a string (a placeholder for grep in R)
    """
    str_bool = df[col].str.match(strg) == True
    str_loc = df.index.values[str_bool].tolist()
    return str_loc 
    

def getadm(df, col, strg): 
    """
    This function finds an administrative unit and creates a categorical label for that unit
    """
    #find the adm unit label 
    adm_bool = df[col].str.match(strg) == True
    adm_loc = df.index.values[adm_bool].tolist()
    adm_lab = df[col][adm_loc].str.replace(strg, "").tolist()
    breaks = adm_loc + [df.index.values.max()]
    adm_name = pd.cut(df.index.values, bins=breaks, labels=adm_lab, right=False, include_lowest=True)
    return adm_name 

#create department, commune, and arrondissement labels 
dep_cat = getadm(df=popdem, col='village', strg='DEP:')
com_cat = getadm(df=popdem, col='village', strg='COM:')


#add labels to DF 
popdem['dep_name'] = dep_cat.astype(str) #convert categorical var to string 
popdem['com_name'] = com_cat.astype(str) 

#special code for arrondissements because of duplicates (concat arrond and commune)
arr_bool = popdem['village'].str.match('ARROND:') == True
arr_loc = popdem.index.values[arr_bool].tolist()
arr_com_name = list( map( str.__add__, popdem['village'][arr_loc].tolist(), popdem['com_name'][arr_loc].tolist() ) )
breaks = arr_loc + [popdem.index.values.max() ]
arr_cats = pd.cut(popdem.index.values, bins=breaks, labels=arr_com_name, right=False, include_lowest=True)
arr_name = arr_cats.astype(str)

popdem['arr_name'] = arr_name

#remove label rows 
dep_headers = getlocstr(df=popdem, col='village', strg='DEP:')
com_headers = getlocstr(df=popdem, col='village', strg='COM:')
arr_headers = getlocstr(df=popdem, col='village', strg='ARROND:')

popdem.drop(dep_headers + com_headers + arr_headers, inplace=True)
popdem.info()
popdem.head()

#delete remaining null values (empty lines from original PDF format)
nullvals = popdem.index.values[pd.isnull(popdem['num_hh'])]
popdem.drop( nullvals, inplace=True)


#Summary statistics with the clean dataset 
by_dep = popdem.groupby('dep_name')
by_dep
print(by_dep.size().head) #total villages/neighborhoods by department 
print(by_dep.sum())
print(by_dep.mean())

by_com = popdem.groupby('com_name')
print(by_com.size().head) #total villages/neighborhoods by commune
print(by_com.sum())
print(by_com.mean())

#plot histograms 

popdem.totalpop.plot.hist(bins=30, range=(0, 15000))
plt.title("Distribution of Village Populations")
plt.ylabel('count of villages')
plt.xlabel('Total Population')