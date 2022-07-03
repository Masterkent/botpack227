// ===============================================================
// SevenB.SBquadshot: a somewhat more beefed up quadshot
// ===============================================================

class SBquadshot extends OLquadshot;

/*
#exec MESH IMPORT MESH=QuadShotthirdNEW ANIVFILE=..\olweapons\MODELS\QuadShotPickup_a.3D DATAFILE=..\olweapons\MODELS\QuadShotPickup_d.3D X=0 Y=0 Z=0
//#exec MESH ORIGIN MESH=QuadShotthirdNEW X=0 Y=0 Z=-100 YAW=34 Pitch=20 Roll=0  //default
#exec MESH ORIGIN MESH=QuadShotthirdNEW X=0 Y=0 Z=-100 YAW=94 Pitch=20 Roll=0
#exec MESH SEQUENCE MESH=QuadShotthirdNEW SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=QuadShotthirdNEW X=0.02 Y=0.02 Z=0.04
#exec MESHMAP SETTEXTURE MESHMAP=QuadShotthirdNEW NUM=4 TEXTURE=GunPick1
*/

#exec OBJ LOAD FILE="SevenBResources.u" PACKAGE=SevenB

//#exec MESH ORIGIN MESH=QuadShotthirdNEW X=64 Y=12 Z=-86 YAW=192 Pitch=90 Roll=128

//left handed (was b0rked)

var bool bInvGroupChecked;

// set which hand is holding weapon
function setHand(float Hand)
{
  Super.SetHand(Hand);
  if ( Hand != 1 ) //test
    Mesh = mesh'QuadShotHeldLSB';
  else
    Mesh = mesh'olweapons.QuadShotHeldR';
}

simulated function PostRender( canvas Canvas )   //render amount of clips left.....
{
  local PlayerPawn P;
  local float multiplier;
  P = PlayerPawn(Owner);
  if  (P != None)
  {
    if(P.Handedness != 1 || p.myhud.isa('challengehud'))
			multiplier=0.8;
		else
			multiplier=0.9;
    //shotsleft=min(shotsleft, ammotype.ammoamount); //happened somehow, but I couldn't track it down, so the fix is right here....
    Canvas.DrawColor.B = 0;
    if (shotsleft < 3 ){       //set colour according to shots left.....
    	Canvas.DrawColor.R = 255;
    	Canvas.DrawColor.G = 0;
		}
    else{
    	Canvas.DrawColor.R = 0;
    	Canvas.DrawColor.G = 255;
		}
    if(P.Handedness != 1)
    	Canvas.SetPos(0.05 * Canvas.ClipX , multiplier * Canvas.ClipY);
    else
      Canvas.SetPos(0.85 * Canvas.ClipX , multiplier * Canvas.ClipY);
   	Canvas.Style = ERenderStyle.STY_Translucent;
    class'FontInfo'.static.B227_SetStaticScaledSmallFont(Canvas, true);
    Canvas.DrawText("In Gun: "$ShotsLeft);

    Canvas.Reset();
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 255;
    Canvas.DrawColor.B = 255;
  }
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
  //local int rndDam;

  if ( PlayerPawn(Owner) != None )
    PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);

  if (Other == Level)
    Spawn(class'OSHeavyWallHitEffect',,, HitLocation+HitNormal*9, Rotator(HitNormal));
  else if ( (Other!=self) && (Other!=Owner) && (Other != None) )
  {
    if ( !Other.IsA('Pawn') && !Other.IsA('Carcass') )
      spawn(class'SpriteSmokePuff',,,HitLocation+HitNormal*9);
     //rndDam = 2 + Rand(5);
    if ( FRand() < 0.2 )
      X *= 2;
     if ( Other.IsA('Pawn') && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
      && (instigator.IsA('PlayerPawn') || (instigator.skill > 2))
      && (!Other.IsA('ScriptedPawn') || !ScriptedPawn(Other).bIsBoss) )
      	Other.TakeDamage(15+rand(13), Pawn(Owner), HitLocation, 35000 * X, 'decapitated');  //approx 2x power headshot
    else
    Other.TakeDamage(8+rand(7), Pawn(Owner), HitLocation, 5000.0*X, mydamagetype);
  }
}
function SetSwitchPriority(pawn Other)   //priority stuff
{
  local int i;
  local name temp, carried;

  if ( PlayerPawn(Other) != None )
  {
    for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == 'OlQuadshot' )
      {
        AutoSwitchPriority = i;
        return;
      }
    // else, register this weapon
    carried = 'OlQuadshot';
    for ( i=AutoSwitchPriority; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++ )
    {
      if ( PlayerPawn(Other).WeaponPriority[i] == '' )
      {
        PlayerPawn(Other).WeaponPriority[i] = carried;
        return;
      }
      else if ( i<ArrayCount(PlayerPawn(Other).WeaponPriority)-1 )
      {
        temp = PlayerPawn(Other).WeaponPriority[i];
        PlayerPawn(Other).WeaponPriority[i] = carried;
        carried = temp;
      }
    }
  }
}

