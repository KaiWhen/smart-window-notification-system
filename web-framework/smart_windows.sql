CREATE TABLE users (
    user_id varchar(225) NOT NULL UNIQUE,
    username varchar(225) NOT NULL,
    PRIMARY KEY (user_id),
    CONSTRAINT unique_user UNIQUE (user_id, username)
);

CREATE TABLE device (
    device_id int NOT NULL UNIQUE,
    device_name varchar(225) NOT NULL,
    is_online BOOLEAN NOT NULL,
    last_reading_at timestamp,
    owner_id varchar(225) NOT NULL,
    PRIMARY KEY (device_id),
    CONSTRAINT unique_device UNIQUE (device_id, device_name),
    CONSTRAINT fk_device_owner_id FOREIGN KEY (owner_id) REFERENCES users(user_id)
);

CREATE TABLE sensor (
    sensor_id int NOT NULL UNIQUE AUTO_INCREMENT,
    sensor_name varchar(225) NOT NULL,
    sensor_type varchar(225) NOT NULL,
    device_id int NOT NULL,
    sensor_env varchar(225) NOT NULL,
    PRIMARY KEY (sensor_id),
    CONSTRAINT unique_sensor UNIQUE (sensor_id, sensor_name, sensor_type, device_id),
    CONSTRAINT fk_device_id FOREIGN KEY (device_id) REFERENCES device(device_id)
);

CREATE TABLE reading (
    reading_id int NOT NULL UNIQUE AUTO_INCREMENT,
    sensor_id int NOT NULL,
    reading_time timestamp NOT NULL,
    reading_value double(6, 2),
    reading_unit varchar(225) NOT NULL,
    PRIMARY KEY (reading_id),
    CONSTRAINT unique_reading UNIQUE (sensor_id, reading_time, reading_value),
    CONSTRAINT fk_sensor_id FOREIGN KEY (sensor_id) REFERENCES sensor(sensor_id)
);

CREATE TABLE user_preference (
    user_id varchar(225) NOT NULL UNIQUE,
    push_interval int,
    notif_days varchar(225),
    CONSTRAINT fk_pref_user_id FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE device_subscription (
    indoor_device_id int NOT NULL,
    outdoor_device_id int NOT NULL,
    user_id varchar(225) NOT NULL,
    CONSTRAINT fk_indoor_device_id FOREIGN KEY (indoor_device_id) REFERENCES device(device_id),
    CONSTRAINT fk_outdoor_device_id FOREIGN KEY (outdoor_device_id) REFERENCES device(device_id),
    CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT unique_device_subscription UNIQUE (indoor_device_id, outdoor_device_id, user_id)
);

CREATE TABLE notification (
    notif_id int NOT NULL UNIQUE AUTO_INCREMENT,
    notif_window_action varchar(225) NOT NULL,
    notif_title varchar(225) NOT NULL,
    notif_body varchar(225) NOT NULL,
    notif_timestamp timestamp NOT NULL,
    breached_list varchar(225) NOT NULL,
    device_id int NOT NULL,
    PRIMARY KEY (notif_id),
    CONSTRAINT fk_notif_device_id FOREIGN KEY (device_id) REFERENCES device(device_id)
);

CREATE TABLE fcm (
    fcm_token varchar(225) UNIQUE NOT NULL,
    fcm_timestamp timestamp,
    user_id varchar(225) NOT NULL UNIQUE,
    last_notif timestamp,
    CONSTRAINT fk_fcm_user_id FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE threshold (
    lower_thresh int NOT NULL,
    upper_thresh int NOT NULL,
    sensor_type varchar(225) NOT NULL,
    device_id int NOT NULL,
    CONSTRAINT fk_thresh_device_id FOREIGN KEY (device_id) REFERENCES device(device_id),
    CONSTRAINT unique_threshold UNIQUE (device_id, sensor_type)
);
