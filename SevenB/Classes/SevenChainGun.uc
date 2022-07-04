// ===============================================================
// SevenB.SevenChainGun: more powerful minigun
// forces walking too
// ===============================================================

class SevenChaingun expands minigun2;

var bool bInvGroupChecked;

function float RateSelf( out int bUseAltMode )  //don't use in water
{
  // don't recommend self in water!
  if (owner.region.zone.bwaterzone)
    return -2;
  return Super.RateSelf(bUseAltMode);
}

function PostBeginPlay()
{
	bInvGroupChecked = true;
	if (Level.Game.bDeathMatch)
	{
		InventoryGroup = 7;
		PickupAmmoCount = 250; //replaces redeemer. get 5/8 full
	}
	else if (tvsp(Level.Game) != none || tvcoop(Level.Game) != none)
		InventoryGroup = 3;
}

function SetWalk(bool bForceWalk){
  local Pawn pOwner;
	powner=pawn(owner);
	if (pOwner==none)
		return;
	if (tvplayer(pOwner)!=none){
		tvplayer(pOwner).bForceWalk=bForceWalk;
		return;
	}
	//must "hack" speeds (has problems w/ stuff likely.. whatever)
	if (bForceWalk){
		pOwner.GroundSpeed = pOwner.Default.GroundSpeed * 0.3;
  	pOwner.JumpZ = -1;
  }
  else{
    pawn(Owner).GroundSpeed = pawn(Owner).Default.GroundSpeed;
	  pawn(Owner).JumpZ = pawn(Owner).Default.JumpZ;
  }
}

function DropFrom(vector StartLocation)
{
	SetWalk(false);
	Super.DropFrom(StartLocation);
}
function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
  local int rndDam;

  if (Other == Level)
    Spawn(class'osLightWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
  else if ( (Other!=self) && (Other!=Owner) && (Other != None) )
  {
    if ( !Other.bIsPawn && !Other.IsA('Carcass') )
      spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
    else
      Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);

    if ( Other.IsA('Bot') && (FRand() < 0.2) )
      Pawn(Other).WarnTarget(Pawn(Owner), 500, X);
    rndDam = 45 + Rand(21);
    if ( FRand() < 0.2 )
      X *= 2.5;
    if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
      && (instigator.IsA('PlayerPawn') || (instigator.IsA('Bot') && !Bot(Instigator).bNovice) ||
        (Other.IsA('ScriptedPawn') && (ScriptedPawn(Other).bIsBoss || level.game.difficulty>=3))) ){
        MyDamageType='Decapitated';
        rndDam*=2;
    }
    Other.TakeDamage(rndDam, Pawn(Owner), HitLocation, rndDam*500.0*X, MyDamageType);
    MyDamageType=default.MyDamageType;
  }
}


simulated event RenderOverlays( canvas Canvas )
{
	super.RenderOverlays(Canvas); // see B227_SpawnShellCase
}

//no firing in water code:
state NormalFire
{
  function AnimEnd()
  {
    if (Pawn(Owner).Weapon != self) GotoState('');
    else if (Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount>0 && !owner.region.zone.bwaterzone)
      Global.Fire(0);
    else if ( Pawn(Owner).bAltFire!=0 && AmmoType.AmmoAmount>0 && !owner.region.zone.bwaterzone)
      Global.AltFire(0);
    else
      GotoState('FinishFire');
  }
  function BeginState(){
  	super.BeginState();
  	SetWalk(true);
  }
  function EndState(){
	  SetWalk(false);
  	super.EndState();
  }

}

state AltFiring
{
  function BeginState(){
  	super.BeginState();
  	SetWalk(true);
  }
  function EndState(){
	  SetWalk(false);
  	super.EndState();
  }
  function Tick( float DeltaTime )
  {
    if (Owner==None)
    {
      AmbientSound = None;
      GotoState('Pickup');
    }

    if  ( bFiredShot && ((pawn(Owner).bAltFire==0) || bOutOfAmmo || owner.region.zone.bwaterzone) )
      GoToState('FinishFire');
  }
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

function AltFire( float Value ) {

  if (owner.region.zone.bwaterzone){
    GotoState('Idle');
    return;
  }
  else
    super.AltFire(value);

}

function Fire( float Value ) {
  if (owner.region.zone.bwaterzone){
    GotoState('Idle');
    return;
  }
  else
    super.Fire(value);
}
state Idle
{

Begin:
  if (Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount>0 && !owner.region.zone.bWaterZone) Fire(0.0);
  if (Pawn(Owner).bAltFire!=0 && AmmoType.AmmoAmount>0 && !owner.region.zone.bWaterZone) AltFire(0.0);
  LoopAnim('Idle',0.2,0.9);
  bPointing=False;
  if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
    Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
  Disable('AnimEnd');
}

simulated function B227_SpawnShellCase()
{
	local LongUT_ShellCase s;
	local vector X,Y,Z;
	local float dir;

	GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);

	if ( PlayerViewOffset.Y >= 0 )
		dir = 1;
	else
		dir = -1;

	s = Spawn(class'LongUT_ShellCase',Owner, '', Owner.Location + CalcDrawOffset() + 30 * X + (0.4 * PlayerViewOffset.Y+5.0) * Y - Z * 5);
	if (s != none)
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.3+0.2)*dir*Y + (FRand()*0.3+1.0) * Z)*160);
}

defaultproperties
{
     AmmoName=Class'SevenB.SevenMiniammo'
     PickupAmmoCount=25
     shaketime=0.300000
     AIRating=0.950000
     DeathMessage="%k's %w converted %o into swiss cheese."
     InventoryGroup=7
     bAmbientGlow=False
     PickupMessage="You got the XP Chaingun."
     ItemName="ChainGun"
     RotationRate=(Yaw=0)
}
