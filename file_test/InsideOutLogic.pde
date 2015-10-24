import java.io.*;
void setup(){
  File file = new File("output.txt");
  FileOutputStream fos = new FileOutputStream(file);
  PrintStream ps  = new PrintStream(fos);
  System.setOut(ps);
  final File folder = new File("/Users/Ongkong/Documents/inside-out/music_files/angry");
  for (final String fileEntry :  listFilesForFolder_array(folder)){
    avgFreq(fileEntry);
  };
  
  

}

void draw(){
}