function Fire( float Value )
{
  local int i;

  if (owner.region.zone.bwaterzone){
    GotoState('Idle');
    return;
  }
	else if (Shotsleft>0)
  {
    AmmoType.UseAmmo(1);
    GotoState('NormalFire');
    if ( PlayerPawn(Owner) != None )
      PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
    bPointing=True;
    bcanclientfire=True;
    clientfire(Value);
    ShotsLeft--;
    //PlayFiring();
    for(i = 0; i < 7; i++)
      TraceFire(1.0);
    if ( Owner.bHidden )
      CheckVisibility();
  }
}

function AltFire( float Value )
{
  local int i, r;
  local vector X,Y,Z;
  local float altaccuracy;
  if (owner.region.zone.bwaterzone){
    GotoState('Idle');
    return;
  }
	else if( Shotsleft > 0)
  {
    GetAxes(pawn(Owner).ViewRotation,x,y,z);
    x=normal(x);
//    If(pawn(owner).GetAnimGroup(Pawn(Owner).animsequence) != 'ducking'){ //only happens if standing up.....
    if (pawn(owner).baseeyeheight!=0){ //duck check VA compatible:
      pawn(Owner).SetLocation(pawn(Owner).Location+vect(0,0,15));
      pawn(Owner).Velocity-=(50*X); //very small recoil
    }
    //If ((pawn(Owner).health>19)&&(pawn(owner).GetAnimGroup(Pawn(Owner).animsequence) != 'ducking'))
    //-if (pawn(Owner).health>49&&pawn(owner).baseeyeheight!=0) //duck check VA compatible:
    //-  pawn(Owner).health-=1;//haha too poweful :D
    //-else if (pawn(Owner).health>7)
    //-  pawn(Owner).health--;
    bcanclientfire=True;
    clientaltfire(Value);
    GotoState('AltFiring');
    if ( PlayerPawn(Owner) != None )
      PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
    While ((ShotsLeft>0)&&(r<4)){
      AmmoType.UseAmmo(1);
      Shotsleft--;
      //PlayAltFiring();
      for (i = 0; i< 7; i++){
        AltAccuracy = 3.0;
        //  If (Pawn(Owner).GetAnimGroup(Pawn(Owner).animsequence) == 'ducking')        //aim becomes a little better
        if (pawn(owner).baseeyeheight==0) //ducking (VA compatible)
          AltAccuracy=AltAccuracy/1.721;
        TraceFire(AltAccuracy);
      }
      r++;
    }
    GotoState('AltFiring');
    if ( Owner.bHidden )
      CheckVisibility();
  }
}

//don't fire underwater:

