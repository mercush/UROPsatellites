function r = EOIRAnalysis(root, satellite_name)
%% Get Instance of STK
scenario = root.CurrentScenario();
root.UnitPreferences.SetCurrentUnit('PowerUnit', 'W')
root.UnitPreferences.SetCurrentUnit('SmallDistanceUnit', 'cm')

%% Get STK Objects
satellite = root.GetObjectFromPath("Satellite/"+satellite_name);
EOIR = root.GetObjectFromPath('Place/Ascension_Island_Saint_Helena_Ascension_and_Tristan_da_Cunha1/Sensor/EOIR');
access = satellite.GetAccessToObject(EOIR);
access.ComputeAccess;
if nargin == 0
    EOIR.CommonTasks.SetPointingTargetedTracking('eTrackModeTranspond','eBoresightRotate', ...
    "*/Satellite/SPACEBEE-1_43142");
    root.ExecuteCommand("EOIR */ TargetConfig AddTarget Satellite/SPACEBEE-1_43142");
else
    EOIR.CommonTasks.SetPointingTargetedTracking('eTrackModeTranspond','eBoresightRotate', ...
    "*/Satellite/"+satellite_name);
    root.ExecuteCommand("EOIR */ TargetConfig AddTarget Satellite/"+satellite_name);
end
%% Get Irradiance Data
sensorToTarget = EOIR.DataProviders.Item('EOIR Sensor To Target Metrics');
if nargin == 0
    sensorToTarget.PreData = 'Satellite/SPACEBEE-1_43142 Band1';
else
    sensorToTarget.PreData = "Satellite/"+satellite_name+" Band1";
end
results = sensorToTarget.ExecElements(scenario.StartTime,scenario.StopTime,60,{...
    'Effective target irradiance'});
irradiance = results.DataSets.ToArray();
%% Get Visual Magnitude from Irradiance Data
v_mag = zeros(1,numel(irradiance));
s = size(irradiance);
for temp1=0:s(1)-1
    for temp2=1:s(2)
       if irradiance{s(2)*temp1+temp2} == 0
           v_mag(s(2)*temp1+temp2) = 0;
       else
       v_mag(s(2)*temp1+temp2)= -2.5*log10(irradiance{s(2)*temp1+temp2}/(1.14*10^(-12)))+0.03;
       end
    end
end
if nargin == 0
    root.ExecuteCommand("EOIR */ TargetConfig RemoveTarget Satellite/SPACEBEE-1_43142");
else
    root.ExecuteCommand("EOIR */ TargetConfig RemoveTarget Satellite/"+satellite_name);
end
r = v_mag;