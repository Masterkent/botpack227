// ===============================================================
// SevenB.SevenSniperRifle: reloadable sniper rifle
// ===============================================================

class SevenSniperRifle expands UIweapons;
var int ClipCount;
var name FireAnims[5];
var vector OwnerLocation;
var float StillTime, StillStart;
var byte newclipanim; //for client stuff.....
var float OldZooming; //for reload zooming
var bool bInvGroupChecked;
replication
{
  // Things the server should send to the client.
  reliable if( bNetOwner && (Role==ROLE_Authority) )
    clipcount;

  reliable if (Role == ROLE_Authority)
    B227_StartReloading,
    B227_FinishReloading;
}
function PostBeginPlay()
{
	bInvGroupChecked = true;
	if (Level.Game.bDeathMatch)
		InventoryGroup = 10;
	else if (tvsp(Level.Game) != none || tvcoop(Level.Game) != none)
		InventoryGroup = 6;
}

simulated function PostRender( canvas Canvas )
{
  local PlayerPawn P;
  local float Scale;
  local float multiplier;
  Super.PostRender(Canvas);
  P = PlayerPawn(Owner);
  if  (P != None){
    if(P.Handedness != 1|| p.myhud.isa('challengehud'))
			multiplier=0.8;
		else
			multiplier=0.9;
      Canvas.DrawColor.B = 0;
    if (clipcount > 5 ){       //set colour according to clipcount.....
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 0;}
    else{
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;}
      if(PlayerPawn(Owner).Handedness != 1){
    Canvas.SetPos(0.05 * Canvas.ClipX , multiplier * Canvas.ClipY);
            Canvas.Style = ERenderStyle.STY_Translucent;
            Canvas.Font = Canvas.SmallFont;  }
            else {
            Canvas.SetPos(0.85 * Canvas.ClipX , multiplier * Canvas.ClipY);
            Canvas.Style = ERenderStyle.STY_Translucent;
            Canvas.Font = Canvas.SmallFont; }
            Canvas.DrawText("Clip: "$7-clipcount);
	if(P.DesiredFOV != P.DefaultFOV )
  {
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;
    Canvas.DrawColor.B = 0;
    bOwnsCrossHair = true;
    Scale = Canvas.ClipX/640;
    Canvas.SetPos(0.5 * Canvas.ClipX - 128 * Scale, 0.5 * Canvas.ClipY - 128 * Scale );
    if ( Level.bHighDetailMode )
      Canvas.Style = ERenderStyle.STY_Translucent;
    else
      Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.DrawIcon(Texture'RReticle', Scale);
    Canvas.SetPos(0.5 * Canvas.ClipX + 64 * Scale, 0.5 * Canvas.ClipY + 96 * Scale);
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;
    Canvas.DrawColor.B = 0;
    Scale = P.DefaultFOV/P.DesiredFOV;
    Canvas.DrawText("X"$int(Scale)$"."$int(10 * Scale - 10 * int(Scale)));
  }
  else if (isinstate('clientnewclip')||isinstate('newclip'))
  	bOwnsCrossHair=true;
  else
    bOwnsCrossHair = false;

    Canvas.Reset();
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 255;
    Canvas.DrawColor.B = 255;
  }
}

function float RateSelf( out int bUseAltMode )
{
  local float dist;

  if ( AmmoType.AmmoAmount <=0 || owner.region.zone.bwaterzone)
    return -2;

  bUseAltMode = 0;
  if ( (Bot(Owner) != None) && Bot(Owner).bSniping )
    return AIRating + 1.15;
  if (  Pawn(Owner).Enemy != None )
  {
    dist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
    if ( dist > 1200 )
    {
      if ( dist > 2000 )
        return (AIRating + 0.75);
      return (AIRating + FMin(0.0001 * dist, 0.45));
    }
  }
  return AIRating;
}

// set which hand is holding weapon
function setHand(float Hand)
{
  Super.SetHand(Hand);
  if ( Hand == 1 )
    Mesh = mesh(DynamicLoadObject("Botpack.Rifle2mL", class'Mesh'));
  else
    Mesh = mesh'Rifle2m';
}

