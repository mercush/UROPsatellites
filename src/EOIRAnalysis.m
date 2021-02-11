function r = EOIRAnalysis(root)
%% Get Instance of STK
scenario = root.CurrentScenario();
root.UnitPreferences.SetCurrentUnit('PowerUnit', 'W')
root.UnitPreferences.SetCurrentUnit('SmallDistanceUnit', 'cm')

%% Get STK Objects
satellite = root.GetObjectFromPath("Satellite/testsat");
EOIR = root.GetObjectFromPath('Place/Ascension_Island_Saint_Helena_Ascension_and_Tristan_da_Cunha1/Sensor/EOIR');
access = satellite.GetAccessToObject(EOIR);
access.ComputeAccess;

EOIR.CommonTasks.SetPointingTargetedTracking('eTrackModeTranspond','eBoresightRotate', ...
"*/Satellite/testsat");
root.ExecuteCommand("EOIR */ TargetConfig AddTarget Satellite/testsat");

%% Get Irradiance Data
sensorToTarget = EOIR.DataProviders.Item('EOIR Sensor To Target Metrics');

sensorToTarget.PreData = "Satellite/testsat Band1";

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
root.ExecuteCommand("EOIR */ TargetConfig RemoveTarget Satellite/testsat");
idx = 1;
for temp = v_mag
    if temp ~= 0
        corrected_avg_v_mag(idx) = temp;
        idx = idx + 1;
    end
end
corrected_avg_v_mag_value = mean(corrected_avg_v_mag);
h = histogram(corrected_avg_v_mag);
title('Visual Magnitude of Satellite Over Time');
xlabel('Time')
ylabel('Visual Magnitude')
r = corrected_avg_v_mag_value;