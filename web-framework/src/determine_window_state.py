# import keras
import constants
import numpy as np
# import tensorflow as tf
import python_weather
import asyncio
from db_api import *
from fcm_notif import send_notification

# model = keras.saving.load_model("../model/model1.keras")


def predict_window_state(indoor_readings, outdoor_readings):
    window_state = indoor_readings[constants.WINDOW_STATE]
    # window_state = 0

    indoor_temp = indoor_readings[constants.TEMPERATURE]['reading_value']
    indoor_hum = indoor_readings[constants.HUMIDITY]['reading_value']
    indoor_eco2 = indoor_readings[constants.ECO2]['reading_value']
    indoor_tvoc = indoor_readings[constants.TVOC]['reading_value']
    indoor_pm1_0 = indoor_readings[constants.PM1_0]['reading_value']
    indoor_pm10 = indoor_readings[constants.PM10]['reading_value']
    indoor_pm2_5 = indoor_readings[constants.PM2_5]['reading_value']

    outdoor_temp = outdoor_readings[constants.TEMPERATURE]['reading_value']
    outdoor_hum = outdoor_readings[constants.HUMIDITY]['reading_value']
    outdoor_eco2 = outdoor_readings[constants.ECO2]['reading_value']
    outdoor_tvoc = outdoor_readings[constants.TVOC]['reading_value']
    outdoor_pm1_0 = outdoor_readings[constants.PM1_0]['reading_value']
    outdoor_pm10 = outdoor_readings[constants.PM10]['reading_value']
    outdoor_pm2_5 = outdoor_readings[constants.PM2_5]['reading_value']

    input_values = np.array([[
        window_state,
        indoor_temp,
        indoor_hum,
        indoor_eco2,
        indoor_tvoc,
        indoor_pm1_0,
        indoor_pm10,
        indoor_pm2_5,
        outdoor_temp,
        outdoor_hum,
        outdoor_eco2,
        outdoor_tvoc,
        outdoor_pm1_0,
        outdoor_pm10,
        outdoor_pm2_5,
    ]])

    input_values = tf.cast(input_values, tf.float32)

    print(f"input values: {input_values}")

    prediction = model.predict(input_values)
    print(f"prediction: {prediction[0][0]}")
    if prediction[0][0] > 0.6:
        return 1
    else:
        return 0


def predict_window_action(device_ids):
    indoor_device_id = device_ids[0]
    outdoor_device_id = device_ids[1]
    indoor_readings = get_latest_sensor_readings(indoor_device_id)
    outdoor_readings = get_latest_sensor_readings(outdoor_device_id)
    # state = predict_window_state(indoor_readings, outdoor_readings)
    # print(state)
    print(indoor_readings[constants.WINDOW_STATE]['reading_value'])
    # if state != indoor_readings[constants.WINDOW_STATE]['reading_value']:
    compare_and_send_notif(device_ids, 0, indoor_readings, outdoor_readings)



def compare_and_send_notif(device_ids, state, indoor_readings, outdoor_readings):
    thresholds = get_thresholds(device_ids[0])
    # breached_list, state = compare_thresholds(thresholds, indoor_readings)
    breached_list, state, outdoor_temp = compare_thresholds_no_nn(thresholds, indoor_readings)
    if state != indoor_readings[constants.WINDOW_STATE]['reading_value']:
        if len(breached_list) > 0:
            send_notification(device_ids, state, breached_list, indoor_readings, outdoor_readings, outdoor_temp)


def compare_thresholds(thresholds, indoor_readings):
    breached_list = []
    for sensor_type in constants.SENSOR_TYPE_LIST:
        indoor_reading_value = indoor_readings[sensor_type]['reading_value']
        lower_thresh = thresholds[sensor_type][0]
        upper_thresh = thresholds[sensor_type][1]
        if indoor_reading_value > upper_thresh or indoor_reading_value < lower_thresh:
            breached_list.append(sensor_type)
    return breached_list


def compare_thresholds_no_nn(thresholds, indoor_readings):
    state = None
    breached_list = []
    upper_temp_breach = False
    lower_temp_breach = False
    upper_hum_breach = False
    lower_hum_breach = False
    air_breached = False
    for sensor_type in constants.SENSOR_TYPE_LIST:
        indoor_reading_value = indoor_readings[sensor_type]['reading_value']
        lower_thresh = thresholds[sensor_type][0]
        upper_thresh = thresholds[sensor_type][1]
        if sensor_type == constants.TEMPERATURE:
            if indoor_reading_value > upper_thresh:
                upper_temp_breach = True
            elif indoor_reading_value < lower_thresh:
                lower_temp_breach = True
        # if sensor_type == constants.HUMIDITY:
        #     if indoor_reading_value > upper_thresh:
        #         upper_hum_breach = True
        #     elif indoor_reading_value < lower_thresh:
        #         lower_hum_breach = True
        if sensor_type not in [constants.TEMPERATURE, constants.HUMIDITY]:
            if indoor_reading_value > upper_thresh or indoor_reading_value < lower_thresh:
                air_breached = True
                breached_list.append(sensor_type)
        
    outdoor_temp, outdoor_humidity = asyncio.run(get_weather())
    if upper_temp_breach and outdoor_temp <= thresholds[constants.TEMPERATURE][1]:
        state = constants.ACTION_OPEN
        breached_list.append(constants.TEMPERATURE)
    elif lower_temp_breach and outdoor_temp >= thresholds[constants.TEMPERATURE][0]:
        state = constants.ACTION_OPEN
        breached_list.append(constants.TEMPERATURE)
    elif lower_temp_breach and outdoor_temp < thresholds[constants.TEMPERATURE][0]:
        state = constants.ACTION_CLOSE
        breached_list.append(constants.TEMPERATURE)
    
    # if upper_hum_breach and outdoor_humidity <= thresholds[constants.HUMIDITY][1]:
    #     state = constants.ACTION_OPEN
    #     breached_list.append(constants.HUMIDITY)
    # elif lower_hum_breach and outdoor_humidity >= thresholds[constants.HUMIDITY][0]:
    #     state = constants.ACTION_OPEN
    #     breached_list.append(constants.HUMIDITY)
    # if upper_hum_breach and outdoor_humidity > thresholds[constants.HUMIDITY][1]:
    #     state = constants.ACTION_CLOSE
    #     breached_list.append(constants.HUMIDITY)
    # elif lower_hum_breach and outdoor_humidity < thresholds[constants.HUMIDITY][0]:
    #     state = constants.ACTION_CLOSE
    #     breached_list.append(constants.HUMIDITY)

    if air_breached:
        state = constants.ACTION_OPEN
    return breached_list, state, outdoor_temp


async def get_weather():
    async with python_weather.Client() as client:
        weather = await client.get('Dún Laoghaire')
        return weather.temperature, weather.humidity