function SetSwitchPriority(pawn Other)   //priority stuff
{
  local int i;
  local name temp, carried;

  if ( PlayerPawn(Other) != None )
  {
    for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == 'SniperRifle' )
      {
        AutoSwitchPriority = i;
        return;
      }
    // else, register this weapon
    carried = 'SniperRifle';
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

//water code:
state Idle
{
  function Fire( float Value )
  {
    if (owner.region.zone.bwaterzone)
      return;
    if ( AmmoType == None )
    {
      // ammocheck
      GiveAmmo(Pawn(Owner));
    }
    if (AmmoType.UseAmmo(1))
    {
      clipcount++;
			GotoState('NormalFire');
      bCanClientFire = true;
      bPointing=True;
      if ( Owner.IsA('Bot') )
      {
        // simulate bot using zoom
        if ( Bot(Owner).bSniping && (FRand() < 0.65) )
          AimError = AimError/FClamp(StillTime, 1.0, 8.0);
        else if ( VSize(Owner.Location - OwnerLocation) < 6 )
          AimError = AimError/FClamp(0.5 * StillTime, 1.0, 3.0);
        else
          StillTime = 0;
      }
      Pawn(Owner).PlayRecoil(FiringSpeed);
      TraceFire(0.0);
      AimError = Default.AimError;
      ClientFire(Value);
    }
  }
  function BeginState()
  {
    bPointing = false;
    SetTimer(0.4 + 1.6 * FRand(), false);
    Super.BeginState();
  }

  function EndState()
  {
    SetTimer(0.0, false);
    Super.EndState();
  }
  event Tick(float DeltaTime) {


     If (Pawn(Owner)!=None&&ammotype!=none) {
      If(PlayerPawn(Owner)!=None){
      //bextra3...only used by mods... same reload key as serpentine..... that ain't in UT, though...so its a unique key :D
      If ((7-clipcount<AmmoType.AmmoAmount)&&(playerpawn(owner).bextra3!=0)&&(clipcount!=0))            //we don't want to reload if all the ammo is actually IN the clip...
      //had problems reloading both....  h4x....  we can't let it reload if that's all the ammo (i.e. all ammo is in clips)
      Gotostate ('Newclip');   }          //just reload the damn thing......

      else {//cheesy botcode..... anyone else who has this that isn't a player is a bot or scripted pawn....
      //no one's pissing this guy off and he doesn't have a full clip... might as well reload
      If ((7-clipcount<AmmoType.AmmoAmount)&&(Pawn(Owner).enemy==None)&&(clipcount!=0))            //we don't want to reload if all the ammo is actually IN the clip...
      //had problems reloading both....  h4x....  we can't let it reload if that's all the ammo (i.e. all ammo is in clips)
      Gotostate ('Newclip');  }           //just reload the damn thing......
      }
  }

Begin:
  bPointing=False;
  if ( AmmoType.AmmoAmount<=0 )
    Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
  if ( Pawn(Owner).bFire!=0 && !owner.region.zone.bwaterzone) Fire(0.0);
  Disable('AnimEnd');
  PlayIdleAnim();
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

function GiveAmmo( Pawn Other )
{
  super.GiveAmmo(Other);
/*clip stuff*/
  If (6<Ammotype.ammoamount)                   //gotta make sure we have enough ammo to fill the clips....
  	ClipCount = 0;
  else
  	ClipCount = 7-Ammotype.ammoamount;
}

function Fire( float Value ) {
  if (owner.region.zone.bwaterzone){
    GotoState('Idle');
    return;
  }
  if ( (AmmoType == None) && (AmmoName != None) )
  {
    // ammocheck
    GiveAmmo(Pawn(Owner));
  }
  if ( AmmoType.UseAmmo(1) )
  {
    clipcount++;
		GotoState('NormalFire');
    bPointing=True;
    bCanClientFire = true;
    ClientFire(Value);
    if ( bRapidFire || (FiringSpeed > 0) )
      Pawn(Owner).PlayRecoil(FiringSpeed);
    if ( bInstantHit )
      TraceFire(0.0);
    else
      ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
  }}

function bool ClientAltFire( float Value )
{
  GotoState('Zooming');
  return true;
}

function AltFire( float Value )
{
  ClientAltFire(Value);
}

///////////////////////////////////////////////////////
state NormalFire
{
  ignores AnimEnd;
	function EndState()
  {
    Super.EndState();
    OldFlashCount = FlashCount;
  }

Begin:
  FlashCount++;
  finishanim();
  if ( bChangeWeapon )
    GotoState('DownWeapon');
  else if ( (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) ){
    GotoState('Idle'); }
  else if (ClipCount>=7){ GoToState('NewClip'); }
  else if ( Pawn(Owner).bFire!=0 && !owner.region.zone.bwaterzone) Global.Fire(0);
  else if ( Pawn(Owner).bAltFire!=0 )Global.AltFire(0);
  GoToState('Idle');
}

function Timer()
{
  local actor targ;
  local float bestAim, bestDist;
  local vector FireDir;
  local Pawn P;

  bestAim = 0.95;
  P = Pawn(Owner);
  if ( P == None )
  {
    GotoState('');
    return;
  }
  if ( VSize(P.Location - OwnerLocation) < 6 )
    StillTime += FMin(2.0, Level.TimeSeconds - StillStart);

  else
    StillTime = 0;
  StillStart = Level.TimeSeconds;
  OwnerLocation = P.Location;
  FireDir = vector(P.ViewRotation);
  targ = P.PickTarget(bestAim, bestDist, FireDir, Owner.Location);
  if ( Pawn(targ) != None )
  {
    SetTimer(1 + 4 * FRand(), false);
    bPointing = true;
    Pawn(targ).WarnTarget(P, 200, FireDir);
  }
  else
  {
    SetTimer(0.4 + 1.6 * FRand(), false);
    if ( (P.bFire == 0) && (P.bAltFire == 0) )
      bPointing = false;
  }
}
//slower:
function PlayFiring()
{
  Owner.PlaySound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*3.0);
  PlayAnim(FireAnims[Rand(5)],0.3 + 0.3 * FireAdjust, 0.05);

  if ( (PlayerPawn(Owner) != None)
    && (PlayerPawn(Owner).DesiredFOV == PlayerPawn(Owner).DefaultFOV) )
    bMuzzleFlash++;
}

//always 100 damage:
function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
  local UT_Shellcase s;

  s = Spawn(class'LongUT_ShellCase',, '', Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * FireOffset.Y+5.0) * Y - Z * 1);
  if ( s != None )
  {
    s.DrawScale = 2.0;
    s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);
  }
  if (Other == Level)
    Spawn(class'OsHeavyWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
  else if ( (Other != self) && (Other != Owner) && (Other != None) )
  {
    if ( Other.bIsPawn )
      Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);
    if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
      && (instigator.IsA('PlayerPawn') || (instigator.IsA('Bot') && !Bot(Instigator).bNovice)) )
      Other.TakeDamage(132, Pawn(Owner), HitLocation, 35000 * X, AltDamageType);
    else
      Other.TakeDamage(66,  Pawn(Owner), HitLocation, 30000.0*X, MyDamageType);
    if ( !Other.bIsPawn && !Other.IsA('Carcass') )
      spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
  }
}

