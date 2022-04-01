// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// SmokeAttachMover.  A smoke generator on the mover.
// defaults ripped from Heiko's old one.
// ============================================================

class SmokeAttachMover expands Mover;
var(Smoke) float SmokeDelay;    // pause between drips
var(Smoke) float SizeVariance;    // how different each drip is
var(Smoke) float BasePuffSize;
var(Smoke) float RisingVelocity;
var(Smoke) class<effects> GenerationType;
//var(Smoke) Vector OffSet;
var(Smoke) Vector OffSet[4];
var(Smoke) byte Trails; //amount of trails
var float i;
//var bool nosmoke;
var(AttachMover) name AttachTag;

replication{  //needed, I assume
  reliable if (role==Role_Authority)
    SmokeDelay, SizeVariance, BasePuffSize, RisingVelocity, GenerationType, Offset, Trails;
}
simulated function Tick(float delta)  //timer is already used :(
{
  local Effects d;
  local byte j;
  super.tick(delta);
  i+=delta;
  if (i<Smokedelay)
  return;
/*  if (nosmoke&&i<1)
  return;
  if (nosmoke&&playercanseeme())   //player can see me checks.
  nosmoke=false;
//  else if (!playercanseeme())
 // nosmoke=true;
  i=0;
  if (nosmoke)
  return;       */
  i=0;
  for (j=0;j<Trails;j++){
    d = Spawn(GenerationType,,,location+(Offset[j]>>rotation));
    d.DrawScale = BasePuffSize+FRand()*SizeVariance;
    if (SpriteSmokePuff(d)!=None)
      SpriteSmokePuff(d).RisingRate = RisingVelocity;
    if (UT_SpriteSmokePuff(D)!=none)
      UT_SpriteSmokePuff(d).RisingRate = RisingVelocity;
    d.remoterole=role_none; //client side spawned.
  }
}

function postbeginplay(){
local Actor Act;
  local Mover Mov;
super.postbeginplay();
Trails=min(4,Trails);
if (level.netmode==nm_standalone)
  i=smokedelay;
if (level.netmode==NM_dedicatedserver)  //don't spawn smoke on dedicated servrs.
  disable('tick');
// Initialize all slaves.
  if ( AttachTag != '' )
    foreach AllActors( class 'Actor', Act, AttachTag )
    {
      Mov = Mover(Act);
      if (Mov == None) {

        Act.SetBase( Self );
      }
      else if (Mov.bSlave) {

        Mov.GotoState('');
        Mov.SetBase( Self );
      }
    }
}

defaultproperties
{
     SmokeDelay=0.050000
     SizeVariance=2.000000
     BasePuffSize=2.000000
     RisingVelocity=300.000000
     GenerationType=Class'Botpack.UT_SpriteSmokePuff'
     Trails=1
     bStasis=True
     bForceStasis=True
}