state Reloading
{
ignores fire, altfire, animend;
  Begin:
  justfired=false;
  finishanim();
  reloader:
  if ((pawn(owner)!=None)&&owner.animsequence!=''&&(pawn(owner).GetAnimGroup(pawn(owner).AnimSequence) == 'waiting')&&(pawn(owner).hasanim('cockgunL')))
    Pawn(owner).PlayAnim('CockGunL',, 0.3);
  PlayAnim('Reload', 1.0, 0.05); //sped up a lot
  Owner.PlaySound(misc1sound, SLOT_None,1.0*Pawn(Owner).SoundDampening);
  FinishAnim();
  ShotsLeft++;
  if ( bChangeWeapon )
    GotoState('DownWeapon');
  else if ( Pawn(Owner).bFire!=0 && !owner.region.zone.bwaterzone)
    Global.Fire(0);
  else if ( Pawn(Owner).bAltFire!=0 && !owner.region.zone.bwaterzone)
    Global.AltFire(0);
  else if ((PlayerPawn(Owner)!=None)&&(shotsleft<ammotype.ammoamount)&&(playerpawn(owner).bextra3!=0)&&(Shotsleft!=9))
  Goto ('reloader');
  else if ((PlayerPawn(Owner)==None)&&(shotsleft<ammotype.ammoamount)&&(Pawn(Owner).enemy==None)&&(Shotsleft!=9))
  Goto ('reloader');
  else GotoState('Idle');          //bye bye.......


}

function bool clientfire(float value){
  if (owner.region.zone.bwaterzone){
    PlayIdleAnim();
    GotoState('');
    return false;
  }
  else
    return super.clientfire(value);
}

function bool clientaltfire(float value){
  if (owner.region.zone.bwaterzone){
    PlayIdleAnim();
    GotoState('');
    return false;
  }
  else
    return super.clientaltfire(value);
}
//override states???// (test network)
state Idle
{

Begin:
  PlayIdleAnim();
  //log ("bwantreload var is set to"$bwantreload);
  bPointing=False;
  if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
    Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
  if ( Pawn(Owner).bFire!=0 && !owner.region.zone.bwaterzone) Fire(0.0);
  if ( Pawn(Owner).bAltFire!=0 && !owner.region.zone.bwaterzone) AltFire(0.0);
}

function PostBeginPlay(){
	bInvGroupChecked=true;
	if (level.game.bDeathMatch){
		 InventoryGroup=3;
	}
}

function float RateSelf( out int bUseAltMode )                                   //UsAaR33:  edited eightball botcode
{
  local float EnemyDist, Rating;
  local vector EnemyDir;
  local Pawn P;

  // don't recommend self if out of ammo
  if ( AmmoType.AmmoAmount <=0 || owner.region.zone.bwaterzone)
    return -2;

  // by default use regular mode
  bUseAltMode = 0;
  P = Pawn(Owner);
  if ( P.Enemy == None )
    return AIRating;

  EnemyDir = P.Enemy.Location - Owner.Location;
  EnemyDist = VSize(EnemyDir);
  Rating = AIRating;

  // use alt if fairly close (and we don't need to worry about reload times)
  if ( EnemyDist < 360 &&(P.Health<60||shotsleft>1))
  bUseAltMode = 1;
  rating = FClamp(AIRating - (EnemyDist - 450) * 0.001, 0.2, 0.94);  //from flak cannon
  return rating;
}

defaultproperties
{
     AmmoName=Class'SevenB.SBShells'
     MyDamageType=shredded
     AIRating=0.800000
     AltRefireRate=0.250000
     InventoryGroup=5
     bAmbientGlow=False
     PickupMessage="You got the QuadShot V.X"
     ItemName="QuadShot V.X"
     ThirdPersonMesh=LodMesh'SevenB.QuadShotthirdNEW'
     MuzzleFlashMesh=LodMesh'Botpack.MuzzFlash3'
     RotationRate=(Yaw=0)
}
