import schedule
import time
from insert_data import insert_readings, insert_reading
from db_api import get_devices_from_subscriptions
from determine_window_state import predict_window_action, get_weather

import asyncio

def collect_readings_loop():
    def collect_readings_job():
        devices = get_devices_from_subscriptions()
        for device_set in devices:
            indoor_device_id = device_set[0]
            outdoor_device_id = device_set[1]
            insert_readings(outdoor_device_id)
            insert_readings(indoor_device_id)
        # outdoor_temp, outdoor_humidity = asyncio.run(get_weather())
        # insert_reading(23, float(outdoor_temp), "ºC")
        # insert_reading(22, float(outdoor_humidity), "%")


    collect_readings_job()
    schedule.every(4).minutes.do(collect_readings_job)

    while True:
        schedule.run_pending()
        time.sleep(1)


def determine_window_state_loop():
    def determine_window_state_job():
        devices = get_devices_from_subscriptions()
        for device_set in devices:
            predict_window_action(device_set)


    # determine_window_state_job()
    schedule.every(5).minutes.do(determine_window_state_job)
    
    while True:
        schedule.run_pending()
        time.sleep(1)
