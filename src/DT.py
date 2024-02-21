# script to run trackability scoring for SSR DIT

# from py2neo import Graph
from win32com.client import GetActiveObject
import math
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import tempfile
import pdb

facility_positions = [(-37.603, 140.388, 0.013851), (-45.639, 167.361, 0.344510), (-44.040, -176.375, 0.104582),
                          (-43.940, -72.450, 0.075715), (-51.655, -58.681, 0.127896), (-34.070, 19.703, 0.416372),
                          (-34.285, 115.934, 0.134033), (-49.530, 69.910, 0.199042), (18.872, -103.290, 0.735454),
                          (-15.096, -44.836, 0.697796), (-15.099, 15.875, 1.365027),
                          (-15.818, 45.893, -0.007232), (5.159, -53.637, 0.037340), (7.612, 134.631, 0.138556),
                          (-15.531, 134.143, 0.196179), (-22.500, 113.989, 0.068118), (-7.261, 72.376, -0.064980),
                          (-15.273, 166.878, 0.196300), (-13.890, -171.938, 0.392109), (18.532, -74.135, 0.291372),
                          (-9.798, -139.073, 0.845423), (-27.128, -109.355, 0.149995), (-7.947, -14.370, 0.216315),
                          (6.890, 158.216, 0.311603), (16.899, 102.561, 0.167567), (15.097, -15.726, 0.087358),
                          (14.846, 14.217, 0.359288), (14.846, 44.914, 2.071660), (17.396, 76.263, 0.382021),
                          (19.787, -155.658, 1.517667), (-15.450, -73.848, 4.202630), (44.676, -105.521, 1.249258),
                          (44.554, -75.459, 0.070607), (40.506, -124.123, 0.002242),
                          (43.040, -8.992, 0.411682), (47.014, -53.061, 0.191380), (45.481, 15.224, 0.252010),
                          (44.891, 44.590, 0.085764), (44.537, 75.371, 0.340541), (44.384, 104.729, 1.223731),
                          (45.271, 135.576, 0.399098), (53.312, 159.728, 0.536244), (55.395, -162.156, 0.673701),
                          (70.024, -162.191, 0.013845), (69.175, 18.258, 0.314617), (67.922, -103.469, -0.005155),
                          (74.757, -46.014, 2.651167), (72.423, 75.289, 0.011348), (71.372, 136.045, 0.010589)]

