import threading
import os
import logging
from jobs import collect_readings_loop, determine_window_state_loop
from flask import Flask, request
from flask_cors import CORS
from flask_mqtt import Mqtt
from db_api import *
from check_readings import determine_window_status
from insert_data import *
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
cors = CORS(app)

app.config['MQTT_BROKER_URL'] = ''
app.config['MQTT_BROKER_PORT'] = 1883
app.config['MQTT_USERNAME'] = os.getenv('MQTT_USER')
app.config['MQTT_PASSWORD'] = os.getenv('MQTT_PASS')

mqtt_client = Mqtt(app)
sub_topic = "/enmon/window"


@mqtt_client.on_connect()
def handle_connect(client, userdata, flags, rc):
   if rc == 0:
       print('Connected successfully')
       mqtt_client.subscribe(sub_topic)
   else:
       print('Bad connection. Code:', rc)


@mqtt_client.on_message()
def handle_mqtt_message(client, userdata, message):
   if message.topic == sub_topic:
        payload = str(message.payload.decode("utf-8"))
        reading = float(payload)
        if reading > 91.5 and reading <= 180:
            window_state = constants.OPEN
        else:
            window_state = constants.CLOSED
        insert_window_reading(16916, window_state)


@app.route('/', methods=['GET', 'POST'])
def hello_world():
    return "EnMon Flask App :)"


@app.route('/readings', methods=['GET', 'POST'])
def return_readings():
    if request.method == 'POST':
        device_ids = request.json
        indoor_id = device_ids['indoor_device_id']
        outdoor_id = device_ids['outdoor_device_id']
        indoor_readings = get_latest_sensor_readings(indoor_id)
        outdoor_readings = get_latest_sensor_readings(outdoor_id)
        readings = {
            'indoor': indoor_readings,
            'outdoor': outdoor_readings
        }
        return readings


@app.route('/readings/historical', methods=['POST'])
def return_readings_historical():
    if request.method == 'POST':
        device_ids = request.json
        indoor_id = device_ids['indoor_device_id']
        outdoor_id = device_ids['outdoor_device_id']
        indoor_readings = get_sensor_readings(indoor_id)
        outdoor_readings = get_sensor_readings(outdoor_id)
        readings = {
            'indoor': indoor_readings,
            'outdoor': outdoor_readings
        }
        return readings


@app.route('/window', methods=['GET', 'POST'])
def return_sensor():
    if request.method == 'GET':
        return get_sensor_reading_window()
    if request.method == 'POST':
        distance = request.data
        print(distance)
        determine_window_status(distance)
        return "OK"


@app.route('/user/reg', methods=['POST'])
def user_reg():
    if request.method == 'POST':
        data = request.json
        user_id = data['user_id']
        username = data['username']
        user_exists = get_user(user_id)
        if user_exists == -1:
            insert_user(user_id, username)
            set_user_preferences(user_id)
            return { 'registered': False }
        else:
            return { 'registered': True }


@app.route('/user', methods=['POST'])
def get_user_info():
    if request.method == 'POST':
        data = request.json
        user_id = data['user_id']
        user = get_user(user_id)
        return user


@app.route('/device/reg', methods=['POST'])
def device_reg():
    if request.method == 'POST':
        data = request.json
        indoor_device_id = data['indoor_device_id']
        outdoor_device_id = data['outdoor_device_id']
        user_id = data['user_id']
        reg = 1
        if not device_exists(indoor_device_id) and device_exists(outdoor_device_id):
            insert_sensors(indoor_device_id, user_id)
            reg = 2
        elif not device_exists(outdoor_device_id) and device_exists(indoor_device_id):
            insert_sensors(outdoor_device_id, user_id)
        elif not device_exists(indoor_device_id) and not device_exists(outdoor_device_id):
            insert_sensors(indoor_device_id, user_id)
            insert_sensors(outdoor_device_id, user_id)
            reg = 2
        
        update_device_subscription(indoor_device_id, outdoor_device_id, user_id)
        return { 'reg': reg }


@app.route('/device', methods=['POST'])
def device():
    if request.method == 'POST':
        data = request.json
        user_id = data['user_id']
        device_ids = get_device_from_user(user_id)
        return device_ids


@app.route('/threshold/set', methods=['POST'])
def threshold_set():
    if request.method == 'POST':
        data = request.json
        insert_thresholds(data)
        return "OK", 200


@app.route('/threshold/device', methods=['POST'])
def get_device_threshold():
    if request.method == 'POST':
        data = request.json
        user_id = data['user_id']
        indoor_device_id = get_device_from_user(user_id)['indoor_device_id']
        thresholds = get_thresholds(indoor_device_id)
        print(thresholds)
        return thresholds


@app.route('/fcm', methods=['POST'])
def fcm():
    if request.method == 'POST':
        data = request.json
        update_fcm_token(data)
        return "OK", 200


@app.route('/user/isowner', methods=['POST'])
def owner():
    if request.method == 'POST':
        device_ids = request.json
        user_id = device_ids['user_id']
        indoor_id = device_ids['indoor_device_id']
        outdoor_id = device_ids['outdoor_device_id']
        is_owner = user_is_owner(user_id, indoor_id, outdoor_id)
        return { 'is_owner': is_owner }
    

@app.route('/user/preferences/days', methods=['POST'])
def set_pref_days():
    if request.method == 'POST':
        data = request.json
        user_id = data['user_id']
        days_list = data['days_list']
        success = update_user_pref_days(user_id, days_list)
        return { 'success': success }


@app.route('/user/preferences/interval', methods=['POST'])
def set_pref_interval():
    if request.method == 'POST':
        data = request.json
        user_id = data['user_id']
        interval = data['interval']
        success = update_user_pref_interval(user_id, interval)
        return { 'success': success }


@app.route('/device/owner', methods=['POST'])
def transfer_owner():
    if request.method == 'POST':
        data = request.json
        user_id = data['user_id']
        target_email = data['target_email']
        indoor_id = data['indoor_device_id']
        outdoor_id = data['outdoor_device_id']
        success = transfer_ownership(user_id, target_email, indoor_id, outdoor_id)
        return { 'success': success }


with app.app_context():
    gunicorn_logger = logging.getLogger('gunicorn.debug')
    app.logger.handlers = gunicorn_logger.handlers
    app.logger.setLevel(gunicorn_logger.level)
    threading.Thread(target=collect_readings_loop).start()
