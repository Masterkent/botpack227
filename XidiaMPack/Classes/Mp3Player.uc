// ===============================================================
// XidiaMPack.Mp3Player: continually plays a sound (mp3?)...
// ===============================================================

class Mp3Player expands Actor;

var int pos; //-1 = left, 0=center, 1=right
var sound Mp3; //the mp3
var playerpawn powner;

function SetMp3 (sound newMp3, int newpos){
  pos=int(owner.collisionradius)*newpos; //edit later?
  Mp3=newMp3;
  powner=playerpawn(owner);
  if (pOwner==none){
    destroy();
    return;
  }
 // setTimer(getSoundDuration(Mp3),true); //is this supported on mp3's?
  //Timer();
  ambientsound=mp3;
  tick(0.0);
}

function Timer(){
  PlaySound(Mp3);
}

function tick (float deltatime){ //update position
  local vector loc, x, y, z;
  local rotator rot;
  local actor a;
  pOwner.PlayerCalcView(a,loc,rot);
  getAxes(rot,x,y,z);
  setLocation(loc+pos*y);
}

defaultproperties
{
     bAlwaysTick=True
     RemoteRole=ROLE_None
}
