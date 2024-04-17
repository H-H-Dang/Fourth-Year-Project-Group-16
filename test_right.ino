#include <WiFi.h>
#include <HTTPClient.h>
#include <Wire.h>
#include "ICM_20948.h"

const char* ssid = "your_wifi_name";  
const char* password = "wifi_password";  

const char* serverAddress = "your_ip_adress";  

SemaphoreHandle_t dataMutex;

WiFiClient wifiClient;
ICM_20948_I2C icm0;
ICM_20948_I2C icm6;
ICM_20948_I2C icm7;
String dataBuffer = "";
const int bufferSize = 60;
int dataCount = 0;

void selectMuxChannel(byte channel) {
  Wire.beginTransmission(0x70);
  Wire.write(1 << channel);
  Wire.endTransmission();
}

bool initializeICM(ICM_20948_I2C& icm) {
  bool status = icm.begin(Wire, 0x68);
  delay(100);
  return status;
}

void accumulateSensorData(ICM_20948_I2C& icm, byte channel) {
  selectMuxChannel(channel);
  if (icm.dataReady()) {
    icm.getAGMT();
    if (xSemaphoreTake(dataMutex, portMAX_DELAY) == pdTRUE) {
      if (dataBuffer.length() > 0) {
        dataBuffer += ",";
      }
      dataBuffer += String(channel) + ":" + String(icm.accX()) + "," + String(icm.accY()) + "," + String(icm.accZ()) + "," + String(icm.gyrX()) + "," + String(icm.gyrY()) + "," + String(icm.gyrZ());
      dataCount++;
      xSemaphoreGive(dataMutex);
    }
  }
}

void Task1code(void* pvParameters) {
  for (;;) {
    accumulateSensorData(icm0, 0);
    accumulateSensorData(icm6, 6);
    accumulateSensorData(icm7, 7);
    delay(0);
  }
}

void sendData() {
  HTTPClient http;
  http.begin(wifiClient, serverAddress);
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");
  String postData = "device_id=arduino_device_right&data=" + dataBuffer;
  int httpResponseCode = http.POST(postData);
  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.println(response);
  } else {
    Serial.print("Error on sending POST: ");
    Serial.println(httpResponseCode);
  }
  http.end();
}

void Task2code(void* pvParameters) {
  for (;;) {
    if (dataCount >= bufferSize) {
      if (xSemaphoreTake(dataMutex, portMAX_DELAY) == pdTRUE) {
        sendData();
        dataBuffer = "";
        dataCount = 0;
        xSemaphoreGive(dataMutex);
      }
    }
    delay(200);
  }
}

void setup() {
  Serial.begin(115200);
  Wire.begin();
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi connected");

  dataMutex = xSemaphoreCreateMutex();

  initializeICM(icm0);
  initializeICM(icm6);
  initializeICM(icm7);

  xTaskCreatePinnedToCore(Task1code, "Task1", 10000, NULL, 1, NULL, 0);
  xTaskCreatePinnedToCore(Task2code, "Task2", 10000, NULL, 1, NULL, 1);
}

void loop() {

}
