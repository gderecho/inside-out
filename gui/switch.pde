
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
filenames[ANGRY].add("dies_irae.mp3");
filenames[ANGRY].add("moonlight_iii.mp3");
filenames[ANXIOUS] = new ArrayList();
filenames[ANXIOUS].add("sacre_2.mp3");
filenames[CALM] = new ArrayList();
filenames[CALM].add("Calm Music - River Flows in You by Yiruma.mp3");
filenames[CALM].add("deutsches_reqiem_1.mp3", "pachelbel.mp3");
filenames[CALM].add("Relaxation Music 11 - Tea Ceremony.mp3");
filenames[CALM].add("Relax Music 2.mp3","Relax Music 3.mp3");
filenames[CALM].add("Relax Music 8.mp3");
filenames[HAPPY] = new ArrayList();
filenames[STRESSED] = new ArrayList();
filenames[STRESSED].add("sacre_1.mp3")
filenames[TIRED] = new ArrayList();
}

String get_filename(int state)
{
    int index = rand.nextInt(filenames[state].size());
    return filenames[state].get(index);
}

}