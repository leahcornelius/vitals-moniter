/*
   Sample code to test my viatl sign moniter
   adapted from 
   Copyright World Famous Electronics LLC - see LICENSE
   Contributors:
     Joel Murphy, https://pulsesensor.com
     Yury Gitman, https://pulsesensor.com
     Bradford Needham, @bneedhamia, https://bluepapertech.com
   By:
     Leo Cornelius,
   Licensed under the MIT License, a copy of which
   should have been included with this software.
   DOES NOT USE REAL SENSORS YET

*/


#define USE_ARDUINO_INTERRUPTS true
#include <PulseSensorPlayground.h>
int hr, spo2, resp, sys, dys = 0;
float temp = 0;
int raw_ecg, raw_pleth, raw_resp, etco2, raw_etco2 = 0;
int interval, previousbpm = 0;
int resp_thresh = 20;
unsigned long previousMillis;
double ekg[] = {0.19136, 0.19136, 0.27337, 0.41006, 0.54675, 0.74282, 2.0672, 4.8761, 9.1102, 13.701, 18.291, 22.881, 27.472, 30.226, 29.92, 26.554, 21.963, 17.373, 12.782, 8.1921, 4.2015, 1.7103, 0.7185, 0.62638, 0.53427, 0.44215, 0.35004, 0.25792, 0.16581, -0.9667, -6.2608, -14.335, -14.306, -1.4965, 22.712, 48.475, 71.736, 76.651, 60.719, 26.441, -10.339, -44.249, -57.116, -46.071, -20.956, -4.5927, 0.149, 0.24213, 0.33526, 0.42839, 0.52151, 0.61464, 0.70777, 0.80089, 0.89402, 0.98715, 1.0803, 1.1734, 1.2665, 1.3597, 1.4528, 1.5459, 1.9248, 3.0181, 4.8258, 7.0621, 9.2985, 11.535, 13.771, 15.65, 16.097, 15.053, 12.877, 10.64, 8.404, 6.1676, 4.0046, 2.3792, 1.3647, 0.88781, 0.48964, 0.1937, 0.032284, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
int i = 0;
int sineA[] =
{ 128 , 150 , 171 , 191 , 209 , 225 ,
  238 , 247 , 253 , 255 , 253 , 247 ,
  238 , 225 , 209 , 191 , 171 , 150 ,
  128 , 105 , 84 , 64 , 46 , 30 ,
  17 , 8 , 2 , 0 , 2 , 8 ,
  17 , 30 , 46 , 64 , 84 , 105 ,
  127
};
int ii;


const int OUTPUT_TYPE = PROCESSING_VISUALIZER;
const int PULSE_INPUT = A0;
const int PULSE_BLINK = 13;    // Pin 13 is the on-board LED
const int PULSE_FADE = 5;
const int THRESHOLD = 550;   // Adjust this number to avoid noise when idle
PulseSensorPlayground pulseSensor(2);
void setup() {
  Serial.begin(115200);
  pulseSensor.analogInput(PULSE_INPUT, 0);
  pulseSensor.blinkOnPulse(PULSE_BLINK, 0);
  pulseSensor.fadeOnPulse(PULSE_FADE, 0);
  pulseSensor.analogInput(A1, 1);
  pulseSensor.blinkOnPulse(12, 1);
  pulseSensor.fadeOnPulse(11, 1);
  pulseSensor.setSerial(Serial);
  pulseSensor.setOutputType(OUTPUT_TYPE);
  pulseSensor.setThreshold(THRESHOLD);
  if (!pulseSensor.begin()) {
    for (;;) {
      // Flash the led to show things didn't work.
      digitalWrite(PULSE_BLINK, LOW);
      delay(50);
      digitalWrite(PULSE_BLINK, HIGH);
      delay(50);
    }
  }
}
int calc_resp() {
  i = i + 10;
  if (i == 33) i = 0;
  return abs(sineA[i] % 30);
}
int calc_spo2() {
  return random(96, 99);
}
float calc_temp() {
  return (random(366, 374) / 10.0);
}
int calc_rr(int w) {
  /*
    if (w > resp_thresh) {
    interval = millis() - previousMillis;
    Serial.println(interval);
    previousMillis = millis();
    previousbpm = 60 / (interval/1000);
    return previousbpm;
    } else {
    return previousbpm;
    }
  */
  return random(16, 19);
}
int calc_etco2(int w) {
  return random(35, 48);
}
void loop() {
  /*
     Wait a bit.
     We don't output every sample, because our baud rate
     won't support that much I/O.
  */
  delay(20);

  // write the latest sample to Serial.
  raw_pleth = analogRead(A2) % 30;
  raw_ecg = pulseSensor.getLatestSample(0);
  //raw_ecg = ekg[ii];
  ii++;
  if (ii == 100) {
    ii = 0;
  }
  raw_resp = calc_resp();
  spo2 = calc_spo2();
  resp = calc_rr(raw_resp);
  temp = calc_temp();
  raw_etco2 = abs(analogRead(A5) % 70);
  etco2 = calc_etco2(raw_etco2);
  sys = -1;
  dys = -1;
  Serial.println(String("[,") + String(pulseSensor.getBeatsPerMinute(0)) + "," + String(spo2) + "," + String(resp) + "," + String(temp) + "," + String(sys) + "," + String(dys) + "," + String(etco2) + "," + String(raw_ecg) + ","  + String(raw_resp) + "," + String(raw_pleth) + "," + String(raw_etco2) + String(",]"));

  if (pulseSensor.sawStartOfBeat()) {
    pulseSensor.outputBeat();
  }
}
