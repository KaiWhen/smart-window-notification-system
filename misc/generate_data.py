import random
import pandas as pd
import numpy as np
from scdata.io.device_api import ScApiDevice
from scdata._config import config

ECO2_COL = "CCS811_ECO2"
TVOC_COL = "CCS811_VOCS"
HUM_COL = "HUM"
PM1_COL = "PMS5003_PM_1"
PM10_COL = "PMS5003_PM_10"
PM25_COL = "PMS5003_PM_25"
TEMP_COL = "TEMP"

new_col_order = [10, 3, 1, 2, 6, 7, 8]

# Set verbose level
config._out_level = 'DEBUG'


'''
input structure:
[window state]
indoor: [temperature, humidity, tvoc, eco2, pm1.0, pm2.5, pm10]
outdoor: [...]
total: 15 inputs

output: 0 (close) or 1 (open)
'''

'''
Scenario 1: Window is closed, and all indoor levels are normal. Window should stay closed
Can use some existing data.
'''
def s1():
    indoor_device = ScApiDevice('16916')
    outdoor_device = ScApiDevice('16958')

    # Load
    indoor_df1 = indoor_device.get_device_data(min_date = '2024-03-8 09:00:00', max_date = '2024-03-8 18:00:00', frequency = '5Min', clean_na = 'drop');
    outdoor_df1 = outdoor_device.get_device_data(min_date = '2024-03-8 09:00:00', max_date = '2024-03-8 18:00:00', frequency = '5Min', clean_na = 'drop');

    indoor_df2 = indoor_device.get_device_data(min_date = '2024-02-21 09:00:00', max_date = '2024-02-21 18:00:00', frequency = '5Min', clean_na = 'drop');
    outdoor_df2 = outdoor_device.get_device_data(min_date = '2024-02-21 09:00:00', max_date = '2024-02-21 18:00:00', frequency = '5Min', clean_na = 'drop');


    indoor_df1.to_csv("data/indoor_03-8.csv")
    outdoor_df1.to_csv("data/outdoor_03-8.csv")

    indoor_df2.to_csv("data/indoor_02-21.csv")
    outdoor_df2.to_csv("data/outdoor_02-21.csv")

    df_s1 = {}

    # extract columns
    row_count = indoor_df1.shape[0] + indoor_df2.shape[0]
    df_s1['Window State'] = np.zeros(row_count, dtype=np.int8)

    df_s1['iTemperature'] = pd.concat([indoor_df1.iloc[:,10], indoor_df2.iloc[:,10]])
    df_s1['iHumidity'] = pd.concat([indoor_df1.iloc[:,3], indoor_df2.iloc[:,3]])
    df_s1['ieCO2'] = pd.concat([indoor_df1.iloc[:,1], indoor_df2.iloc[:,1]])
    df_s1['iTVOC'] = pd.concat([indoor_df1.iloc[:,2], indoor_df2.iloc[:,2]])
    df_s1['iPM1.0'] = pd.concat([indoor_df1.iloc[:,6], indoor_df2.iloc[:,6]])
    df_s1['iPM10'] = pd.concat([indoor_df1.iloc[:,7], indoor_df2.iloc[:,7]])
    df_s1['iPM2.5'] = pd.concat([indoor_df1.iloc[:,8], indoor_df2.iloc[:,8]])
    
    df_s1['oTemperature'] = pd.concat([outdoor_df1.iloc[:,10], outdoor_df2.iloc[:,10]])
    df_s1['oHumidity'] = pd.concat([outdoor_df1.iloc[:,3], outdoor_df2.iloc[:,3]])
    df_s1['oeCO2'] = pd.concat([outdoor_df1.iloc[:,1], outdoor_df2.iloc[:,1]])
    df_s1['oTVOC'] = pd.concat([outdoor_df1.iloc[:,2], outdoor_df2.iloc[:,2]])
    df_s1['oPM1.0'] = pd.concat([outdoor_df1.iloc[:,6], outdoor_df2.iloc[:,6]])
    df_s1['oPM10'] = pd.concat([outdoor_df1.iloc[:,7], outdoor_df2.iloc[:,7]])
    df_s1['oPM2.5'] = pd.concat([outdoor_df1.iloc[:,8], outdoor_df2.iloc[:,8]])

    df_s1['Target'] = np.zeros(shape=row_count, dtype=np.int8)

    df_s1 = pd.DataFrame(df_s1)
    df_s1 = df_s1.dropna()

    df_s1.to_csv("data/train/s1.csv")
# s1()


