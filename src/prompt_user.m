function [satellite_name, eoirshape, eoirparameters, keplerianelements, sizeshapetype, locationtype, nodetype] = prompt_user()
satellite_name = input("What's the name of the satellite in the Satellites folder?: ",'s');
eoirshape = lower(input("What's the EOIR shape? (Box, Cone, Coupler, Cylinder, Plate, Sphere): ",'s'));
while ~ismember(eoirshape,["box","cone","coupler","cylinder","plate","sphere"])
    eoirshape = lower(input("Try Again. What's the EOIR shape? (Box, Cone, Coupler, Cylinder, Plate, Sphere): ",'s'));
end
if eoirshape == "box"
    eoirparameters = input("What are the EOIR parameters? Input as <width>, <height>, <depth> (in meters): ",'s');
    eoirparameters = str2double(regexp(eoirparameters, ' *, *','split'));
elseif eoirshape == "cone"
    eoirparameters = input("What are the EOIR parameters? Input as <height>, <radius>: ",'s');
    eoirparameters = str2double(regexp(eoirparameters, ' *, *','split'));
elseif eoirshape == "coupler"
    eoirparameters = input("What are the EOIR parameters? Input as <radius1>, <height>, <radius2>: ",'s');
    eoirparameters = str2double(regexp(eoirparameters, ' *, *','split'));
elseif eoirshape == "cylinder"
    eoirparameters = input("What are the EOIR parameters? Input as <height>, <radius>: ",'s');
    eoirparameters = str2double(regexp(eoirparameters, ' *, *','split'));
elseif eoirshape == "plate"
    eoirparameters = input("What are the EOIR parameters? Input as <width>, <length>: ",'s');
    eoirparameters = str2double(regexp(eoirparameters, ' *, *','split'));
elseif eoirshape == "sphere"
    eoirparameters = input("What are the EOIR parameters? Input as <radius>: ",'s');
    eoirparameters = str2double(regexp(eoirparameters, ' *, *','split'));
end
%% Prompt size shape type for satellite
sizeshapetype = lower(input("What format do you want to input the size and shape?(Altitude, MeanMotion, ShapePeriod, ShapeRadius, SemimajorAxis): ",'s'));
while ~ismember(sizeshapetype,["altitude","meanmotion","shapeperiod","shaperadius","semimajoraxis"])
    sizeshapetype = lower(input("Try again. What format do you want to input the size and shape?(Altitude, MeanMotion, ShapePeriod, ShapeRadius, SemimajorAxis): ",'s'));
end
if sizeshapetype == "altitude"
    sizeshapetype = 'eSizeShapeAltitude';
elseif sizeshapetype == "meanmotion"
    sizeshapetype = 'eSizeShapeMeanMotion';
elseif sizeshapetype == "shapeperiod"
    sizeshapetype = 'eSizeShapePeriod';
elseif sizeshapetype == "shaperadius"
    sizeshapetype = 'eSizeShapeRadius';
elseif sizeshapetype == "semimajoraxis"
    sizeshapetype = 'eSizeShapeSemimajorAxis';
end
%% Prompt ascending node type
nodetype = lower(input("What format do you want to input the location?(LAN, RAAN): ",'s'));
while ~ismember(nodetype,["lan","raan"])
    nodetype = lower(input("Try again. What format do you want to input the size and shape?(LAN, RAAN): ",'s'));
end
if nodetype == "raan"
    nodetype = 'eAscNodeRAAN';
elseif nodetype == "lan"
    nodetype = 'eAscNodeLAN';
end
%% Prompt Location type for satellite
locationtype = lower(input("What format do you want to input the location?(ArgumentOfLatitude, EccentricAnomaly, MeanAnomaly, TimePastAN, TimePastPerigee, TrueAnomaly): ",'s'));
while ~ismember(locationtype,["argumentoflatitude","eccentricanomaly","meananomaly","timepastan","pastperigee","trueanomaly"])
    locationtype = lower(input("Try again. What format do you want to input the location?(ArgumentOfLatitude, EccentricAnomaly, MeanAnomaly, TimePastAN, TimePastPerigee, TrueAnomaly): ",'s'));
end
if locationtype == "argumentoflatitude"
    locationtype = 'eLocationArgumentOfLatitude';
elseif locationtype == "eccentricanomaly"
    locationtype = 'eLocationEccentricAnomaly';
elseif locationtype == "meananomaly"
    locationtype = 'eLocationMeanAnomaly';
elseif locationtype == "timepastan"
    locationtype = 'eLocationTimePastAN';
elseif locationtype == "timepastperigee"
    locationtype = 'eLocationTimePastPerigee';
elseif locationtype == "trueanomaly"
    locationtype = 'eLocationTrueAnomaly';
end
%% Set keplerianelements variable
if sizeshapetype == "eSizeShapeAltitude"
    keplerianelements(1) = input("Enter the apogee altitude: ");
    keplerianelements(2) = input("Enter the perigee altitude: ");
elseif sizeshapetype == "eSizeShapeMeanMotion"
    keplerianelements(1) = input("Enter the mean motion: ");
    keplerianelements(2) = input("Enter the eccentricity: ");
elseif sizeshapetype == "eSizeShapePeriod"
    keplerianelements(1) = input("Enter the eccentricity: ");
    keplerianelements(2) = input("Enter the period: ");
elseif sizeshapetype == "eSizeShapeRadius"
    keplerianelements(1) = input("Enter the apogee radius: ");
    keplerianelements(2) = input("Enter the perigee radius: ");
elseif sizeshapetype == "eSizeShapeSemimajorAxis"
    keplerianelements(1) = input("Enter the eccentricity: ");
    keplerianelements(2) = input("Enter the semimajor axis: ");
end
keplerianelements(3) = input("Enter the inclination: ");
keplerianelements(4) = input("Enter the argument of perigee: ");
if nodetype == "eAscNodeRAAN"
    keplerianelements(5) = input("Enter the RAAN: ");
elseif nodetype == "eAscNodeLAN"
    keplerianelements(5) = input("Enter the LAN: ");
end
if locationtype == "eLocationArgumentOfLatitude"
    keplerianelements(6) = input("Enter the argument of latitude: ");
elseif locationtype == "eLocationEccentricAnomaly"
    keplerianelements(6) = input("Enter the eccentric anomaly: ");
elseif locationtype == "eLocationMeanAnomaly"
    keplerianelements(6) = input("Enter the mean anomaly: ");
elseif locationtype == "eLocationTimePastAN"
    keplerianelements(6) = input("Enter the time past ascending node: ");
elseif locationtype == "eLocationTimePastPerigee"
    keplerianelements(6) = input("Enter the time past perigee: ");
elseif locationtype == "eLocationTrueAnomaly"
    keplerianelements(6) = input("Enter the true anomaly: ");
end