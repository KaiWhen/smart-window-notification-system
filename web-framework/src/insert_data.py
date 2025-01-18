import requests
import mariadb
from mariadb_conn import connect_db
from datetime import datetime
from db_api import *

SC_URL = "https://api.smartcitizen.me/v0/devices/"


def get_data(device_id):
    url = SC_URL + str(device_id)
    try:
        r = requests.get(url)
        data = r.json()
        return data
    except:
        print("Error")
        return -1


def get_sensor_data(device_id):
    url = SC_URL + str(device_id)
    try:
        r = requests.get(url)
        data = r.json()
        sensor_data = data['data']['sensors']
    except Exception as e:
        print(f"Error: {e}")
        return -1

    return sensor_data


def insert_sensors(device_id, user_id):
    data = get_data(device_id)
    if data == -1:
        return
    device_name = data['name']
    last_reading_at = data['last_reading_at']
    last_reading_timestamp = datetime.fromisoformat(last_reading_at.replace("Z", "+00:00"))
    system_tags = data['system_tags']
    if system_tags[0] in ["online", "offline"]:
        is_online = True if system_tags[0] == "online" else False
    else:
        sensor_env = system_tags[0]
    if system_tags[1] in ["online", "offline"]:
        is_online = True if system_tags[1] == "online" else False
    else:
        sensor_env = system_tags[1]
    conn = connect_db()
    db_cur = conn.cursor()
    try:
        db_cur.execute(
            "INSERT INTO device(device_id, device_name, is_online, last_reading_at, owner_id) VALUES (?, ?, ?, ?, ?)",
            (device_id, device_name, is_online, last_reading_timestamp, user_id)
        )
        conn.commit()
    except mariadb.Error as e:
        print(f"Error: {e}")
        return False

    if sensor_env.casefold() == "indoor":
        insert_window_sensor(device_id, sensor_env)

    sensor_data = get_sensor_data(device_id)
    if sensor_data == -1:
        conn.close()
        return
    for sensor in sensor_data:
        sensor_name = sensor['name']
        # sensor_id = sensor['id']
        sensor_description = sensor['description']
        sensor_name_split = sensor_name.split(' - ')
        if len(sensor_name_split) > 1:
            sensor_type = sensor_name_split[1]
        elif "Battery" in sensor_name:
            sensor_type = "Battery"
        try:
            db_cur.execute(
                "INSERT INTO sensor(sensor_name, sensor_type, device_id, sensor_env) VALUES (?, ?, ?, ?)",
                (sensor_description, sensor_type, device_id, sensor_env)
            )
            conn.commit()
        except mariadb.Error as e:
            print(f"Error: {e}")
    conn.close()


def insert_readings(device_id):
    device_data = get_data(device_id)
    if device_data == -1:
        return
    device_id = device_data['id']

    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute("SELECT sensor_id FROM sensor WHERE device_id=? AND sensor_type!=?", (device_id, constants.WINDOW_STATE))
    sensor_ids = []
    for sensor_id in db_cur:
        sensor_ids.append(sensor_id[0])

    i = 0
    sensor_data = get_sensor_data(device_id)
    if sensor_data == -1:
        conn.close()
        return
    for sensor in sensor_data:
        sensor_id = sensor_ids[i]
        reading_time = device_data['last_reading_at']
        reading_timestamp = datetime.fromisoformat(reading_time.replace("Z", "+00:00"))
        reading_value = round(sensor['value'], 2)
        reading_unit = sensor['unit']
        try:
            db_cur.execute(
                "INSERT INTO reading(sensor_id, reading_time, reading_value, reading_unit) VALUES (?, ?, ?, ?)",
                (sensor_id, reading_timestamp, reading_value, reading_unit)
            )
            db_cur.execute(
                "UPDATE device SET last_reading_at=? WHERE device_id=?",
                (reading_timestamp, device_id)
            )
            conn.commit()
        except mariadb.Error as e:
            print(f"Error: {e}")
        i += 1
    conn.close()


def insert_window_sensor(device_id, sensor_env):
    conn = connect_db()
    db_cur = conn.cursor()
    sensor_name = "Window Sensor"
    sensor_type = "Window State"
    try:
        db_cur.execute(
            "INSERT INTO sensor(sensor_name, sensor_type, device_id, sensor_env) VALUES (?, ?, ?, ?)",
            (sensor_name, sensor_type, device_id, sensor_env)
        )
        conn.commit()
    except mariadb.Error as e:
        print(f"Error: {e}")
    conn.close()