#%%
def main():
    
    # Connect to STK scenario
    uiApplication = GetActiveObject('STK12.Application')
    uiApplication.Visible = True
    root = uiApplication.Personality2
    scenario = root.CurrentScenario

    # Inputs
    print("\n------\nInputs\n------")
    # graph = Graph("bolt://localhost:7687", auth=("neo4j", "ssr"))
    ASO_type = int(input("Enter 1 or 2 to score either: (1) an ASO already in orbit or (2) a new ASO - "))

    if ASO_type == 1:
        norad_id = input("Input the NORAD ID for the ASO you want to score: ")

        aso_orb = query_orbit(norad_id, graph)

    elif ASO_type == 2:
        print("\nOrbital Elements")
        aso_orb = {}
        SMA = float(input("Enter the planned semimajor axis in kilometers: "))
        aso_orb['SMA'] = SMA * 1000
        inclination = float(input("Enter the planned inclination of the orbit in degrees: "))
        aso_orb['Inc'] = math.radians(inclination)
        eccentricity = float(input("Enter the planned eccentricity of the orbit: "))
        aso_orb['Ecc'] = eccentricity
        raan = float(input("Enter the planned right ascension of the ascending node in degrees: "))
        aso_orb['RAAN'] = math.radians(raan)
        argp = float(input("Enter the planned argument of perigee in degrees: "))
        aso_orb['ArgP'] = math.radians(argp)

    # Additional inputs
    print("\n\nPhysical Properties")
    Height = float(input("Enter satellite Height in m: "))
    Width = float(input("Enter satellite Width in m: "))
    Depth = float(input("Enter satellite Depth in m: "))
    reflectance = float(input("Enter satellite reflectance (%): "))
    RCS = float(input("Enter the ASO's estimated radar cross-section in m^2: "))
    RCS = 10 * math.log10(RCS) # dBsm

    # Build satellite
    satellite = scenario.Children.New(18, "ASO")
    # Set Keplerian elements
    keplerian = satellite.Propagator.InitialState.Representation.ConvertTo(1)
    keplerian.LocationType = 5
    keplerian.SizeShape.Eccentricity = aso_orb['Ecc']
    keplerian.SizeShape.SemiMajorAxis = aso_orb['SMA'] / 1000
    keplerian.Orientation.Inclination = math.degrees(aso_orb['Inc'])
    keplerian.Orientation.ArgOfPerigee = math.degrees(aso_orb['ArgP'])  # deg
    keplerian.Orientation.AscNode.Value = math.degrees(aso_orb['RAAN'])  # deg
    keplerian.Location.Value = 0

    # Apply the changes made to the satellite's state and propagate:
    satellite.Propagator.InitialState.Representation.Assign(keplerian)
    satellite.Propagator.Propagate()

    # Compute Metrics ---------------------------------------------------------
    
    # 1. Radar Detectability scoring
    # Function: radar_detectability()
    print('\nRadar Detectability Analysis\n----------------------------\n')
    radar_detect_results = pd.DataFrame(columns=['Metric', 'Value', 'Tier', 'Score'])
    prob_detection = radar_detectability(root,RCS)
    radar_detect_results = fill_d_dataframe(radar_detect_results, prob_detection)
    radar_det_score = radar_detect_results['Score'].iloc[0]
    print(radar_detect_results)
    # optical_detectability(root)

    # 2. Radar Trackability scoring
    # Functions: radar_trackability() & optical_tracability()
    print('\nRadar Trackability Analysis\n---------------------------\n')
    radar_results = pd.DataFrame(columns=['Metric', 'Value', 'Tier', 'Score'])
    avg_pass, avg_coverage, avg_interval = radar_trackability(aso_orb, root)
    radar_results = fill_dataframe(radar_results, avg_pass, avg_coverage, avg_interval)
    print(radar_results)
    radar_score = radar_results['Score'].mean()
    print("\nOverall T Radar Score: {}\n".format(radar_score))
    
    # 3. Optical Trackability scoring
    print('\nOptical Trackability Analysis\n-----------------------------\n')
    optical_results = pd.DataFrame(columns=['Metric', 'Value', 'Tier', 'Score'])
    opt_pass, opt_coverage, opt_int = optical_trackability(aso_orb, root)
    optical_results = fill_dataframe(optical_results, opt_pass, opt_coverage, opt_int)
    print(optical_results)
    optical_score = optical_results['Score'].mean()
    print("\nOverall T Optical Score: {}".format(optical_score))
    
    # 4. Optical Detectability
    print('\nOptical Detectability Analysis\n------------------------------\n')
    Vavg, tier, opt_det_score, opt_det_results = optical_detectability(root, Height, Width, Depth, reflectance)
    print(opt_det_results)
    print("\nOverall Optical Detectability Score: {}".format(opt_det_score))
    # print("Avg Magnitude {} mag".format(opt_detect_results))
    
    
    # Overall Results
    print('\n\nOverall Scores \n--------------\n')
    print('Trackability Score: {} (larger of Radar and Optical Trackability Scores)'.format(max(radar_score,optical_score)))
    print('Detectability Score: {} (average of Radar and Optical Detectability Scores)'.format(np.mean([radar_det_score,opt_det_score])))

#%% Radar Detectability

