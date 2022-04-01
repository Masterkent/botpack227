// ============================================================
// oldskool.oldskoolRootwindow: The main window.....
// didn't want it to extend umenu root window, but was forced to, for RA compatibility.......
// ============================================================

class oldskoolRootwindow expands UMenuRootWindow
config(oldskool);
//load the nullmusic into package
#exec OBJ LOAD FILE="Music\nullmusic.umx" PACKAGE="olroot"

//main vars for backrounds and musics
var config string Backround;       //the backround & the music we are going to play......
var config string musicclass;
var config bool force;         //force music
var config int track; //track selected (for CD's or songs with multiple tracks)
var config bool cdused;
var config string savedroot; //the last rootwindow that was used.
var config bool bscoreboard;  //for notifies to spawn.
var config bool bhud;
var replicationinfo CRI;
//CSHP timer.
var float reptimer;
var int oldtrack;
var ticky ticky;
var bool bswaptrack;  //music bug related vars
var float swaptime;
//var vool cshpcheck;

function Created()
{
  Super(UwindowRootWindow).Created();
  if (ticky==None){                        //music ticker.....
  ticky=getEntryLevel().spawn (class'olroot.ticky');
  ticky.root=self;} //set me...
  StatusBar = UMenuStatusBar(CreateWindow(class'Umenu.UMenuStatusBar', 0, 0, 50, 16));
  StatusBar.HideWindow();
  MenuBar = UmenuMenuBar(CreateWindow(class'olroot.oldskoolMenuBar', 50, 0, 500, 16));

  BetaFont = Font(DynamicLoadObject("UWindowFonts.UTFont40", class'Font'));
  Resized();
  oldtrack=3;
}

function Paint(Canvas C, float MouseX, float MouseY)
{
  local class<backrounds> bg;

  if(Console.bNoDrawWorld)
  {
    DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'MenuBlack');

    if (Console.bBlackOut)
      return;
    bg=class<backrounds>(Dynamicloadobject(Backround, class'class'));
   if (bg!=none)
   bg.static.drawbackground(self,c);  //now draw background (the function allows customized functions, as well as OSX support)
  }
}
function notifyafterlevelchange(){  //allow music to change
local playerpawn o;
o=Console.ViewPort.Actor;
tick(0.0);
if (getlevel().netmode==nm_client) //CSHP notifiers!
reptimer=0.1;

if (bhud)
getlevel().spawn(class<spawnnotify>(dynamicloadobject("oldskool.oldhudNotify",class'class')));
if (bScoreBoard)
getlevel().spawn(class<spawnnotify>(dynamicloadobject("oldskool.oldboardNotify",class'class')));
if (ticky==none){  //may have been nuked by CSHP
  ticky=getEntryLevel().spawn (class'olroot.ticky');
  ticky.root=self;}

}
function Tick(float delta) {     //actual music changer.....  (not an actor, thus isn't REALLY a tick...... )
local playerpawn o;
local byte cdtrack;
local string musiclocal;
local replicationinfo RI; //CSHP
super.tick(delta); //for quitting
if (reptimer!=0.0){
reptimer+=delta;
if (cri!=none)
cshpdetected(cri);
else{
foreach console.viewport.actor.childactors(class'replicationinfo',RI){
if (ri.class.name=='CheatRI'){
cshpdetected(ri);
break;}
}     }
if (reptimer>15) //no CSHP found in 15 seconds.
reptimer=0.0;  }
if (bswaptrack){
swaptime+=delta;
if (swaptime>=0.5){
swaptime=0.0;
bswaptrack=false;
console.viewport.actor.ClientSetMusic(Music(DynamicLoadObject(musicclass, class'music')), byte(track), cdtrack, MTRAN_Fade);}
else
return;}
o=Console.ViewPort.Actor;              //screw getplayerowner() :D
//cdused=bool(o.ConsoleCommand("get ini:Engine.Engine.AudioDevice UseCDMusic"));
if ((force&&o!=none&&o.myhud!=none&&!o.myhud.Isa('oldskoolhud')&&!o.myhud.Isa('intronullhud')) || cdused|| o.song==None || string(o.song)~="utmenu23.utmenu23"){ //check if music should be allowed to change...
If (cdused){
Musiclocal="olroot.null";
cdtrack=byte(track);}//make it stay as null music......
else{
musiclocal=musicclass;
cdtrack=255;} //stop cd music....
if ((cdused&&int(o.cdtrack)!=track)||(!cdused&&(!(string(o.song)~=musiclocal))||int(o.songSection)!=track)){    //check if it's already set..
if (musiclocal=="olroot.null"||!messedsong()){
oldtrack=track;
o.ClientSetMusic(Music(DynamicLoadObject(musiclocal, class'music')), byte(track), cdtrack, MTRAN_Fade);}
else{
o.ClientSetMusic(Music(DynamicLoadObject(musiclocal, class'music')), 0, cdtrack, MTRAN_Fade);
bswaptrack=true;}}      //actually set it (note: server has authority over clientsetmusic, yet it's only called when the playerpawn enter's so that's not a big deal....
}
}
function cshpdetected(replicationinfo cshp){ //handle CSHP stuff
local string temp;
//i=cshp.GetPropertyText(bsimple);
//cshp.setpropertytext(
temp=cshp.getpropertytext("PackageList");
if (instr(temp,"olroot?oldskool?")==-1){
cshp.setpropertytext("PackageList","olroot?oldskool?"$temp);  //load olroot into allowed packages.
cshp.setpropertytext("PackageCnt",string(int(cshp.getpropertytext("PackageCnt"))+2));} //add 1 to package count.
//cshp.disable('tick');
//reptimer=0.0;
cri=cshp;
}
function bool messedsong(){  //is song screwed?    (some songs at track 0 are messed up.
if (track==0||(oldtrack==0&&string(console.viewport.actor.Song.class)~=musicclass)) //0 track works fine.
return false;
if (musicclass=="utemple.utemple"||musicclass=="unreal4.unreal4"||musicclass=="nali.nali"||musicclass=="skytwn.skytwn")
return true;
return false;
}

defaultproperties
{
     Backround="olroot.utbackround"
     musicclass="utmenu23.utmenu23"
     force=True
     savedroot="umenu.UMenuRootWindow"
}
