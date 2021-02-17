function AggregateAnalysis(satellite_name, EOIRshape, EOIRparams, Keplerianelts)
%{
     - EOIRshape is box, cone, coupler, cylinder, plate, or sphere
     - EOIRparams is an ARRAY (can be one element) whose parameters and order are 
    specified here: https://help.agi.com/stk/Subsystems/connectCmds/connectCmds.htm#cmd_EOIR.htm
     - Keplerian is a 6-element array whose entries represent the 6 Keplerian
    elements of the satellite. The entries are the 
    mean motion, (degrees/sec) 
    eccentricity, (unitless)
    inclination, (degrees)
    argument of perigee, (degrees)
    right ascension, (degrees)
    mean anomaly, (degrees)
    respectively. 
     - satellite_name is the name of the satellite. This can be whatever
     you'd like
%}
%% Prompt the user
if nargin == 0
    [satellite_name, EOIRshape, EOIRparams, Keplerianelts, sizeshapetype, locationtype, nodetype] = prompt_user();
    disp("EOIRshape is "+EOIRshape)
    disp("EOIRparams are:")
    disp(EOIRparams)
    disp("Keplerianelts are:")
    disp(Keplerianelts)
else
    sizeshapetype = 'eSizeShapeMeanMotion';
    locationtype = 'eLocationMeanAnomaly';
    nodetype = 'eAscNodeRAAN';
    EOIRshape = lower(string(EOIRshape));
end
%% Getting STK server
app = actxGetRunningServer('STK12.application');
root = app.Personality2;
scenario = root.CurrentScenario();
%% Get Radar Cross Section
disp("Running Radar Cross section Calculation")
RCSavg = rcs_calculation(satellite_name);
%% Building Satellite
disp("Setting up STK objects")
satellite = scenario.Children.New('eSatellite',"testsat");
keplerian = satellite.Propagator.InitialState.Representation.ConvertTo('eOrbitStateClassical');
keplerian.SizeShapeType = sizeshapetype;
keplerian.LocationType = locationtype;
keplerian.Orientation.AscNodeType = nodetype;
if sizeshapetype == "eSizeShapeMeanMotion"
    keplerian.SizeShape.MeanMotion = Keplerianelts(1);
    keplerian.SizeShape.Eccentricity = Keplerianelts(2);
elseif sizeshapetype == "eSizeShapeAltitude"
    keplerian.SizeShape.ApogeeAltitude = Keplerianelts(1);
    keplerian.SizeShape.PerigeeAltitude = Keplerianelts(2);
elseif sizeshapetype == "eSizeShapePeriod"
    keplerian.SizeShape.Eccentricity = Keplerianelts(1);
    keplerian.SizeShape.Period = Keplerianelts(2);
elseif sizeshapetype == "eSizeShapeRadius"
    keplerian.SizeShape.ApogeeRadius = Keplerianelts(1);
    keplerian.SizeShape.PerigeeRadius = Keplerianelts(2);    
elseif sizeshapetype == "eSizeShapeSemimajorAxis"
    keplerian.SizeShape.Eccentricity = Keplerianelts(1);
    keplerian.SizeShape.SemiMajorAxis  = Keplerianelts(2);
end
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

disp("Running Radar Detectability Analysis")
 radardet = RadarAnalysis(root);
 disp(radardet)
%% Set EOIR shape
if EOIRshape == "box"
    root.ExecuteCommand("EOIR */Satellite/testsat Shape Type Box "+EOIRparams(1)+" "+EOIRparams(2)+" "+EOIRparams(3)+" Reflectance 17.5");
elseif EOIRshape == "cone"    
    root.ExecuteCommand("EOIR */Satellite/testsat Shape Type Cone "+EOIRparams(1)+" "+EOIRparams(2)+" Reflectance 17.5");
elseif EOIRshape == "coupler"    
    root.ExecuteCommand("EOIR */Satellite/testsat Shape Type Coupler "+EOIRparams(1)+" "+EOIRparams(2)+" "+EOIRparams(3)+" Reflectance 17.5");
elseif EOIRshape == "cylinder"
    root.ExecuteCommand("EOIR */Satellite/testsat Shape Type Cylinder "+EOIRparams(1)+" "+EOIRparams(2)+" Reflectance 17.5");
elseif EOIRshape == "plate"
    root.ExecuteCommand("EOIR */Satellite/testsat Shape Type Plate "+EOIRparams(1)+" "+EOIRparams(2)+" Reflectance 17.5");
elseif EOIRshape == "sphere"   
    root.ExecuteCommand("EOIR */Satellite/testsat Shape Type Sphere "+EOIRparams(1)+" Reflectance 17.5");
end
%% Get Analyses
% disp("Running Radar Detectability Analysis")
% radardet = RadarAnalysis(root);
% disp(radardet)
% disp("Running EOIR Detectability Analysis")
% eoirdet = EOIRAnalysis(root);
% disp(eoirdet)
% disp("Running Radar Trackability Analysis")
% radartrack = ActiveSat_access_radar(root);
% disp(radartrack)
% disp("Running EOIR TrackabilityAnalysis")
% eoirtrack = STK_access_optical(root);
% disp(eoirtrack)
%% Deleting Satellite
scenario.Children.Unload('eSatellite','testsat')