function TraceFire( float Accuracy )
{
  local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
  local actor Other;
  local Pawn PawnOwner;

  PawnOwner = Pawn(Owner);

  Owner.MakeNoise(PawnOwner.SoundDampening);
  GetAxes(PawnOwner.ViewRotation,X,Y,Z);
  StartTrace = Owner.Location + PawnOwner.Eyeheight * Z;
  AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, 2*AimError, False, False);
  X = vector(AdjustedAim);
  EndTrace = StartTrace + 10000 * X;
  Other = PawnOwner.TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
  ProcessTraceHit(Other, HitLocation, HitNormal, X,Y,Z);
}

///////////////////////////////////////////////////////
state Zooming
{
  function Tick(float DeltaTime)
  {
    if ( Pawn(Owner).bAltFire == 0 )
    {
      if ( (PlayerPawn(Owner) != None) )
        PlayerPawn(Owner).StopZoom();
      SetTimer(0.0,False);
      GoToState('Idle');
    }
  }

  function BeginState()
  {
    if ( Owner.IsA('PlayerPawn') )
    {
      //-if ( PlayerPawn(Owner).Player.IsA('ViewPort') )
      PlayerPawn(Owner).ToggleZoom();
      SetTimer(0.2,True);
    }
    else
    {
      Pawn(Owner).bFire = 1;
      Pawn(Owner).bAltFire = 0;
      Global.Fire(0);
    }
  }
}

///////////////////////////////////////////////////////////
function PlayIdleAnim()
{
  if ( Mesh != PickupViewMesh )
    PlayAnim('Still',1.0, 0.05);
}

//reloading:
function playdownclip(){
  PlayAnim('Down',1,0.05);
}

function playselectclip(){
  PlayAnim('Select',1,0);
}

