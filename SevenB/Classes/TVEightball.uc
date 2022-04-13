// ================g===============================================
// This package is for use with the Partial Conversion, Seven Bullets, by Team Phalanx
// TVEightball : reloadable eightball that won't lock on good guys
// ===============================================================

class TVEightball expands UIweapons;

var name LoadAnim[6], RotateAnim[6], FireAnim[6];
var int RocketsLoaded, ClientRocketsLoaded, clipcount, oldclip;
var bool bClientDone, bRotated, bPendingLock;

Replication
{
  reliable if ( bNetOwner && (Role == ROLE_Authority) )
    clipcount;
}

function setHand(float Hand)
{
  Super.SetHand(Hand);

  if ( Hand == 0 )
    PlayerViewOffset.Y = 0;
  if ( Hand == 1 )
    Mesh = mesh(DynamicLoadObject("Botpack.EightML", class'Mesh'));
  else
    Mesh = mesh'EightM';
}

simulated event RenderTexture(ScriptedTexture Tex)     /*why not show clips?*/
{
  local Color C;
  local string Temp;

  Temp = String(8-clipcount);

  while(Len(Temp) < 3) Temp = "0"$Temp;

  C.R = 255;
  C.G = 0;
  C.B = 0;

  Tex.DrawColoredText( 2, 10, Temp, Font'LEDFont2', C );
}

simulated event RenderOverlays( canvas Canvas )
{
  Texture'MiniAmmoled'.NotifyActor = Self;
  Super.RenderOverlays(Canvas);
  Texture'MiniAmmoled'.NotifyActor = None;
}

simulated function PostRender( canvas Canvas )
{
  local float XScale;
  local PlayerPawn P;
  local float multiplier;

  Super.PostRender(Canvas);
  bOwnsCrossHair = bLockedOn;
  if ( bOwnsCrossHair )
  {
    // if locked on, draw special crosshair
    XScale = FMax(1.0, class'UTC_HUD'.static.B227_CrosshairSize(Canvas, 640.0));
    Canvas.SetPos(0.5 * (Canvas.ClipX - Texture'Crosshair6'.USize * XScale), 0.5 * (Canvas.ClipY - Texture'Crosshair6'.VSize * XScale));
    Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.DrawIcon(Texture'Crosshair6', XScale);
    Canvas.Style = 1;
  }
  if (isinstate('clientnewclip')||isinstate('newclip'))
  	bOwnsCrossHair=true;
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
        Canvas.Font = Canvas.SmallFont;
	}
    else {
    	Canvas.SetPos(0.85 * Canvas.ClipX , multiplier * Canvas.ClipY);
    	Canvas.Style = ERenderStyle.STY_Translucent;
        Canvas.Font = Canvas.SmallFont;
	}
    Canvas.DrawText("Clip: "$8-clipcount);

    Canvas.Reset();
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 255;
    Canvas.DrawColor.B = 255;
   }
}

function PlayLoading(float rate, int num)
{
  if ( Owner == None )
    return;
  Owner.PlaySound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);
  PlayAnim(LoadAnim[num],0.9, 0.05);
}

function PlayRotating(int num)
{
  Owner.PlaySound(Misc3Sound, SLOT_None, 0.1*Pawn(Owner).SoundDampening);
  PlayAnim(RotateAnim[num], 0.9, 0.05);
}

function PlayRFiring(int num)
{
  if ( Owner.IsA('PlayerPawn') )
  {
    PlayerPawn(Owner).shakeview(ShakeTime, ShakeMag*RocketsLoaded, ShakeVert); //shake player view
    PlayerPawn(Owner).ClientInstantFlash( -0.4, vect(650, 450, 190));
  }
  if ( Affector != None )
    Affector.FireEffect();
  Owner.PlaySound(AltFireSound, SLOT_None, 4.0*Pawn(Owner).SoundDampening);
  PlayAnim(FireAnim[num], 0.6, 0.05);
}

function PlayIdleAnim()
{
  if ( Mesh == PickupViewMesh )
    return;
  if (AnimSequence == LoadAnim[0] )
    PlayAnim('Idle',0.1,0.0);
  else
    TweenAnim('Idle', 0.5);
}

