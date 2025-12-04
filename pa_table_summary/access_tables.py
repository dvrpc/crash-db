import pandas as pd
from urllib.parse import quote_plus
from sqlalchemy import create_engine
from settings import access_file


odbc_str = r"DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};" rf"DBQ={access_file};"

engine = create_engine("access+pyodbc:///?odbc_connect=" + quote_plus(odbc_str))

CRASH = pd.read_sql("SELECT * FROM CRASH", engine, dtype={"CRN": int})

FLAG = pd.read_sql(
    "select f.*, c.CRASH_YEAR, c.COUNTY from FLAG f INNER JOIN CRASH c on f.CRN = c.CRN",
    engine,
    dtype={"CRN": int},
)


PERSON = pd.read_sql(
    "select p.*, c.CRASH_YEAR, c.COUNTY from PERSON p INNER JOIN CRASH c on p.CRN = c.CRN",
    engine,
    dtype={"CRN": int},
)

CYCLE = pd.read_sql(
    "select cy.*, cr.CRASH_YEAR, cr.COUNTY from CYCLE cy INNER JOIN CRASH cr on cy.CRN = cr.CRN",
    engine,
    dtype={"CRN": int},
)

COMMVEH = pd.read_sql(
    "select cv.*, cr.CRASH_YEAR, cr.COUNTY from COMMVEH cv INNER JOIN CRASH cr on cv.CRN = cr.CRN",
    engine,
    dtype={"CRN": int},
)


ROADWAY = pd.read_sql(
    "select r.*, cr.CRASH_YEAR from ROADWAY r INNER JOIN CRASH cr on r.CRN = cr.CRN",
    engine,
    dtype={"CRN": int},
)


TRAILVEH = pd.read_sql(
    "select t.*, cr.CRASH_YEAR, cr.COUNTY from TRAILVEH t INNER JOIN CRASH cr on t.CRN = cr.CRN",
    engine,
    dtype={"CRN": int},
)


VEHICLE = pd.read_sql(
    "select v.*, cr.CRASH_YEAR, cr.COUNTY from VEHICLE v INNER JOIN CRASH cr on v.CRN = cr.CRN",
    engine,
    dtype={"CRN": int},
)


tables = [
    [CRASH, "CRASH"],
    [FLAG, "FLAG"],
    [PERSON, "PERSON"],
    [CYCLE, "CYCLE"],
    [COMMVEH, "COMMVEH"],
    [ROADWAY, "ROADWAY"],
    [TRAILVEH, "TRAILVEH"],
    [VEHICLE, "VEHICLE"],
]

years = ["2019", "2020", "2021", "2022", "2023"]

counties = [
    ["09", "BUCKS"],
    ["15", "CHESTER"],
    ["23", "DELAWARE"],
    ["46", "MONTGOMERY"],
    ["67", "PHILADELPHIA"],
]


for table in tables:
    for year in years:
        for county in counties:
            if table[1] == "CRASH":
                df = table[0].loc[
                    (table[0]["CRASH_YEAR"] == year) & (table[0]["COUNTY"] == county[0])
                ]
                df.to_csv(
                    "C:/Users/bcarney/Documents/pa_crash_data/{}_{}_{}.csv".format(
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
                    df.drop(columns=["CRASH_YEAR"])
                    df.to_csv(
                        "C:/Users/bcarney/Documents/pa_crash_data/{}_{}_{}.csv".format(
                            table[1], county[1], year
                        ),
                        index=False,
                    )
                else:
                    df = table[0].loc[
                        (table[0]["CRASH_YEAR"] == year)
                        & (table[0]["COUNTY"] == county[0])
                    ]
                    df.drop(columns=["CRASH_YEAR", "COUNTY"])
                    df.to_csv(
                        "C:/Users/bcarney/Documents/pa_crash_data/{}_{}_{}.csv".format(
                            table[1], county[1], year
                        ),
                        index=False,
                    )
    print(f"{table[1]} success")
