import mariadb
import constants
from mariadb_conn import connect_db


def get_sensor(sensor_id):
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute("SELECT * FROM sensor WHERE sensor_id=?", (sensor_id,))
    for sensor_id, sensor_name, sensor_type, device_id, _ in db_cur:
        result = {
            'sensor_id': sensor_id,
            'sensor_name': sensor_name,
            'sensor_type': sensor_type,
            'device_id': device_id
        }
    conn.close()
    return result


def get_sensors(sensor_ids):
    results = {
        'sensors': []
    }
    for sensor_id in sensor_ids:
        results['sensors'].append(get_sensor(sensor_id))
    
    return results


def get_latest_sensor_readings(device_id):
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute("SELECT sensor_id, sensor_type, sensor_env FROM sensor WHERE device_id=?", (device_id,))
    sensor_ids = []
    window_sensor_id = 0
    sensor_en = ""
    for sensor_id, sensor_type, sensor_env in db_cur:
        sensor_en = sensor_env
        if sensor_type == constants.WINDOW_STATE:
            window_sensor_id = sensor_id
        else:
            sensor_ids.append(sensor_id)

    db_cur.execute("SELECT last_reading_at FROM device WHERE device_id=?", (device_id,))
    for last_reading in db_cur:
        last_reading_time = last_reading[0]
    reading_query = "SELECT sensor_id, reading_value, reading_unit, reading_time FROM reading WHERE sensor_id IN ({}) AND reading_time=%s".format(', '.join(['%s']*len(sensor_ids)))
    params = sensor_ids + [last_reading_time]
    db_cur.execute(reading_query, params)

    results = {}
    for sensor_id, reading_value, reading_unit, reading_time in db_cur:
        sensor_type = get_sensor(sensor_id)['sensor_type']
        results[sensor_type] = {
            'sensor_id': sensor_id,
            'reading_value': reading_value,
            'reading_unit': reading_unit,
            'reading_time': reading_time
        }

    if sensor_en == "indoor":
        window_reading_query = "SELECT sensor_id, reading_value, reading_unit, reading_time FROM reading WHERE sensor_id=? order by reading_time desc limit 1"
        db_cur.execute(window_reading_query, (window_sensor_id,))
        for sensor_id, reading_value, reading_unit, reading_time in db_cur:
            window_sensor_type = constants.WINDOW_STATE
            results[window_sensor_type] = {
                'sensor_id': sensor_id,
                'reading_value': reading_value,
                'reading_unit': reading_unit,
                'reading_time': reading_time
            }

    conn.close()
    return results


def get_sensor_reading_window():
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute("SELECT reading_value FROM reading WHERE reading_unit=? order by reading_time desc limit 1", ('state',))
    for reading in db_cur:
        reading_value = reading[0]
    conn.close()
    return reading_value


def get_sensor_readings(device_id):
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute("SELECT sensor_id, sensor_type FROM sensor WHERE device_id=?", (device_id,))
    sensor_ids = []
    for sensor_id, sensor_type in db_cur:
        sensor_ids.append((sensor_id, sensor_type))
    # db_cur.execute("SELECT last_reading_at FROM device WHERE device_id=?", (device_id,))
    # for last_reading in db_cur:
    #     last_reading_time = last_reading[0]
    # print(last_reading_time)
    # reading_ query = "SELECT sensor_id, reading_value, reading_unit FROM reading WHERE sensor_id IN ({}) order by reading_time desc limit 160".format(', '.join(map(str, sensor_ids)))
    reading_query = "SELECT reading_time, reading_value, reading_unit FROM reading WHERE sensor_id=? order by reading_time desc limit 20"
    results = {}
    for sensor in sensor_ids:
        params = (sensor[0],)
        db_cur.execute(reading_query, params)
        results[sensor[1]] = []
        i=0
        for reading_time, reading_value, reading_unit in db_cur:
            result = {}
            result['reading_time'] = reading_time.strftime("%H:%M")
            result['reading_value'] = round(reading_value, 2)
            result['reading_unit'] = reading_unit
            result['count'] = i
            results[sensor[1]].append(result)
            i += 1
    conn.close()
    return results


def get_device_temp_thresh(device_id):
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute(
        "SELECT lower_thresh, upper_thresh FROM threshold WHERE device_id=? AND sensor_type=?",
        (device_id, constants.TEMPERATURE)
    )
    for lower_thresh, upper_thresh in db_cur:
        lower_temp_thresh = lower_thresh
        upper_temp_thresh = upper_thresh

    conn.close()
    return (lower_temp_thresh, upper_temp_thresh)


