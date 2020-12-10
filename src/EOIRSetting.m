function r = EOIRSetting()
% Directory should be set with microsoft format (backslashes instead of
% slashes)
%% Initialize application
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

EOIR.CommonTasks.SetPointingTargetedTracking('eTrackModeTranspond',...
    'eBoresightRotate', '*/Satellite/TestSatellite');
EOIR.SetPatternType('eSnEOIR');
light = EOIR.AccessConstraints.AddConstraint('eCstrLighting');
light.Condition = 'ePenumbraOrUmbra';
band1 = EOIR.Pattern.Bands.Item(int32(0));
band1.HorizontalHalfAngle = 0.3;
band1.VerticalHalfAngle = 0.3;
band1.OpticalInputMode = 'eFocalLengthAndApertureDiameter';
band1.EffFocalL = 100;
band1.EntrancePDia = 50;
root.ExecuteCommand('EOIR */ TargetConfig AddTarget Satellite/TestSatellite');
%% Compute access
access = satellite.GetAccessToObject(EOIR);
access.ComputeAccess;

% IAgStkAccess access: Access calculation
% Get and display the Computed Access Intervals
intervalCollection = access.ComputedAccessIntervalTimes;

% Set the intervals to use to the Computed Access Intervals
computedIntervals = intervalCollection.ToArray(0, -1);
access.SpecifyAccessIntervals(computedIntervals)
%% Save EOIR Data
for i=1:size(computedIntervals,1)
    scenario.Animation.StartTime = computedIntervals{i};
    root.Rewind();
    if computedIntervals{i}(2) == ' '
        filename = append(computedIntervals{i}(1),computedIntervals{i}(3:5),...
            computedIntervals{i}(9:10),computedIntervals{i}(12:13),...
            computedIntervals{i}(15:16), computedIntervals{i}(18:19),...
            computedIntervals{i}(21:23));
    else
        filename = append(computedIntervals{i}(1:2),...
        computedIntervals{i}(4:6), computedIntervals{i}(8:11),...
        computedIntervals{i}(13:14),computedIntervals{i}(16:17),...
        computedIntervals{i}(19:20),computedIntervals{i}(22:24));
    end
    root.ExecuteCommand(append('EOIRDetails */Facility/TestFacility/',...
        'Sensor/TestEOIR SaveSceneRawData "',pwd,'\DetectabilityTesting\MoreEOIRFiles\',filename,'.txt"'));
end
%% Computes the visual magnitude from each file
v_mag = VisualMagnitudeFromEOIRData(append(pwd,'\DetectabilityTesting\MoreEOIRFiles\'));
r = v_mag;
%% Close Application
root.CloseScenario
end
