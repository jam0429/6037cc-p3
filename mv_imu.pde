import ddf.minim.*;     //import the minim library
import ddf.minim.effects.*;
import ddf.minim.analysis.*;

import processing.serial.*; // import the Processing serial library
Serial myPort;              // The serial port

float pitch;
float roll;

Minim minim;
AudioPlayer bgm;
FFT fft;

float []size, psize;  //the size of the dots, 'size' for the newest value, 'psize' for the used value, 'psize' always get close to 'size'  
float []brs, pbrs;    //the brightness value of the dots
float []huee;         //the hue value of the dots 
float pspeed, speed;  //the rotate speed of dots' circle
float pdis, dis;      //the radius of the dots' circle
int num = 16;         //the number of dots

void setup() {
  //music vis
  size(800, 800, P2D);
  colorMode(HSB, 255);
  size = new float[num];   //initialize the variables
  psize = new float[num];
  brs = new float[num];
  pbrs = new float[num];
  huee = new float[num];
  minim = new Minim(this);
  bgm = minim.loadFile("Your Silent Face.mp3", 1024);    //load music file
  fft = new FFT(bgm.bufferSize(), bgm.sampleRate());   //create FFT object of the music
  bgm.loop();
  
  //pitch and roll
   printArray(Serial.list());

  // Change the 0 to the appropriate number of the serial port
  // that your microcontroller is attached to.
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);
  // read incoming bytes to a buffer
  // until you get a linefeed (ASCII 10):
  myPort.bufferUntil('\n');
}

void draw() {
  //background(0);
  fill(255, 15);              //make the background white recovery slowly, so there are tails follow the dots
  rect(0, 0, width, height);
  
 fill(255,0,0);
ellipse(width/2,height/2,pitch,pitch);

  fft.forward(bgm.mix);       //FFT analyze of the music
  noStroke();
  println(bgm.left.level());

  for (int i=0; i<num; i++) {    //update the variables
    huee[i]+=random(0.1, 1);      //make the colors of the dots slightly different
    if (huee[i]>=255)huee[i]=huee[i]%255;
    brs[i] = map(fft.getBand(10+i), 0, 60, 150, 255);   //brighness change according to different FFT band energy
    size[i] = map(fft.getBand(10+i), 0, 60, 15, 80);    //size change according to different FFT band energy
    pbrs[i] += (brs[i]-pbrs[i])*0.2;                    //the used value get close to the new updated value
    pbrs[i] = constrain(pbrs[i], 0, 255);
    psize[i] += (size[i]-psize[i])*0.2;
    psize[i] = constrain(psize[i], 15, 80);
  }
  speed = map(abs(bgm.left.level()), 0.05, 0.5, 0.1, 1.5);  //speed change according to the volume
  dis = map(abs(bgm.left.level()), 0.05, 0.5, roll, roll);  //circle radius change according to the volume
  pspeed += speed;
  pdis += (dis-pdis)*0.1;


  for (int i=0; i<num; i++) {    //draw the dots
    fill(huee[i], 200, pbrs[i]);
    pushMatrix();
    translate(width*0.5, height*0.5);
    rotate(radians(i*(float(360)/float(num))+pspeed));
    ellipse(pdis, 0, psize[i], psize[i]);
    popMatrix();
  }
  
  

  
 
}

void serialEvent(Serial myPort) {
  // read the serial buffer:
  String myString = myPort.readStringUntil('\n');
  if (myString != null) {
    // println(myString);
    myString = trim(myString);

    // split the string at the commas
    // and convert the sections into floats:
    float sensors[] = float(split(myString, ','));
    
    pitch = sensors[0];
    roll = sensors[1];
    
    print("Pitch : " + pitch + "\t");
    print("Roll : " + roll + "\t");
    println();
    
  }
}
