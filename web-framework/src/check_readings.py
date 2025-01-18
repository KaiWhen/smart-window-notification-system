import time
import schedule
from insert_data import *
from db_api import *
import constants
from fcm_notif import send_notification


def determine_window_status(reading_value):
    if float(reading_value) > constants.WINDOW_THRESH:
        window_status = constants.CLOSED
    elif float(reading_value) <= constants.WINDOW_THRESH:
        window_status = constants.OPEN
    
    insert_window_reading(window_status)


def open_temp_check(indoor_reading, outdoor_reading, device_id):
    thresh_range = get_device_temp_thresh(device_id)
    if float(indoor_reading) < thresh_range[0] and float(outdoor_reading) < thresh_range[0]: # indoor below threshold + outdoor below threshold, should CLOSE
        return 1
    elif float(indoor_reading) > thresh_range[1] and float(outdoor_reading) > thresh_range[1]: # indoor above threshold + outdoor above upper thresh, should CLOSE and turn on AC
        return 1
    else:
        return 0


def closed_temp_check(indoor_reading, outdoor_reading, device_id):
    thresh_range = get_device_temp_thresh(device_id)
    if float(indoor_reading) > thresh_range[1] and float(outdoor_reading) < thresh_range[1]: # indoor above upper thresh and outdoor below lower thresh, should OPEN
        return 1
    elif float(indoor_reading) < thresh_range[0] and float(outdoor_reading) > thresh_range[0]: # indoor below lower thresh and outdoor above lower thresh, should OPEN
        return 1
    else:
        return 0


def open_airquality_check(indoor_reading, outdoor_reading, threshold):
    if float(indoor_reading) >= threshold and float(outdoor_reading) >= threshold: # indoor exceeds threshold and outdoor exceeds threshold, should CLOSE and open air ventilation
        return 1
    elif float(indoor_reading) < threshold and float(outdoor_reading) >= threshold: # indoor is below threshold but outdoor is above, should CLOSE
        return 1
    else:
        return 0


def closed_airquality_check(indoor_reading, outdoor_reading, threshold):
    if float(indoor_reading) >= threshold and float(outdoor_reading) < threshold: # indoor exceeds threshold and outdoor is below threshold, should OPEN
        return 1
    else:
        return 0


def determine_window_action(device_ids):
    indoor_device_id = device_ids[0]
    outdoor_device_id = device_ids[1]
    indoor_readings = get_latest_sensor_readings(indoor_device_id)
    outdoor_readings = get_latest_sensor_readings(outdoor_device_id)

    window_status = indoor_readings[constants.WINDOW_STATE]

    indoor_temp = indoor_readings[constants.TEMPERATURE]
    outdoor_temp = outdoor_readings[constants.TEMPERATURE]

    window_action = constants.ACTION_OPEN
    breached_list = []

    if window_status == constants.OPEN:
        temp = open_temp_check(indoor_temp, outdoor_temp, indoor_device_id)
        if temp == 1:
            breached_list.append(constants.TEMPERATURE)
        conflict = False
        
        air_breached_count = 0
        for threshold in constants.THRESHOLDS:
            breached = open_airquality_check(indoor_readings[indoor_readings[threshold[0]], outdoor_readings[threshold[0]], threshold[1]])
            air_breached_count += breached
            if breached == 1:
                breached_list.append(threshold[0])

        if temp == 1 or air_breached_count == 1:
            window_action = constants.ACTION_CLOSE
            send_notification(indoor_device_id, window_action, conflict, breached_list, indoor_readings, outdoor_readings)
        if temp == 1 and air_breached_count > 0:
            conflict = True
        
    else:
        temp = closed_temp_check(indoor_temp, outdoor_temp, indoor_device_id)
        if temp == 1:
            breached_list.append(constants.TEMPERATURE)
        window_action = constants.ACTION_CLOSE
        conflict = False
        air_breached_count = 0
        for threshold in constants.THRESHOLDS:
            breached = closed_airquality_check(indoor_readings[indoor_readings[threshold[0]], outdoor_readings[threshold[0]], threshold[1]])
            air_breached_count += breached
            if breached == 1:
                breached_list.append(threshold[0])
        
        if temp == 1 or air_breached_count > 0:
            window_action = constants.ACTION_OPEN
            send_notification(indoor_device_id, window_action, conflict, breached_list, indoor_readings, outdoor_readings)
        if temp == 0 and air_breached_count > 0:
            conflict = True
