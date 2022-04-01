// A communications point
// Code by Sergey 'Eater' Levin, 2002

class NCCommPoint extends Keypoint;

var int conversenum;
var() string ConvStrings[20];
var() sound ConvSounds[20];
var() float ConvSpeakTime[20];
var() int PlayerSpeaks[20];
var() bool bNewDiary;
var() string DiaryMsg;
var() bool speakOnce;
var() string speakName;
var() int mindist;
var() name ConvEndEvent;
var NCPawnEnchantTalk enchant;
var mesh talkerMesh;
var texture talkerskin;

defaultproperties
{
     bNewDiary=True
     speakName="Elder DuNuuva"
     MinDist=1000
     talkerMesh=LodMesh'UnrealShare.Nali1'
     talkerskin=Texture'UnrealShare.Skins.JNali2'
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