# calculates metrics for radar detectability score
def radar_detectability(root,RCS):
    scenario = root.CurrentScenario
    

    # Set RCS
    satellite = root.GetObjectFromPath('Satellite/ASO')
    satellite.RadarCrossSection.Inherit = 0
    satellite.RadarCrossSection.Model.FrequencyBands.Item(int(0)).ComputeStrategy.ConstantValue = RCS

    # get access to satellite from radar sensors
    radar = []
    access = []
    for i in range(1, 8):
        radar.append(root.GetObjectFromPath('/Place/facility_{}/Radar/Radar'.format(i)))
        try:
            radar[i - 1].Model.AntennaControl.EmbeddedModel.BeamDirectionProvider.Directions.AddObject(satellite)
        except:
            pass
        access.append(satellite.GetAccessToObject(radar[i - 1]))
        access[i - 1].ComputeAccess()

    # get sensor with longest access
    access_data = []
    durations = []
    for i in range(1, 8):
        access_data.append(access[i-1].DataProviders.Item('Access Data').Exec(scenario.StartTime, scenario.StopTime))
        durations.append(sum(list(access_data[i-1].Intervals.Item(0).Datasets.GetDataSetByName('Duration').GetValues())))
    max_value = max(durations)
    max_index = durations.index(max_value)

    longest_access = access[max_index]
    Probability = longest_access.DataProviders.Item('Radar SearchTrack').Exec(scenario.StartTime, scenario.StopTime, 60)
    total_probability = []
    for i in range(0, (Probability.Intervals.Count - 1)):
        partial_probability = list(Probability.Intervals.Item(int(i)).DataSets.GetDataSetByName('S/T PDet1').GetValues())
        for j in partial_probability:
            total_probability.append(j)
    # plt.scatter(total_probability)
    # plt.show()
    
    # Remove all accesses
    root.ExecuteCommand('ClearAllAccess /')
    
    return max(total_probability)

#%% Radar and Optical Trackability

# calculates metrics for radar trackability score
def radar_trackability(aso_orb, root):
    scenario = root.CurrentScenario

    # place facilities in scenario
    count = 1
    for i in facility_positions:
        facility_name = "facility_" + str(count)
        facility = scenario.Children.New(8, facility_name)
        lat = i[0]
        long = i[1]
        alt = i[2]
        facility.Position.AssignGeodetic(lat, long, alt)
        sensor_name = "sensor_" + str(count)
        sensor = facility.Children.New(20, sensor_name)

        pattern1 = sensor.Pattern
        pattern1.ConeAngle = 60
        count += 1

    # create sensor constellation
    constellation = scenario.Children.New(6, 'SensorNetwork')
    for i in range(1, 50):
        constellation.Objects.Add('*/Facility/facility_{}/Sensor/sensor_{}'.format(i, i))

    # create chains and compute access
    chain_name = 'chain_1'
    chain = scenario.Children.New(4, chain_name)
    sat_chain = 'Satellite/ASO'
    chain.Objects.Add(sat_chain)
    chain.Objects.Add('Constellation/SensorNetwork')

    chain.DataSaveMode = 2
    chain.ComputeAccess()

    root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec')
    scenario = root.CurrentScenario

    chainDP = chain.DataProviders.Item('Complete Access').Exec(scenario.StartTime, scenario.StopTime)
    durations = list(chainDP.DataSets.GetDataSetByName('Duration').GetValues())
    number_of_intervals = len(durations)
    total_access = sum(durations)
    avg_pass = total_access / number_of_intervals
    avg_coverage = total_access / 2592000
    avg_interval = (2592000 - total_access) / number_of_intervals
    
    # Save access data
    try:
        # Get start, stop, duration as list
        durations = list(chainDP.DataSets.GetDataSetByName('Duration').GetValues())
        start_list = list(chainDP.DataSets.GetDataSetByName('Start Time').GetValues())
        stop_list = list(chainDP.DataSets.GetDataSetByName('Stop Time').GetValues())  
        from_list = list(chainDP.DataSets.GetDataSetByName('From Object').GetValues())
        to_list = list(chainDP.DataSets.GetDataSetByName('To Object').GetValues())
        # Create dataframe to save
        df = pd.DataFrame(columns=['From','To','Start','Stop','Duration'])
        df['From'] = from_list
        df['To'] = to_list
        df['Start'] = start_list
        df['Stop'] = stop_list
        df['Duration'] = durations
        # Save dataframe
        df.to_csv('Access_Times_Radar.csv')
        
    except:
        print('Error saving LOS access data')

    # unload objects
    for i in range(1, 50):
        scenario.Children.Unload(8, 'facility_' + str(i))
    scenario.Children.Unload(6, 'SensorNetwork')
    scenario.Children.Unload(4, 'chain_1')
    
    # Remove all accesses
    root.ExecuteCommand('ClearAllAccess /')

    return avg_pass, avg_coverage, avg_interval


