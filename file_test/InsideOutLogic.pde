import java.io.*;
import java.lang.*;

void setup(){
  //File file = new File("output.txt");
  //OutputStream fos = null;
  //fos = createOutput(file);
  //PrintStream ps  = new PrintStream(fos);
  //System.setOut(ps);
  
  final File folder = new File("/Users/Ongkong/Documents/IB BOOK/findAvgFreq/music");
  for (final String fileEntry :  listFilesForFolder_array(folder)){
    println(fileEntry);
    println(avgFreq(fileEntry));
  };
  
  

}

void draw(){
}