// tell bot how valuable this weapon would be to use, based on the bot's combat situation
// also suggest whether to use regular or alternate fire mode
function float RateSelf( out int bUseAltMode )
{
  local float EnemyDist, Rating;
  local bool bRetreating;
  local vector EnemyDir;
  local Pawn P;

  // don't recommend self if out of ammo
  if ( AmmoType.AmmoAmount <=0 )
    return -2;

  // by default use regular mode (rockets)
  bUseAltMode = 0;
  P = Pawn(Owner);
  if ( P.Enemy == None )
    return AIRating;

  // if standing on a lift, make sure not about to go around a corner and lose sight of target
  // (don't want to blow up a rocket in bot's face)
  if ( (P.Base != None) && (P.Base.Velocity != vect(0,0,0))
    && !P.CheckFutureSight(0.1) )
    return 0.1;

  EnemyDir = P.Enemy.Location - Owner.Location;
  EnemyDist = VSize(EnemyDir);
  Rating = AIRating;

  // don't pick rocket launcher is enemy is too close
  if ( EnemyDist < 360 )
  {
    if ( P.Weapon == self )
    {
      // don't switch away from rocket launcher unless really bad tactical situation
      if ( (EnemyDist > 230) || ((P.Health < 50) && (P.Health < P.Enemy.Health - 30)) )
        return Rating;
    }
    return 0.05 + EnemyDist * 0.001;
  }

  // nades are good if higher than target, bad if lower than target
  if ( Owner.Location.Z > P.Enemy.Location.Z + 120 )
    Rating += 0.25;
  else if ( P.Enemy.Location.Z > Owner.Location.Z + 160 )
    Rating -= 0.35;
  else if ( P.Enemy.Location.Z > Owner.Location.Z + 80 )
    Rating -= 0.05;

  // decide if should use alternate fire (grenades) instead
  if ( (Owner.Physics == PHYS_Falling) || Owner.Region.Zone.bWaterZone ){
    rating-=0.3;
    bUseAltMode = 0;
  }
  else
  {
    // grenades are good covering fire when retreating
    bRetreating = ( ((EnemyDir/EnemyDist) Dot Owner.Velocity) < -0.7 );
    bUseAltMode = 1;     //load up?
    if ( bRetreating && (EnemyDist < 800) && (FRand() < 0.4) )
      bUseAltMode = 0;        //fire now
  }
  return Rating;
}

// return delta to combat style while using this weapon
function float SuggestAttackStyle()
{
  local float EnemyDist;
  if (Pawn(Owner).Enemy==none)
    return  -0.2;
  // recommend backing off if target is too close
  EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
  if ( EnemyDist < 600 )
  {
    if ( EnemyDist < 300 )
      return -1.5;
    else
      return -0.7;
  }
  else
    return -0.2;
}

function FiringRockets()
{
  PlayRFiring(ClientRocketsLoaded - 1);
  bClientDone = true;
  Disable('Tick');
}

function AltFire( float Value )
{
	bPointing=True;
	bCanClientFire = true;
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1)){
    	clipcount++;
		GoToState('AltFiring');
	}
}

//////////////////////////////////////////////////////
state AltFiring
{
  function Tick( float DeltaTime )
  {
    if( (pawn(Owner).bAltFire==0) || (RocketsLoaded > 5) || clipcount >= 8)  // If if Fire button down, load up another
       GoToState('FireRockets');
  }


  function AnimEnd()
  {
    if ( bRotated )
    {
      bRotated = false;
      PlayLoading(1.1, RocketsLoaded);
    }
    else
    {
      if ( RocketsLoaded == 6 || clipcount>=8)
      {
        GotoState('FireRockets');
        return;
      }
      RocketsLoaded++;
      AmmoType.UseAmmo(1);
	  clipcount++;
      if ( (PlayerPawn(Owner) == None) && ((FRand() > 0.5) || (Pawn(Owner).Enemy == None)) )
        Pawn(Owner).bAltFire = 0;
      bPointing = true;
      Owner.MakeNoise(0.6 * Pawn(Owner).SoundDampening);
      RotateRocket();
    }
  }

  function RotateRocket()
  {
    if (AmmoType.AmmoAmount<=0||clipcount >= 8)
    {
      GotoState('FireRockets');
      return;
    }
    PlayRotating(RocketsLoaded-1);
    bRotated = true;
  }

  function BeginState()
  {
    Super.BeginState();
    RocketsLoaded = 1;
    RotateRocket();
  }

Begin:
  bLockedOn = False;
}

