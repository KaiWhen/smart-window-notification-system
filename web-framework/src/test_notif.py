import schedule
import time
from insert_data import insert_readings
from db_api import get_devices_from_subscriptions
from determine_window_state import predict_window_action


def determine_window_state_loop():
    def determine_window_state_job():
        devices = get_devices_from_subscriptions()
        for device_set in devices:
            predict_window_action(device_set)


    determine_window_state_job()
    schedule.every(5).minutes.do(determine_window_state_job)
    
    while True:
        schedule.run_pending()
        time.sleep(1)


determine_window_state_loop()