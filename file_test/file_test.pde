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

/* return arraylist of files in the folder*/
ArrayList<String> listFilesForFolder_array(final File folder){
  
  ArrayList<String> list_of_files = new ArrayList<String>();
  
  for (final File fileEntry : folder.listFiles()) { 
       list_of_files.add(fileEntry.getName());
    }
    
   return list_of_files;
}


void setup(){
  final File folder = new File("/Users/John/Documents/Inside_Out/inside-out/music_files/angry");
  listFilesForFolder(folder);
}

void draw(){

}