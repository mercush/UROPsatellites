%% Initialize application
app=actxserver('STK12.application');
root = app.Personality2;
scenario = root.Children.New('eScenario','MATLAB_Test');
disp(scenario.InstanceName);
%% Insert satellites, facilities, EOIR sensor
facility = scenario.Children.New('eFacility','TestFacility');
facility.Position.AssignGeodetic(-68.9905,84.5464,1.98147);
satellite = scenario.Children.New('eSatellite','TestSatellite');
EOIR = facility.Children.New('eSensor','TestEOIR');
EOIR.CommonTasks.SetPointingTargetedTracking('eTrackModeTranspond','eBoresightRotate','*/Satellite/TestSatellite');
EOIR.SetPatternType('eSnEOIR');
%% Save EOIR Data
%root.ExecuteCommand('EOIRDetails */Satellite/TestSatellite/Sensor/TestEOIR SaveSceneRawData "C:\Users\Mauricio Barba\Documents\GitHub\UROPsatellites\src\DetectabilityTesting\MoreEOIRFiles"')