function r = RadarAnalysis(root)
scenario = root.CurrentScenario();

satellite = root.GetObjectFromPath("Satellite/testsat");
for i = 1:7
    rad(i) = root.GetObjectFromPath(strcat('Place/facility_',num2str(i),'/Radar/Radar'));
    acc(i) = satellite.GetAccessToObject(rad);
    acc(i).ComputeAccess;
    
end
for i = 1:7
    accessdata(i) = acc(i).DataProviders.Item('Access Data').Exec(scenario.StartTime,scenario.StopTime,60);
    durations(i) = 0;
    for j = 0:accessdata(i).Count-1
        durations(i) = durations(i) + accessdata(i).Item(j).Datasets.GetDataSetByName('Duration').GetValues;
    end
    [argvalue, argmax] = max(durations);
end
radar = rad(argmax);
access = acc(argmax);

phased = radar.Model.AntennaControl.EmbeddedModel;
phased.BeamDirectionProvider.Directions.AddObject(satellite)
Probability = access.DataProviders.Item('Radar SearchTrack').Exec(scenario.StartTime,scenario.StopTime,60);
TotalProbability = [];
for i = 0:Probability.Interval.Count-1
    SomeProbability = cell2mat(Probability.Interval.Item(int32(i)).DataSets.GetDataSetByName('S/T PDet1').GetValues);
    TotalProbability = cat(1,TotalProbability,SomeProbability);
end
phased.BeamDirectionProvider.Directions.RemoveAll()
bar(TotalProbability);
title('Probability of Detection Over Time');
xlabel('Time')
ylabel('Probability of Detection')
r = max(TotalProbability);

