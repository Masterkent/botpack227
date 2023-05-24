//=============================================================================
// ChainSaw.
//=============================================================================
class ChainSaw extends TournamentWeapon;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var() float Range;
var() sound HitSound, DownSound;
var Playerpawn LastHit;

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;

	bUseAltMode = 0;

	if ( (Pawn(Owner) == None) || (Pawn(Owner).Enemy == None) )
		return 0;

	EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	if ( EnemyDist > 400 )
		return -2;

	if ( EnemyDist < 110 )
		bUseAltMode = 1;

	return ( FMin(1.0, 81/(EnemyDist + 1)) );
}

function float SuggestAttackStyle()
{
	return 1.0;
}

function float SuggestDefenseStyle()
{
	return -0.7;
}

function Fire( float Value )
{
	GotoState('NormalFire');
	bPointing=True;
	bCanClientFire = true;
	Pawn(Owner).PlayRecoil(FiringSpeed);
	ClientFire(value);
	TraceFire(0.0);
}

function PlayFiring()
{
	LoopAnim( 'Jab2', 0.7, 0.0 );
	AmbientSound = HitSound;
	SoundVolume = 255 * B227_SoundDampening();
}

function AltFire( float Value )
{
	GotoState('AltFiring');
	Pawn(Owner).PlayRecoil(FiringSpeed);
	bCanClientFire = true;
	bPointing=True;
	ClientAltFire(value);
}

function PlayAltFiring()
{
	PlayAnim( 'Swipe', 0.6 );
	AmbientSound = HitSound;
	SoundVolume = 255 * B227_SoundDampening();
}

function EndAltFiring()
{
	AmbientSound = Sound'Botpack.ChainIdle';
	SoundVolume = default.SoundVolume * B227_SoundDampening();
	TweenAnim('Idle', 1.0);
}


state NormalFire
{
	ignores AnimEnd;

	function BeginState()
	{
		Super.BeginState();
		AmbientSound = HitSound;
		SoundVolume = 255 * B227_SoundDampening();
	}

	function EndState()
	{
		AmbientSound = Sound'Botpack.ChainIdle';
		Super.EndState();
		SoundVolume = Default.SoundVolume * B227_SoundDampening();
	}

Begin:
	Sleep(0.15);
	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	SoundVolume = 255 * B227_SoundDampening();
	TraceFire(0.0);
	Sleep(0.15);
	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	if ( LastHit != None )
	{
		LastHit.ClientFlash( -0.38, vect(530, 90, 90));
		LastHit.ShakeView(0.25, 600, 6);
	}
	if ( Pawn(Owner).bFire == 0 )
		Finish();
	Goto('Begin');
}

/* Weapon's client states are removed in this conversion
////////////////////////////////////////////////////////
state ClientFiring
{
	simulated function EndState()
	{
		AmbientSound = Sound'Botpack.ChainIdle';
		Super.EndState();
		SoundVolume = Default.SoundVolume;
	}
}

state ClientAltFiring
{
	simulated function AnimEnd()
	{
		if ( AnimSequence != 'Idle' )
		{
			EndAltFiring();
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner) == None )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else if ( Pawn(Owner).bAltFire != 0 )
			Global.ClientAltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}

	function EndState()
	{
		AmbientSound = Sound'Botpack.ChainIdle';
		Super.EndState();
		SoundVolume = Default.SoundVolume;
	}
}
*/

state AltFiring
{
	ignores AnimEnd;

	function Fire(float F)
	{
	}

	function AltFire(float F)
	{
	}

	function BeginState()
	{
		Super.BeginState();
		AmbientSound = HitSound;
		SoundVolume = 255 * B227_SoundDampening();
	}

	function EndState()
	{
		Super.EndState();
		AmbientSound = Sound'Botpack.ChainIdle';
		SoundVolume = Default.SoundVolume * B227_SoundDampening();
	}

Begin:
	AmbientSound = HitSound;
	Sleep(0.1);
	SoundVolume = 255 * B227_SoundDampening();
	FinishAnim();
	EndAltFiring();
	FinishAnim();
	Finish();
}

state Idle
{
	ignores animend;

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

Begin:
	bPointing=False;
	SoundVolume = default.SoundVolume * B227_SoundDampening();
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Pawn(Owner).bFire!=0 )
		Fire(0.0);
	if ( Pawn(Owner).bAltFire!=0 )
		AltFire(0.0);
	FinishAnim();
	AnimFrame=0;
	PlayIdleAnim();
	Goto('Begin');
}

function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		PlayAnim( 'Idle', 1.0, 0.0 );
}

// Finish a firing sequence
function Finish()
{
	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	if ( PlayerPawn(Owner) == None )
	{
		if ( (Pawn(Owner).bFire != 0) && (FRand() < RefireRate) )
			Global.Fire(0);
		else if ( (Pawn(Owner).bAltFire != 0) && (FRand() < AltRefireRate) )
			Global.AltFire(0);
		else
		{
			Pawn(Owner).StopFiring();
			GotoState('Idle');
		}
		return;
	}
	if ( Pawn(Owner).bFire!=0 )
		Global.Fire(0);
	else if ( Pawn(Owner).bAltFire!=0 )
		Global.AltFire(0);
	else
		GotoState('Idle');
}

