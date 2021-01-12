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
results = sensorToTarget.Exec(scenario.StartTime,scenario.StopTime,60);
datasets = results.DataSets;

Time = cell2mat(datasets.GetDataSetByName('Time').GetValues);
irradiance = cell2mat(datasets.GetDataSetByName('Effective target irradiance').GetValues);
%% Get Visual Magnitude from Irradiance Data
% for temp=1:size(computedIntervals,1)
%     % v_mag(temp)= -2.5*log10(irradiance/(1.14*10^(-12)))+0.03;
% end
% r = v_mag;

%% More info
%https://help.agi.com/stkdevkit/index.htm#../Subsystems/connectCmds/Content/cmd_EOIRDetails.htm#desc
%https://help.agi.com/stkdevkit/index.htm#stkObjects/ObjModMatlabCodeSamples.htm#131