# calculates metrics for optical trackability score
def optical_trackability(aso_orb, root):
    scenario = root.CurrentScenario
    
    # TODO: Set lighting constraints on satellite
    # Apply Access Lighting constraint (penumbra or direct sun)
    satellite = root.GetObjectFromPath('Satellite/ASO')
    accessConstraintsSat = satellite.AccessConstraints
    satLightCstr = accessConstraintsSat.AddConstraint(25) # eCstrLighting
    satLightCstr.Condition = 2 # ePenumbraOrDirectSun
    
    # place facilities in scenario
    count = 1
    for i in facility_positions:
        facility_name = "facility_" + str(count)
        facility = scenario.Children.New(8, facility_name)
        lat = i[0]
        long = i[1]
        alt = i[2]
        facility.Position.AssignGeodetic(lat, long, alt)
        sensor_name = "sensor_" + str(count)
        sensor = facility.Children.New(20, sensor_name)
        accessConstraintsSens = sensor.AccessConstraints
        light = accessConstraintsSens.AddConstraint(25) 
        light.Condition = 3 # ePenumbraOrUmbra light constraint

        pattern1 = sensor.Pattern
        pattern1.ConeAngle = 60 # Cone angle constraint
        count += 1

    # create sensor constellation
    constellation = scenario.Children.New(6, 'SensorNetwork')
    for i in range(1, 50):
        constellation.Objects.Add('*/Facility/facility_{}/Sensor/sensor_{}'.format(i, i))

    # create chain and compute access
    chain_name = 'chain_1'
    chain = scenario.Children.New(4, chain_name)
    sat_chain = 'Satellite/ASO'
    chain.Objects.Add(sat_chain)
    chain.Objects.Add('Constellation/SensorNetwork')

    chain.DataSaveMode = 2
    chain.ComputeAccess()

    root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec')
    scenario = root.CurrentScenario

    chainDP = chain.DataProviders.Item('Complete Access').Exec(scenario.StartTime, scenario.StopTime)
    durations = list(chainDP.DataSets.GetDataSetByName('Duration').GetValues())
    number_of_intervals = len(durations)
    total_access = sum(durations)
    avg_pass = total_access / number_of_intervals
    avg_coverage = total_access / 2592000
    avg_interval = (2592000 - total_access) / number_of_intervals
    
    # Save access data
    try:
        # Get start, stop, duration as list
        durations = list(chainDP.DataSets.GetDataSetByName('Duration').GetValues())
        start_list = list(chainDP.DataSets.GetDataSetByName('Start Time').GetValues())
        stop_list = list(chainDP.DataSets.GetDataSetByName('Stop Time').GetValues())  
        from_list = list(chainDP.DataSets.GetDataSetByName('From Object').GetValues())
        to_list = list(chainDP.DataSets.GetDataSetByName('To Object').GetValues())
        # Create dataframe to save
        df = pd.DataFrame(columns=['From','To','Start','Stop','Duration'])
        df['From'] = from_list
        df['To'] = to_list
        df['Start'] = start_list
        df['Stop'] = stop_list
        df['Duration'] = durations
        # Save dataframe
        df.to_csv('Access_Times_Optical.csv')
        
    except:
        print('Error saving LOS access data')
    

    # unload objects
    for i in range(1, 50):
        scenario.Children.Unload(8, 'facility_' + str(i))
    scenario.Children.Unload(6, 'SensorNetwork')
    scenario.Children.Unload(4, 'chain_1')
    
    # Remove all accesses
    root.ExecuteCommand('ClearAllAccess /')

    return avg_pass, avg_coverage, avg_interval

#%% Optical Detectability

