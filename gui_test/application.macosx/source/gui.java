import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import controlP5.*; 
import ddf.minim.*; 
import processing.serial.*; 
import java.io.*; 
import java.util.*; 
import java.util.Random; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class gui extends PApplet {




public void fadeOut(AudioPlayer oldsong){
  oldsong.shiftGain(0, -50, 2000);
}
public void fadeIn(AudioPlayer newsong){
  newsong.rewind();
  newsong.setGain(0);
  newsong.play();
  newsong.shiftGain(-50, 0, 2000);
}







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
int eggshell = color(255, 253, 248);
int heart = 0;   // This variable times the heart image 'pulse' on screen
//  THESE VARIABLES DETERMINE THE SIZE OF THE DATA WINDOWS
int PulseWindowWidth = 490;
int PulseWindowHeight = 300; 
int BPMWindowWidth = 180;
int BPMWindowHeight = 340;
boolean beat = false;    // set when a heart beat is detected, then cleared
ArrayList<Integer> current_bpm_set = new ArrayList<Integer>();
String base_path = "/Users/John/Documents/Inside_Out/inside-out/music_files";
String current_mood = "happy";
String song_name = "";
int bpm_buffer_size = 1000;
Filenames file_names = new Filenames();
Minim minim;
AudioPlayer song;
boolean fade = false;
long time1 = 0;
int time2;
int wait = 3000;

public void settings(){
  size(900,600);
}

public void setup() 
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
  zoom = 0.75f; 
  
  for (int i=0; i<rate.length; i++)
  {
    rate[i] = 555;      // Place BPM graph line at bottom of BPM Window 
  }
  for (int i=0; i<RawY.length; i++)
  {
    RawY[i] = height/2; // initialize the pulse window data line to V/2
  }
  
}

public void draw() 
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
  offset = map(zoom,0.5f,1,150,0);                // calculate the offset needed at this scale
  for (int i = 0; i < RawY.length-1; i++) {      // move the pulse waveform by
    RawY[i] = RawY[i+1];                         // shifting all raw datapoints one pixel left
    float dummy = RawY[i] * zoom + offset;       // adjust the raw data to the selected scale
    ScaledY[i] = constrain(PApplet.parseInt(dummy),44,556);   // transfer the raw data array to the scaled array
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
   rate[rate.length-1] = PApplet.parseInt(dummy);       // set the rightmost pixel to the new data point value
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
      
      if (!fade){
        song.shiftGain(0, -200, wait);
        fade = true;
        time1 = millis();
        println(time1);
      } 
        println(time1);
        
      if (millis() - time1 >= wait){
       time1 = millis();
       fade = false;
       song.pause();
       println("tick");
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
      
      String music_name = file_names.get_filename(c_md_state);
      song_name = music_name;
      //println(music_name);
      //println(c_md);
      song = minim.loadFile(base_path+"/" + c_md + "/" + music_name + "/");
      //song.rewind();
      
      song.setGain(-50);
      song.play();
      song.shiftGain(-50, 0, wait);
      
      text = cp5.addTextlabel("label")
                   .setText("Now Playing: " + song_name.substring(0,song_name.length()-4))
                   .setPosition(0,0)
                   .setColorValue(0xffffff00)
                   .setFont(createFont("Times",24));
      
    }

  }

}

/* update current mood */
public void update_current_mood(int bpm){
  if (current_bpm_set.size() < bpm_buffer_size){
    current_bpm_set.add(bpm);
  } else {
    current_bpm_set.clear();
  }
}

/* select the mood */
public String mood_selector(){
  double slope = 0.0f;
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
  
  
  public boolean over() 
  {
      return mouseX >= x && mouseX <= x+w && 
        mouseY >= y && mouseY <= y+h;

  }

}


public void serialEvent(Serial port)
{ 
   String inData = port.readStringUntil('\n');
   inData = trim(inData);                 // cut off white space (carriage return)
   
   if (inData.charAt(0) == 'S')
   {          
     inData = inData.substring(1);        // cut off the leading 'S'
     Sensor = PApplet.parseInt(inData);                // convert the string to usable int
   }
   
   if (inData.charAt(0) == 'B')
   {          
     inData = inData.substring(1);        // cut off the leading 'B'
     BPM = PApplet.parseInt(inData);                   // convert the string to usable int
     beat = true;                         // set beat flag to advance heart rate graph
     heart = 20;                          // begin heart image 'swell' timer
   }
   
   if (inData.charAt(0) == 'Q'){            // leading 'Q' means IBI data 
     inData = inData.substring(1);        // cut off the leading 'Q'
     IBI = PApplet.parseInt(inData);                   // convert the string to usable int
   }
}

public int getMoodState(String mood){
    
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
  
  public void playMusic()
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
	
  public void changeSong(String song_name){
    String c_md = mood_selector();
    if (this.song.isPlaying()){
      this.song.close();
    }
    this.song = minim.loadFile(base_path+"/" + c_md + "/" + song_name + "/");
    this.song.play();
    currently_playing = true;
    current_mood = c_md;
  }

	public void fadeOut(AudioPlayer oldsong){
	  oldsong.shiftGain(0, -50, 2000);
	}

	public void fadeIn(AudioPlayer newsong){
	  newsong.rewind();
	  newsong.setGain(0);
	  newsong.play();
	  newsong.shiftGain(-50, 0, 2000);
	}
  
}

/*
    THIS SCROLLBAR OBJECT IS BASED ON THE ONE FROM THE BOOK "Processing" by Reas and Fry
*/