def device_exists(device_id):
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute("SELECT device_id FROM device WHERE device_id=?", (device_id,))
    if db_cur.rowcount == 0:
        conn.close()
        return False
    else:
        conn.close()
        return True


def get_device_from_user(user_id):
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute("SELECT indoor_device_id, outdoor_device_id FROM device_subscription WHERE user_id=?", (user_id,))
    if db_cur.rowcount == 0:
        return "Not found", 204
    for indoor_device_id, outdoor_device_id in db_cur:
        indoor_device = indoor_device_id
        outdoor_device = outdoor_device_id
    conn.close()
    return {
        'indoor_device_id': indoor_device,
        'outdoor_device_id': outdoor_device
    }


def get_devices_from_subscriptions():
    conn = connect_db()
    db_cur = conn.cursor()
    devices = []
    db_cur.execute("SELECT indoor_device_id, outdoor_device_id FROM device_subscription")
    for indoor_device_id, outdoor_device_id in db_cur:
        devices.append((indoor_device_id, outdoor_device_id))
    conn.close()
    return list(set(devices))


def get_user(user_id):
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute("SELECT user_id, username FROM users WHERE user_id=?", (user_id,))
    if db_cur.rowcount == 0:
        conn.close()
        return -1
    else:
        for user_id, username in db_cur:
            result = {
                'user_id': user_id,
                'username': username
            }
        conn.close()
        return result


def get_thresholds(device_id):
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute("SELECT lower_thresh, upper_thresh, sensor_type FROM threshold WHERE device_id=?", (device_id,))
    results = {}
    for lower_thresh, upper_thresh, sensor_type in db_cur:
        results[sensor_type] = (lower_thresh, upper_thresh)
    conn.close()
    return results


def get_users_from_subscription(indoor_device_id, outdoor_device_id):
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute(
        "SELECT user_id FROM device_subscription WHERE indoor_device_id=? AND outdoor_device_id=?",
        (indoor_device_id, outdoor_device_id)
    )
    user_ids = []
    for user_id in db_cur:
        user_ids.append(user_id[0])
    conn.close()
    return user_ids


def user_subscription_exists(user_id):
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute(
        "SELECT user_id FROM device_subscription WHERE user_id=?",
        (user_id, )
    )
    if db_cur.rowcount > 0:
        return True
    return False


def get_user_fcm(user_id):
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute(
        "SELECT user_id, fcm_token FROM fcm WHERE user_id=?",
        (user_id,)
    )
    if db_cur.rowcount > 0:
        for _, fcm_token in db_cur:
            user_fcm_token = fcm_token
        return user_fcm_token
    else:
        return None


def get_fcm_tokens_from_users(user_ids):
    if len(user_ids) != 0:
        conn = connect_db()
        db_cur = conn.cursor()
        fcm_token_query = "SELECT fcm_token FROM fcm WHERE user_id in ({})".format(', '.join(['%s'] * len(user_ids)))
        db_cur.execute(fcm_token_query, user_ids)
        fcm_tokens = []
        for fcm_token in db_cur:
            fcm_tokens.append(fcm_token[0])
        print(fcm_tokens)
        return fcm_tokens
    else:
        return []


def user_is_owner(user_id, indoor_device_id, outdoor_device_id):
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute(
        "SELECT owner_id FROM device WHERE owner_id=? AND device_id=?",
        (user_id, indoor_device_id)
    )
    if db_cur.rowcount > 0:
        db_cur.execute(
            "SELECT owner_id FROM device WHERE owner_id=? AND device_id=?",
            (user_id, outdoor_device_id)
        )
        if db_cur.rowcount > 0:
            return True
    else:
        return False
    

def get_user_by_username(email):
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute(
        "SELECT user_id FROM users WHERE username=?",
        (email,)
    )
    if db_cur.rowcount > 0:
        for user_id in db_cur:
            return user_id[0]
    else:
        return -1


def get_user_preferences(user_id):
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute(
        "SELECT notif_days, push_interval FROM user_preference WHERE user_id=?",
        (user_id,)
    )
    results = {}
    for notif_days, push_interval in db_cur:
        results['notif_days'] = notif_days
        results['push_interval'] = push_interval
    return results


def get_user_last_notif(user_id):
    conn = connect_db()
    db_cur = conn.cursor()
    db_cur.execute(
        "SELECT last_notif FROM fcm WHERE user_id=?",
        (user_id,)
    )
    for last_notif in db_cur:
        return last_notif[0]
    return -1


# print(get_sensor_readings(16916))
# print(get_sensor(113))
# print(get_latest_sensor_readings(16916))
