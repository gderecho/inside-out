
void setup(){
  final File folder = new File("/Users/Ongkong/Documents/inside-out/music_files/angry");
  for (final String fileEntry :  listFilesForFolder_array(folder)){
    avgFreq(fileEntry);
  };
  
  

}

void draw(){
}