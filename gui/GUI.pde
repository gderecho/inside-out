import controlP5.*;
import ddf.minim.*;
import processing.serial.*;

PFont font;
Scrollbar scaleBar;
Serial port;
PImage pic;
ControlP5 cp5;
Button test;
boolean state;
boolean take_care_flag;
final boolean BEGIN = false;
final boolean END = true;
Music music;

/* from serial */
int Sensor;      // HOLDS PULSE SENSOR DATA FROM ARDUINO
int IBI;         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
int BPM;         // HOLDS HEART RATE VALUE FROM ARDUINO
int[] RawY;      // HOLDS HEARTBEAT WAVEFORM DATA BEFORE SCALING
int[] ScaledY;   // USED TO POSITION SCALED HEARTBEAT WAVEFORM
int[] rate;      // USED TO POSITION BPM DATA WAVEFORM
float zoom;      // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
float offset;    // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
color eggshell = color(255, 253, 248);
int heart = 0;   // This variable times the heart image 'pulse' on screen
//  THESE VARIABLES DETERMINE THE SIZE OF THE DATA WINDOWS
int PulseWindowWidth = 490;
int PulseWindowHeight = 300; 
int BPMWindowWidth = 180;
int BPMWindowHeight = 340;
boolean beat = false;    // set when a heart beat is detected, then cleared



/* from serialEvent */
void serialEvent(Serial port){ 
   String inData = port.readStringUntil('\n');
   inData = trim(inData);                 // cut off white space (carriage return)
   
   if (inData.charAt(0) == 'S'){          // leading 'S' for sensor data
     inData = inData.substring(1);        // cut off the leading 'S'
     Sensor = int(inData);                // convert the string to usable int
   }
   if (inData.charAt(0) == 'B'){          // leading 'B' for BPM data
     inData = inData.substring(1);        // cut off the leading 'B'
     BPM = int(inData);                   // convert the string to usable int
     beat = true;                         // set beat flag to advance heart rate graph
     heart = 20;                          // begin heart image 'swell' timer
   }
 if (inData.charAt(0) == 'Q'){            // leading 'Q' means IBI data 
     inData = inData.substring(1);        // cut off the leading 'Q'
     IBI = int(inData);                   // convert the string to usable int
   }
}

void setup() 
{
  size(900,600);
  pic = loadImage("img/mudd_hacks_splash_no_button.png");
  cp5 = new ControlP5(this);
  noStroke();

  PImage begin = loadImage("img/button.png");
  test = new Button(300,300,begin.width,begin.height, begin);
  state = BEGIN;
  
  // GO FIND THE ARDUINO
  println(Serial.list());    // print a list of available serial ports
  // choose the number between the [] that is connected to the Arduino
  port = new Serial(this, Serial.list()[1], 115200);  // make sure Arduino is talking serial at this baud rate
  port.clear();            // flush buffer
  port.bufferUntil('\n');  // set buffer full flag on receipt of carriage return
  
  frameRate(100);  
  //font = loadFont("Arial-BoldMT-24.vlw");
  //textFont(font);
  textAlign(CENTER);
  rectMode(CENTER);
  ellipseMode(CENTER);  
// Scrollbar constructor inputs: x,y,width,height,minVal,maxVal
  scaleBar = new Scrollbar (400, 575, 180, 12, 0.5, 1.0);  // set parameters for the scale bar
  RawY = new int[PulseWindowWidth];          // initialize raw pulse waveform array
  ScaledY = new int[PulseWindowWidth];       // initialize scaled pulse waveform array
  rate = new int [BPMWindowWidth];           // initialize BPM waveform array
  zoom = 0.75; 
  
}

void draw() 
{
  if(state == BEGIN)
  {
    image(pic, 0, 0);
    test.display();
  }
  else
  {
   
    rect(width/4,height/4,PulseWindowWidth,PulseWindowHeight);        
    RawY[RawY.length-1] = (1023 - Sensor) - 212;                   // place the new raw datapoint at the end of the array
    zoom = 40;                                                     // get current waveform scale value
    offset = map(zoom,0.5,1,150,0);                // calculate the offset needed at this scale
    
    for (int i = 0; i < RawY.length-1; i++) 
    {      // move the pulse waveform by
      RawY[i] = RawY[i+1];                         // shifting all raw datapoints one pixel left
      float dummy = RawY[i] * zoom + offset;       // adjust the raw data to the selected scale
      ScaledY[i] = constrain(int(dummy),44,556);   // transfer the raw data array to the scaled array
    }
    
    stroke(250,0,0);                               // red is a good color for the pulse waveform
    noFill();
    beginShape();                                  // using beginShape() renders fast
    
    for (int x = 1; x < ScaledY.length-1; x++) 
    {    
      vertex(x+10, ScaledY[x]);                    //draw a line connecting the data points
    }
      endShape(); 
      
  }
  
  if(test.pressed() && take_care_flag==false)
  {
    clear();
    redraw();
    state = END;
    music = new Music(0,0,0,0,new Minim(this));
    music.playMusic();
    take_care_flag = true;
  }
}

//--------------------------------------------------------------------------------//

class Button
{
  int x, y;
  int w, h;
  PImage click;
  
  public Button(int x, int y, int w, int h, PImage click)
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.click = click;
  }

  public boolean pressed() 
  {
    /*print("Mouse pressed: ");
    print(mousePressed);
    print("\n");
    print("Over: ");
    print(over());
    print("\n");*/
    return over() && mousePressed;
  }
  
  public void display()
  {
    image(click,x,y);
  }
  
  
  boolean over() 
  {
      return mouseX >= x && mouseX <= x+w && 
        mouseY >= y && mouseY <= y+h;

  }

}


//--------------------------------------------------------------------------------//

class Music
{
  int x, y, w, h;
  Minim minim;
  Textlabel text;
  boolean currently_playing=false;
  
  public Music(int x, int y, int w, int h, Minim minim)
  {
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    this.minim = minim;
    text = cp5.addTextlabel("label")
                    .setText("Now Playing: ____ ____")
                    .setPosition(x,y)
                    .setColorValue(0xffffff00)
                    .setFont(createFont("Times",24));
  }
  
  void playMusic()
  {
    if(currently_playing)
      return;
    AudioPlayer song = minim.loadFile("/Users/nicholasdraper/Documents/MuddHacks/inside-out/music_files/calm/Relax Music 3.mp3");
    song.play();
    currently_playing = true;
  }
  
}