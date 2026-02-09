import pandas as pd
from sqlalchemy import create_engine, text
from settings import crash_db_engine

engine = create_engine(crash_db_engine)

crash = pd.read_sql_query(
    "SELECT * FROM pa.all_crash where crash_year in ('2020', '2021', '2022', '2023', '2024');",
    con=engine,
)

crash_null = crash.isnull().sum()

person = pd.read_sql_query(
    "SELECT p.* from pa.all_person p INNER JOIN pa.all_crash c on p.crn = c.crn where c.crash_year in ('2020', '2021', '2022', '2023','2024');",
    con=engine,
)


tables = ["crash", "person", "roadway", "vehicle", "commveh", "cycle"]


for table in tables:
    if table == "crash":
        df = pd.read_sql_query(
            "SELECT * FROM pa.all_{} where crash_year in ('2020', '2021', '2022', '2023', '2024');".format(
                table
            ),
            con=engine,
        )

        nulls = df.isnull().sum()
        nulls.to_csv("G:/My Drive/penndot_2019_2023/{}_nulls.csv".format(table))
    else:
        df = pd.read_sql_query(
            "SELECT r.* from pa.all_{} r INNER JOIN pa.all_crash c on r.crn = c.crn where c.crash_year in ('2020', '2021', '2022', '2023','2024');".format(
                table
            ),
            con=engine,
        )

        nulls = df.isnull().sum()
        nulls.to_csv("G:/My Drive/penndot_2019_2023/{}_nulls.csv".format(table))