def insert_reading(sensor_id, reading, reading_unit):
    conn = connect_db()
    db_cur = conn.cursor()
    reading_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    try:
        db_cur.execute(
            "INSERT INTO reading(sensor_id, reading_time, reading_value, reading_unit) VALUES (?, ?, ?, ?)",
            (sensor_id, reading_time, reading, reading_unit)
        )
        conn.commit()
    except mariadb.Error as e:
        print(f"Error: {e}")
    conn.close()


def insert_window_reading(device_id, reading):
    conn = connect_db()
    db_cur = conn.cursor()
    sensor_type = "Window State"
    reading_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    db_cur.execute("SELECT sensor_id FROM sensor WHERE device_id=? AND sensor_type=?", (device_id, sensor_type))
    for sensor in db_cur:
        sensor_id = sensor[0]
    try:
        db_cur.execute(
            "INSERT INTO reading(sensor_id, reading_time, reading_value, reading_unit) VALUES (?, ?, ?, ?)",
            (sensor_id, reading_time, reading, "state")
        )
        conn.commit()
    except mariadb.Error as e:
        print(f"Error: {e}")
    conn.close()


def insert_threshold(device_id, lower_thresh, upper_thresh, sensor_type):
    conn = connect_db()
    db_cur = conn.cursor()
    try:
        db_cur.execute(
            "INSERT INTO threshold(lower_thresh, upper_thresh, sensor_type, device_id) VALUES (?, ?, ?, ?)",
            (lower_thresh, upper_thresh, sensor_type, device_id)
        )
        conn.commit()
    except mariadb.Error as e:
        print(f"Error: {e}")
    conn.close()


def insert_thresholds(thresholds):
    thresholds = thresholds['thresholds']
    user_id = thresholds['user_id']
    thresholds = thresholds['thresholds']
    device_ids = get_device_from_user(user_id)
    device_id = device_ids['indoor_device_id']
    for threshold in thresholds:
        sensor_type = threshold['sensor_type']
        lower_thresh = threshold['lower_thresh']
        upper_thresh = threshold['upper_thresh']
        update_threshold(device_id, lower_thresh, upper_thresh, sensor_type)


def update_threshold(device_id, lower_thresh, upper_thresh, sensor_type):
    conn = connect_db()
    db_cur = conn.cursor()
    # indoor_device_id = get_db_data.get_device_from_user(user_id)['indoor_device_id']
    db_cur.execute("SELECT * FROM threshold WHERE device_id=? AND sensor_type=?", (device_id, sensor_type))
    if db_cur.rowcount > 0:
        try:
            db_cur.execute(
                "UPDATE threshold SET lower_thresh=?, upper_thresh=? WHERE device_id=? AND sensor_type=?",
                (lower_thresh, upper_thresh, device_id, sensor_type)
            )
            conn.commit()
        except mariadb.Error as e:
            print(f"Error: {e}")
    else:
        insert_threshold(device_id, lower_thresh, upper_thresh, sensor_type)
    conn.close()


def insert_fcm_token(fcm):
    conn = connect_db()
    db_cur = conn.cursor()
    fcm_token = fcm['fcm_token']
    fcm_timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    user_id = fcm['user_id']
    try:
        db_cur.execute(
            "INSERT INTO fcm(fcm_token, fcm_timestamp, user_id, last_notif) VALUES (?, ?, ?, ?)",
            (fcm_token, fcm_timestamp, user_id, fcm_timestamp)
        )
        conn.commit()
    except mariadb.Error as e:
        print(f"Error: {e}")
    conn.close()


def update_fcm_token(fcm):
    user_id = fcm['user_id']
    user_fcm_token = get_user_fcm(user_id)
    if user_fcm_token is not None:
        if user_fcm_token != fcm['fcm_token']:
            conn = connect_db()
            db_cur = conn.cursor()
            db_cur.execute(
                "UPDATE fcm SET fcm_token=? WHERE user_id=?",
                (fcm['fcm_token'], user_id)
            )
            conn.commit()
            conn.close()
    else:
        insert_fcm_token(fcm)


def insert_user(user_id, username):
    conn = connect_db()
    db_cur = conn.cursor()
    try:
        db_cur.execute(
            "INSERT INTO users(user_id, username) VALUES (?, ?)",
            (user_id, username)
        )
        conn.commit()
        conn.close()
        return True
    except mariadb.Error as e:
        print(f"Error: {e}")
        conn.close()
        return False