class Scrollbar{
 int x,y;               // the x and y coordinates
 float sw, sh;          // width and height of scrollbar
 float pos;             // position of thumb
 float posMin, posMax;  // max and min values of thumb
 boolean rollover;      // true when the mouse is over
 boolean locked;        // true when it's the active scrollbar
 float minVal, maxVal;  // min and max values for the thumb
 
 Scrollbar (int xp, int yp, int w, int h, float miv, float mav){ // values passed from the constructor
  x = xp;
  y = yp;
  sw = w;
  sh = h;
  minVal = miv;
  maxVal = mav;
  pos = x - sh/2;
  posMin = x-sw/2;
  posMax = x + sw/2;  // - sh; 
 }
 
 // updates the 'over' boolean and position of thumb
 public void update(int mx, int my) {
   if (over(mx, my) == true){
     rollover = true;            // when the mouse is over the scrollbar, rollover is true
   } else {
     rollover = false;
   }
   if (locked == true){
    pos = constrain (mx, posMin, posMax);
   }
 }

 // locks the thumb so the mouse can move off and still update
 public void press(int mx, int my){
   if (rollover == true){
    locked = true;            // when rollover is true, pressing the mouse button will lock the scrollbar on
   }else{
    locked = false;
   }
 }
 
 // resets the scrollbar to neutral
 public void release(){
  locked = false; 
 }
 
 // returns true if the cursor is over the scrollbar
 public boolean over(int mx, int my){
  if ((mx > x-sw/2) && (mx < x+sw/2) && (my > y-sh/2) && (my < y+sh/2)){
   return true;
  }else{
   return false;
  }
 }
 
 // draws the scrollbar on the screen
 public void display (){

  noStroke();
  fill(255);
  rect(x, y, sw, sh);      // create the scrollbar
  fill (250,0,0);
  if ((rollover == true) || (locked == true)){             
   stroke(250,0,0);
   strokeWeight(8);           // make the scale dot bigger if you're on it
  }
  ellipse(pos, y, sh, sh);     // create the scaling dot
  strokeWeight(1);            // reset strokeWeight
 }
 
 // returns the current value of the thumb
 public float getPos() {
  float scalar = sw / sw;  // (sw - sh/2);
  float ratio = (pos-(x-sw/2)) * scalar;
  float p = minVal + (ratio/sw * (maxVal - minVal));
  return p;
 } 
 }
 


class Filenames {
  
final int ANGRY   = 0;
final int ANXIOUS = 1;
final int CALM    = 2;
final int HAPPY   = 3;
final int STRESSED = 4;
final int TIRED   = 5;

Random rand;
ArrayList<String>[] filenames;
Filenames()
{
rand = new Random();
filenames = new ArrayList[6];

filenames[ANGRY] = new ArrayList();
//filenames[ANGRY].add("dies_irae.mp3");
//filenames[ANGRY].add("moonlight_iii.mp3");
final File angry_folder = new File("/Users/John/Documents/Inside_Out/inside-out/music_files/angry");
filenames[ANGRY] = listFilesForFolder_array(angry_folder);

filenames[ANXIOUS] = new ArrayList();
final File anxious_folder = new File("/Users/John/Documents/Inside_Out/inside-out/music_files/anxious");
filenames[ANXIOUS] = listFilesForFolder_array(anxious_folder);
//filenames[ANXIOUS].add("sacre_2.mp3");

filenames[CALM] = new ArrayList();
final File calm_folder = new File("/Users/John/Documents/Inside_Out/inside-out/music_files/calm");
filenames[CALM] = listFilesForFolder_array(calm_folder);

//filenames[CALM].add("Calm Music - River Flows in You by Yiruma.mp3");
//filenames[CALM].add("deutsches_reqiem_1.mp3", "pachelbel.mp3");
//filenames[CALM].add("Relaxation Music 11 - Tea Ceremony.mp3");
//filenames[CALM].add("Relax Music 2.mp3","Relax Music 3.mp3");
//filenames[CALM].add("Relax Music 8.mp3");
filenames[HAPPY] = new ArrayList();
final File happy_folder = new File("/Users/John/Documents/Inside_Out/inside-out/music_files/happy");
filenames[HAPPY] = listFilesForFolder_array(happy_folder);

filenames[STRESSED] = new ArrayList();
final File stressed_folder = new File("/Users/John/Documents/Inside_Out/inside-out/music_files/stressed");
filenames[STRESSED] = listFilesForFolder_array(stressed_folder);
//filenames[STRESSED].add("sacre_1.mp3");

filenames[TIRED] = new ArrayList();
final File tired_folder = new File("/Users/John/Documents/Inside_Out/inside-out/music_files/tired");
filenames[TIRED] = listFilesForFolder_array(tired_folder);
}

/* return arraylist of files in the folder*/
public ArrayList<String> listFilesForFolder_array(final File folder){
  
  ArrayList<String> list_of_files = new ArrayList<String>();
  
  for (final File fileEntry : folder.listFiles()) { 
       list_of_files.add(fileEntry.getName());
    }
    
   return list_of_files;
}

public String get_filename(int state)
{    
    int index = rand.nextInt(filenames[state].size());
    while (filenames[state].get(index).equals(".DS_Store") || filenames[state].get(index).equals("README.md")){
      index = rand.nextInt(filenames[state].size());
    }
    return filenames[state].get(index);
}

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "gui" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
