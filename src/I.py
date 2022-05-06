# Maya Slavin
# script to create a Cypher query for SSR Identification score for an ASO

import pandas as pd
import requests
from py2neo import Graph
import math
import matplotlib.pyplot as plt
from statistics import mean, pstdev

# using 48 m as uncertainty value for SMA based on average state vector uncertainty of sample objects in LeoLabs
rms_uncert = 48
# using .005 radians of uncertainty for inclination
inc_uncert = .005

def main():
    # URL = "http://arcade.spacetech-ibm.com/auth/register"
    # PARAMS = {"email": "mslavin", "password": "ssr"}
    # headers = {"accept": "application/json", "Content-Type": "application/json"}
    # r = requests.post(url=URL, data=PARAMS, headers=headers)
    # print(r)
    # gets neo4j instance running on computer
    graph = Graph("bolt://localhost:7687", auth=("neo4j", "ssr"))

    ASO_type = int(input("Enter 1 or 2 to score either: (1) an ASO already in orbit or (2) a new ASO - "))

    if ASO_type == 1:
        norad_id = input("Input the NORAD ID for the ASO you want to score: ")
        # ephem_data = get_arcade_info(norad_id)
        # if ephem_data:
        #     print("Altitude from ARCADE ephemeris: " + str(
        #         calc_altitude(ephem_data['ephemeris'][-1]['state_vector'])) + " km")

        # leolabs_id = get_leolabs_catalogid(norad_id)
        # rms_uncert = get_leolabs_info(leolabs_id)
        # print("RMS Uncertainty from LeoLabs: " + str(rms_uncert) + " meters")

        aso_orb = query_orbit(norad_id, graph)
        print(aso_orb)
        # get_all_orbits(norad_id, graph)
        count_similar_ASOs(aso_orb, graph)

    elif ASO_type == 2:
        SMA = float(input("Enter the planned semimajor axis in kilometers: "))
        SMA = SMA * 1000
        inclination = float(input("Enter the planned inclination of the orbit in degrees: "))
        inclination = math.radians(inclination)
        count_similar_new_ASO(SMA, inclination, graph)


def count_similar_new_ASO(SMA, inc, graph):
    sma_range = (SMA - rms_uncert, SMA + rms_uncert)
    inc_range = (inc - inc_uncert, inc + inc_uncert)

    print("Range for Inc Query in ASTRIAGraph: (" + str(math.degrees(inc_range[0])) + ", " + str(
        math.degrees(inc_range[1])) + ")")
    print("Range for SMA Query in ASTRIAGraph: " + str(sma_range))
    upper = sma_range[1]
    lower = sma_range[0]

    sma_query = "MATCH(SO:SpaceObject)-[:has_orbit]->(orb:OrbitalElementsSet) WHERE " + str(
        lower) + " < orb.SMA < " + str(
        upper) + " RETURN count(DISTINCT SO.NoradId)"
    inc_query = "MATCH(SO:SpaceObject)-[:has_orbit]->(orb:OrbitalElementsSet) WHERE " + str(
        inc_range[0]) + " < orb.Inc < " + str(inc_range[1]) + " RETURN count(DISTINCT SO.NoradId)"
    combined_query = "MATCH(SO:SpaceObject)-[:has_orbit]->(orb:OrbitalElementsSet) WHERE " + str(
        inc_range[0]) + " < orb.Inc < " + str(inc_range[1]) + " AND " + str(lower) + " < orb.SMA < " + str(
        upper) + " RETURN count(DISTINCT SO.NoradId)"
    print(combined_query)

    results = graph.run(combined_query).to_data_frame()
    print("Number of ASOs in same Inc and SMA range: " + str(results.iloc[0][0]))