state NewClip
{
ignores Fire, AltFire;

begin:
  B227_StartReloading();
  //-OldZooming=0;
  //-if (playerpawn(owner)!=none && PlayerPawn(Owner).Player.IsA('ViewPort') && PlayerPawn(Owner).DesiredFOV != PlayerPawn(Owner).DefaultFOV){
  //-   //PlayerPawn(Owner).ToggleZoom();
  //-   OldZooming=PlayerPawn(Owner).DesiredFov;
  //-   PlayerPawn(Owner).DesiredFov=Playerpawn(Owner).defaultfov;
  //-}
  Playdownclip();
  FinishAnim();
  if ((pawn(owner)!=None)&&owner.animsequence!=''&&(pawn(owner).GetAnimGroup(pawn(owner).AnimSequence) == 'waiting')&&(pawn(owner).hasanim('cockgunL')))
    Pawn(owner).PlayAnim('CockGunL',, 0.3);

	sleep(0.2);
  If (6<ammotype.ammoamount)
  ClipCount = 0;
  else
  ClipCount = 7-ammotype.ammoamount;
  Owner.PlaySound(Sound'UnrealShare.Cocking', SLOT_None,1.0*Pawn(Owner).SoundDampening);
  sleep(0.3);
	Playselectclip();
  FinishAnim();
//  bcanclientfire=true;
  if ( bChangeWeapon ){
  	//-OldZooming=0;
    B227_FinishReloading(false);
    GotoState('DownWeapon');
  }
  B227_FinishReloading(true);
  //-if (OldZooming>0){
  //-  PlayerPawn(Owner).DesiredFov=OldZooming;
  //-  OldZooming=0;
  //-}
  if ( Pawn(Owner).bFire!=0 && !owner.region.zone.bwaterzone)
    Global.Fire(0);
  else if ( Pawn(Owner).bAltFire!=0)
    Global.AltFire(0);
  else GotoState('Idle');
}

simulated function B227_StartReloading()
{
	if (PlayerPawn(owner) != none && PlayerPawn(Owner).DesiredFOV != PlayerPawn(Owner).DefaultFOV)
	{
		OldZooming = PlayerPawn(Owner).DesiredFov;
		PlayerPawn(Owner).DesiredFov = PlayerPawn(Owner).DefaultFOV;
	}
}

simulated function B227_FinishReloading(bool bRestoreOldZooming)
{
	if (OldZooming > 0)
	{
		if (bRestoreOldZooming && PlayerPawn(Owner) != none)
			PlayerPawn(Owner).DesiredFov = OldZooming;
		OldZooming = 0;
	}
}

 //so its immediately called

function Finish()
{
  if ( (Pawn(Owner).bFire!=0) && !owner.region.zone.bwaterzone  && (FRand() < 0.6) )
    Timer();

  if ( bChangeWeapon )
    GotoState('DownWeapon');
  else if ( PlayerPawn(Owner) == None )
    Super.Finish();
  else if ( (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) )
    GotoState('Idle');
  else if (ClipCount>=7) GoToState('NewClip');
  else if ( Pawn(Owner).bFire!=0 && !owner.region.zone.bwaterzone)
    Global.Fire(0);
  else if (Pawn(Owner).bAltFire!=0 )
    Global.AltFire(0);
  else
    GotoState('Idle');
}

defaultproperties
{
     FireAnims(0)=Fire
     FireAnims(1)=Fire2
     FireAnims(2)=Fire3
     FireAnims(3)=Fire4
     FireAnims(4)=Fire5
     WeaponDescription="Classification: Long Range Ballistic"
     AmmoName=Class'Botpack.BulletBox'
     PickupAmmoCount=7
     bInstantHit=True
     bAltInstantHit=True
     FiringSpeed=1.800000
     FireOffset=(Y=-5.000000,Z=-2.000000)
     MyDamageType=shot
     AltDamageType=Decapitated
     shakemag=400.000000
     shaketime=0.150000
     shakevert=8.000000
     AIRating=0.570000
     RefireRate=0.600000
     AltRefireRate=0.300000
     FireSound=Sound'Botpack.SniperRifle.SniperFire'
     SelectSound=Sound'UnrealI.Rifle.RiflePickup'
     DeathMessage="%k put a bullet through %o's head."
     NameColor=(R=0,G=0)
     bDrawMuzzleFlash=True
     MuzzleScale=1.000000
     FlashY=0.110000
     FlashO=0.014000
     FlashC=0.031000
     FlashLength=0.013000
     FlashS=256
     MFTexture=Texture'Botpack.Rifle.MuzzleFlash2'
     AutoSwitchPriority=5
     InventoryGroup=10
     bAmbientGlow=False
     PickupMessage="You got a Inuit Sniper Rifle."
     ItemName="Inuit Sniper Rifle"
     PlayerViewOffset=(X=5.000000,Y=-1.600000,Z=-1.700000)
     PlayerViewMesh=LodMesh'Botpack.Rifle2m'
     PlayerViewScale=2.000000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'Botpack.RiflePick'
     ThirdPersonMesh=LodMesh'Botpack.RifleHand'
     StatusIcon=Texture'Botpack.Icons.UseRifle'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzsr3'
     MuzzleFlashScale=0.100000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy3'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseRifle'
     Rotation=(Roll=-1536)
     Mesh=LodMesh'Botpack.RiflePick'
     bNoSmooth=False
     CollisionRadius=32.000000
     CollisionHeight=8.000000
     RotationRate=(Yaw=0)
}
