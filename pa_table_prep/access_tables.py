import pandas as pd
import numpy as np
from urllib.parse import quote_plus
from sqlalchemy import create_engine
from settings import access_file
import fields as f

odbc_str = r"DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};" rf"DBQ={access_file};"

engine = create_engine("access+pyodbc:///?odbc_connect=" + quote_plus(odbc_str))

CRASH = pd.read_sql(
    "SELECT * FROM CRASH",
    engine,
    dtype={"CRN": int},
)


# Modify Access columns to match Data Dictionary
CRASH["INJURY_COUNT"] = CRASH[["MIN_INJ_COUNT", "MOD_INJ_COUNT", "MAJ_INJ_COUNT"]].sum(
    axis=1
)

"""
CRASH = CRASH.replace("  ", None, regex=True)

CRASH.rename(
    columns={
        "NON_MOTR_DEATH_COUNT": "NONMOTR_DEATH_COUNT",
        "PED_MAJ_INJ_COUNT": "PED_SUSP_SERIOUS_INJ_COUNT",
        "TOTAL_INJ_COUNT": "TOT_INJ_COUNT",
        "WEATHER": "WEATHER1",
        "MAJ_INJ_COUNT": "SUSP_SERIOUS_INJ_COUNT",
        "MOD_INJ_COUNT": "SUSP_MINOR_INJ_COUNT",
    },
    inplace=True,
)

CRASH["POSSIBLE_INJ_COUNT"] = np.nan


CRASH = CRASH[f.crash_cols]


CRASH = CRASH.astype(f.crash_dict)

CRASH.loc[CRASH["COUNTY"] == "67", "MUNICIPALITY"] = "67301"

CRASH.loc[CRASH["MUNICIPALITY"] == "6", "MUNICIPALITY"] = ""


CRASH.loc[
    ~CRASH["ROAD_CONDITION"].isin(
        ["01", "02", "03", "04", "05", "06", "07", "08", "09", "22", "98", "99"]
    ),
    "ROAD_CONDITION",
] = ""


FLAGS = pd.read_sql(
    "select f.*, c.CRASH_YEAR, c.COUNTY from FLAG f INNER JOIN CRASH c on f.CRN = c.CRN",
    engine,
    dtype={"CRN": int},
)

null_flags = [
    "ATV_ROUTE",
    "FEDERAL_AID_ROUTE",
    "HIT_ROADWAY_EQUIPMENT",
    "HIT_RUN",
    "HIT_TEMP_CONSTRUCTION_BARRIER",
    "HIT_TRAFFIC_ISLAND",
    "HIT_UTILITY_POLE",
    "IMPAIRED_NONMOTORIST",
    "INTERSECTION_RELATED",
    "MARIJUANA_DRUGGED_DRIVER",
    "SCHOOL_BUS_RELATED",
]

for col in null_flags:
    FLAGS[col] = None

FLAGS = FLAGS[f.flags_cols]

FLAGS = FLAGS.astype(f.flags_dict)


PERSON = pd.read_sql(
    "select p.*, c.CRASH_YEAR, c.COUNTY from PERSON p INNER JOIN CRASH c on p.CRN = c.CRN",
    engine,
    dtype={"CRN": int},
)

null_person = ["VULNERABLE_ROADWAY_USER"]


for col in null_person:
    PERSON[col] = None

PERSON = PERSON[f.person_cols]

PERSON = PERSON.astype(f.person_dict)

PERSON.loc[
    ~PERSON["AIRBAG_PADS"].isin(["00", "05", "06", "08", "09", "13", "19", "99"]),
    "AIRBAG_PADS",
] = "99"


CYCLE = pd.read_sql(
    "select cy.*, cr.CRASH_YEAR, cr.COUNTY from CYCLE cy INNER JOIN CRASH cr on cy.CRN = cr.CRN",
    engine,
    dtype={"CRN": int},
)

CYCLE = CYCLE[f.cycle_cols]

CYCLE = CYCLE.astype(f.cycle_dict)


COMMVEH = pd.read_sql(
    "select cv.*, cr.CRASH_YEAR, cr.COUNTY from COMMVEH cv INNER JOIN CRASH cr on cv.CRN = cr.CRN",
    engine,
    dtype={"CRN": int},
)


COMMVEH.rename(
    columns={
        "CARRIER_ADDR_1": "CARRIER_ADDR1",
        "CARRIER_ADDR_2": "CARRIER_ADDR2",
        "CARRIER_ADDR_CITY": "CARRIER_CITY",
        "CARRIER_ADDR_STATE": "CARRIER_STATE",
        "CARRIER_ADDR_ZIP": "CARRIER_ZIP",
    },
    inplace=True,
)

null_commveh = [
    "PARTIAL_TRAILER_VIN",
    "PERMITTED",
    "SPECIAL_SIZING1",
    "SPECIAL_SIZING2",
    "SPECIAL_SIZING3",
    "SPECIAL_SIZING4",
    "TYPE_OF_CARRIER",
]

for col in null_commveh:
    COMMVEH[col] = None


COMMVEH = COMMVEH[f.commveh_cols]

COMMVEH = COMMVEH.astype(f.commveh_dict)


ROADWAY = pd.read_sql(
    "select r.*, cr.CRASH_YEAR from ROADWAY r INNER JOIN CRASH cr on r.CRN = cr.CRN",
    engine,
    dtype={"CRN": int},
)

null_roadway = ["RAMP", "OFFSET_FT"]

for col in null_roadway:
    ROADWAY[col] = None

ROADWAY = ROADWAY[f.roadway_cols]

ROADWAY = ROADWAY.astype(f.roadway_dict)


TRAILVEH = pd.read_sql(
    "select t.*, cr.CRASH_YEAR, cr.COUNTY from TRAILVEH t INNER JOIN CRASH cr on t.CRN = cr.CRN",
    engine,
    dtype={"CRN": int},
)

null_trailveh = ["TRAILER_PARTIAL_VIN"]

for col in null_trailveh:
    TRAILVEH[col] = None


TRAILVEH = TRAILVEH[f.trailveh_cols]

TRAILVEH = TRAILVEH.astype(f.trailveh_dict)

TRAILVEH.loc[
    (TRAILVEH["TRL_VEH_REG_STATE"] == "0 ") | (TRAILVEH["TRL_VEH_REG_STATE"] == "1 "),
    "TRL_VEH_REG_STATE",
] = ""

VEHICLE = pd.read_sql(
    "select v.*, cr.CRASH_YEAR, cr.COUNTY from VEHICLE v INNER JOIN CRASH cr on v.CRN = cr.CRN",
    engine,
    dtype={"CRN": int},
)

VEHICLE.rename(columns={"VEH_ROLE_CD": "VEH_ROLE"}, inplace=True)

null_vehicle = [
    "NM_AT_INTERSECTION",
    "NM_CROSSING_TCD",
    "NM_DISTRACTION",
    "NM_IN_CROSSWALK",
    "NM_LIGHTING",
    "NM_POWERED",
    "NM_REFLECT",
    "NON_MOTORIST",
    "TOW_IND",
]

for col in null_vehicle:
    VEHICLE[col] = None

VEHICLE = VEHICLE[f.vehicle_cols]

VEHICLE = VEHICLE.astype(f.vehicle_dict)

VEHICLE.loc[
    ~VEHICLE["UNIT_TYPE"].isin(["01", "02", "03", "05", "06", "21", "30", "33", "51"]),
    "UNIT_TYPE",
] = ""


VEHICLE.loc[
    (VEHICLE["VINA_BODY_TYPE_CD"] == "T  ")
    | (VEHICLE["VINA_BODY_TYPE_CD"] == "P  ")
    | (VEHICLE["VINA_BODY_TYPE_CD"] == "M  ")
    | (VEHICLE["VINA_BODY_TYPE_CD"] == "C  "),
    "VINA_BODY_TYPE_CD",
] = ""

VEHICLE.loc[VEHICLE["VEH_REG_STATE"] == "P ", "VEH_REG_STATE"] = ""

VEHICLE["VINA_BODY_TYPE_CD"] = VEHICLE["VINA_BODY_TYPE_CD"].str.strip()


VEHICLE["MAKE_CD"] = ""

VEHICLE = VEHICLE[VEHICLE["CRN"] != 2020085055]


tables = [
    [CRASH, "CRASH"],
    [FLAGS, "FLAGS"],
    [PERSON, "PERSON"],
    [CYCLE, "CYCLE"],
    [COMMVEH, "COMMVEH"],
    [ROADWAY, "ROADWAY"],
    [TRAILVEH, "TRAILVEH"],
    [VEHICLE, "VEHICLE"],
]

years = ["2019", "2020", "2021", "2022", "2023", "2024"]

counties = [
    ["09", "BUCKS"],
    ["15", "CHESTER"],
    ["23", "DELAWARE"],
    ["46", "MONTGOMERY"],
    ["67", "PHILADELPHIA"],
]
"""
"""
for table in tables:
    for year in years:
        for county in counties:
            if table[1] == "CRASH":
                df = table[0].loc[
                    (table[0]["CRASH_YEAR"] == year) & (table[0]["COUNTY"] == county[0])
                ]
                df = df.replace({" ": None, "    ": None, "  ": None, "   ": None})
                df = df.replace("None", "", regex=True)
                df = df.replace("nan", "", regex=True)
                df.to_csv(
                    "C:/Users/bcarney/Documents/pa/{}_{}_{}.csv".format(
                        table[1], county[1], year
                    ),
                    index=False,
                )
            else:
                if table[1] == "ROADWAY":
                    df = table[0].loc[
                        (table[0]["CRASH_YEAR"] == year)
                        & (table[0]["COUNTY"] == county[0])
                    ]
                    df.drop(columns=["CRASH_YEAR"], inplace=True)
                    df = df.replace({" ": None, "    ": None, "  ": None, "   ": None})
                    df = df.replace("None", "", regex=True)
                    df = df.replace("nan", "", regex=True)
                    df.to_csv(
                        "C:/Users/bcarney/Documents/pa/{}_{}_{}.csv".format(
                            table[1], county[1], year
                        ),
                        index=False,
                    )
                else:
                    df = table[0].loc[
                        (table[0]["CRASH_YEAR"] == year)
                        & (table[0]["COUNTY"] == county[0])
                    ]
                    df.drop(columns=["CRASH_YEAR", "COUNTY"], inplace=True)
                    df = df.replace({" ": None, "    ": None, "  ": None, "   ": None})
                    df = df.replace("None", "", regex=True)
                    df = df.replace("nan", "", regex=True)
                    df.to_csv(
                        "C:/Users/bcarney/Documents/pa/{}_{}_{}.csv".format(
                            table[1], county[1], year
                        ),
                        index=False,
                    )
    print(f"{table[1]} success")
"""
