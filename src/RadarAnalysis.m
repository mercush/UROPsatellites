function r = RadarAnalysis
app = actxGetRunningServer('STK12.application');
root = app.Personality2;
scenario = root.CurrentScenario;

facility = root.GetObjectFromPath('Place/Ascension_Island_Saint_Helena_Ascension_and_Tristan_da_Cunha1');
satellite = root.GetObjectFromPath('Satellite/SPACEBEE-1_43142');
radar = root.GetObjectFromPath('Place/Ascension_Island_Saint_Helena_Ascension_and_Tristan_da_Cunha1/Radar/Radar');
access = satellite.GetAccessToObject(radar);
access.ComputeAccess;

Probability = access.DataProviders.Item('Radar SearchTrack').Exec(scenario.StartTime,scenario.StopTime,60);
maxprob = 0;
for i = 0:Probability.Interval.Count-1
    SomeProbability = cell2mat(Probability.Interval.Item(int32(i)).DataSets.GetDataSetByName('S/T PDet1').GetValues);
    if max(SomeProbability) > maxprob
        maxprob = max(SomeProbability);
    end
end
r = maxprob;