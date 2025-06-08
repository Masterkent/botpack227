// ============================================================
// OLweapons.olSMenf: SMP enforcer style!!!!!!!
// Psychic_313: unchanged
// ============================================================

class olSMenf expands olSMmag;
//skinz
#exec OBJ LOAD FILE="OLweaponsResources.u" PACKAGE=OLweapons

var() texture MuzzleFlashVariations[5];
state NormalFire
{
ignores Fire, AltFire, animend;
  function EndState(){
    bSteadyFlash3rd = false;
    super.endstate();
   }
Begin:
  bmuzzleflash++;
  bSteadyFlash3rd = true;
  sleep(0.07);
  if (ClipCount>35) Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
  bSteadyFlash3rd = false;
  if ( bChangeWeapon )
    GotoState('DownWeapon');
  else if ( PlayerPawn(Owner) == None )
    Super.Finish();
  else if ( (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) ){
    GotoState('Idle'); }
  else if (ClipCount>=40) GoToState('NewClip');
  else if ( Pawn(Owner).bFire!=0 ) Global.Fire(0);
  else if ( Pawn(Owner).bAltFire!=0 ){Global.AltFire(0);}
  GoToState('Idle');
}

state NewClip           //new animations...........
{
ignores Fire, AltFire;
Begin:
  //hack sorta to play cockgun (only works if the mesh is in wating state).  I like Hasanim!!!!
  if ((pawn(owner)!=None)&&(pawn(owner).GetAnimGroup(pawn(owner).AnimSequence) == 'waiting')&&(pawn(owner).hasanim('cockgun')))
  Pawn(owner).PlayAnim('CockGun',, 0.3);
  PlayAnim('Eject',1.54,0.05);
  Owner.PlaySound(Misc2Sound, SLOT_None,1.0*Pawn(Owner).SoundDampening);
  FinishAnim();
  //PlayAnim('Down',0.05);
  //FinishAnim();
  If (39<ammotype.ammoamount)
  ClipCount = 0;
  else
  ClipCount = 40-ammotype.ammoamount;
  Owner.PlaySound(SelectSound, SLOT_None,1.0*Pawn(Owner).SoundDampening);
  PlayAnim('Select',1.466666,0.07);
  FinishAnim();
  if ( bChangeWeapon )
    GotoState('DownWeapon');
  else if ( Pawn(Owner).bFire!=0 )
    Global.Fire(0);
  else if ( Pawn(Owner).bAltFire!=0 )
    Global.AltFire(0);
  else GotoState('Idle');
}
function PlayShotGunFiring()
{
  if ( Affector != None )
    Affector.FireEffect();
  if ( PlayerPawn(Owner) != None )
  {
    PlayerPawn(Owner).ClientInstantFlash( -0.2, vect(325, 225, 95));
    PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
  }

bMuzzleFlash++;
Owner.PlaySound(AltFireSound, SLOT_None,2.0*Pawn(Owner).SoundDampening);
  PlayAnim('Shot2', 0.348387, 0.05);}

state AltFiring
{
ignores Fire, AltFire, animend;
  function EndState(){
    Super.EndState();
    OldFlashCount = FlashCount;
  }
Begin:
  FinishAnim();
Repeater:
  if (AmmoType.UseAmmo(1))
  {
    GetAxes(pawn(Owner).ViewRotation,x,y,z);
    x=normal(x);
    If(pawn(owner).GetAnimGroup(Pawn(Owner).animsequence) != 'ducking'){ //only happens if standing up.....
    pawn(Owner).SetLocation(pawn(Owner).Location+vect(0,0,15));
    pawn(Owner).Velocity-=(849*X); }//simple little thingy.....
    if ( PlayerPawn(Owner) != None &&playerpawn(owner).player.isa('viewport'))
      PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
    ClipCount++;
    TraceFire(AltAccuracy);
    for (i = 0; i< 9; i++){
    If (ClipCount<40){
    AmmoType.UseAmmo(1);
    FlashCount++;
    clipcount++; //if there is stuff in the clip then there's ammo...
    AltAccuracy = (frand()+1)*1.62;//wierd accuracy calculation....spices up the accuracy even more :D
    If(Pawn(Owner).GetAnimGroup(Pawn(Owner).animsequence) == 'ducking')        //aim becomes a little better
    AltAccuracy=AltAccuracy/2.5;
    TraceFire(AltAccuracy);
    }}

    PlayShotGunFiring();
    //throw backwards.....
    FinishAnim();
  }
  if ( AltAccuracy < 3 )
    AltAccuracy += 0.5;
  //if (ClipCount>15) Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
  if ( bChangeWeapon )
    GotoState('DownWeapon');
  else if ( Pawn(Owner).Weapon != Self )
    GotoState('Idle');
  else if ((Pawn(Owner).bAltFire!=0)
    && AmmoType.AmmoAmount>0 && ClipCount<40)
  {

       Goto('Repeater');
  }
  PlayAnim('T2', 0.9, 0.05);
  FinishAnim();
  Finish();
}

