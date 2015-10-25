import controlP5.*;
import ddf.minim.*;
import processing.serial.*;
import java.io.*;
import java.util.*;


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
ArrayList<Integer> current_bpm_set = new ArrayList<Integer>();
String base_path = "/Users/John/Documents/Inside_Out/inside-out/music_files";
String current_mood = "calm";
String song_name = "";
int bpm_buffer_size = 500;
Filenames file_names = new Filenames();
Minim minim;
AudioPlayer song;
AudioPlayer song2;
boolean song_is_playing = false;
boolean song2_is_playing = false;

boolean fade = false;
long time1 = 0;
long time2 = 0;

int wait = 3000;

void settings(){
  size(900,600);
}

void setup() 
{ 
  minim = new Minim(this);
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
  textAlign(CENTER);
  rectMode(CENTER);
  ellipseMode(CENTER);  
// Scrollbar constructor inputs: x,y,width,height,minVal,maxVal
  //scaleBar = new Scrollbar (400, 575, 180, 12, 0.5, 1.0);  // set parameters for the scale bar
  RawY = new int[PulseWindowWidth];          // initialize raw pulse waveform array
  ScaledY = new int[PulseWindowWidth];       // initialize scaled pulse waveform array
  rate = new int [BPMWindowWidth];           // initialize BPM waveform array
  zoom = 0.75; 
  
  for (int i=0; i<rate.length; i++)
  {
    rate[i] = 555;      // Place BPM graph line at bottom of BPM Window 
  }
  for (int i=0; i<RawY.length; i++)
  {
    RawY[i] = height/2; // initialize the pulse window data line to V/2
  }
  
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

    update_current_mood(BPM);
    // int mood = mood_selector();
    // String  music_name = Filenames.get_filename(mood);


  background(0,0,0);
  noStroke();
// DRAW OUT THE PULSE WINDOW AND BPM WINDOW RECTANGLES  
  fill(0,0,0);  // color for the window background
  rect(255,height/2,PulseWindowWidth,PulseWindowHeight);
  rect(600,385,BPMWindowWidth,BPMWindowHeight);
  
// DRAW THE PULSE WAVEFORM
  // prepare pulse data points    
  RawY[RawY.length-1] = (1023 - Sensor) - 212;   // place the new raw datapoint at the end of the array
  //zoom = scaleBar.getPos();                      // get current waveform scale value
  offset = map(zoom,0.5,1,150,0);                // calculate the offset needed at this scale
  for (int i = 0; i < RawY.length-1; i++) {      // move the pulse waveform by
    RawY[i] = RawY[i+1];                         // shifting all raw datapoints one pixel left
    float dummy = RawY[i] * zoom + offset;       // adjust the raw data to the selected scale
    ScaledY[i] = constrain(int(dummy),44,556);   // transfer the raw data array to the scaled array
  }
  stroke(0,255,0);                               // red is a good color for the pulse waveform
  noFill();
  beginShape();                                  // using beginShape() renders fast
  for (int x = 1; x < ScaledY.length-1; x++) {    
    vertex(x+10, ScaledY[x]);                    //draw a line connecting the data points
  }
  endShape();
  
// DRAW THE BPM WAVE FORM
// first, shift the BPM waveform over to fit then next data point only when a beat is found
 if (beat == true){   // move the heart rate line over one pixel every time the heart beats 
   beat = false;      // clear beat flag (beat flag waset in serialEvent tab)
   for (int i=0; i<rate.length-1; i++){
     rate[i] = rate[i+1];                  // shift the bpm Y coordinates over one pixel to the left
   }
// then limit and scale the BPM value
   BPM = min(BPM,200);                     // limit the highest BPM value to 200
   float dummy = map(BPM,0,200,555,215);   // map it to the heart rate window Y
   rate[rate.length-1] = int(dummy);       // set the rightmost pixel to the new data point value
 } 
 // GRAPH THE HEART RATE WAVEFORM
 stroke(250,0,0);                          // color of heart rate graph
 strokeWeight(2);                          // thicker line is easier to read
 noFill();
 beginShape();
 for (int i=0; i < rate.length-1; i++){    // variable 'i' will take the place of pixel x position   
   vertex(i+510, rate[i]);                 // display history of heart rate datapoints
 }
 endShape();
 
// DRAW THE HEART AND MAYBE MAKE IT BEAT
  fill(250,0,0);
  stroke(250,0,0);
  // the 'heart' variable is set in serialEvent when arduino sees a beat happen
  heart--;                    // heart is used to time how long the heart graphic swells when your heart beats
  heart = max(heart,0);       // don't let the heart variable go into negative numbers
  if (heart > 0){             // if a beat happened recently, 
    strokeWeight(8);          // make the heart big
  }
  smooth();   // draw the heart with two bezier curves
  bezier(width-100,50, width-20,-20, width,140, width-100,150);
  bezier(width-100,50, width-190,-20, width-200,140, width-100,150);
  strokeWeight(1);          // reset the strokeWeight for next time


// PRINT THE DATA AND VARIABLE VALUES
  fill(eggshell);                                       // get ready to print text
  text("IBI " + IBI + "mS",600,585);                    // print the time between heartbeats in mS
  text(BPM + " BPM",600,200);                           // print the Beats Per Minute
  //text("Pulse Window Scale " + nf(zoom,1,2), 150, 585); // show the current scale of Pulse Window
  
//  DO THE SCROLLBAR THINGS
  //scaleBar.update (mouseX, mouseY);
  //scaleBar.display();
  }
  
   fill(250,0,0);
    stroke(250,0,0);
                    // the 'heart' variable is set in serialEvent when arduino sees a beat happen
    heart--;                    // heart is used to time how long the heart graphic swells when your heart beats
    heart = max(heart,0);       // don't let the heart variable go into negative numbers
    if (heart > 0)
    {             // if a beat happened recently, 
      strokeWeight(8);          // make the heart big
    }
    smooth();   // draw the heart with two bezier curves
    bezier(width-100,50, width-20,-20, width,140, width-100,150);
    bezier(width-100,50, width-190,-20, width-200,140, width-100,150);
    strokeWeight(1);
  
  if(test.pressed() && take_care_flag==false)
  {
    clear();
    redraw();
    state = END;
    //music = new Music(0,0,0,0,new Minim(this));
    //music.playMusic();
    //song = minim.loadFile("mysong.wav");
    //String c_md = mood_selector();
    int c_md_state = getMoodState(current_mood);
    
    String music_name = file_names.get_filename(c_md_state);
    song_name = music_name;
    //println(music_name);
    //println(c_md);
    song = minim.loadFile(base_path+"/" + current_mood + "/" + music_name + "/");
    song.play();
    song_is_playing = true;
    
    println("debug 1");
    take_care_flag = true;
    //println(current_mood);

  } else if (take_care_flag){
    /* if current mood is different */
    Textlabel text = cp5.addTextlabel("label")
                   .setText("Now Playing: " + song_name.substring(0,song_name.length()-4))
                   .setPosition(0,0)
                   .setColorValue(0xffffff00)
                   .setFont(createFont("Times",24));
                    
    String c_md = mood_selector();
    //println("the true loop");
    //println(c_md);
    int c_md_state = getMoodState(c_md);
    
    if (c_md.equals(current_mood)){
      c_md = "not changing";
    }
    
    //if(millis() - time1 >= wait){
    //    println("tick");//if it is, do something
    //    time1 = millis();//also update the stored time
    //    fade = false;
    //    song.close();
    //  }
      
      //if (song.getGain() < -18.0){
      //  fade = false;
      //  song.close();
      //}
    
    println(fade);
    
    if(!c_md.equals("not changing")){  //no changing when the array is not filled up
      //println("debug 2");
      
      if (song_is_playing){
        if (!fade){
          song.shiftGain(0, -50, wait);
          fade = true;
          
          time1 = millis();
          println(time1);
        } 
        println(time1);
        
      if (millis() - time1 >= wait){
         time1 = millis();
         fade = false;
         song.pause();
         song_is_playing = false;
         println("tick");
       }
       
      String music_name = file_names.get_filename(c_md_state);
      song_name = music_name;
        //println(music_name);
        //println(c_md);
      song2 = minim.loadFile(base_path+"/" + c_md + "/" + music_name + "/");
        //song.rewind();
      
      song2.setGain(-50);
      song2.play();
      song2.shiftGain(-50, 0, wait);
      song2_is_playing = true;
       
     }
     
     if (song2_is_playing){
        if (!fade){
          song2.shiftGain(0, -50, wait);
          fade = true;
          
          time2 = millis();
          println(time2);
        } 
        println(time2);
        
      if (millis() - time2 >= wait){
         time2 = millis();
         fade = false;
         song2.pause();
         song2_is_playing = false;
         println("tick");
       }
       
      String music_name = file_names.get_filename(c_md_state);
      song_name = music_name;
        //println(music_name);
        //println(c_md);
      song = minim.loadFile(base_path+"/" + c_md + "/" + music_name + "/");
        //song.rewind();
      
      song.setGain(-50);
      song.play();
      song.shiftGain(-50, 0, wait);
      song_is_playing = true;
     }
     
      
      //}
      
      //song.close();
      
      //print(song.getGain());
      
      //if(millis() - time1 >= wait){
      //  println("tick");//if it is, do something
      //  time1 = millis();//also update the stored time
      //  fade = false;
      //  song.close();
      //}
      
      //if (song.getGain() < -40.0){
      // fade = false;
      // song.close();
      //}
      //song.close();
      
      
      
      //if (song.isPlaying()){
        //song.shiftGain(0, -20, 5000);
        //song.close();
      //}
      
      //String music_name = file_names.get_filename(c_md_state);
      //song_name = music_name;
      ////println(music_name);
      ////println(c_md);
      //song = minim.loadFile(base_path+"/" + c_md + "/" + music_name + "/");
      ////song.rewind();
      
      //song.setGain(-50);
      //song.play();
      //song.shiftGain(-50, 0, wait);
      
      text = cp5.addTextlabel("label")
                   .setText("Now Playing: " + song_name.substring(0,song_name.length()-4))
                   .setPosition(0,0)
                   .setColorValue(0xffffff00)
                   .setFont(createFont("Times",24));
      
    }

  }

}

