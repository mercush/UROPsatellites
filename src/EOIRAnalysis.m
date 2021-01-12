%% Get Instance of STK
uiApplication = actxGetRunningServer('STK12.application');
root = uiApplication.Personality2;
scenario = root.CurrentScenario;

%% Get STK Objects
satellite = root.GetObjectFromPath('Satellite/SPACEBEE-1_43142');
place = root.GetObjectFromPath('Place/Ascension_Island_Saint_Helena_Ascension_and_Tristan_da_Cunha1');
radar = root.GetObjectFromPath('Place/Ascension_Island_Saint_Helena_Ascension_and_Tristan_da_Cunha1/Radar/Radar');
EOIR = root.GetObjectFromPath('Place/Ascension_Island_Saint_Helena_Ascension_and_Tristan_da_Cunha1/Sensor/Sensor');

%% Get Irradiance Data
sensorToTarget = EOIR.DataProviders.Item('EOIR Sensor To Target Metrics');
sensorToTarget.PreData = 'Satellite/SPACEBEE-1_43142 Sensor';
results = sensorToTarget.Exec(scenario.StartTime,scenario.StopTime,60);
datasets = results.DataSets;

% Time = cell2mat(datasets.GetDataSetByName('Time').GetValues);

%% Get Visual Magnitude from Irradiance Data
% v_mag = zeros(size(computedIntervals,1),1);
% for temp=1:size(computedIntervals,1)
%     scenario.Animation.StartTime = computedIntervals{temp};
%     root.Rewind()
%     irradiance_data = EOIR.DataProviders.Item('EOIR Sensor To Target Metrics').Exec(scenario.StartTime,scenario.StopTime,60)
%     % irradiance = cell2mat(irradiance_data.DataSets.GetDataSetByName('Effective target irradiance').GetValues);
%     % v_mag(temp)= -2.5*log10(irradiance/(1.14*10^(-12)))+0.03;
% end
% r = v_mag;

%% More info
%https://help.agi.com/stkdevkit/index.htm#../Subsystems/connectCmds/Content/cmd_EOIRDetails.htm#desc
%https://help.agi.com/stkdevkit/index.htm#stkObjects/ObjModMatlabCodeSamples.htm#131