///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
state Idle
{
  event Tick(float DeltaTime) {


     If (Pawn(Owner)!=None&&ammotype!=none) {
      If(PlayerPawn(Owner)!=None){
      //bextra3...only used by mods... same reload key as serpentine..... that ain't in UT, though...so its a unique key :D
      If ((8-clipcount<AmmoType.AmmoAmount)&&(playerpawn(owner).bextra3!=0)&&(clipcount!=0))            //we don't want to reload if all the ammo is actually IN the clip...
      //had problems reloading both....  h4x....  we can't let it reload if that's all the ammo (i.e. all ammo is in clips)
      Gotostate ('Newclip');   }          //just reload the damn thing......

      else {//cheesy botcode..... anyone else who has this that isn't a player is a bot or scripted pawn....
      //no one's pissing this guy off and he doesn't have a full clip... might as well reload
      If ((8-clipcount<AmmoType.AmmoAmount)&&(Pawn(Owner).enemy==None)&&(clipcount!=0))            //we don't want to reload if all the ammo is actually IN the clip...
      //had problems reloading both....  h4x....  we can't let it reload if that's all the ammo (i.e. all ammo is in clips)
      Gotostate ('Newclip');  }           //just reload the damn thing......
      }
  }

Begin:
  if (Pawn(Owner).bFire!=0) Fire(0.0);
  if (Pawn(Owner).bAltFire!=0) AltFire(0.0);
  bPointing=False;
  if (AmmoType.AmmoAmount<=0)
    Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
  PlayIdleAnim();
}

///////////////////////////////////////////////////////
state FireRockets
{
  function Fire(float F) {}
  function AltFire(float F) {}

  function ForceFire()
  {
    bForceFire = true;
  }

  function ForceAltFire()
  {
    bForceAltFire = true;
  }

  function bool SplashJump()
  {
    return false;
  }

  function BeginState()
  {
    local vector FireLocation, StartLoc, X,Y,Z;
    local rotator FireRot, RandRot;
    local ut_grenade g;
    local float Angle, RocketRad;
    local pawn PawnOwner;
    local PlayerPawn PlayerOwner;
    local int DupRockets;
    local bool bMultiRockets;

    PawnOwner = Pawn(Owner);
    if ( PawnOwner == None )
      return;
    PawnOwner.PlayRecoil(FiringSpeed);
    PlayerOwner = PlayerPawn(Owner);
    Angle = 0;
    DupRockets = RocketsLoaded - 1;
    if (DupRockets < 0) DupRockets = 0;
    GetAxes(PawnOwner.ViewRotation,X,Y,Z);
    StartLoc = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;

    if (PawnOwner.IsA('playerpawn'))
			AdjustedAim = PawnOwner.AdjustAim(AltProjectileSpeed, StartLoc, AimError, True, bAltWarnTarget);
	  else
			AdjustedAim = PawnOwner.AdjustToss(AltProjectileSpeed, StartLoc, AimError, True, bAltWarnTarget);

    if ( PlayerOwner != None )
      AdjustedAim = PawnOwner.ViewRotation;

    PlayRFiring(RocketsLoaded-1);
    Owner.MakeNoise(PawnOwner.SoundDampening);
    bPointing = true;
    FireRot = AdjustedAim;
	RocketRad=7;
    bMultiRockets = ( RocketsLoaded > 1 );
    While ( RocketsLoaded > 0 )
    {
      if ( bMultiRockets )
        Firelocation = StartLoc - (Sin(Angle)*RocketRad - 7.5)*Y + (Cos(Angle)*RocketRad - 7)*Z - X * 4 * FRand();
      else
        FireLocation = StartLoc;

      g = Spawn( class 'sevenGrenade',, '', FireLocation,AdjustedAim);
      g.NumExtraGrenades = DupRockets;
      if ( DupRockets > 0 )
      {
        RandRot.Pitch = FRand() * 1500 - 750;
        RandRot.Yaw = FRand() * 1500 - 750;
        RandRot.Roll = FRand() * 1500 - 750;
        g.Velocity = g.Velocity >> RandRot;
      }

      Angle += 1.0484; //2*3.1415/6;
      RocketsLoaded--;
    }
    bRotated = false;
  }

  function AnimEnd()
  {
    if ( !bRotated && (AmmoType.AmmoAmount > 0) && clipcount<8)
    {
      PlayLoading(1.5,0);
      RocketsLoaded = 1;
      bRotated = true;
      return;
    }
    Finish();
  }
Begin:
}
//some bot/scriptedpawn crap:
function Fire( float Value )
{

  bPointing=True;
  if ( AmmoType == None )
  {
    // ammocheck
    GiveAmmo(Pawn(Owner));
  }
  if ( AmmoType.UseAmmo(1) )
  {
    clipcount++;
    bCanClientFire = true;
    RocketsLoaded = 1;
    GotoState('');
    GotoState('FireRockets', 'Begin');   //to be sure beginstate() is called
  }
}

