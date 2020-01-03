import processing.serial.*;
import java.awt.Toolkit;
import processing.sound.*;
SoundFile file;
Graph g, g1, g2, g3;
int pSize = 1000;  
int ofs, ofr, oft, ofp =0;
boolean raspberrypi = false;
float[] xdata = new float[pSize];
float[] ecgdata = new float[pSize];
float[] respdata = new float[pSize];
float[] bpmArray = new float[pSize];
float[] ecg_avg = new float[pSize];                          
float[] resp_avg = new float[pSize];
float[] spo2data = new float[pSize];
float[] spo2Array_IR = new float[pSize];
float[] spo2Array_RED = new float[pSize];
float[] rpmArray = new float[pSize];
float[] ppgArray = new float[pSize];
float[] etco2data = new float[pSize];
int ofec;
String lhc;
float time = 0;
boolean startPlot = false;
boolean grid = false;
Serial port = null;
String inString = "\0";  
int heartRate = -1;
int spo2 = -1;
int resp = -1;
float temp = -1;
int sys = -1;
int dys = -1;
int etco2 = -1;
int arrayIndex, o = 0;
double maxe, mine, maxr, minr, maxs, mins, minc, maxc;
int hr_min, hr_max, spo2_min, spo2_max, resp_min, resp_max, sys_min, sys_max, dys_min, dys_max, etco2_max, etco2_min = 0;
double temp_min, temp_max;
boolean alarm = false;
boolean silenced = false;
int alarm_level = 0;
int place = 0;
int of =0;
int level_3_interval = 50;
int previousMillis = 0;
int level_1_interval = 3500;
int alarms = 0;
boolean freeze = true;
public void setup() 
{
  fullScreen();
  background(0);
  hr_min = 45;
  hr_max = 120;
  spo2_min = 92;
  spo2_max = 100;
  resp_min = 12;
  resp_max = 20;
  temp_min = 36;
  temp_max = 38;
  sys_min =  95;
  sys_max = 130;
  dys_min = 30;
  dys_max = 85;
  g = new Graph(10, 20, 1008, 148);
  g1 = new Graph(10, 316, 1008, 100);
  g2 = new Graph(10, 188, 1008, 120);
  g3 = new Graph(10, 484, 1008, 100);
  g.GraphColor = color(0, 255, 0);
  g1.GraphColor = color(0, 191, 255);
  g2.GraphColor = color(255, 255, 0);
  g3.GraphColor = color(150, 0, 150);
  setChartSettings();                                    // graph function to set minimum and maximum for axis

  /*******  Initializing zero for buffer ****************/

  for (int i=0; i<pSize; i++) 
  {
    time = time + 1;
    xdata[i]=time;
    ecgdata[i] = 0;
    respdata[i] = 0;
    ppgArray[i] = 0;
    etco2data[i] = 0;
  }
  time = 0;
}

void startSerial() {
  try
  { 
    if (raspberrypi) port = new Serial(this, Serial.list()[2], 115200);
    else port = new Serial(this, Serial.list()[1], 115200);
    port.clear();
    port.bufferUntil('\n');
    startPlot = true;
  }
  catch(Exception e)
  {
    System.exit (0);
  }
}
void serialEvent (Serial myPort) {
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');
  processData(inString);
}

