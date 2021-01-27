function [r1, r2] = AggregateAnalysis(EOIRShape, Keplerianelts, satellite_name)
%{
     - EOIRShape is a 3-element array whose entries reprsent height, width,
    and depth respectively.
     - Keplerian is a 6-element array whose entries represent the 6 Keplerian
    elements of the satellite. The entries are the mean motion,
    eccentricity, inclination, argument of perigee, right ascension, and
    mean anomaly, respectively
     - satellite_name is the name of the satellite. This can be whatever
     you'd like
%}
satellite_name = string(satellite_name);
%% Getting STK server
app = actxGetRunningServer('STK12.application');
root = app.Personality2;
scenario = root.CurrentScenario();
RCSavg = rcs_calculation();
%% Building Satellite
satellite = scenario.Children.New('eSatellite',satellite_name);
keplerian = satellite.Propagator.InitialState.Representation.ConvertTo('eOrbitStateClassical');
keplerian.SizeShapeType = 'eSizeShapeMeanMotion';
keplerian.LocationType = 'eLocationMeanAnomaly';
keplerian.Orientation.AscNodeType = 'eAscNodeRAAN';
keplerian.SizeShape.MeanMotion = Keplerianelts(1);
keplerian.SizeShape.Eccentricity = Keplerianelts(2);
keplerian.Orientation.Inclination = Keplerianelts(3);
keplerian.Orientation.ArgOfPerigee = Keplerianelts(4);
keplerian.Orientation.AscNode.Value = Keplerianelts(5);
keplerian.Location.Value = Keplerianelts(6);
satellite.Propagator.InitialState.Representation.Assign(keplerian);
satellite.Propagator.Propagate;
satellite.Propagator.InitialState.Representation.Assign(keplerian);
satellite.Propagator.Propagate;
%% Satellite radar and EOIR properties
satellite.RadarCrossSection.Inherit = 0;
satellite.RadarCrossSection.Model.FrequencyBands.Item(int32(0)).ComputeStrategy.ConstantValue = RCSavg;
root.ExecuteCommand("EOIR */Satellite/"+satellite_name+" Shape Type Box "+EOIRShape(1)+" "+EOIRShape(2)+" "+EOIRShape(3)+" Reflectance 17.5");

%% Get Radar and EOIR Analyses
r1 = RadarAnalysis(root, satellite_name);
r2 = EOIRAnalysis(root, satellite_name);
scenario.Children.Unload('eSatellite',satellite_name)