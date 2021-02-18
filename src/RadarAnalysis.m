function r = RadarAnalysis(root)
scenario = root.CurrentScenario();

satellite = root.GetObjectFromPath("Satellite/testsat");
for i = 1:7
    rad(i) = root.GetObjectFromPath(strcat("/Place/facility_"+num2str(i)+"/Radar/Radar"));
    rad(i).Model.AntennaControl.EmbeddedModel.BeamDirectionProvider.Directions.AddObject(satellite);
    acc(i) = satellite.GetAccessToObject(rad(i));
    acc(i).ComputeAccess;
    
end
for i = 1:7
    accessdata(i) = acc(i).DataProviders.Item('Access Data').Exec(scenario.StartTime,scenario.StopTime);
    durations(i) = sum(cell2mat(accessdata(i).Intervals.Item(0).Datasets.GetDataSetByName('Duration').GetValues));
    [argvalue, argmax] = max(durations);
end
radar = root.GetObjectFromPath("Place/facility_7/Radar/Radar");
access = acc(argmax);

Probability = access.DataProviders.Item('Radar SearchTrack').Exec(scenario.StartTime,scenario.StopTime,60);
TotalProbability = [];
for i = 0:Probability.Interval.Count-1
    SomeProbability = cell2mat(Probability.Interval.Item(int32(i)).DataSets.GetDataSetByName('S/T PDet1').GetValues);
    TotalProbability = cat(1,TotalProbability,SomeProbability);
end
bar(TotalProbability);
title('Probability of Detection Over Time');
xlabel('Time')
ylabel('Probability of Detection')
r = max(TotalProbability);

