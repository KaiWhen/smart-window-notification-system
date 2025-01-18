from scdata.io.device_api import ScApiDevice
from scdata.test import Test
from scdata._config import config
import matplotlib.pyplot as plt
import plotly.graph_objs as go
import pandas as pd
import numpy as np
from mariadb_conn import connect_db
from datetime import datetime


def plot_pm25():
    indoor_device = ScApiDevice('16916')
    outdoor_device = ScApiDevice('17232')

    # Load
    indoor = indoor_device.get_device_data(min_date = '2024-04-11 11:20:00', max_date = '2024-03-11 13:30:00', frequency = '1Min');
    outdoor = outdoor_device.get_device_data(min_date = '2024-04-11 11:20:00', max_date = '2024-03-11 13:30:00', frequency = '1Min');

    timestamps = pd.date_range(start='2024-04-11 11:20:00', end='2024-03-11 13:29:00', freq='1min')
    indoor["timestamps"] = timestamps
    outdoor["timestamps"] = timestamps

    # Calculate 24-hour rolling average
    indoor['24h_mean'] = indoor['PMS5003_PM_25'].rolling(window=288, min_periods=1).mean()  # 288 = 24*60/5
    outdoor['24h_mean'] = outdoor['PMS5003_PM_25'].rolling(window=288, min_periods=1).mean()

    # Plotting
    plt.figure(figsize=(15, 6))

    # Indoor data
    plt.plot(indoor['timestamps'].values, indoor['24h_mean'].values, label='Indoor PM2.5 24h mean', color='blue', linestyle='--')
    plt.plot(indoor['timestamps'].values, indoor['PMS5003_PM_25'].values, label='Indoor PM2.5 Concentration', color='blue', alpha=0.5)
    

    # Outdoor data
    plt.plot(outdoor['timestamps'].values, outdoor['24h_mean'].values, label='Outdoor PM2.5 24h mean', color='green', linestyle='--')
    plt.plot(outdoor['timestamps'].values, outdoor['PMS5003_PM_25'].values, label='Outdoor PM2.5 Concentration', color='green', alpha=0.5)

    # WHO PM2.5 limit
    plt.axhline(y=15, color='red', linestyle='--', label='WHO PM2.5 Limit (15 ug/m³)')

    plt.title('PM2.5 Concentration 2024-03-03 - 2024-03-10')
    plt.xlabel('Date')
    plt.ylabel('PM2.5 (ug/m³)')
    plt.legend()
    plt.xticks(rotation=45)
    # plt.tight_layout()
    plt.grid(True)
    plt.show()


def plot_tvoc():
    indoor_device = ScApiDevice('16916')
    outdoor_device = ScApiDevice('17232')

    # Load
    indoor = indoor_device.get_device_data(min_date = '2024-04-11 10:00:00', max_date = '2024-04-11 12:30:00', frequency = '1Min');
    outdoor = outdoor_device.get_device_data(min_date = '2024-04-11 10:00:00', max_date = '2024-04-11 12:30:00', frequency = '1Min');

    # print(len(indoor))
    # print(len(outdoor))

    timestamps = pd.date_range(start='2024-04-11 10:00:00', end='2024-04-11 12:29:00', freq='1min')
    indoor["timestamps"] = timestamps
    outdoor["timestamps"] = timestamps

    # Plotting
    plt.figure(figsize=(10, 6))

    # Indoor data
    plt.plot(indoor['timestamps'].values, indoor['CCS811_VOCS'].values, label='Indoor TVOC Concentration', color='blue', alpha=1.0)
    

    # Outdoor data
    plt.plot(outdoor['timestamps'].values, outdoor['CCS811_VOCS'].values, label='Outdoor TVOC Concentration', color='green', alpha=1.0)

    open_time = '2024-04-11 10:24:53'
    open_line_x = datetime.strptime(open_time, '%Y-%m-%d %H:%M:%S')
    plt.axvline(open_line_x, color='orange', linestyle='--', label='Window Opens', alpha=0.5)

    close_time = '2024-04-11 11:26:56'
    close_line_x = datetime.strptime(close_time, '%Y-%m-%d %H:%M:%S')
    plt.axvline(close_line_x, color='red', linestyle='--', label='Window Closes', alpha=0.5)
    # tvoc safe limit
    # plt.axhline(y=500, color='red', linestyle='--', label='500ppb Safe Limit')

    
    xlabels = [pd.to_datetime(t).strftime('%H:%M') for t in indoor['timestamps'].values]

    plt.title('TVOC Concentration 2024-04-11 10:00 - 2024-04-11 12:30 UTC')
    plt.xlabel('Time')
    plt.ylabel('TVOC (ppb)')
    plt.legend()
    plt.xticks(rotation=45)
    # plt.tight_layout()
    plt.grid(True)
    plt.show()

# plot_tvoc()


