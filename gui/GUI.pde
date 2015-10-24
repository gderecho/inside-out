import controlP5.*;
import ddf.minim.*;

PImage pic;
ControlP5 cp5;
Button test;
boolean state;
boolean take_care_flag;
final boolean BEGIN = false;
final boolean END = true;
Music music;

void setup() 
{
  size(900,600);
  pic = loadImage("img/mudd_hacks_splash_no_button.png");
  cp5 = new ControlP5(this);
  noStroke();

  PImage begin = loadImage("img/button.png");
  test = new Button(300,300,begin.width,begin.height, begin);
  state = BEGIN;
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