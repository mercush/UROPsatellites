%% Initialize application
clear;
app=actxserver('STK12.application');
root = app.Personality2;
scenario = root.Children.New('eScenario','MATLAB_Test');
disp(scenario.InstanceName);
scenario.SetTimePeriod('30 Jun 2020 16:00:00.000','30 Aug 2020 16:00:00.000');
scenario.StartTime = '30 Jun 2020 16:00:00.000';
scenario.StopTime = '30 Jul 2020 16:00:00.000';
root.ExecuteCommand('Animate * Reset');
%% Insert satellites, facilities, EOIR sensor
facility = scenario.Children.New('eFacility','TestFacility');
facility.Position.AssignGeodetic(-68.9905,84.5464,1.98147);
satellite = scenario.Children.New('eSatellite','TestSatellite');
EOIR = facility.Children.New('eSensor','TestEOIR');

%% Set Satellite and EOIR Properties
satellite.SetPropagatorType('ePropagatorSGP4');
propagator = satellite.Propagator;
propagator.CommonTasks.AddSegsFromOnlineSource('43142');
propagator.AutoUpdateEnabled = true;
propagator.Propagate;
light = satellite.AccessConstraints.AddConstraint('eCstrLighting');
light.Condition = 'eDirectSun';

EOIR.CommonTasks.SetPointingTargetedTracking('eTrackModeTranspond','eBoresightRotate','*/Satellite/TestSatellite');
EOIR.SetPatternType('eSnEOIR');
light = EOIR.AccessConstraints.AddConstraint('eCstrLighting');
light.Condition = 'ePenumbraOrUmbra';
%% Compute access and set animation time
access = satellite.GetAccessToObject(EOIR);
access.ComputeAccess;

%% Save EOIR Data
%root.ExecuteCommand('EOIRDetails */Satellite/TestSatellite/Sensor/TestEOIR SaveSceneRawData "C:\Users\Mauricio Barba\Documents\GitHub\UROPsatellites\src\DetectabilityTesting\MoreEOIRFiles"')