import ddf.minim.analysis.*;
import ddf.minim.*;

Minim       minim;
AudioPlayer jingle;
FFT         fft;
BeatDetect beat;
import java.io.*;

ArrayList<String> listFilesForFolder_array(final File folder){
  
  ArrayList<String> list_of_files = new ArrayList<String>();
  
  for (final File fileEntry : folder.listFiles()) { 
       list_of_files.add(fileEntry.getName());
    }
    
   return list_of_files;
}

int numBeats(String filename){
  minim = new Minim(this);
  int beats = 0;
  jingle = minim.loadFile(filename, 65536);
  jingle.loop();
  jingle.mute();
  fft = new FFT( jingle.bufferSize(), jingle.sampleRate() );
  beat = new BeatDetect(jingle.bufferSize(), jingle.sampleRate() );
  while( beats<100){
  for(int i = 0; i < beat.detectSize(); i++)
  {
    beat.detect(jingle.mix);
    
    if(beat.isOnset(i)){
      beats ++;
    }
  }
  }
  return beats;
}
Float[] avgFreq(String filename){
  float beats = 0;
  float avg = 0.0;
  float time = 0.0;
  minim = new Minim(this);
  jingle = minim.loadFile("./music/" + filename, 1024);
  float sampleRate = jingle.sampleRate();
  jingle.play();
  jingle.mute();
  fft = new FFT( jingle.bufferSize(), sampleRate );
  beat = new BeatDetect(jingle.bufferSize(), sampleRate );
  while (time < jingle.getMetaData().length()){
    fft.forward( jingle.mix );
    avg = avg + fft.calcAvg(0, fft.specSize());
    beat.detect(jingle.mix);
    for(int i = 0; i < beat.detectSize(); i++)
    { 
      if(beat.isOnset(i)){
        beats ++;
      }
    }
    time = time + (1024/sampleRate);
    
  }
  Float[] results = {beats, avg};
  return results;
}