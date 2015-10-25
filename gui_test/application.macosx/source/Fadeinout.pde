import ddf.minim.*;


void fadeOut(AudioPlayer oldsong){
  oldsong.shiftGain(0, -50, 2000);
}
void fadeIn(AudioPlayer newsong){
  newsong.rewind();
  newsong.setGain(0);
  newsong.play();
  newsong.shiftGain(-50, 0, 2000);
}