
import java.util.Random;

final int ANGRY   = 0;
final int ANXIOUS = 1;
final int CALM    = 2;
final int HAPPY   = 3;
final int STRESSED = 4;
final int TIRED   = 5;

Random rand;

rand = new Random();

String[6][] filenames;

filenames[ANGRY] = ["dies_irae.mp3","moonlight_iii.mp3"]
filenames[ANXIOUS] = ["sacre_2.mp3"]
filenames[CALM] = ["Calm Music - River Flows in You by Yiruma.mp3",
    "deutsches_reqiem_1.mp3", "pachelbel.mp3", 
    "Relaxation Music 11 - Tea Ceremony.mp3",
    "Relax Music 2.mp3","Relax Music 3.mp3",
    "Relax Music 8.mp3"]
filenames[HAPPY] = []
filenames[STRESSED] = ["sacre_1.mp3"]
filenames[TIRED] = ["barber.mp3"]

String get_filename(int state)
{
    int index = rand.nextInt(filenames[state].length);
    return filenames[state][index];
}
