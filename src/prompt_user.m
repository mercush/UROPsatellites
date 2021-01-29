%{
Needs to output 
 - Satellite Name
 - EOIR type, eoir 
%}
sat_name = input("What's the satellite name (no spaces): ",'s');
while sum(isspace(sat_name)) ~= 0
    sat_name = input("Try Again. What's the satellite name (no spaces): ",'s');
end
eoirshape = lower(input("What's the EOIR shape? (Box, Cone, Coupler, Cylinder, Plate, Sphere): ",'s'));
while ~ismember(eoirshape,["box","cone","coupler","cylinder","plate","sphere"])
    eoirshape = lower(input("Try Again. What's the EOIR shape? (Box, Cone, Coupler, Cylinder, Plate, Sphere): ",'s'));
end
if eoirshape == "box"
    eoirparameters = input("What are the EOIR parameters? Input as <width>, <height>, <depth> (in meters): ",'s');
    eoirparameters = regexp(eoirparameters, ' *, *','split');
elseif eoirshape == "cone"
    eoirparameters = input("What are the EOIR parameters? Input as <height>, <radius>: ",'s');
    eoirparameters = regexp(eoirparameters, ' *, *','split');
elseif eoirshape == "coupler"
    eoirparameters = input("What are the EOIR parameters? Input as <radius1>, <height>, <radius2>: ",'s');
    eoirparameters = regexp(eoirparameters, ' *, *','split');
elseif eoirshape == "cylinder"
    eoirparameters = input("What are the EOIR parameters? Input as <height>, <radius>: ",'s');
    eoirparameters = regexp(eoirparameters, ' *, *','split');
elseif eoirshape == "plate"
    eoirparameters = input("What are the EOIR parameters? Input as <width>, <length>: ",'s');
    eoirparameters = regexp(eoirparameters, ' *, *','split');
elseif eoirshape == "sphere"
    eoirparameters = input("What are the EOIR parameters? Input as <radius>: ",'s');
    eoirparameters = regexp(eoirparameters, ' *, *','split');
end
%% Prompt size shape type for satellite
sizeshapetype = lower(input("What format do you want to input the size and shape?(Altitude, MeanMotion, ShapePeriod, ShapeRadius, SemimajorAxis)",'s'));
while ~ismember(sizeshapetype,["altitude","meanmotion","shapeperiod","shaperadius","semimajoraxis"])
    sizeshapetype = lower(input("Try again. What format do you want to input the size and shape?(Altitude, MeanMotion, ShapePeriod, ShapeRadius, SemimajorAxis)",'s'));
end
if sizeshapetype == "altitude"
    sizeshapetype = "eSizeShapeAltitude";
elseif sizeshapetype == "meanmotion"
    sizeshapetype = "eSizeShapeMeanMotion";
elseif sizeshapetype == "shapeperiod"
    sizeshapetype = "eSizeShapePeriod";
elseif sizeshapetype == "shaperadius"
    sizeshapetype = "eSizeShapeRadius";
elseif sizeshapetype == "semimajoraxis"
    sizeshapetype = "eSizeShapeSemimajorAxis";
end
%% Prompt Location type for satellite
locationtype = lower(input("What format do you want to input the location?(ArgumentOfLatitude, EccentricAnomaly, MeanAnomaly, TimePastAN, TimePastPerigee, TrueAnomaly)",'s'));
while ~ismember(locationtype,["argumentoflatitude","eccentricanomaly","meananomaly","timepastan","pastperigee","trueanomaly"])
    locationtype = lower(input("Try again. What format do you want to input the location?(ArgumentOfLatitude, EccentricAnomaly, MeanAnomaly, TimePastAN, TimePastPerigee, TrueAnomaly)",'s'));
end
if locationtype == "argumentoflatitude"
    locationtype = "eLocationArgumentOfLatitude";
elseif locationtype == "eccentricanomaly"
    locationtype = "eLocationEccentricAnomaly";
elseif locationtype == "meananomaly"
    locationtype = "eLocationMeanAnomaly";
elseif locationtype == "timepastan"
    locationtype = "eLocationTimePastAN";
elseif locationtype == "timepastperigee"
    locationtype = "eLocationTimePastPerigee";
elseif locationtype == "trueanomaly"
    locationtype = "eLocationTrueAnomaly";
end
%% Prompt ascending node type
nodetype = lower(input("What format do you want to input the location?(LAN, RAAN)",'s'));
while ~ismember(nodetype,["lan","raan"])
    nodetype = lower(input("Try again. What format do you want to input the size and shape?(LAN, RAAN)",'s'));
end
if nodetype == "raan"
    nodetype = "eAscNodeRAAN";
elseif nodetype == "lan"
    nodetype = "eAscNodeLAN";
end