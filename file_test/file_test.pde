import java.io.*;

void listFilesForFolder(final File folder) {
    for (final File fileEntry : folder.listFiles()) {
        if (fileEntry.isDirectory()) {
            listFilesForFolder(fileEntry);
        } else {
            println(fileEntry.getName());
        }
    }
}

void setup(){
  final File folder = new File("/Users/John/Documents/Inside_Out/inside-out/music_files/angry");
  listFilesForFolder(folder);
}

void draw(){

}