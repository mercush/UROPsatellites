function r = ActiveSat_access_radar(root)
%% STK_access_radar
facilitypos1 = [-37.603, 140.388, 0.013851; -45.639, 167.361, 0.344510; -44.040, -176.375, 0.104582; -43.940, -72.450, 0.075715; -51.655, -58.681, 0.127896; -34.070, 19.703, 0.416372; -34.285, 115.934, 0.134033; -49.530, 69.910, 0.199042];
facilitypos2 = [18.872     -103.290    0.735454; -15.096      -44.836    0.697796; -15.099       15.875    1.365027; -15.818       45.893    -0.007232; 5.159      -53.637    0.037340; 7.612      134.631    0.138556; -15.531      134.143    0.196179; -22.500      113.989    0.068118; -7.261       72.376    -0.064980; -15.273      166.878    0.196300; -13.890     -171.938    0.392109; 18.532      -74.135    0.291372; -9.798     -139.073    0.845423; -27.128     -109.355    0.149995; -7.947      -14.370    0.216315; 6.890      158.216    0.311603; 16.899      102.561    0.167567; 15.097      -15.726    0.087358; 14.846       14.217    0.359288; 14.846       44.914    2.071660; 17.396       76.263    0.382021; 19.787     -155.658    1.517667; -15.450      -73.848    4.202630];
facilitypos3 = [44.676     -105.521    1.249258; 44.554      -75.459    0.070607; 40.506     -124.123    0.002242; 43.040       -8.992    0.411682; 47.014      -53.061    0.191380; 45.481       15.224    0.252010; 44.891       44.590    0.085764; 44.537       75.371    0.340541; 44.384      104.729    1.223731; 45.271      135.576    0.399098; 53.312      159.728    0.536244; 55.395     -162.156    0.673701];
facilitypos4 = [70.024     -162.191    0.013845; 69.175       18.258    0.314617; 67.922     -103.469    -0.005155; 74.757      -46.014    2.651167; 72.423       75.289    0.011348; 71.372      136.045    0.010589];
facilitypos = [facilitypos1;facilitypos2;facilitypos3;facilitypos4];
%% Initiate Scenario
scenario = root.CurrentScenario();

%% Insert facilities
for n = 1:49
    facilityname = strcat( 'facility_',num2str(n) );
    facility = scenario.Children.New('eFacility',facilityname);
    lat = facilitypos(n,1);
    long = facilitypos(n,2);
    alt = facilitypos(n,3);
    facility.Position.AssignGeodetic(lat,long,alt);
    sensorname = strcat( 'sensor_',num2str(n) );
    sensor = facility.Children.New('eSensor',sensorname);

    pattern1 = sensor.Pattern;
    pattern1.ConeAngle = 60;
end

%% Create sensor constellation
constellation = root.CurrentScenario.Children.New('eConstellation','SensorNetwork');
for i = 1:49
    senschain = strcat( 'Facility/facility_ ',num2str(i),'/Sensor/sensor_',num2str(i) );
    constellation.Objects.Add(senschain);
end

%% Create chains and compute access


chainname = 'chain_1';
chain = root.CurrentScenario.Children.New('eChain', chainname);

satchain = 'Satellite/testsat';
chain.Objects.Add(satchain);

chain.Objects.Add('Constellation/SensorNetwork');

chain.DataSaveMode = 'eSaveAccesses';
chain.ComputeAccess();

root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
scenario = root.CurrentScenario;

chainDP = chain.DataProviders.Item('Complete Access').Exec(scenario.StartTime, scenario.StopTime);
durations = cell2mat(chainDP.DataSets.GetDataSetByName('Duration').GetValues);
no_intervals = size(durations);
totalaccess = sum(durations);
avg_pass = totalaccess/no_intervals(1);
avg_coverage = totalaccess/2592000;
avg_interval = (2592000-totalaccess)/no_intervals(1);
%% Unload objects
for n = 1:49
    scenario.Children.Unload('eFacility',strcat('facility_',num2str(n)))
end
scenario.Children.Unload('eConstellation','SensorNetwork')
scenario.Children.Unload('eChain','chain_1')
%% Get the results
r = [avg_pass, avg_coverage, avg_interval]; 