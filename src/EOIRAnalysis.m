function r = EOIRAnalysis
%% Get Instance of STK
uiApplication = actxGetRunningServer('STK12.application');
root = uiApplication.Personality2;
scenario = root.CurrentScenario;
root.UnitPreferences.SetCurrentUnit('PowerUnit', 'W')
root.UnitPreferences.SetCurrentUnit('SmallDistanceUnit', 'cm')

%% Get STK Objects
satellite = root.GetObjectFromPath('Satellite/SPACEBEE-1_43142');
place = root.GetObjectFromPath('Place/Ascension_Island_Saint_Helena_Ascension_and_Tristan_da_Cunha1');
radar = root.GetObjectFromPath('Place/Ascension_Island_Saint_Helena_Ascension_and_Tristan_da_Cunha1/Radar/Radar');
EOIR = root.GetObjectFromPath('Place/Ascension_Island_Saint_Helena_Ascension_and_Tristan_da_Cunha1/Sensor/EOIR');

%% Get Irradiance Data
sensorToTarget = EOIR.DataProviders.Item('EOIR Sensor To Target Metrics');
sensorToTarget.PreData = 'Satellite/SPACEBEE-1_43142 Band1';
results = sensorToTarget.ExecElements(scenario.StartTime,scenario.StopTime,60,{...
    'Effective target irradiance'});
datasets = results.DataSets;
irradiance = results.DataSets.ToArray();
%% Get Visual Magnitude from Irradiance Data
v_mag = zeros(1,numel(irradiance));
s = size(irradiance);
for temp1=0:s(1)-1
    for temp2=1:s(2)
       v_mag(s(2)*temp1+temp2)= -2.5*log10(irradiance{s(2)*temp1+temp2}/(1.14*10^(-12)))+0.03;
    end
end
r = v_mag;