function SetSwitchPriority(pawn Other)         //uses master priority
{
  local int i;
  local name temp, carried;

  if ( PlayerPawn(Other) != None )
  {
    for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == 'UT_Eightball' )
      {
        AutoSwitchPriority = i;
        return;
      }
    // else, register this weapon
    carried = 'UT_Eightball';
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
  Playdownclip();
  FinishAnim();
  oldclip=clipcount;
  if ((pawn(owner)!=None)&&owner.animsequence!=''&&(pawn(owner).GetAnimGroup(pawn(owner).AnimSequence) == 'waiting')&&(pawn(owner).hasanim('cockgunL')))
    Pawn(owner).PlayAnim('CockGunL',, 0.3);
  sleep(0.2);
	If (7<ammotype.ammoamount)
  ClipCount = 0;
  else
  ClipCount = 8-ammotype.ammoamount;
  Owner.PlaySound(Sound'UnrealShare.Cocking', SLOT_None,1.0*Pawn(Owner).SoundDampening);
  sleep(0.3);
	Playselectclip();
  FinishAnim();
  if (oldclip>=8){
	PlayLoading(1.5,0);
  	FinishAnim();
  }
  RocketsLoaded = 1;
  bRotated = true;
//  bcanclientfire=true;
  if ( bChangeWeapon ){
    GotoState('DownWeapon');
  }
	if ( Pawn(Owner).bFire!=0 && !owner.region.zone.bwaterzone)
    Global.Fire(0);
  else if ( Pawn(Owner).bAltFire!=0)
    Global.AltFire(0);
  else GotoState('Idle');
}

//reload stuff:
function GiveAmmo( Pawn Other )
{
  super.GiveAmmo(Other);
/*clip stuff*/
  If (7<Ammotype.ammoamount)                   //gotta make sure we have enough ammo to fill the clips....
  	ClipCount = 0;
  else
  	ClipCount = 8-Ammotype.ammoamount;
}

function Finish()
{
  if ( (Pawn(Owner).bFire!=0)  && (FRand() < 0.6) )
    Timer();

  if ( bChangeWeapon )
    GotoState('DownWeapon');
  else if ( (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) )
    GotoState('Idle');
  else if (ClipCount>=8)
    GoToState('NewClip');
  else if ( PlayerPawn(Owner) == None )
    Super.Finish();
  else if ( Pawn(Owner).bFire!=0)
    Global.Fire(0);
  else if (Pawn(Owner).bAltFire!=0 )
    Global.AltFire(0);
  else
    GotoState('Idle');
}

defaultproperties
{
     LoadAnim(0)=load1
     LoadAnim(1)=Load2
     LoadAnim(2)=Load3
     LoadAnim(3)=Load4
     LoadAnim(4)=Load5
     LoadAnim(5)=Load6
     RotateAnim(0)=Rotate1
     RotateAnim(1)=Rotate2
     RotateAnim(2)=Rotate3
     RotateAnim(3)=Rotate4
     RotateAnim(4)=Rotate5
     RotateAnim(5)=Rotate3
     FireAnim(0)=Fire1
     FireAnim(1)=Fire2
     FireAnim(2)=Fire3
     FireAnim(3)=Fire4
     FireAnim(4)=Fire2
     FireAnim(5)=Fire3
     WeaponDescription="Classification: Heavy Ballistic"
     AmmoName=Class'SevenB.SBGrenadeAmmo'
     PickupAmmoCount=8
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     bRecommendSplashDamage=True
     FiringSpeed=1.000000
     FireOffset=(X=10.000000,Y=-5.000000,Z=-8.800000)
     ProjectileClass=Class'SevenB.Sevengrenade'
     AltProjectileClass=Class'SevenB.Sevengrenade'
     shakemag=350.000000
     shaketime=0.200000
     shakevert=7.500000
     AIRating=0.810000
     RefireRate=0.250000
     AltRefireRate=0.250000
     AltFireSound=Sound'UnrealShare.Eightball.EightAltFire'
     CockingSound=Sound'UnrealShare.Eightball.Loading'
     SelectSound=Sound'UnrealShare.Eightball.Selecting'
     Misc1Sound=Sound'UnrealShare.Eightball.SeekLock'
     Misc2Sound=Sound'UnrealShare.Eightball.SeekLost'
     Misc3Sound=Sound'UnrealShare.Eightball.BarrelMove'
     DeathMessage="%o was smacked down by %k's %w."
     NameColor=(G=0,B=0)
     AutoSwitchPriority=9
     InventoryGroup=9
     bAmbientGlow=False
     PickupMessage="You got the USM Grenade Launcher."
     ItemName="Grenade Launcher"
     PlayerViewOffset=(X=2.400000,Y=-1.000000,Z=-2.200000)
     PlayerViewMesh=LodMesh'Botpack.Eightm'
     PlayerViewScale=2.000000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'Botpack.Eight2Pick'
     ThirdPersonMesh=LodMesh'Botpack.EightHand'
     StatusIcon=Texture'Botpack.Icons.Use8ball'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.Use8ball'
     Mesh=LodMesh'Botpack.Eight2Pick'
     bNoSmooth=False
     CollisionHeight=10.000000
     RotationRate=(Yaw=0)
}
