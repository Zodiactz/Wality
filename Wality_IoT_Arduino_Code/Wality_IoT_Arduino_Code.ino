#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SH110X.h>
#include <qrcode.h>
#include <WiFi.h>
#include <HTTPClient.h>

// Define the OLED reset pin and I2C address
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET    -1  // No reset pin
#define SCREEN_ADDRESS 0x3C

Adafruit_SH1106G display = Adafruit_SH1106G(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

// Define sensor and LED
#define LED_BUILTIN 2
#define SENSOR 27

long currentMillis = 0;
long previousMillis = 0;
int interval = 1000;
float calibrationFactor = 5.7;
volatile byte pulseCount;
byte pulse1Sec = 0;
float flowRate;
unsigned int flowMilliLitres;
unsigned long totalMilliLitres;
unsigned long lastQuantityChange = 0;
float lastTotalMilliLitres = 0;
int countdown = 30;  // Countdown starts from 30 seconds
bool isCountingDown = false;
bool showFinalResult = false;
unsigned long finalDisplayStart = 0;
bool resetForNextUser = false;
bool showQRCode = false;
bool qrCodeShown = false;
String generatedWaterId;
unsigned long qrCodeStartTime = 0;

// Replace with your network credentials
const char* ssid = "Hoho";
const char* password = "satnha555";

void IRAM_ATTR pulseCounter() {
  pulseCount++;
}

void setup() {
  Serial.begin(115200);

  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(SENSOR, INPUT_PULLUP);

  pulseCount = 0;
  flowRate = 0.0;
  flowMilliLitres = 0;
  totalMilliLitres = 0;
  previousMillis = 0;

  attachInterrupt(digitalPinToInterrupt(SENSOR), pulseCounter, FALLING);

  // Initialize the OLED display
  if (!display.begin(SCREEN_ADDRESS, OLED_RESET)) {
    Serial.println(F("SSD1306 allocation failed"));
    for (;;);
  }
  display.display();
  delay(1000);
  display.clearDisplay();

  // Initialize Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("Connected to Wi-Fi");
}

void generateRandomWaterId() {
  generatedWaterId = String(random(100000, 999999));
}

void uploadDataToMongoDB() {
  HTTPClient http;
  String url = "https://data.mongodb-api.com/app/wality-1-djgtexn/endpoint/createQRwater";
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  
  String body = "{\"waterId\":\"" + generatedWaterId + "\",\"quantity\":" + totalMilliLitres + ",\"status\":\"deactive\"}";
  int httpCode = http.POST(body);
  
  if (httpCode > 0) {
    String payload = http.getString();
    Serial.println("Data uploaded: " + payload);
  } else {
    Serial.println("Error on HTTP request");
  }
  http.end();
}

bool getDataStatus() {
  if (totalMilliLitres != lastTotalMilliLitres) {
      // Water flow increased, delete data and reset
      deleteDataFromMongoDB();
      resetForNextUser = true;
      showQRCode = false;
      qrCodeShown = false;
    }
  HTTPClient http;
  String url = "https://data.mongodb-api.com/app/wality-1-djgtexn/endpoint/getWaterId?waterId=" + generatedWaterId;
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  
  int httpCode = http.GET();
  
  if (httpCode > 0) {
    String payload = http.getString();
    Serial.println("Received status: " + payload);
    if (payload.indexOf("\"status\":\"active\"") > 0) {
      return true;
    }
  } else {
    Serial.println("Error on HTTP request");
  }
  http.end();
  return false;
}

void deleteDataFromMongoDB() {
  HTTPClient http;
  String url = "https://data.mongodb-api.com/app/wality-1-djgtexn/endpoint/delWaterId?waterId=" + generatedWaterId;
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  
  int httpCode = http.GET();
  
  if (httpCode > 0) {
    String payload = http.getString();
    Serial.println("Data deleted: " + payload);
  } else {
    Serial.println("Error on HTTP request");
  }
  http.end();
}

void drawQRCode(const char* data) {
  QRCode qrcode;
  uint8_t qrcodeData[qrcode_getBufferSize(3)];
  qrcode_initText(&qrcode, qrcodeData, 3, 0, data);

  int offsetX = (SCREEN_WIDTH - qrcode.size * 2) / 2;  // Center the QR code horizontally
  int offsetY = (SCREEN_HEIGHT - qrcode.size * 2) / 2;  // Center the QR code vertically
  
  for (uint8_t y = 0; y < qrcode.size; y++) {
    for (uint8_t x = 0; x < qrcode.size; x++) {
      if (qrcode_getModule(&qrcode, x, y)) {
        // Each QR code module is 2x2 pixels
        display.fillRect(offsetX + x * 2, offsetY + y * 2, 2, 2, SH110X_WHITE);
      } else {
        display.fillRect(offsetX + x * 2, offsetY + y * 2, 2, 2, SH110X_BLACK);
      }
    }
  }
}

void loop() {
  currentMillis = millis();

  if (showQRCode) {
    // Check if water flow continues during QR code display
    if (pulseCount > 0) {  // Check if there's any new pulse
      // Water flow detected, delete data and reset
      deleteDataFromMongoDB();
      resetForNextUser = true;
      showQRCode = false;
      qrCodeShown = false;
      pulseCount = 0;  // Reset pulse count to avoid multiple triggers
    } else if (!qrCodeShown) {
      // Display QR code
      qrCodeStartTime = millis();
      display.clearDisplay();
      display.setTextSize(1);
      display.setTextColor(SH110X_WHITE);
      display.setCursor(0, 0);
      display.display();
      drawQRCode((generatedWaterId).c_str());
      display.display();
      qrCodeShown = true;
    }

    // Handle timeout for QR code display
    if (currentMillis - qrCodeStartTime >= 30000) {
      deleteDataFromMongoDB();
      resetForNextUser = true;
      showQRCode = false;
      qrCodeShown = false;
    } else if (getDataStatus()) {
      // If status is active, indicate success and reset
      display.clearDisplay();
      display.setTextSize(2);
      display.setTextColor(SH110X_WHITE);
      display.setCursor(0, 0);
      display.print("SUCCESS!");
      display.display();
      delay(5000); // Show SUCCESS! for 5 seconds
      deleteDataFromMongoDB();
      resetForNextUser = true;
      showQRCode = false;
      qrCodeShown = false;
    }

    return;
  }

  // The rest of the existing loop code follows
  if (currentMillis - previousMillis > interval) {
    pulse1Sec = pulseCount;
    pulseCount = 0;

    // Calculate flow rate
    flowRate = ((1000.0 / (millis() - previousMillis)) * pulse1Sec) / calibrationFactor;
    previousMillis = millis();

    // Calculate flow in milliliters
    flowMilliLitres = (flowRate / 60) * 1000;
    totalMilliLitres += flowMilliLitres;

    if (!showFinalResult && !resetForNextUser) {
      if (totalMilliLitres != 0) {
        if (pulse1Sec > 0) {
          lastQuantityChange = millis();
          lastTotalMilliLitres = totalMilliLitres;
          isCountingDown = false;
          countdown = 5;
        } else if (!isCountingDown && (millis() - lastQuantityChange) >= 1000) {
          isCountingDown = true;
        }

        if (isCountingDown) {
          if (countdown > 0 && (millis() - lastQuantityChange) >= 1000 * (6 - countdown)) {
            countdown--;
          }

          display.clearDisplay();
          display.setTextSize(2);
          display.setTextColor(SH110X_WHITE);
          display.setCursor((SCREEN_WIDTH - 12 * 9) / 2, 0); // Center "Countdown"
          display.print("Countdown: ");
          display.println(countdown);
          display.display();
        }

        if (countdown == 0) {
          showFinalResult = true;
          finalDisplayStart = millis();
          generateRandomWaterId();
          uploadDataToMongoDB();
        }

        if (!isCountingDown) {
          display.clearDisplay();
          display.setTextSize(2);
          display.setTextColor(SH110X_WHITE);
          display.setCursor(0, 0);
          display.print("Flow");

          String waterText = String(totalMilliLitres) + " mL";
          int16_t x1, y1;
          uint16_t textWidth, textHeight;
          display.getTextBounds(waterText, 0, 0, &x1, &y1, &textWidth, &textHeight);
          display.setCursor(SCREEN_WIDTH - textWidth, SCREEN_HEIGHT - textHeight);
          display.println(waterText);

          display.display();
        }
      } else {
        display.clearDisplay();
        display.setTextSize(2);
        display.setTextColor(SH110X_WHITE);
        display.setCursor(0, 0);
        display.print("Flow");

        String waterText = "0 mL";
        int16_t x1, y1;
        uint16_t textWidth, textHeight;
        display.getTextBounds(waterText, 0, 0, &x1, &y1, &textWidth, &textHeight);
        display.setCursor(SCREEN_WIDTH - textWidth, SCREEN_HEIGHT - textHeight);
        display.println(waterText);

        display.display();
      }
    }

    if (showFinalResult) {
      display.clearDisplay();
      display.setTextSize(2);
      display.setTextColor(SH110X_WHITE);
      display.setCursor(0, 0);
      display.print("Final Flow");

      String waterText = String(totalMilliLitres) + " mL";
      int16_t x1, y1;
      uint16_t textWidth, textHeight;
      display.getTextBounds(waterText, 0, 0, &x1, &y1, &textWidth, &textHeight);
      display.setCursor(SCREEN_WIDTH - textWidth, SCREEN_HEIGHT - textHeight);
      display.println(waterText);

      display.display();

      if (millis() - finalDisplayStart >= 5000) {
        resetForNextUser = true;
        showFinalResult = false;
        showQRCode = true;  // Start showing QR code after final result
      }
    }

    if (resetForNextUser) {
      totalMilliLitres = 0;
      lastTotalMilliLitres = 0;
      isCountingDown = false;
      countdown = 30;  // Reset countdown timer
      resetForNextUser = false;

      display.clearDisplay();
      display.setTextSize(2);
      display.setTextColor(SH110X_WHITE);
      display.setCursor(0, 0);
      display.print("Flow");

      String waterText = "0 mL";
      int16_t x1, y1;
      uint16_t textWidth, textHeight;
      display.getTextBounds(waterText, 0, 0, &x1, &y1, &textWidth, &textHeight);
      display.setCursor(SCREEN_WIDTH - textWidth, SCREEN_HEIGHT - textHeight);
      display.println(waterText);

      display.display();
    }
  }
}

