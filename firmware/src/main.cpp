#include <Arduino.h>
#include <ArduinoJson.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <PubSubClient.h>
#include <bits/stdc++.h>
#include <Wire.h>
#include <DNSServer.h>            // Local DNS Server used for redirecting all requests to the configuration portal
#include <WiFiManager.h>

int V3_PIN = 5;

const int MPU_addr=0x68;
int16_t AcX,AcY,AcZ,Tmp,GyX,GyY,GyZ;
 
int minVal=265;
int maxVal=402;

double x;
double y;
double z;

const char* mqtt_broker = "";
const char* client_name = "window_sensor_16916";
const char* mqtt_user = "";
const char* mqtt_password = "";

const char* pub_topic = "/enmon/window";

unsigned long lastTime = 0;
unsigned long timerDelay = 500;

WiFiClient espClient;
PubSubClient client(espClient);

void reconnect() {
  while (!client.connected()) {
    Serial.println("Attempting MQTT connection...");
    if (client.connect(client_name, mqtt_user, mqtt_password)) {
      Serial.println("connected");
      client.publish("/enmon/connected", "connected to MQTT");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void connectmqtt()
{
  client.connect(client_name, mqtt_user, mqtt_password);
  {
    Serial.println("connected to MQTT");
    client.publish("/enmon/connected",  "connected to MQTT");

    if (!client.connected())
    {
      reconnect();
    }
  }
}

void setup()
{
  pinMode(V3_PIN, OUTPUT);
  digitalWrite(V3_PIN, HIGH);
  delay(50);
  Wire.begin();
  Wire.beginTransmission(MPU_addr);
  Wire.write(0x6B);
  Wire.write(0);
  Wire.endTransmission(true);
  Serial.begin(9600);
  
  WiFiManager wifiManager;
  wifiManager.setConfigPortalTimeout(180);

  bool res;
  res = wifiManager.autoConnect("ESP32AP", "smartwindow"); // password protected ap

  if(!res) {
      Serial.println("Failed to connect, restarting");
      ESP.restart();
  } 
  else {
      //if you get here you have connected to the WiFi    
      Serial.println("WiFi Connected");
  }

  client.setServer(mqtt_broker, 1883); //connecting to mqtt server 
  connectmqtt();
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  Wire.beginTransmission(MPU_addr);
  Wire.write(0x3B);
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_addr,14,true);
  AcX=Wire.read()<<8|Wire.read();
  AcY=Wire.read()<<8|Wire.read();
  AcZ=Wire.read()<<8|Wire.read();
  int xAng = map(AcX,minVal,maxVal,-90,90);
  int yAng = map(AcY,minVal,maxVal,-90,90);
  int zAng = map(AcZ,minVal,maxVal,-90,90);
  
  x= RAD_TO_DEG * (atan2(-yAng, -zAng)+PI) - 4;
  y= RAD_TO_DEG * (atan2(-xAng, -zAng)+PI);
  z= RAD_TO_DEG * (atan2(-yAng, -xAng)+PI);
  
  Serial.print("AngleX= ");
  Serial.println(x);

  if ((millis() - lastTime) > timerDelay) {
    //Check WiFi connection status
    if(WiFi.status() == WL_CONNECTED) {
      char angle_str[8];
      dtostrf(x, 6, 2, angle_str);
      client.publish(pub_topic, angle_str);
    }
    else {
      Serial.println("WiFi Disconnected");
    }
    lastTime = millis();
  }
  
  delay(4000);
}