void processData(String in) {
  if (in != null) {
    in = trim(in); // trim off whitespaces.
    println(in);
    String[] inTemp = split(in, ',');
    if (inTemp[0] != "[" || inTemp[inTemp.length-1] != "]") {
      int len = inTemp.length;
      if (len - 1 == 12) {
        heartRate = int(inTemp[1]);
        spo2 = int(inTemp[2]);
        resp = int(inTemp[3]);
        temp = float(inTemp[4]);
        sys = int(inTemp[5]);
        dys = int(inTemp[6]);
        etco2 = int(inTemp[7]);
        ecgdata[arrayIndex] = float(inTemp[8]);
        ppgArray[arrayIndex] = float(inTemp[10]);
        respdata[arrayIndex] = float(inTemp[9]);
        etco2data[arrayIndex] = float(inTemp[11]);
        arrayIndex++;
        if (arrayIndex == pSize)
        {  
          arrayIndex = 0;
          time = 0;
        }
        time = time+1;
        xdata[arrayIndex] = time;
        println(arrayIndex);
        // Calculating the minimum & maximum of the wave forms for auto scaling

        maxe = max(ecgdata);
        mine = min(ecgdata);
        maxr = max(respdata);
        minr = min(respdata);
        maxs = max(spo2data);
        mins = min(spo2data);
        minc = min(etco2data);
        maxc = max(etco2data);
        if ((maxe != g.yMax1))
          g.yMax1 = (int)maxe;
        if ((mine != g.yMin1))
          g.yMin1 = (int)mine;

        if ((maxr != g1.yMax1))
          g1.yMax1 = (int)maxr;
        if ((minr != g1.yMin1))
          g1.yMin1 = (int)minr;

        if ((maxs != g2.yMax1))
          g2.yMax1 = (int)maxs;
        if ((mins != g2.yMin1))
          g2.yMin1 = (int)mins;

        if ((maxc != g3.yMax1))
          g3.yMax1 = (int)maxc;
        if ((minc != g3.yMin1))
          g3.yMin1 = (int)minc;
      } else println("Invalid Input Count");
    } else println("Missing [ or ]");
  } else println("Null value!");
}
void setChartSettings() {
  g.xDiv=10; 
  g.xMax1=pSize; 
  g.xMin1=0;  
  g.yMax1=1300; 
  g.yMin1=-400;

  g1.xDiv=10;  
  g1.xMax1=pSize; 
  g1.xMin1=0;  
  g1.yMax1=30; 
  g1.yMin1=0;

  g2.xDiv=10;  
  g2.xMax1=pSize; 
  g2.xMin1=0;  
  g2.yMax1=30; 
  g2.yMin1=0;

  g3.xDiv=10;  
  g3.xMax1=pSize; 
  g3.xMin1=0;  
  g3.yMax1=70; 
  g3.yMin1=0;
}