function Slash()
{
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, AimError, False, False);
	EndTrace = Owner.Location + (Range * vector(AdjustedAim));
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if ( (Other == None) || (Other == Owner) || (Other == self) )
		return;

	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	Other.TakeDamage(110, Pawn(Owner), HitLocation, -10000.0 * Y, AltDamageType);
	if ( !Other.bIsPawn && !Other.IsA('Carcass') )
		spawn(class'SawHit',,,HitLocation+HitNormal, rotator(HitNormal));
}


function TraceFire(float accuracy)
{
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	LastHit = None;
	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);
	EndTrace = Owner.Location + (10 + Range) * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if ( (Other == None) || (Other == Owner) || (Other == self) )
		return;

	Other.TakeDamage(20.0, Pawn(Owner), HitLocation, -15000 * X, MyDamageType);
	if ( !Other.bIsPawn && !Other.IsA('Carcass') )
		spawn(class'SawHit',,,HitLocation+HitNormal, Rotator(HitNormal));
	else if ( Other.IsA('PlayerPawn') && (Pawn(Other).Health > 0) )
		LastHit = PlayerPawn(Other);
}


function PlayPostSelect()
{
	AmbientSound = Sound'Botpack.ChainIdle';
	SoundVolume = default.SoundVolume * B227_SoundDampening();
	/*-
	if ( Level.NetMode == NM_Client )
	{
		Super.PlayPostSelect();
		return;
	}
	*/
}


function TweenDown()
{
	Owner.PlaySound(DownSound, SLOT_None, 4.0 * Pawn(Owner).SoundDampening);
	Super.TweenDown();
	AmbientSound = None;
}

function setHand(float Hand)
{
	if (Hand > 0 && !class'B227_Config'.default.bChainSawAllowLeftHandedness)
		Hand = 0;
	super.setHand(Hand);
}

simulated function vector B227_PlayerViewOffset(Canvas Canvas)
{
	local vector ViewOffset;
	local float ScaleY;

	ViewOffset = PlayerViewOffset;
	if (B227_ViewOffsetMode() == 1 && class'B227_Config'.default.bChainSawFixWidescreenView)
	{
		ScaleY = Tan(Canvas.Viewport.Actor.FOVAngle * Pi / 360.0);
		ViewOffset.Y *= FMax(1.0, Square(ScaleY));
		if (ViewOffset.Y > 0)
		{
			ViewOffset.Y = FMin(ViewOffset.Y, Abs(default.PlayerViewOffset.Y * 100));
			ViewOffset.Y = FMax(ViewOffset.Y, PlayerViewOffset.Y * ScaleY);
		}
		else if (ViewOffset.Y < 0)
		{
			ViewOffset.Y = FMax(ViewOffset.Y, -Abs(default.PlayerViewOffset.Y * 100));
			ViewOffset.Y = FMin(ViewOffset.Y, PlayerViewOffset.Y * ScaleY);
		}
	}
	return ViewOffset;
}

defaultproperties
{
	Range=90.000000
	HitSound=Sound'Botpack.ChainSaw.SawHit'
	DownSound=Sound'Botpack.ChainSaw.ChainPowerDown'
	WeaponDescription="Classification: Melee Blade\n\nPrimary Fire: When the trigger is held down, the chain covered blade will rev up. Drive this blade into opponents to inflict massive damage.\n\nSecondary Fire: The revved up blade can be swung horizontally and can cause instant decapitation of foes.\n\nTechniques: The chainsaw makes a loud and recognizable roar and can be avoided by listening for audio cues."
	bMeleeWeapon=True
	bRapidFire=True
	FireOffset=(X=10.000000,Y=-2.500000,Z=5.000000)
	MyDamageType=slashed
	AltDamageType=Decapitated
	RefireRate=1.000000
	AltRefireRate=1.000000
	SelectSound=Sound'Botpack.ChainSaw.ChainPickup'
	DeathMessage="%k ripped into %o with a blood soaked %w."
	PickupMessage="Its been five years since I've seen one of these."
	ItemName="Chainsaw"
	PlayerViewOffset=(X=2.000000,Y=-1.100000,Z=-0.900000)
	PlayerViewMesh=LodMesh'Botpack.chainsawM'
	PickupViewMesh=LodMesh'Botpack.ChainSawPick'
	ThirdPersonMesh=LodMesh'Botpack.CSHand'
	StatusIcon=Texture'Botpack.Icons.UseSaw'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Icon=Texture'Botpack.Icons.UseSaw'
	Mesh=LodMesh'Botpack.ChainSawPick'
	bNoSmooth=False
	SoundVolume=100
}
