
import java.util.Random;
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
ArrayList<String> listFilesForFolder_array(final File folder){
  
  ArrayList<String> list_of_files = new ArrayList<String>();
  
  for (final File fileEntry : folder.listFiles()) { 
       list_of_files.add(fileEntry.getName());
    }
    
   return list_of_files;
}

String get_filename(int state)
{    
    int index = rand.nextInt(filenames[state].size());
    while (filenames[state].get(index).equals(".DS_Store")){
      index = rand.nextInt(filenames[state].size());
    }
    return filenames[state].get(index);
}

}