def optical_detectability(root,Height,Width,Depth,reflectance):
    
    # Get handles to scenario and satellite
    scenario = root.CurrentScenario
    satellite = root.GetObjectFromPath('Satellite/ASO')
    
    # Apply Access Lighting constraint (penumbra or direct sun)
    try:
        accessConstraintsSat = satellite.AccessConstraints
        satLightCstr = accessConstraintsSat.AddConstraint(25) # eCstrLighting
        satLightCstr.Condition = 2 # ePenumbraOrDirectSun
    except:
        # Contraint already added
        pass
    
    # Set the EOIR reflectance and Shape as box <Height><Width><Depth> 
    root.ExecuteCommand('EOIR */Satellite/ASO Shape Type Box {h} {w} {d} Material GrayBody Reflectance {r}'.format(h=Height,w=Width,d=Depth, r=reflectance))

    # Create dictionary to store data
    opt_dict = {'Facility_1':{},'Facility_2':{},'Facility_3':{},'Facility_4':{},
                'Facility_5':{},'Facility_6':{}, 'Facility_7':{}}
    
    
    # Loop through 7 SSRD stations
    for i in range(7):
        
        # Get EOIR sensor
        sensor_num = i+1 # Sensor number (1-7)
        name = 'Facility_'+str(sensor_num)
        eoir = root.GetObjectFromPath('/Place/facility_{}/Sensor/EOIR'.format(sensor_num))
        
        # Set pointing to target ASO
        eoir.SetPointingType(5) # eSnPtTargeted
        try:
            eoir.Pointing.Targets.Add('*/Satellite/ASO')
        except:
            pass
    
        # Apply Access Lighting constraint (penumbra or umbra)
        accessConstraintsSen = eoir.AccessConstraints
        senLightCstr = accessConstraintsSen.GetActiveConstraint(25) # AgEAccessConstraints.eCstrLighting
        senLightCstr.Condition = 3 # ePenumbraOrUmbra
        
        # Compute access
        access = satellite.GetAccessToObject(eoir)
        access.ComputeAccess()
        access_data = access.DataProviders.Item('Access Data').Exec(scenario.StartTime, scenario.StopTime)
        
        # Get total duration
        num_access = access_data.Intervals.Count
        if num_access > 0:
            dur = access_data.Intervals.Item(0).DataSets.GetDataSetByName('Duration').GetValues() # List of durations
            tot_dur = sum(dur)
            max_dur = max(dur)
        else:
            tot_dur = 0
        
        # Store data in dict
        opt_dict[name]['num_access'] = num_access
        opt_dict[name]['tot_dur'] = float(tot_dur)
        opt_dict[name]['max_dur'] = float(max_dur)
        opt_dict[name]['eoir'] = eoir # Handle to eoir sensor object
        opt_dict[name]['access_data'] = access_data # Handle to access data
    
    # Load to dataframe
    df = pd.DataFrame(opt_dict).T
    
    # EOIR visibility
    # Find facility with best access (longest total duration)
    ind = np.argmax(df.tot_dur)
    best_station = df.index[ind]
    
    # Remove all accesses
    root.ExecuteCommand('ClearAllAccess /')
    
    # Compute access for best facility
    eoir = root.GetObjectFromPath('/Place/facility_{}/Sensor/EOIR'.format(str(ind+1)))
    eoir.SetPointingType(5) # eSnPtTargeted
    # Apply Access Lighting constraint (penumbra or umbra)
    accessConstraintsSen = eoir.AccessConstraints
    senLightCstr = accessConstraintsSen.GetActiveConstraint(25) # AgEAccessConstraints.eCstrLighting
    senLightCstr.Condition = 3 # ePenumbraOrUmbra
    
    # Compute access
    access = satellite.GetAccessToObject(eoir)
    access.ComputeAccess()

    # EOIR configuration
    # Add satellite to EOIR Configuration
    root.ExecuteCommand('EOIR */ TargetConfig AddTarget Satellite/ASO')


    # Create report: EOIR Sensor-to-Target Metrics
    tmp = tempfile.NamedTemporaryFile(delete=False,suffix='.csv') # Temporary file
    outfile = tmp.name # Name of file (.csv)
    
    # See: https://help.agi.com/stkdevkit/index.htm#../Subsystems/connectCmds/Content/infoReportAdditionalData.htm?Highlight=%22Sensor-to-Target%22
    root.ExecuteCommand('ReportCreate */Place/facility_1/Sensor/EOIR Style "EOIR Sensor-to-Target Metrics" Type Export File "{}" AdditionalData "Satellite/ASO Band1" TimeStep 120.0 '.format(outfile)) # Full search
    # root.ExecuteCommand('ReportCreate */Place/facility_1/Sensor/EOIR Style "EOIR Sensor-to-Target Metrics" Type Display AdditionalData "Satellite/ASO Band1" TimePeriod "Access/Place-facility_1-Sensor-EOIR-To-Satellite-ASO AccessIntervals.First Interval" TimeStep 60.0') # First access interval
    # root.ExecuteCommand('ReportCreate */Place/facility_1/Sensor/EOIR Style "EOIR Sensor-to-Target Metrics" Type Display AdditionalData "Satellite/ASO Band1" TimePeriod "Access/Place-facility_1-Sensor-EOIR-To-Satellite-ASO AccessIntervals.Longest Interval" TimeStep 10.0') # First access interval
    # root.ExecuteCommand('ReportCreate */Place/facility_1/Sensor/EOIR Style "EOIR Sensor-to-Target Metrics" Type Display AdditionalData "Satellite/ASO Band1" TimePeriod Intervals "Access/Place-facility_1-Sensor-EOIR-To-Satellite-ASO AccessIntervals" TimeStep 30.0 ') # All access intervals
    # root.ExecuteCommand('ReportCreate */Place/facility_1/Sensor/EOIR Style "EOIR Sensor-to-Target Metrics" Type Display AdditionalData "Satellite/ASO Band1" TimePeriod Intervals "C:/Users/scott/Documents/Repos/python_rough_code/STK/intervals.int" TimeStep 30.0 ') # All access intervals

    # Extract data from report
    dfrep = pd.read_csv(outfile,header=2)
    # Rename columns
    dfrep = dfrep.rename(columns={'Time (UTCG)':'Time'})
    dfrep['Time'] = pd.to_datetime(dfrep.Time) # Convert time to datetime
    # Delete temp file
    tmp.close()
    
    # Compute Vmag
    Vref = 0.03 # Vega reference
    Eref = 1.140129e-12 # Irradiance of Vega
    Vmag = Vref - 2.5*np.log10(dfrep['Effective target irradiance (W/cm^2)']/Eref)
    # Insert into dataframe
    dfrep.insert(2,'Vmag',Vmag)
    
    # Compute average of values < 15
    Vavg = dfrep['Vmag'][dfrep.Vmag < 15].mean()
    
    # Determine Optical Detectability score
    # if average vmag < 15, the rating is Detectable, and score is 1
    # if average vmag > 15, the rating is Not detectable, and the score is 0.5
    if Vavg <= 15:
        tier = 'Detectable'
        score = 1.
    elif Vavg > 15:
        tier = 'Not detectable'
        score = 0.5
    
    # Format results into dataframe
    row = {'Metric': ' Avg Visual Magnitude (mag)', 'Value': Vavg, 'Tier': tier, 'Score': score}
    df = pd.DataFrame(columns=['Metric', 'Value', 'Tier', 'Score'])
    df = df.append(row, ignore_index=True)
    
    # Plot
    fig, ax = plt.subplots()
    ax.plot(dfrep.Time,dfrep.Vmag,'ob',label='Measurements')
    ax.plot([dfrep.Time.min(),dfrep.Time.max()],[15,15],':r',label='Cutoff') # Reference line
    ax.plot([dfrep.Time.min(),dfrep.Time.max()],[Vavg,Vavg],':b',label='Average = {}'.format(str(np.round(Vavg,3)))) # Reference line
    ax.invert_yaxis()
    ax.set_ylabel('Vmag (mag)')
    ax.set_xlabel('Epoch')
    ax.legend(loc="lower left")

    return Vavg, tier, score, df



