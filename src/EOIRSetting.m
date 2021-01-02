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
band1 = EOIR.Pattern.Bands.Item(int32(0))
disp(band1.NEI)
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
%% Computes Visual Magnitude
% v_mag = zeros(size(computedIntervals,1),1);
% for temp=1:size(computedIntervals,1)
%     scenario.Animation.StartTime = computedIntervals{temp};
%     root.Rewind()
%     irradiance_data = EOIR.DataProviders.Item('EOIR Sensor To Target Metrics').Exec(scenario.StartTime,scenario.StopTime,60)
%     % irradiance = cell2mat(irradiance_data.DataSets.GetDataSetByName('Effective target irradiance').GetValues);
%     % v_mag(temp)= -2.5*log10(irradiance/(1.14*10^(-12)))+0.03;
% end
% r = v_mag;
