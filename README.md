# UROPsatellites
Some code for my UROP
## Description of the files:
### TLEData
Class that scapes for the TLE data of some 2000 satellites from the Celestrak website. It has several methods that get satellite information from these data.
### EOIRSetting
This is a function that returns the visual magnitude of the SPACEBEE satellite at several times of the month. The EOIR, facility, and satellite are all set up in a particular way in this file. EOIR raw sensor data files are saved in `./DetectabilityTesting/MoreEOIRFiles`. 
### ActiveSate_access_radar
Gets information from the TLE data collected from the Celestrak site. Simulates satellites with these parameters and gets their access from STK.
### DifferencePostedRecorded
Gets the difference between the time that a satellite's TLE data was collected and published on the Celestrak website.
### PlotData
Plots a histogram with of the difference of a satellite's TLE data being published and recorded against the frequency that this value is in some range.
### RCS_Calculator
Given a .STL file, it gets the radar cross section of a satellite with the shape described in the .STL file
### VisualMagnitudeFromEOIRData
Given en EOIR raw sensor data file, it calculates the visual magnitude of the satellite.