def plot_eco2():
    indoor_device = ScApiDevice('16916')
    outdoor_device = ScApiDevice('17232')

    # Load
    indoor = indoor_device.get_device_data(min_date = '2024-04-11 10:00:00', max_date = '2024-04-11 12:30:00', frequency = '1Min');
    outdoor = outdoor_device.get_device_data(min_date = '2024-04-11 10:00:00', max_date = '2024-04-11 12:30:00', frequency = '1Min');

    timestamps = pd.date_range(start='2024-04-11 10:00:00', end='2024-04-11 12:29:00', freq='1min')
    indoor["timestamps"] = timestamps
    outdoor["timestamps"] = timestamps

    # Plotting
    plt.figure(figsize=(10, 6))

    # Indoor data
    plt.plot(indoor['timestamps'].values, indoor['CCS811_ECO2'].values, label='Indoor eCO2 Concentration', color='blue', alpha=1.0)
    

    # Outdoor data
    plt.plot(outdoor['timestamps'].values, outdoor['CCS811_ECO2'].values, label='Outdoor eCO2 Concentration', color='green', alpha=1.0)

    open_time = '2024-04-11 10:24:53'
    open_line_x = datetime.strptime(open_time, '%Y-%m-%d %H:%M:%S')
    plt.axvline(open_line_x, color='orange', linestyle='--', label='Window Opens', alpha=0.5)

    close_time = '2024-04-11 11:26:56'
    close_line_x = datetime.strptime(close_time, '%Y-%m-%d %H:%M:%S')
    plt.axvline(close_line_x, color='red', linestyle='--', label='Window Closes', alpha=0.5)

    plt.title('eCO2 Concentration 2024-04-11 10:00 - 2024-04-11 12:30 UTC')
    plt.xlabel('Time')
    plt.ylabel('eCO2 (ppm)')
    plt.legend()
    plt.xticks(rotation=45)
    # plt.tight_layout()
    plt.grid(True)
    plt.show()

# plot_eco2()


def plot_window_status():
    conn = connect_db()
    db_cur = conn.cursor()
    reading_query = "SELECT reading_value, reading_time FROM reading WHERE sensor_id=? AND reading_time>=? AND reading_time<=?"
    params = (1, '2024-04-11 10:00:00', '2024-04-11 12:30:00')
    db_cur.execute(reading_query, params)
    readings = []
    for reading_value, reading_time in db_cur:
        readings.append({'timestamp': reading_time, 'state': reading_value})

    df = pd.DataFrame(readings)
    print(df.head())
    # timestamps = pd.date_range(start='2024-03-03 00:00:00', end='2024-03-10 23:55:00', freq='1min')
    # window_status = np.random.choice([0, 1], size=len(timestamps), p=[0.99, 0.01])  # Adjust probabilities to have window closed most of the time
    # window = pd.DataFrame({'timestamp': timestamps, 'status': window_status})

    plt.figure(figsize=(12, 2))
    plt.step(df['timestamp'].values, df['state'].values, where='mid', label='Window Status', color='black')

    # notification_points = window[window['status'].diff() == 1]['timestamp'] - pd.Timedelta(minutes=60)
    # plt.scatter(notification_points, [1] * len(notification_points), color='red', label='Notification Sent')

    plt.title("Window State")
    plt.ylabel('Closed (0) Open (1)')
    plt.show()


# plot_window_status()


def plot_temp_hum():
    indoor_device = ScApiDevice('16916')
    outdoor_device = ScApiDevice('17232')

    # Load
    indoor = indoor_device.get_device_data(min_date = '2024-04-11 10:00:00', max_date = '2024-04-11 12:30:00', frequency = '2Min');
    outdoor = outdoor_device.get_device_data(min_date = '2024-04-11 10:00:00', max_date = '2024-04-11 12:30:00', frequency = '2Min');

    timestamps = pd.date_range(start='2024-04-11 10:00:00', end='2024-04-11 12:28:00', freq='2min')
    indoor["timestamps"] = timestamps
    outdoor["timestamps"] = timestamps

    # Plotting
    plt.figure(figsize=(10, 6))

    # Indoor data
    plt.plot(indoor['timestamps'].values, indoor['TEMP'].values, label='Indoor Temperature °C', color='green')
    plt.plot(indoor['timestamps'].values, indoor['HUM'].values, label='Indoor Humidity %', color='blue')

    # Outdoor data
    plt.plot(outdoor['timestamps'].values, outdoor['TEMP'].values, label='Outdoor Temperature °C', color='green', linestyle="--", alpha=0.5)
    plt.plot(outdoor['timestamps'].values, outdoor['HUM'].values, label='Outdoor Humidity %', color='blue', linestyle="--", alpha=0.5)

    open_time = '2024-04-11 10:24:53'
    open_line_x = datetime.strptime(open_time, '%Y-%m-%d %H:%M:%S')
    plt.axvline(open_line_x, color='orange', linestyle='--', label='Window Opens', alpha=0.5)

    close_time = '2024-04-11 11:26:56'
    close_line_x = datetime.strptime(close_time, '%Y-%m-%d %H:%M:%S')
    plt.axvline(close_line_x, color='red', linestyle='--', label='Window Closes', alpha=0.5)

    plt.title("Temperature and Humidity")
    plt.legend()
    plt.xlabel("Time")
    plt.ylabel("Temperature (°C)/Humidity (%)")
    plt.xticks(rotation=45)
    plt.show()


# plot_temp_hum()


def get_data():
    indoor_device = ScApiDevice('16916')
    outdoor_device = ScApiDevice('17232')

    # Load
    indoor = indoor_device.get_device_data(min_date = '2024-04-11 10:20:04', max_date = '2024-04-11 10:20:04');
    outdoor = outdoor_device.get_device_data(min_date = '2024-04-11 10:20:04', max_date = '2024-04-11 10:21:04');

    print(indoor)
    print(outdoor)

    indoor.to_csv('indoor.csv')
    outdoor.to_csv('outdoor.csv')

get_data()