'''
Scenario 2: Window is open, indoor levels are normal but outdoor levels are abnormal (temperature is low, pm levels are high).
Can use existing data.
'''
def s2():
    indoor_device = ScApiDevice('16916')
    outdoor_device = ScApiDevice('16958')

    # Load
    indoor_df1 = indoor_device.get_device_data(min_date = '2024-03-8 09:00:00', max_date = '2024-03-8 18:00:00', frequency = '5Min', clean_na = 'drop');
    outdoor_df1 = outdoor_device.get_device_data(min_date = '2024-03-8 09:00:00', max_date = '2024-03-8 18:00:00', frequency = '5Min', clean_na = 'drop');

    indoor_df2 = indoor_device.get_device_data(min_date = '2024-03-11 00:00:00', max_date = '2024-03-11 15:50:00', frequency = '5Min', clean_na = 'drop');
    outdoor_df2 = outdoor_device.get_device_data(min_date = '2024-03-11 00:00:00', max_date = '2024-03-11 15:50:00', frequency = '5Min', clean_na = 'drop');

    indoor_df2.to_csv("data/indoor_03-11.csv")
    outdoor_df2.to_csv("data/outdoor_03-11.csv")

    df = {}

    # extract columns
    row_count = indoor_df1.shape[0] + indoor_df2.shape[0]
    df['Window State'] = np.ones(row_count, dtype=np.int8)

    df['iTemperature'] = pd.concat([indoor_df1.iloc[:,10], indoor_df2.iloc[:,10]])
    df['iHumidity'] = pd.concat([indoor_df1.iloc[:,3], indoor_df2.iloc[:,3]])
    df['ieCO2'] = pd.concat([indoor_df1.iloc[:,1], indoor_df2.iloc[:,1]])
    df['iTVOC'] = pd.concat([indoor_df1.iloc[:,2], indoor_df2.iloc[:,2]])
    df['iPM1.0'] = pd.concat([indoor_df1.iloc[:,6], indoor_df2.iloc[:,6]])
    df['iPM10'] = pd.concat([indoor_df1.iloc[:,7], indoor_df2.iloc[:,7]])
    df['iPM2.5'] = pd.concat([indoor_df1.iloc[:,8], indoor_df2.iloc[:,8]])
    
    df['oTemperature'] = pd.concat([outdoor_df1.iloc[:,10], outdoor_df2.iloc[:,10]])
    df['oHumidity'] = pd.concat([outdoor_df1.iloc[:,3], outdoor_df2.iloc[:,3]])
    df['oeCO2'] = pd.concat([outdoor_df1.iloc[:,1], outdoor_df2.iloc[:,1]])
    df['oTVOC'] = pd.concat([outdoor_df1.iloc[:,2], outdoor_df2.iloc[:,2]])
    df['oPM1.0'] = pd.concat([outdoor_df1.iloc[:,6], outdoor_df2.iloc[:,6]])
    df['oPM10'] = pd.concat([outdoor_df1.iloc[:,7], outdoor_df2.iloc[:,7]])
    df['oPM2.5'] = pd.concat([outdoor_df1.iloc[:,8], outdoor_df2.iloc[:,8]])

    df['Target'] = np.zeros(shape=row_count, dtype=np.int8)

    df = pd.DataFrame(df)
    df = df.dropna()

    df.to_csv("data/train/s2.csv")

# s2()


'''
Scenario 3: Window is closed, indoor temperature can be low or high but air quality is always bad, outdoor levels are normal. Should open window.
This is prioritising air quality (especially pm2.5 and pm1.0).
Can't find existing data so this data is made up
'''
def s3():
    row_count = 500

    df = {}
    df['Window State'] = np.zeros(row_count, dtype=np.int8)

    df['iTemperature'] = [round(random.uniform(15.0, 30.0), 2) for _ in range(row_count)]
    df['iHumidity'] = [round(random.uniform(30.0, 70.0), 2) for _ in range(row_count)]
    df['ieCO2'] = [round(random.uniform(200.0, 3000.0), 2) for _ in range(row_count)]
    df['iTVOC'] = [round(random.uniform(100.0, 1000.0), 2) for _ in range(row_count)]
    df['iPM1.0'] = [round(random.uniform(10.0, 50.0), 1) for _ in range(row_count)]
    df['iPM10'] = [round(random.uniform(0.0, 100.0), 1) for _ in range(row_count)]
    df['iPM2.5'] = [round(random.uniform(15.0, 50.0), 1) for _ in range(row_count)]
    
    df['oTemperature'] = [round(random.uniform(-10.0, 30.0), 2) for _ in range(row_count)]
    df['oHumidity'] = [round(random.uniform(30.0, 90.0), 2) for _ in range(row_count)]
    df['oeCO2'] = [round(random.uniform(400.0, 2200.0), 2) for _ in range(row_count)]
    df['oTVOC'] = [round(random.uniform(0.0, 500.0), 2) for _ in range(row_count)]
    df['oPM1.0'] = [round(random.uniform(0.0, 9.9), 1) for _ in range(row_count)]
    df['oPM10'] = [round(random.uniform(0.0, 49.9), 1) for _ in range(row_count)]
    df['oPM2.5'] = [round(random.uniform(0.0, 14.9), 1) for _ in range(row_count)]

    df['Target'] = np.ones(shape=row_count, dtype=np.int8)

    df = pd.DataFrame(df)
    df.to_csv(f"data/train/s3-{random.randint(1, 100)}.csv")

# s3()