function PlayIdleAnim()
{
  if ( Mesh == PickupViewMesh )
    return;
  if ( (FRand()>0.96) && (AnimSequence != 'Twiddle') )
    PlayAnim('Twiddle',0.6,0.3);
  else
    LoopAnim('Sway',0.2, 0.3);
}
state Idle
{
  function AnimEnd()
  {
    PlayIdleAnim();
  }
  event Tick(float DeltaTime) {

      If (Pawn(Owner)!=None) {
      If(PlayerPawn(Owner)!=None){
      //bextra3...only used by mods... same reload key as serpentine..... that ain't in UT, though...so its a unique key :D
      If ((40-clipcount<AmmoType.AmmoAmount)&&(playerpawn(owner).bextra3!=0)&&(clipcount!=0))            //we don't want to reload if all the ammo is actually IN the clip...
      //had problems reloading both....  h4x....  we can't let it reload if that's all the ammo (i.e. all ammo is in clips)
      Gotostate ('Newclip');   }          //just reload the damn thing......

      else {//cheesy botcode..... anyone else who has this that isn't a player is a bot or scripted pawn....
      //no one's pissing this guy off and he doesn't have a full clip... might as well reload
      If ((40-clipcount<AmmoType.AmmoAmount)&&(Pawn(Owner).enemy==None)&&(clipcount!=0))            //we don't want to reload if all the ammo is actually IN the clip...
      //had problems reloading both....  h4x....  we can't let it reload if that's all the ammo (i.e. all ammo is in clips)
      Gotostate ('Newclip');  }           //just reload the damn thing......
      }
  }


Begin:
  bPointing=False;
  if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
    Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
  //Disable('AnimEnd');
  LoopAnim('Sway',0.02, 0.1);
  //SetTimer(1.5,True);
  if ( /*bFireMem ||*/ Pawn(Owner).bFire!=0 ) Global.Fire(0.0);
  if ( /*bAltFireMem ||*/ Pawn(Owner).bAltFire!=0 ) Global.AltFire(0.0);
}
function setHand(float Hand)
{
  Super.SetHand(Hand);
  if ( Hand == 1 )
    Mesh = mesh'AutoML';
  else
    Mesh = mesh'AutoMR';
  //now set skinz....

}

function PlayFiring()
{
  LoopAnim('Shoot',2, 0.02);
  }
