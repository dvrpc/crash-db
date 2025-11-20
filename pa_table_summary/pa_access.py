import pandas as pd

df = pd.read_csv("G:/My Drive/penndot_2019_2023/crash/CRASH.csv")

mixedtype = df.iloc[:, [8, 9, 65, 66, 87, 89, 91, 99, 100, 101, 105, 107, 109]]

mixedtype.to_csv("G:/My Drive/penndot_2019_2023/crash_mixed_types.csv")

print(df["TIME_OF_DAY"].str.len)
