// ============================================================
// OLweapons.OLquadshot: this is a quadshot that works
// based around the trishot from Legacy, coded by Cerr.
// I think I have the right to use it :D :D :D ::D
// Psychic_313: unchanged except to fix imports for those not on the Legacy team :-)
// ============================================================
class OLquadshot expands UIweapons;                                  //fire and reload sound from legacy

#exec OBJ LOAD FILE="OLweaponsResources.u" PACKAGE=OLweapons

//third person meshes (aligned correctly......)

//first person (scale fix, two hands, different anim lebels....)
//right handed                                X=0 Y=0 Z=0

//left handed

var int ShotsLeft;
var bool justfired;

replication
{
  // Thing the server should send to the client.
  reliable if( bNetOwner && (Role==ROLE_Authority) )
    shotsleft;
}

function float RateSelf( out int bUseAltMode )                                   //UsAaR33:  edited eightball botcode
{
  local float EnemyDist, Rating;
  local vector EnemyDir;
  local Pawn P;

  // don't recommend self if out of ammo
  if ( AmmoType.AmmoAmount <=0 )
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
  rating = FClamp(AIRating - (EnemyDist - 450) * 0.001, 0.2, AIRating);  //from flak cannon
  return rating;
  }

// set which hand is holding weapon
function setHand(float Hand)
{
  Super.SetHand(Hand);
  if ( Hand == 1 )
    Mesh = mesh'olweapons.QuadShotHeldL';
  else
    Mesh = mesh'olweapons.QuadShotHeldR';
}

