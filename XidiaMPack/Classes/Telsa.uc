// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// Telsa : The tesla bolt that fires stuff at player.
// Usage: shove it somewhere in the level where nothing blocks it.  then have fun ;p
// Triggering enables/disables.
// Tesla, Telsa, whatever...
// ============================================================

class Telsa expands Keypoint;

//editor config:
var () bool bEnabled;
var () bool bTriggerOnceOnly;
var () byte MaxBolts; //can do 8 max internally actually.
var () bool AttackPlayers; //can it attack players?
var () bool AttackEnemies; //attack anything else?
var () vector BeamOffset; //offset of base location..
var () bool HasCap; //should beam have a cap or simply hide itself?
var () float RotSpeed; //maximum rotation speed/sec. (rad/s)
//Think of this as an air resistance factor????
var () int MaxLength; //where beam cuts off. not very scientific :) SHOULD BE MULTIPLE OF 81!!
var () int MaxDamage; //Damage per second AT LENGTH 1.  Interesting note: longer the beam=less damage;
// Damage is assumed as 0 at max and at this number at 0.
// I have based the calculation on Ohm's law.      shock=maxdamage/curlength*delta
// (this is assuming any other resistance/volt constants 1 or damage is based on them. whatever...)

//internal vars:
var StarterTelsaBolt Bolts[8]; //bolts that attack...
event PostBeginPlay(){
  if (benabled)
    SetTimer(0.93,true);
  if (MaxBolts>8)
    MaxBolts=8;
}
event Trigger (Actor Other, pawn EventInstigator){
  Instigator=EventInstigator;
  bEnabled=!benabled;
  if (bTriggerOnceOnly)
    disable('trigger');
  SetTimer(0.93*byte(benabled),benabled);
}
function StarterTelsaBolt SpawnBolt(){
  local byte i;
  for (i=0;i<MaxBolts;i++)
    if (Bolts[i]==none||Bolts[i].bdeleteme){
       Bolts[i]=Spawn(class'StarterTelsaBolt');
       return Bolts[i];
     }
}
function bool BoltIsAttacking (actor p){
  local byte i;
  for (i=0;i<MaxBolts;i++)
    if (Bolts[i]!=none&&!Bolts[i].bdeleteme&&Bolts[i].Target==p)
      return true;
}
function bool CheckScripted(pawn p){
  return AttackEnemies;
}

event Timer (){
  local pawn p;
  local StarterTelsaBolt Tb;
  for (p=level.pawnlist;p!=none;p=p.nextpawn)
    if (((p.bisplayer&&AttackPlayers)||(!p.bisplayer&&CheckScripted(p)))&&vsize(p.location-location)<MaxLength&&!BoltIsAttacking(p)){
      tb=SpawnBolt();
      if (tb==none)
        return;
      Tb.maxdamage=maxdamage;
      Tb.AimRotation=rotator(P.location-0.62 * vect(0,0,1)*P.CollisionHeight-Location);
      Tb.BeamOffSet=BeamOffSet;
      Tb.docap=HasCap;
      Tb.RotSpeed=rotSpeed;
      Tb.MaxPos=float(MaxLength)/tb.beamsize+1.5;
      Tb.Target=p;
      return; //only 1 beam at once.
    }
}

defaultproperties
{
     bEnabled=True
     MaxBolts=4
     AttackPlayers=True
     RotSpeed=0.400000
     MaxLength=1053
     MaxDamage=1000
     bStatic=False
}
