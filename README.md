# UROPsatellites
Some code for my UROP. Running the MATLAB scripts is as easy as opening src/DetectabilityTesting/DetectabilityTesting.sc then running one of these MATLAB scripts.
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
## Troubleshooting
* If you're having a hard time connecting STK and MATLAB try doing the following:
1. Close STK.
2. Run `clear` in the MATLAB command window. This should take 1 to 2 seconds. Note that this will clear all variables saved in the MATLAB command window.
3. reopen STK.
4. Try to run the MATLAB script again
* Supposedly, getting the irradiance data is faster if the EOIR synthetic scene is closed.
In the RCS_Calculator.mlx file, set the numberical parameter of the `mesh` function to either 0.1 or 0.5 so that MATLAB doesn't crash. Rendering the image takes about a minute.