def insert_device_subscription(indoor_device_id, outdoor_device_id, user_id):
    conn = connect_db()
    db_cur = conn.cursor()
    try:
        db_cur.execute(
            "INSERT INTO device_subscription(indoor_device_id, outdoor_device_id, user_id) VALUES (?, ?, ?)",
            (indoor_device_id, outdoor_device_id, user_id)
        )
        conn.commit()
    except mariadb.Error as e:
        print(f"Error: {e}")
    conn.close()


def update_device_subscription(indoor_device_id, outdoor_device_id, user_id):
    conn = connect_db()
    db_cur = conn.cursor()
    print(outdoor_device_id)
    if user_subscription_exists(user_id):
        try:
            db_cur.execute(
                "UPDATE device_subscription SET indoor_device_id=?, outdoor_device_id=? WHERE user_id=?",
                (indoor_device_id, outdoor_device_id, user_id)
            )
            conn.commit()
        except mariadb.Error as e:
            print(f"Error: {e}")
        conn.close()
    else:
        insert_device_subscription(indoor_device_id, outdoor_device_id, user_id)


def insert_notification(window_action, title, body, timestamp, breached_list, device_id):
    conn = connect_db()
    db_cur = conn.cursor()
    try:
        db_cur.execute(
            "INSERT INTO notification(notif_window_action, notif_title, notif_body, notif_timestamp, breached_list, device_id) VALUES (?, ?, ?, ?, ?, ?)",
            (
                window_action,
                title,
                body,
                timestamp,
                breached_list,
                device_id
            )
        )
        conn.commit()
    except mariadb.Error as e:
        print(f"Error: {e}")
    conn.close()


def transfer_ownership(user_id, target_user, indoor_device_id, outdoor_device_id):
    conn = connect_db()
    db_cur = conn.cursor()
    success = False
    if user_is_owner(user_id, indoor_device_id, outdoor_device_id):
        target_user_id = get_user_by_username(target_user)
        if target_user_id != -1:
            try:
                db_cur.execute(
                    "UPDATE device SET owner_id=? WHERE device_id=?",
                    (
                        target_user_id,
                        indoor_device_id
                    )
                )
                db_cur.execute(
                    "UPDATE device SET owner_id=? WHERE device_id=?",
                    (
                        target_user_id,
                        outdoor_device_id
                    )
                )
                conn.commit()
                success = True
            except mariadb.Error as e:
                print(f"Error: {e}")

    conn.close()
    return success


def set_user_preferences(user_id):
    conn = connect_db()
    db_cur = conn.cursor()
    days_list = [True, True, True, True, True, True, True]
    days_list = [str(b) for b in days_list]
    days = ','.join(days_list)
    interval = 5
    try:
        db_cur.execute(
            "INSERT INTO user_preference(user_id, notif_days, push_interval) VALUES (?, ?, ?)",
            (user_id, days, interval)
        )
        conn.commit()
    except mariadb.Error as e:
        print(f"Error: {e}")

    conn.close()


def update_user_pref_days(user_id, days_list):
    conn = connect_db()
    db_cur = conn.cursor()
    success = False
    days_list = [str(b) for b in days_list]
    days = ','.join(days_list)
    try:
        db_cur.execute(
            "UPDATE user_preference SET notif_days=? WHERE user_id=?",
            (days, user_id)
        )
        conn.commit()
        success = True
    except mariadb.Error as e:
        print(f"Error: {e}")

    conn.close()
    return success


def update_user_pref_interval(user_id, interval):
    conn = connect_db()
    db_cur = conn.cursor()
    success = False
    try:
        db_cur.execute(
            "UPDATE user_preference SET push_interval=? WHERE user_id=?",
            (interval, user_id)
        )
        conn.commit()
        success = True
    except mariadb.Error as e:
        print(f"Error: {e}")

    conn.close()
    return success


def update_users_last_notif(users):
    conn = connect_db()
    db_cur = conn.cursor()
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    for user in users:
        try:
            db_cur.execute(
                "UPDATE fcm SET last_notif=? WHERE user_id=?",
                (now, user)
            )
            conn.commit()
        except mariadb.Error as e:
            print(f"Error: {e}")
    conn.close()

# "https://api.smartcitizen.me/v0/devices/16958" # outside
# "https://api.smartcitizen.me/v0/devices/16916" # inside