/* update current mood */
void update_current_mood(int bpm){
  if (current_bpm_set.size() < bpm_buffer_size){
    current_bpm_set.add(bpm);
  } else {
    current_bpm_set.clear();
  }
}

/* select the mood */
String mood_selector(){
  double slope = 0.0;
  int bpm = 0;
  if (current_bpm_set.size() == bpm_buffer_size){
    println("mood selector true");
    for (int i = 0; i < current_bpm_set.size()-1; i++ ){
     slope += current_bpm_set.get(i+1) - current_bpm_set.get(i);     
    }
    slope = slope / (double)(current_bpm_set.size()-1);
    println(slope);
    
    /* choose the mood according to slope*/
    /*stressed slope = 1.225*/
    /*tired slope = -1.45*/
    /*angry slope = 1.2*/
    /*anxious = 0.75 */
    /*happy = 0.5 */
    /*calm = 0 */
    
    for (int i = 0; i < current_bpm_set.size(); i++ ){
      bpm += current_bpm_set.get(i);
    }
    bpm = bpm/ current_bpm_set.size();
    println(bpm);
    int ANGRY   = 0;
    int ANXIOUS = 1;
    int CALM    = 2;
    int HAPPY   = 3;
    int STRESSED = 4;
    int TIRED   = 5;
    
    if (slope > 0){
      if (bpm < 70){
       return "tired";
      } else if (bpm < 80){
       return "happy";
      } else if (bpm < 90){
       return "calm";
      } else if (bpm < 100){
       return "anxious";
      } else if (bpm < 110){
       return "stressed";
      } else{
       return "angry";
      }
    } else if (slope == 0){
      return "calm";
    } else{  // slope < 0
      if (bpm < 70){
       return "tired";
      } else if (bpm < 80){
       return "tired";
      } else if (bpm < 90){
       return "happy";
      } else if (bpm < 100){
       return "happy";
      } else if (bpm < 110){
       return "happy";
      } else{
       return "happy";
      }
    }
    
    //if (bpm < 70){
    // return "tired";
    //} else if (bpm < 80){
    // return "happy";
    //} else if (bpm < 90){
    // return "calm";
    //} else if (bpm < 100){
    // return "anxious";
    //} else if (bpm < 110){
    // return "stressed";
    //} else{
    // return "angry";
    //}
    
  } else{
    return "not changing";
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


void serialEvent(Serial port)
{ 
   String inData = port.readStringUntil('\n');
   inData = trim(inData);                 // cut off white space (carriage return)
   
   if (inData.charAt(0) == 'S')
   {          
     inData = inData.substring(1);        // cut off the leading 'S'
     Sensor = int(inData);                // convert the string to usable int
   }
   
   if (inData.charAt(0) == 'B')
   {          
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

int getMoodState(String mood){
    
    if ( mood.equals("calm")){
      return 2;
    } else if (mood.equals("happy")){
       return 3;
    } else if (mood.equals("anxious")){
      return 1;
    } else if (mood.equals("angry")){
      return 0;
    } else if ( mood.equals("stressed")){
      return 4;
    } else {
      return 5;
    }
    
    //switch(mood){
    //case mood.equals("calm"):
    //    return 2;
    //case mood.equals("happy") :
    //    return 3;
    //case mood.equals("anxious"):
    //    return 1;
    //case mood.equals("angry"):
    //    return 0;
    //case mood.equals("stressed"):
    //    return 4;
    //default :  // tired
    //   return 5;
  }

//--------------------------------------------------------------------------------//

class Music
{
  int x, y, w, h;
  Minim minim;
  Textlabel text;
  boolean currently_playing=false;
  AudioPlayer song;
  
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
    String c_md = mood_selector();
    int c_md_state = getMoodState(c_md);

    if(c_md.equals(current_mood)){
      return;
    } else{
      String music_name = file_names.get_filename(c_md_state);
      println(music_name);
      song = minim.loadFile(base_path+"/" + c_md + "/" + music_name + "/");
      song.play();
      
      currently_playing = true;
      current_mood = c_md;
    }
  }
	
  void changeSong(String song_name){
    String c_md = mood_selector();
    if (this.song.isPlaying()){
      this.song.close();
    }
    this.song = minim.loadFile(base_path+"/" + c_md + "/" + song_name + "/");
    this.song.play();
    currently_playing = true;
    current_mood = c_md;
  }

	void fadeOut(AudioPlayer oldsong){
	  oldsong.shiftGain(0, -50, 2000);
	}

	void fadeIn(AudioPlayer newsong){
	  newsong.rewind();
	  newsong.setGain(0);
	  newsong.play();
	  newsong.shiftGain(-50, 0, 2000);
	}
  
}