def count_similar_ASOs(aso_orb, graph):
    sma_range = (aso_orb['SMA'] - rms_uncert, aso_orb['SMA'] + rms_uncert)
    inc = aso_orb['Inc']
    inc_range = (inc - inc_uncert, inc + inc_uncert)
    print("ASO Inclination: " + str(math.degrees(inc)))
    print("Range for Inc Query in ASTRIAGraph: (" + str(math.degrees(inc_range[0])) + ", " + str(
        math.degrees(inc_range[1])) + ")")
    print("Range for SMA Query in ASTRIAGraph: " + str(sma_range))
    upper = sma_range[1]
    lower = sma_range[0]

    sma_query = "MATCH(SO:SpaceObject)-[:has_orbit]->(orb:OrbitalElementsSet) WHERE " + str(
        lower) + " < orb.SMA < " + str(
        upper) + " RETURN count(DISTINCT SO.NoradId)"
    inc_query = "MATCH(SO:SpaceObject)-[:has_orbit]->(orb:OrbitalElementsSet) WHERE " + str(
        inc_range[0]) + " < orb.Inc < " + str(inc_range[1]) + " RETURN count(DISTINCT SO.NoradId)"
    combined_query = "MATCH(SO:SpaceObject)-[:has_orbit]->(orb:OrbitalElementsSet) WHERE " + str(
        inc_range[0]) + " < orb.Inc < " + str(inc_range[1]) + " AND " + str(lower) + " < orb.SMA < " + str(
        upper) + " RETURN count(DISTINCT SO.NoradId)"
    print(combined_query)

    results = graph.run(combined_query).to_data_frame()
    print("Number of ASOs in same Inc and SMA range: " + str(results.iloc[0][0] - 1))


def get_all_orbits(norad_id, graph):
    query = "MATCH(SO:SpaceObject)-[:has_orbit]->(orb:OrbitalElementsSet) WHERE SO.NoradId='" + str(
        norad_id) + "' RETURN SO, orb"
    results = graph.run(query).to_data_frame()

    orbits = results.loc[:]['orb']
    SMAs = []
    for i in orbits:
        SMAs.append(i['SMA'])
    plt.hist(SMAs)
    plt.title("Histogram of ASO SMA Measurements in ASTRIAGraph")
    plt.xlabel("Semimajor Axis (m)")
    plt.ylabel("Number of Measurements")
    plt.show()

    plt.plot(SMAs)
    plt.title("ASO SMA Over Time")
    plt.ylabel("Semimajor Axis (m)")
    plt.show()
    print("Average SMA: " + str(mean(SMAs)) + " m")
    print("SMA Std Dev: " + str(pstdev(SMAs)) + " m")


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


def calc_altitude(state_vector):
    sum = state_vector[0] ** 2 + state_vector[1] ** 2 + state_vector[2] ** 2
    alt = sum ** (1 / 2)
    return alt


def get_arcade_info(norad_id):
    URL = "https://arcade.spacetech-ibm.com/asos/" + str(norad_id)

    r = requests.get(url=URL)
    data = r.json()
    print("ARCADE data: ")
    print(data)

    URL2 = "https://arcade.spacetech-ibm.com/ephemeris/" + str(norad_id)
    r2 = requests.get(url=URL2)
    data2 = r2.json()
    return data2


def get_leolabs_catalogid(norad_id):
    URL = "https://api.leolabs.space/v1/catalog/objects/search"
    PARAMS = {'noradCatalogNumbers': norad_id}
    headers = {"Authorization": "basic phvPigw36oMVB5ly:T0PeSpsFuo7J1wmjFhXWE12LkwuHKB3Ty7VeSzeS7Dw"}
    try:
        r = requests.get(url=URL, params=PARAMS, headers=headers)
    except requests.exceptions.RequestException as err:
        raise SystemExit(err)
    data = r.json()
    # print(data)
    return data['objects'][0]['catalogNumber']


def get_leolabs_info(leolabs_id):
    URL = "https://api.leolabs.space/v1/catalog/objects/" + str(leolabs_id) + "/states"
    PARAMS = {'latest': 'true'}
    headers = {"Authorization": "basic phvPigw36oMVB5ly:T0PeSpsFuo7J1wmjFhXWE12LkwuHKB3Ty7VeSzeS7Dw"}

    try:
        r = requests.get(url=URL, params=PARAMS, headers=headers)
        r.raise_for_status()
    except requests.exceptions.RequestException as err:
        print(err.response.text)
        raise SystemExit(err)

    data = r.json()
    return data['states'][0]['uncertainties']['rmsPosition']


if __name__ == '__main__':
    main()

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
