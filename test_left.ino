#include <SPI.h>
#include <WiFiNINA.h>
#include <ArduinoHttpClient.h>
#include <Wire.h>
#include <ICM_20948.h>

const char ssid[] = "your_wifi_name"; 
const char pass[] = "wifi_password"; 

const String deviceId = "arduino_device_1eft"; 

const char serverAddress[] = "your_ip_address"; 
int serverPort = 443; 

const byte qwiicMuxAddress = 0x70;
ICM_20948_I2C icm0;
ICM_20948_I2C icm6;
ICM_20948_I2C icm7;

WiFiClient wifi;
HttpClient client = HttpClient(wifi, serverAddress, serverPort);

String dataBuffer = ""; 
const int bufferSize = 60; 
int dataCount = 0; 

void setup() {
  Serial.begin(9600);
  Wire.begin();
  WiFi.begin(ssid, pass);

  while (WiFi.status() != WL_CONNECTED) {
    delay(100);
    Serial.print(".");
  }
  Serial.println("connected!");

  initializeSensors();
 
}

void loop() {
  accumulateSensorData(icm0, 0);
  accumulateSensorData(icm6, 6);
  accumulateSensorData(icm7, 7);

  
  if (dataCount >= bufferSize) {
    sendData();
    dataBuffer = ""; 
    dataCount = 0; 
  }

  delay(10); 
}

void accumulateSensorData(ICM_20948_I2C &icm, byte channel) {
  selectMuxChannel(channel);
  if (icm.dataReady()) {
    icm.getAGMT(); 
    
    if (dataBuffer.length() > 0) {
      dataBuffer += ","; 
    }
    dataBuffer += String(channel) + ":" + String(icm.accX()) + "," + String(icm.accY()) + "," + String(icm.accZ()) + ","  + String(icm.gyrX()) + "," + String(icm.gyrY()) + "," + String(icm.gyrZ());
    dataCount++;
  }
}


void sendData() {
  
  String postData = "device_id=" + deviceId + "&data=" + dataBuffer;
  Serial.println(postData);
  
  Serial.println("Sending batch data to server...");
  client.post("/data", "application/x-www-form-urlencoded", postData);

  Serial.println(client.responseBody());
}


void initializeSensors() {
  selectMuxChannel(0);
  if (!initializeICM(icm0)) {
    Serial.println("ICM-20948 on channel 0 initialization failed");
  } else {
    Serial.println("ICM-20948 on channel 0 initialized successfully");
  }

  selectMuxChannel(6);
  if (!initializeICM(icm6)) {
    Serial.println("ICM-20948 on channel 6 initialization failed");
  } else {
    Serial.println("ICM-20948 on channel 6 initialized successfully");
  }

  selectMuxChannel(7);
  if (!initializeICM(icm7)) {
    Serial.println("ICM-20948 on channel 7 initialization failed");
  } else {
    Serial.println("ICM-20948 on channel 7 initialized successfully");
  }
}

void selectMuxChannel(byte channel) {
  Wire.beginTransmission(qwiicMuxAddress);
  Wire.write(1 << channel);
  Wire.endTransmission();
}

bool initializeICM(ICM_20948_I2C &icm) {
  bool status = icm.begin(Wire, 0x68); 
  delay(100); 
  return status;
}