# calculates metrics for optical detectability score
def optical_detectability_old(root):
    scenario = root.CurrentScenario
    root.UnitPreferences.SetCurrentUnit('PowerUnit', 'W')
    root.UnitPreferences.SetCurrentUnit('SmallDistanceUnit', 'cm')

    # compute the access for each EOIR sensor
    satellite = root.GetObjectFromPath('Satellite/ASO')
    EOIR = []
    access = []
    for i in range(1, 8):
        EOIR.append(root.GetObjectFromPath('/Place/facility_{}/Sensor/EOIR'.format(i)))
        access.append(satellite.GetAccessToObject(EOIR[i - 1]))
        access[i - 1].ComputeAccess()

    # get sensor with most access to ASO
    access_data = []
    durations = []
    for i in range(1, 8):
        access_data.append(access[i - 1].DataProviders.Item('Access Data').Exec(scenario.StartTime, scenario.StopTime))
        durations.append(
            sum(list(access_data[i - 1].Intervals.Item(0).Datasets.GetDataSetByName('Duration').GetValues())))
    max_value = max(durations)
    max_index = durations.index(max_value)

    EOIR_sensor = EOIR[max_index]
    longest_access = access[max_index]
    print(durations, EOIR_sensor, longest_access)



#%% Utility functions