simulated event RenderOverlays(canvas Canvas)         //muzzle stuff.....
{
  local PlayerPawn PlayerOwner;
  local int realhand;

  if ( (bMuzzleFlash > 0) && !Level.bDropDetail )
    MFTexture = MuzzleFlashVariations[Rand(5)];
  PlayerOwner = PlayerPawn(Owner);
  if ( PlayerOwner != None )
  {
    if ( PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV )
      return;
    realhand = PlayerOwner.Handedness;
    if (  (Level.NetMode == NM_Client) && (realHand == 2) )
    {
      bHideWeapon = true;
      return;
    }
    if ( !bHideWeapon )
    {
      if ( Mesh == mesh'AutoML' )
        PlayerOwner.Handedness = 1;

    }
  }
  if ( (PlayerOwner == None) || (PlayerOwner.Handedness == 0) )
  {
    if ( AnimSequence == 'Shot2' )
    {
      FlashO = -2 * Default.FlashO;
      FlashY = Default.FlashY * 2.5;
    }
    else
    {
      FlashO = 1.9 * Default.FlashO;
      FlashY = Default.FlashY;
    }
  }
  else if ( AnimSequence == 'Shot2' )
  {
    FlashO = Default.FlashO * 0.3;
    FlashY = Default.FlashY * 2.5;
  }
  else
  {
    FlashO = Default.FlashO;
    FlashY = Default.FlashY;
  }
  if ( !bHideWeapon  )
  {
    if ( PlayerOwner == None )
      bMuzzleFlash = 0;
  }
  multiskins[1]=texture'enfredtwo';  //swap skin so it is displayed only in 1st person
  Super.RenderOverlays(Canvas);
  multiskins[1]=default.MultiSkins[1];
  if ( PlayerOwner != None )
    PlayerOwner.Handedness = realhand;
}
function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
  local ut_shellcase s;
  local vector realLoc;

  realLoc = Owner.Location + CalcDrawOffset();
  if (frand()<0.31415926){     //we don't want too many shell cases....
  s = Spawn(class'ut_ShellCase',Pawn(Owner), '', realLoc + 20 * X + FireOffset.Y * Y + Z);
  if ( s != None )
    s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);}

  if (B227_ShouldTraceFireThroughWarpZones())
    B227_WarpedTraceFire(self, B227_FireStartTrace, B227_FireEndTrace, 8, Other, HitLocation, HitNormal, X);

  if (Other == Level)
    Spawn(class'Ut_heavyWallHitEffect',,, HitLocation+HitNormal*9, Rotator(HitNormal));
  else if ((Other != self) && (Other != Owner) && (Other != None) )
  {
    if ( FRand() < 0.2 )
      X *= 5;
    Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 3000.0*X, 'shot');
    if ( !Other.IsA('Pawn') && !Other.IsA('Carcass') )
      spawn(class'SpriteSmokePuff',,,HitLocation+HitNormal*9);
  }
}

function SetSwitchPriority(pawn Other)         //uses master priority
{
  local int i;
  local name temp, carried;

  if ( PlayerPawn(Other) != None )
  {
    for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == 'olSMmag' )
      {
        AutoSwitchPriority = i;
        return;
      }
    // else, register this weapon
    carried = 'olSMmag';
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

defaultproperties
{
     MuzzleFlashVariations(0)=Texture'botpack.Skins.Muz1'
     MuzzleFlashVariations(1)=Texture'botpack.Skins.Muz2'
     MuzzleFlashVariations(2)=Texture'botpack.Skins.Muz3'
     MuzzleFlashVariations(3)=Texture'botpack.Skins.Muz4'
     MuzzleFlashVariations(4)=Texture'botpack.Skins.Muz5'
     InstFlash=-0.200000
     InstFog=(X=325.000000,Y=225.000000,Z=95.000000)
     AmmoName=Class'OLweapons.osmagammo2'
     FireSound=Sound'botpack.enforcer.E_Shot'
     CockingSound=Sound'botpack.enforcer.Cocking'
     SelectSound=Sound'botpack.enforcer.Cocking'
     bDrawMuzzleFlash=True
     MuzzleScale=1.000000
     FlashY=0.100000
     FlashO=0.020000
     FlashC=0.035000
     FlashLength=0.020000
     FlashS=128
     MFTexture=Texture'botpack.Skins.Muz1'
     PickupMessage="You got the SMP 8920.  Now kick some @$$!"
     ItemName="SMP 8920"
     PlayerViewOffset=(X=3.300000,Y=-2.000000,Z=-3.000000)
     PlayerViewMesh=LodMesh'botpack.AutoML'
     PickupViewMesh=LodMesh'botpack.MagPick'
     ThirdPersonMesh=LodMesh'botpack.AutoHand'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'botpack.muzzEF3'
     MuzzleFlashScale=0.080000
     MuzzleFlashTexture=Texture'botpack.Skins.Muzzy2'
     bHidden=True
     Mesh=LodMesh'botpack.MagPick'
     MultiSkins(0)=Texture'OLweapons.enfredone'
     MultiSkins(1)=Texture'OLweapons.thridskin'
     MultiSkins(2)=Texture'OLweapons.enfredthree'
     MultiSkins(3)=Texture'OLweapons.enfredfour'
     CollisionRadius=24.000000
     CollisionHeight=12.000000
}