simulated function PostRender( canvas Canvas )   //render amount of clips left.....
{
    local PlayerPawn P;
    local float multiplier;

    Super.PostRender(Canvas);

    P = PlayerPawn(Owner);
    if  (P != None)
    {
        if (ChallengeHUD(P.myhud) != none)
            multiplier=0.8;
        else
            multiplier=0.9;
        //shotsleft=min(shotsleft, ammotype.ammoamount); //happened somehow, but I couldn't track it down, so the fix is right here....
        Canvas.DrawColor.B = 0;
        if (shotsleft < 3 )
        {
            //set colour according to shots left.....
            Canvas.DrawColor.R = 255;
            Canvas.DrawColor.G = 0;
        }
        else
        {
            Canvas.DrawColor.R = 0;
            Canvas.DrawColor.G = 255;
        }
        if (P.Handedness != 1)
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
function PlayPostSelect()
{
shotsleft=max(1, shotsleft); //hehe :D
super.playpostselect();
}
function float SuggestAttackStyle()        //taken from flakcannon (tells about aggression if baddie's got weapon)
{
  return 0.3;
}

function float SuggestDefenseStyle()
{
  return -0.2;
}
function Fire( float Value )
{
  local int i;

  if (Shotsleft>0)
  {
    AmmoType.UseAmmo(1);
    GotoState('NormalFire');
    if ( PlayerPawn(Owner) != None )
      PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
    bPointing=True;
    bcanclientfire=True;
    clientfire(Value);
    ShotsLeft--;
    PlayFiring();
    for(i = 0; i < 12; i++)
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
  if( Shotsleft > 0 )
  {
    GetAxes(pawn(Owner).ViewRotation,x,y,z);
    x=normal(x);
//    If(pawn(owner).GetAnimGroup(Pawn(Owner).animsequence) != 'ducking'){ //only happens if standing up.....
    if (pawn(owner).baseeyeheight!=0){ //duck check VA compatible:
      pawn(Owner).SetLocation(pawn(Owner).Location+vect(0,0,15));
      pawn(Owner).Velocity-=(849*X); //simple little thingy.....
    }
    //If ((pawn(Owner).health>19)&&(pawn(owner).GetAnimGroup(Pawn(Owner).animsequence) != 'ducking'))
    //-if (pawn(Owner).health>19&&pawn(owner).baseeyeheight!=0) //duck check VA compatible:
    //-  pawn(Owner).health-=2;//haha too poweful :D
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
      PlayAltFiring();
      for (i = 0; i< 12; i++){
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

function PlayFiring()
{
  Owner.PlaySound(FireSound,, Pawn(Owner).SoundDampening);
  justfired=true;
  PlayAnim('Fire', 0.5, 0.05);
  bMuzzleFlash++;
}

function PlayAltFiring()
{
Owner.PlaySound(FireSound,, Pawn(Owner).SoundDampening);
PlayAnim('Fire', 0.2, 0.05);
bMuzzleFlash++;
justfired=true;
}

state Reloading
{
ignores fire, altfire, animend;
  Begin:
  justfired=false;
  finishanim();
  reloader:
  PlayAnim('Reload', 1.0, 0.05); //sped up a lot
  Owner.PlaySound(misc1sound, SLOT_None,1.0*Pawn(Owner).SoundDampening);
  FinishAnim();
  ShotsLeft++;
  if ( bChangeWeapon )
    GotoState('DownWeapon');
  else if ( Pawn(Owner).bFire!=0 )
    Global.Fire(0);
  else if ( Pawn(Owner).bAltFire!=0 )
    Global.AltFire(0);
  else if ((PlayerPawn(Owner)!=None)&&(shotsleft<ammotype.ammoamount)&&(playerpawn(owner).bextra3!=0)&&(Shotsleft!=9))
  Goto ('reloader');
  else if ((PlayerPawn(Owner)==None)&&(shotsleft<ammotype.ammoamount)&&(Pawn(Owner).enemy==None)&&(Shotsleft!=9))
  Goto ('reloader');
  else GotoState('Idle');          //bye bye.......


}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
  //local int rndDam;

  if ( PlayerPawn(Owner) != None )
    PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);

  if (B227_ShouldTraceFireThroughWarpZones())
    B227_WarpedTraceFire(self, B227_FireStartTrace, B227_FireEndTrace, 8, Other, HitLocation, HitNormal, X);

  if (Other == Level)
    Spawn(class'OSHeavyWallHitEffect',,, HitLocation+HitNormal*9, Rotator(HitNormal));
  else if ( (Other!=self) && (Other!=Owner) && (Other != None) )
  {
    if ( !Other.IsA('Pawn') && !Other.IsA('Carcass') )
      spawn(class'SpriteSmokePuff',,,HitLocation+HitNormal*9);
     //rndDam = 2 + Rand(5);
    if ( FRand() < 0.2 )
      X *= 2;
    Other.TakeDamage(5, Pawn(Owner), HitLocation, 5000.0*X, mydamagetype);
  }
}

///////////////////////////////////////////////////////
state NormalFire
{
ignores Fire, AltFire, animend;

function EndState()
  {
    Super.EndState();
    OldFlashCount = FlashCount;
  }
Begin:
  flashcount++;
  FinishAnim();
  if( ShotsLeft <= 0 && AmmoType.AmmoAmount > 0 )
  {
    Gotostate('Reloading');
  }
  else
  Finish();
}

state AltFiring
{
ignores Fire, AltFire, animend;

function EndState()
  {
    Super.EndState();
    OldFlashCount = FlashCount;
  }
Begin:
  flashcount++;
  FinishAnim();
  if( Shotsleft <= 0 &&ammotype.ammoamount>0)
  Gotostate('Reloading');
  else
  Finish();
}

//**********************************************************************************
// Weapon is up, but not firing
state Idle
{
   event Tick(float DeltaTime) {
    global.tick(deltatime);
    If (Pawn(Owner)!=None) {
      If(PlayerPawn(Owner)!=None){
      If ((Shotsleft<AmmoType.AmmoAmount)&&(ammotype.ammoamount>0)&&(playerpawn(owner).bextra3!=0)&&(Shotsleft!=9)) {
       bcanclientfire=true;
      Gotostate('Reloading');   }}

      else {
      //no one's pissing this guy off and he doesn't have a full clip... might as well reload
      If ((Shotsleft<AmmoType.AmmoAmount)&&(ammotype.ammoamount>0)&&(Pawn(Owner).enemy==None)&&(Shotsleft!=9))
       Gotostate('Reloading');  }
      }
  }

  function bool PutDown()
  {
    GotoState('DownWeapon');
    return True;
  }

Begin:
  PlayIdleAnim();
  //log ("bwantreload var is set to"$bwantreload);
  bPointing=False;
  if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
    Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
  if ( Pawn(Owner).bFire!=0 ) Fire(0.0);
  if ( Pawn(Owner).bAltFire!=0 ) AltFire(0.0);
}

function PlayIdleAnim()
{
  if (justfired)
    PlayAnim ('stillfire',,0.05);
  else
    PlayAnim ('still',,0.05);
}

defaultproperties
{
     ShotsLeft=9
     WeaponDescription="Classification: Quad-Barrelled Shotgun\n\nPrimary Fire: Uses one shell. Low accuracy.\n\nSecondary Fire: Discharges all shells in gun (up to 4).  Even less accurate.\n\nTechniques: Reload often (set button in control options).  Note that the alt fire has a very powerful kickback that will cause light damage to its user.  Ducking will improve accuracy, as well as reduce self-damage."
     AmmoName=Class'OLweapons.OlShells'
     PickupAmmoCount=15
     bInstantHit=True
     bAltInstantHit=True
     bSpecialIcon=False
     FireOffset=(Y=-0.500000)
     MyDamageType=shot
     AIRating=0.700000
     FireSound=Sound'OLweapons.QuadShot.Qsfire'
     CockingSound=Sound'UnrealI.Rifle.RiflePickup'
     SelectSound=Sound'UnrealI.Rifle.RiflePickup'
     Misc1Sound=Sound'OLweapons.QuadShot.reloadsound'
     DeathMessage="%o was blasted to bits by %k's %w."
     bDrawMuzzleFlash=True
     MuzzleScale=1.000000
     FlashY=0.110000
     FlashO=0.140000
     FlashC=0.031000
     FlashLength=0.013000
     FlashS=256
     MFTexture=Texture'botpack.Rifle.MuzzleFlash2'
     AutoSwitchPriority=4
     InventoryGroup=3
     PickupMessage="You got the QuadShot"
     ItemName="QuadShot"
     PlayerViewOffset=(X=4.500000,Y=-2.500000,Z=-3.750000)
     PlayerViewMesh=LodMesh'OLweapons.QuadShotHeldr'
     PlayerViewScale=0.700000
     PickupViewMesh=LodMesh'UnrealI.QuadShotPickup'
     ThirdPersonMesh=LodMesh'OLweapons.QuadShotthird'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'botpack.muzzsr3'
     MuzzleFlashScale=0.100000
     MuzzleFlashTexture=Texture'botpack.Skins.Muzzy3'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     ActivateSound=Sound'UnrealI.Rifle.RiflePickup'
     Mesh=LodMesh'UnrealI.QuadShotPickup'
     bNoSmooth=False
     CollisionRadius=40.000000
     CollisionHeight=11.000000
     LightBrightness=228
     LightHue=30
     LightSaturation=71
     Mass=40.000000
}
