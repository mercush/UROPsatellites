# -*- coding: utf-8 -*-
"""
Created on Wed Jun 22 21:32:25 2022

@author: scott
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Read in Irradiance values and convert to visual magnitude

# From STK reference
# https://help.agi.com/stk/LinkedDocuments/Visual_Magnitude_FAQ_Part_I_II.pdf

# Vmag = Vref - 2.5*log10(E/Eref)
# where
# E is irradiance values
# Vref is the visual magnitude of reference star
# Eref if irradiance of reference star



# Filename (change this to the name of the csv file)
# filename = r'C:\Users\scott\satellite_data\Data\Input_Data\ssrstellarinputs\test_1.csv'
# filename = r'C:\Users\scott\satellite_data\Data\Input_Data\ssrstellarinputs\InnerShell_test_1.csv'
# filename = r'C:\Users\scott\satellite_data\Data\Input_Data\ssrstellarinputs\MidShell_test_1.csv'
# filename = r'C:\Users\scott\satellite_data\Data\Input_Data\ssrstellarinputs\OuterShell_test_1.csv'
# filename = r'C:\Users\scott\satellite_data\Data\Ratings\DITdata_Endurosat\VisualMagntiudes.csv'
filename = r'C:\Users\scott\satellite_data\Data\Ratings\Visual_mag.csv'



# Read in data
df = pd.read_csv(filename,header=0)
df['Time'] = pd.to_datetime(df.Time) # Convert time to datetime

# Compute Vmag
Vref = 0.03 # Vega reference
Eref = 1.140129e-12 # Irradiance of Vega
Vmag = Vref - 2.5*np.log10(df.Irradiance/Eref)

# Insert into dataframe
df.insert(2,'Vmag',Vmag)

# Compute average of values < 15
Vavg = df['Vmag'][df.Vmag < 15].mean()


# Plot
fig, ax = plt.subplots()
ax.plot(df.Time,df.Vmag,'ob',label='Measurements')
ax.plot([df.Time.min(),df.Time.max()],[15,15],':r',label='Cutoff') # Reference line
ax.plot([df.Time.min(),df.Time.max()],[Vavg,Vavg],':b',label='Average = {}'.format(str(np.round(Vavg,3)))) # Reference line
ax.invert_yaxis()
ax.set_ylabel('Vmag (mag)')
ax.set_xlabel('Epoch')
ax.legend(loc="lower left")
