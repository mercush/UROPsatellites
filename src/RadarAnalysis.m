function r = RadarAnalysis(root)
scenario = root.CurrentScenario();
satellite = root.GetObjectFromPath("Satellite/testsat");
radar = root.GetObjectFromPath('Place/Ascension_Island_Saint_Helena_Ascension_and_Tristan_da_Cunha1/Radar/Radar');
access = satellite.GetAccessToObject(radar);
access.ComputeAccess;

phased = radar.Model.AntennaControl.EmbeddedModel;
phased.BeamDirectionProvider.Directions.AddObject(satellite)
Probability = access.DataProviders.Item('Radar SearchTrack').Exec(scenario.StartTime,scenario.StopTime,60);
TotalProbability = [];
for i = 0:Probability.Interval.Count-1
    SomeProbability = cell2mat(Probability.Interval.Item(int32(i)).DataSets.GetDataSetByName('S/T PDet1').GetValues);
    TotalProbability = TotalProbability + SomeProbability;
end
phased.BeamDirectionProvider.Directions.RemoveAll()
h = histogram(corrected_avg_v_mag);
title('Probability of Detection Over Time');
xlabel('Time')
ylabel('Probability of Detection')
r = max(TotalProbability);