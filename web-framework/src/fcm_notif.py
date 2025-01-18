import firebase_admin
from firebase_admin import credentials, messaging
import constants
from insert_data import *
from datetime import datetime
from db_api import *

firebase_cred = credentials.Certificate("../serviceAccountKey.json")
firebase_app = firebase_admin.initialize_app(firebase_cred)


def send_push(title, body, fcm_token, notif_data):
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body
            ),
            android=messaging.AndroidConfig(
                notification=messaging.AndroidNotification(
                    default_sound=True,
                    default_vibrate_timings=True
                )
            ),
            data=notif_data,
            token=fcm_token
        )
        response = messaging.send(message)
        print(f'Successfully sent notification: {response}')
    except Exception as e:
        print(f"Failed to send notification: {e}")


def send_notification(device_ids, window_action, breached_list, indoor_readings, outdoor_readings, outdoor_temp):
    users = get_users_from_subscription(device_ids[0], device_ids[1])
    notif_users = []
    now = datetime.now()
    weekday = now.weekday()
    hour = now.hour
    if hour >= 8 and hour < 18:
        for user in users:
            user_preferences = get_user_preferences(user)
            notif_days = user_preferences['notif_days'].split(",")
            if notif_days[weekday] == "True":
                user_last_notif = get_user_last_notif(user)
                if user_last_notif != -1:
                    if (now - user_last_notif).total_seconds() / 60.0 >= user_preferences['push_interval']:
                        notif_users.append(user)
        fcm_tokens = get_fcm_tokens_from_users(notif_users)
        if len(fcm_tokens) == 0:
            return
        update_users_last_notif(notif_users)
    else:
        return
    
    title = ""
    if window_action == constants.ACTION_OPEN:
        title = "Open the Window"
    else:
        title = "Close the Window"

    breached_list_str = ', '.join(breached_list)
    body = f"The following thresholds were breached: {breached_list_str}"

    breached_str = []
    notif_data = {}
    print(breached_list)
    for breached in breached_list:
        outdoor_string = f"Outdoor {breached}: {outdoor_temp}" if breached in [constants.TEMPERATURE] else ""
        breached_str.append(
            f"Indoor {breached}: {round(indoor_readings[breached]['reading_value'], 2)}\n{outdoor_string}"
        )
        notif_data['reading_time'] = indoor_readings[breached]['reading_time'].strftime("%H:%M")

    breached_str = '\n\n'.join(breached_str)
    print(breached_str)
    notif_data['details'] = breached_str
    
    for fcm_token in fcm_tokens:
        send_push(title, body, fcm_token, notif_data)
    insert_notification(window_action, title, body, now, breached_list_str, device_ids[0])