# calculates scores for detectability and builds dataframe to display results
def fill_d_dataframe(dataframe, prob_detection):
    if prob_detection < 0.5:
        tier = 'Difficult to Detect'
        score = 0
    elif 0.5 <= prob_detection < 0.75:
        tier = 'Detectable'
        score = 0.5
    elif 0.75 <= prob_detection:
        tier = 'More Detectable'
        score = 1.0

    row = {'Metric': 'Max Probability of Detection', 'Value': prob_detection, 'Tier': tier, 'Score': score}
    dataframe = dataframe.append(row, ignore_index=True)
    return dataframe

# calculate scores for trackability and build dataframe to display results
def fill_dataframe(dataframe, avg_pass, avg_coverage, avg_interval):
    if avg_pass < 120:
        pass_tier = 'Difficult to Track'
        pass_score = 0
    elif 120 <= avg_pass < 180:
        pass_tier = "Trackable"
        pass_score = 0.25
    elif 180 <= avg_pass < 400:
        pass_tier = 'More Trackable'
        pass_score = 0.5
    elif 400 <= avg_pass:
        pass_tier = 'Very Trackable'
        pass_score = 1.0

    pass_row = {'Metric': ' Avg Pass (s)', 'Value': avg_pass, 'Tier': pass_tier, 'Score': pass_score}
    dataframe = dataframe.append(pass_row, ignore_index=True)

    if avg_coverage < 0.1:
        cover_tier = 'Difficult to Track'
        cover_score = 0
    elif 0.1 <= avg_coverage < .25:
        cover_tier = 'Trackable'
        cover_score = 0.25
    elif .25 <= avg_coverage < .60:
        cover_tier = 'More Trackable'
        cover_score = 0.5
    elif .60 < avg_coverage:
        cover_tier = 'Very Trackable'
        cover_score = 1.0

    cover_row = {'Metric': ' Avg Coverage', 'Value': avg_coverage, 'Tier': cover_tier, 'Score': cover_score}
    dataframe = dataframe.append(cover_row, ignore_index=True)

    if avg_interval > 43200:
        int_tier = 'Difficult to Track'
        int_score = 0
    elif 43200 <= avg_interval < 14400:
        int_tier = 'Trackable'
        int_score = 0.25
    elif 14400 >= avg_interval:
        int_tier = 'More Trackable'
        int_score = 0.5

    int_row = {'Metric': ' Avg Interval (s)', 'Value': avg_interval, 'Tier': int_tier, 'Score': int_score}
    dataframe = dataframe.append(int_row, ignore_index=True)
    return dataframe

# writes Cypher query to get orbital elements for ASO already in ASTRIAGraph and executes query
def query_orbit(norad_id, graph):
    query = "MATCH(SO:SpaceObject)-[:has_orbit]->(orb:OrbitalElementsSet) WHERE SO.NoradId='" + str(
        norad_id) + "' RETURN SO, orb"
    print(query)
    results = graph.run(query).to_data_frame()

    if results.empty:
        print("ASO not found in ASTRIAGraph")
        return -1
    else:
        latest_orbit = results.iloc[-1]
        return latest_orbit['orb']


if __name__ == '__main__':
    main()
