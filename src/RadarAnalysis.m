%% Initialize application
app=actxserver('STK12.application');
root = app.Personality2;
scenario = root.Children.New('eScenario','MATLAB_Test');
disp(scenario.InstanceName);
scenario.SetTimePeriod('30 Jun 2020 16:00:00.000','30 Aug 2020 16:00:00.000');
scenario.StartTime = '30 Jun 2020 16:00:00.000';
scenario.StopTime = '30 Jul 2020 16:00:00.000';
root.ExecuteCommand('Animate * Reset');
%% Insert satellites, facilities
facility = scenario.Children.New('eFacility','TestFacility');
facility.Position.AssignGeodetic(-68.9905,84.5464,1.98147);
satellite = scenario.Children.New('eSatellite','TestSatellite');
radar = facility.Children.New('eRadar','TestRadar');
%% Set satellite properties and propagate
satellite.SetPropagatorType('ePropagatorSGP4');
propagator = satellite.Propagator;
propagator.CommonTasks.AddSegsFromOnlineSource('43142');
propagator.AutoUpdateEnabled = true;
propagator.Step = 60
propagator.Propagate;
light = satellite.AccessConstraints.AddConstraint('eCstrLighting');
light.Condition = 'eDirectSun';
satellite.RadarCrossSection.Inherit = 0;
%% Set radar properties
radar.Model.Transmitter.FrequencySpecification = 'eRadarFrequencySpecFrequency'
radar.Model.Transmitter.Frequency = 0.45;
radar.Model.Transmitter.Power = 70;
radar.Model.AntennaControl.SetEmbeddedModel("Phased Array")
phased = radar.Model.AntennaControl.EmbeddedModel;
phased.BeamDirectionProvider.Enabled = 1;
phased.BeamDirectionProvider.Directions.AddObject(satellite)
phased.BeamDirectionProvider.LimitsExceededBehaviorType = 'eLimitsExceededBehaviorTypeIgnoreObject';
phased.ElementConfigurationType = 'eElementConfigurationTypePolygon';
phased.ElementConfiguration.NumElementsX = 64;
phased.ElementConfiguration.NumElementsY = 64;
phased.ElementConfiguration.NumSides = 4;
phased.ElementConfiguration.SpacingX = 0.5
%% Compute access between satellite and radar
access = satellite.GetAccessToObject(radar);
access.ComputeAccess;

%% Get Probability of Detection
PDT = access.DataProviders.Item('Radar SearchTrack').Exec(scenario.StartTime,scenario.StopTime,60)
SomeProbability = cell2mat(PDT.Interval.Item(cast(1,'int32')).DataSets.GetDataSetByName('S/T PDet1').GetValues)

%% Get the max probability for the trackability score
maxprob = 0;
for i=0:PDT.Interval.Count-1
    SomeProbability = cell2mat(PDT.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('S/T PDet1').GetValues);
    if max(SomeProbability) > maxprob
        maxprob = max(SomeProbability);
    end
end