public void draw() {
  alarms = 0;
  background(0);
  if (keyPressed) {
    if (key == 27) {
      exit();
    }
  }
  if (!startPlot)                              // Calling the method to connect with the serial port
    startSerial();
  delay(1000);

  g.DrawAxis();                              // Draw the grid for the graph
  if (startPlot)                             // If the condition is true, then the plotting is done
  {
    g.LineGraph(xdata, ecgdata);
    g1.LineGraph(xdata, respdata);
    g2.LineGraph(xdata, ppgArray);
    g3.LineGraph(xdata, etco2data);
    alarm_level =0;
    stroke(200);          
    fill(0);
    rectMode(CORNER);
    if (etco2 < etco2_min && etco2 != -1 || etco2 > etco2_max && etco2 != 1) {
      alarm = true;
      alarm_level = 2;
      if (ofec == 1) {
        fill(255, 0, 0);
        ofec = 0;
      } else {
        fill(0);
      }
      rect(720, 612, 300, 148, 7);
      fill (0);
      fill(255, 255, 0);
      rect(35, 720, 500, 40, 0);
      textSize(30);
      fill(255, 0, 0);
      if (etco2 < etco2_min) lhc = "low";
      if (etco2 > etco2_max) lhc = "high";
      alarms++;
      if (place==1) {
        text("ETC02 "+lhc, 38, 750);
        place = 0;
        alarm = true;
        alarm_level = 2;
      } else {
        text("ETC02 "+lhc, 355, 750);
        place = 1;
        alarm = true;
        alarm_level = 2;
      }
    } else {
      fill(0);
      rect(720, 612, 300, 148, 7);
    }
    if (heartRate < hr_min && heartRate != -1 || heartRate > hr_max && heartRate != -1) {
      alarm = true;
      alarm_level = 2;
      alarms++;
      if (of ==1) {
        fill(255, 0, 0);
        of = 0;
      } else {
        fill(0);
        of = 1;
      }

      rect(1020, 20, 300, 148, 7);
      if (heartRate < hr_max) lhc = "low";
      if (heartRate > hr_min) lhc = "high";
      alarms++;
      if (place==1) {
        text("Heart Rate "+lhc, 38, 750);
        place = 0;
        alarm = true;
        alarm_level = 2;
      } else {
        text("Heart Rate "+lhc, 300, 750);
        place = 1;
        alarm = true;
        alarm_level = 2;
      }

      fill(0);
    } else {
      rect(1020, 20, 300, 148, 7);
    }
    if (spo2 < spo2_min && spo2 != -1 || spo2 > spo2_max && spo2 != -1) {
      alarms++;
      String lh;
      if (spo2<spo2_min) {
        lh="Low";
      } else {
        lh ="High";
      }
      if (ofs ==1) {
        fill(255, 0, 0);
        ofs = 0;
      } else {
        fill(0);
        ofs = 1;
      }
      rect(1020, 168, 300, 148, 7);
      fill(0);
      fill(255, 255, 0);
      rect(35, 720, 500, 40, 0);
      textSize(30);
      fill(255, 0, 0);
      if (place==1) {
        text("SP02 "+lh, 38, 750);
        place = 0;
        alarm = true;
        alarm_level = 2;
      } else {
        text("SP02 "+lh, 395, 750);
        place = 1;
        alarm = true;
        alarm_level = 2;
      }
      fill(0);
    } else {
      rect(1020, 168, 300, 148, 7);
    }
    if (resp < resp_min && resp != -1 || resp > resp_max && resp != -1) {
      alarm = true;
      alarm_level = 2;
      if (ofr ==1) {
        fill(255, 0, 0);
        ofr = 0;
      } else {
        fill(0);
        ofr = 1;
      }
      rect(1020, 316, 300, 148, 7);
      fill(0);
    } else {
      rect(1020, 316, 300, 148, 7);
    }
    if (temp < temp_min && temp != -1 || temp > temp_max && temp != -1) {
      alarm = true;
      alarm_level = 2;
      if (oft ==1) {
        fill(255, 0, 0);
        oft = 0;
      } else {
        fill(0);
        oft = 1;
      }
      rect(1020, 464, 300, 148, 7);
      fill(0);
    } else {
      rect(1020, 464, 300, 148, 7);
    }

    if (sys < sys_min && sys != -1 && dys != -1 || sys > sys_max && sys != -1 && dys != -1 || dys < dys_min && sys != -1 && dys != -1 || dys > dys_max && sys != -1 && dys != -1) {
      /*
      alarm = true;
       alarm_level = 2;
       */
      if (ofp ==1) {
        fill(255, 0, 0);
        ofp = 0;
      } else {
        fill(0);
        ofp = 1;
      }
      rect(1020, 612, 300, 148, 7);
      fill(0);
    } else {
      rect(1020, 612, 300, 148, 7);
    }
    textSize(25);
    fill(0, 255, 0);
    //textAlign(RIGHT);

    textSize(80);
    if (heartRate != -1) {
      text(heartRate, 1030, 135);
    }
    fill(255, 255, 0);
    if (spo2 != -1) {
      text(spo2, 1030, 283);
    }
    fill(0, 191, 255);
    if (resp != -1) {
      text(resp, 1030, 431);
    }
    fill(255, 0, 0);
    if (temp != -1) {
      String tempString = str(temp);
      int[] temps = int(split(tempString, '.'));
      textSize(75);
      if (temp < temp_min || temp > temp_max) {
        fill(255, 255, 255);
        text(temps[0]+"."+temps[1], 1030, 579);
      } else {
        text(temps[0]+"."+temps[1], 1030, 579);
      }
    }
    fill(255, 255, 255);
    if (sys != -1) {
      textSize(50);
      text(sys +"/"+dys, 1030, 727);
    }
    textSize(25);
    text("ECG", 1030, 50);
    if (heartRate == -1) {
      textSize(90);
      text("- - -", 1030, 135);
      textSize(20);
      text("LEADS OFF", 1200, 50);
      if (alarm_level != 2 && alarm_level != 3) {
        alarm_level = 1;
      }
      alarm = true;
    }
    textSize(90);
    textSize(30);
    text("BPM", 1250, 125);
    textSize(25);
    fill(255, 255, 255);
    text("SPO2", 1030, 198);
    if (spo2 == -1) {
      textSize(20);
      text("SEN OFF", 1200, 198);
      textSize(90);
      text("- - -", 1030, 283);
      alarm = true;
      if (alarm_level != 2 && alarm_level != 3) {
        alarm_level = 1;
      }
    }
    textSize(90);
    textSize(60);
    text(" %", 1230, 283);
    textSize(25);
    fill(255, 255, 255);
    text("RESP", 1030, 346);
    if (resp == -1) {
      textSize(20);
      text("SEN OFF", 1200, 346);
      textSize(90);
      text("- - -", 1030, 283);
      alarm = true;
      if (alarm_level != 2 && alarm_level != 3) {
        alarm_level = 1;
      }
      alarm = true;
    }
    textSize(90);
    textSize(30);
    text("RPM", 1250, 421);
    textSize(25);
    fill(255, 255, 255);
    text("TEMP", 1030, 494);
    if (temp == -1) {
      textSize(20);
      text("SEN OFF", 1200, 494);
      textSize(90);
      text("- - -", 1030, 431);
      alarm = true;
      if (alarm_level != 2 && alarm_level != 3) {
        alarm_level = 1;
      }
    }

    textSize(25);
    text("ETC02", 730, 642);
    textSize(60);
    text("*C", 1232, 579);
    textSize(25);
    fill(255, 255, 255);
    text("NIBP", 1030, 642);
    if (sys == -1) {
      textSize(20);
      text("CUFF OFF", 1200, 642);
      textSize(35);
      text("- - - / - - -", 1030, 727);
      /* do not alarm for cuff off as there is no bp cuff module yet
       alarm = true;
       
       if (alarm_level != 2 && alarm_level != 3) {
       alarm_level = 1;
       }
       */
    }
    textSize(35);
    textSize(25);
    text(" mmHg", 1230, 727);
    if (heartRate==0) {
      fill(255, 0, 0);
      rect(35, 720, 500, 40, 0);
      textSize(30);
      fill(255, 255, 255);
      if (place==1) {
        text("Cardiac Arest", 38, 750);
        place = 0;
        alarm = true;
        alarm_level = 3;
      } else {
        text("Cardiac Arest", 338, 750);
        place = 1;
        alarm = true;
        alarm_level = 3;
      }
    } else if (resp == 0) {
      fill(255, 0, 0);
      rect(35, 720, 500, 40, 0);
      textSize(30);
      fill(255, 255, 255);
      alarm = true;
      alarm_level = 3;
      if (place==1) {
        text("Apnea", 38, 750);
        place = 0;
      } else {
        text("Apnea", 458, 750);
        place = 1;
      }
    }
    if (alarm == true && silenced == false) {
      if (alarm_level == 3) {
        if (millis() - previousMillis > level_3_interval) {
          file = new SoundFile(this, "alarms/Level3.mp3");
          file.play();
          previousMillis = millis();
        }
      } else if (alarm_level == 2) {
        file = new SoundFile(this, "alarms/level2.mp3");
        file.play();
      } else if (alarm_level == 1) {
        if (millis() - previousMillis > level_1_interval) {
          file = new SoundFile(this, "alarms/level1.mp3");
          file.play();
          previousMillis = millis();
        }
      }
    }
    g.LineGraph(xdata, ecgdata);
    g1.LineGraph(xdata, respdata);
    g2.LineGraph(xdata, ppgArray);
    g3.LineGraph(xdata, etco2data);
  } else                                     // Default value is set
  {
    stroke(200);          
    fill(0);
    textSize(90);
    text("- - -", 1030, 135);
    text("- - -", 1030, 283);
    text("- - -", 1030, 431);
    text("- - -", 1030, 579);
    textSize(35);
    text("- - - / - - -", 1030, 727);
    rectMode(CORNER);
    rect(1020, 20, 300, 148, 7);
    rect(1020, 168, 300, 148, 7);
    rect(1020, 316, 300, 148, 7);
    rect(1020, 464, 300, 148, 7);
    rect(1020, 612, 300, 148, 7);
    rect(720, 612, 300, 148, 7);
    textSize(25);
    fill(90, 150, 75);
    //textAlign(RIGHT);
    text("ECG", 1030, 50);
    textSize(20);
    text("LEADS OFF", 1200, 50);
    textSize(90);
    textSize(30);
    text("BPM", 1250, 125);
    textSize(25);
    fill(255, 255, 255);
    text("SPO2", 1030, 198);
    textSize(20);
    text("SEN OFF", 1200, 198);
    textSize(90);
    textSize(60);
    text(" %", 1230, 283);
    textSize(25);
    fill(255, 255, 255);
    text("RESP", 1030, 346);
    textSize(20);
    text("SEN OFF", 1200, 346);
    textSize(90);
    textSize(30);
    text("RPM", 1250, 421);
    textSize(25);
    fill(255, 255, 255);
    text("TEMP", 1030, 494);
    textSize(20);
    text("SEN OFF", 1200, 494);
    textSize(90);
    textSize(60);
    text("*C", 1232, 579);
    textSize(25);
    fill(255, 255, 255);
    text("NIBP", 1030, 642);
    textSize(20);
    text("CUFF OFF", 1200, 642);
    textSize(35);
    textSize(25);
    text(" mmHg", 1230, 727);
    textSize(90);
    text("- - -", 1030, 135);
    text("- - -", 1030, 283);
    text("- - -", 1030, 431);
    text("- - -", 1030, 579);
    textSize(35);
    text("- - - / - - -", 1030, 727);
  }
}
void mousePressed() {
  exit();
}
