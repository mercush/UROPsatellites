# UROPsatellites
Some code for my UROP. To get started, you'll want to run `git clone https://github.com/mauriciobarba/UROPsatellites.git`. Also, get a hang of how to use the `cd` command in your shell. Once you've figured that out, you'll want to `cd` into the UROPsatellites directory on your computer that you've just cloned. The base directory for these instructions is the UROPsatellites folder. Since I'm using a Linux machine, directories are written using forward slashes (`/`). If you're using a Windows shell, these should probably be replaed with backslashes (`\`). 
# Setup
### Dependencies
* MATLAB
* STK
* Python
* pip
### Setup Instructions
For running MATLAB scripts, do the following:
1. Open `src/DetectabilityTesting/DetectabilityTesting.sc` with STK
2. Run one of the MATLAB scripts located in `./src`. 

For running python scripts, do the following:
1. First, you'll want to make sure python and pip are installed on your machine. Instructions for how to set these up are [here](https://wiki.python.org/moin/BeginnersGuide/Download). Before running the clustering analysis, you'll have to set up and activate the python virtual environment.
2. `pip install virtualenv`
3. `python -m virtualenv ./ClusterAnalysis/cluster-env`
4. Depending on which shell you're using, activating the virtual environment is either `source ./ClusterAnalysis/cluster-env/bin/activate` or `source .\ClusterAnalysis\cluster-env\Scripts\activate`.
![howtoactivate](ClusterAnalysis/howtoactivatevenv.png)
5. `pip install -r requirements.txt`.
You'll have to activate the virtual environment every time you want to run the clustering analysis. 

### TLEData
Class that scapes for the TLE data of some 2000 satellites from the Celestrak website. It has several methods that get satellite information from these data.
### EOIRSetting
This is a function that returns the visual magnitude of the SPACEBEE satellite at several times of the month. The EOIR, facility, and satellite are all set up in a particular way in this file. EOIR raw sensor data files are saved in `./DetectabilityTesting/MoreEOIRFiles`. 
### ActiveSat_access_radar
Gets information from the TLE data collected from the Celestrak site. Simulates satellites with these parameters and gets their access from STK.
### DifferencePostedRecorded
Gets the difference between the time that a satellite's TLE data was collected and published on the Celestrak website.
### PlotData
Plots a histogram with of the difference of a satellite's TLE data being published and recorded against the frequency that this value is in some range.
### RCS_Calculator
Given a .STL file, it gets the radar cross section of a satellite with the shape described in the .STL file
### VisualMagnitudeFromEOIRData
Given en EOIR raw sensor data file, it calculates the visual magnitude of the satellite.
### Clustering Analysis
Plots the clusters of satellites in polar coordinates. Cartesian coordinates for these satellites are found in the groundtrush_cluster.xlsx excel file. 
## Troubleshooting
* If you're having a hard time connecting STK and MATLAB try doing the following:
1. Close STK.
2. Run `clear` in the MATLAB command window. This should take 1 to 2 seconds. Note that this will clear all variables saved in the MATLAB command window.
3. reopen STK.
4. Try to run the MATLAB script again
* Supposedly, getting the irradiance data is faster if the EOIR synthetic scene is closed. It takes a long time no matter what. Consequently, running EOIRAnalysis.m takes a while.
* If the DetectabilityTesting STK file is taking too long to open do the following:
1. Run `git status` to see if there were any changes to files related to STK. Such files are found in the DetectabilityTesting. If you don't see that any of these files have been altered I'm not really sure what the problem is. If they have been altered, continue following the steps.
2. Run `git restore` followed by the names of the STK-related files that have been altered. For example `git restore ./DetectabilityTesting/DetectabilityTesting.sc3`
* In the RCS_Calculator.mlx file, set the numerical parameter of the `mesh` function to either 0.1 or 0.5 so that MATLAB doesn't crash. Rendering the image takes about a minute.
* If `pip` or `python` aren't working, try `pip3` or `python3` respectively.
## Acknowledgements
All work under the ClusterAnalysis directory was done by Vishnu Narayanan
