//=============================================================================
// Enforcer
//=============================================================================
class Enforcer extends TournamentWeapon;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var() int hitdamage;
var  float AltAccuracy;
var Enforcer SlaveEnforcer;		// The left (second) Enforcer is a slave to the right.
var bool bIsSlave;
var bool bSetup;				// used for setting display properties
var bool bFirstFire, bBringingUp;
var() localized string DoubleName;
var() texture MuzzleFlashVariations[5];
var int DoubleSwitchPriority;

var travel bool B227_bDoubleEnforcer;

replication
{
	reliable if ( bNetOwner && (Role == ROLE_Authority) )
		SlaveEnforcer, bIsSlave, bBringingUp;

	reliable if (Role == ROLE_Authority)
		B227_bDoubleEnforcer;
}

function Destroyed()
{
	Super.Destroyed();
	if ( SlaveEnforcer != None )
		SlaveEnforcer.Destroy();
}

function AnimEnd()
{
	/*-if ( (Level.NetMode == NM_Client) && bBringingUp  && (Mesh != PickupViewMesh) )
	{
		bBringingUp = false;
		PlaySelect();
	}
	else
	*/
	Super.AnimEnd();
}

function bool WeaponSet(Pawn Other)
{
	if ( bIsSlave )
		return false;
	else
		Super.WeaponSet(Other);
}

function SetSwitchPriority(pawn Other)
{
	local int i;

	if ( PlayerPawn(Other) != None )
	{
		Super.SetSwitchPriority(Other);

		// also set double switch priority

		for (i = 0; i < ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
			if ( PlayerPawn(Other).WeaponPriority[i] == 'DoubleEnforcer' )
			{
				DoubleSwitchPriority = i;
				return;
			}
	}
}

// Return the switch priority of the weapon (normally AutoSwitchPriority, but may be
// modified by environment (or by other factors for bots)
function float SwitchPriority()
{
	local int bTemp;

	if ( bIsSlave )
		return -10;
	if ( !Owner.IsA('PlayerPawn') )
		return RateSelf(bTemp);
	else if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
	{
		if ( Pawn(Owner).Weapon == self )
			return -0.5;
		else
			return -1;
	}
	else if ( SlaveEnforcer != None )
		return DoubleSwitchPriority;
	else
		return AutoSwitchPriority;
}

function DropFrom(vector StartLocation)
{
	if (!SetLocation(StartLocation))
		return;
	if (SlaveEnforcer != none)
	{
		if (B227_CanDropSlaveEnforcer() && Owner != none)
			B227_DropSlaveEnforcer();
		else
			SlaveEnforcer.Destroy();

		SlaveEnforcer = none;
	}
	AIRating = default.AIRating;
	B227_bDoubleEnforcer = false;
	PickupViewScale = default.PickupViewScale;
	super.DropFrom(StartLocation);
}

function SetDisplayProperties(ERenderStyle NewStyle, texture NewTexture, bool bLighting, bool bEnviroMap )
{
	if ( !bSetup )
	{
		bSetup = true;
		if ( SlaveEnforcer != None )
			SlaveEnforcer.SetDisplayProperties(NewStyle, NewTexture, bLighting, bEnviromap);
		bSetup = false;
	}
	Super.SetDisplayProperties(NewStyle, NewTexture, bLighting, bEnviromap);
}

function SetDefaultDisplayProperties()
{
	if ( !bSetup )
	{
		bSetup = true;
		if ( SlaveEnforcer != None )
			SlaveEnforcer.SetDefaultDisplayProperties();
		bSetup = false;
	}
	Super.SetDefaultDisplayProperties();
}

event float BotDesireability(Pawn Bot)
{
	local Enforcer AlreadyHas;
	local float desire;

	desire = MaxDesireability + Bot.AdjustDesireFor(self);
	AlreadyHas = Enforcer(Bot.FindInventoryType(class));
	if ( AlreadyHas != None )
	{
		if ( (!bHeldItem || bTossedOut) && bWeaponStay )
			return 0;
		if ( AlreadyHas.SlaveEnforcer != None )
		{
			if ( (RespawnTime < 10)
				&& ( bHidden || (AlreadyHas.AmmoType == None)
					|| (AlreadyHas.AmmoType.AmmoAmount < AlreadyHas.AmmoType.MaxAmmo)) )
				return 0;
			if ( AlreadyHas.AmmoType == None )
				return 0.25 * desire;

			if ( AlreadyHas.AmmoType.AmmoAmount > 0 )
				return FMax( 0.25 * desire,
						AlreadyHas.AmmoType.MaxDesireability
						 * FMin(1, 0.15 * AlreadyHas.AmmoType.MaxAmmo/AlreadyHas.AmmoType.AmmoAmount) );
		}
	}
	if ( (Bot.Weapon == None) || (Bot.Weapon.AIRating <= 0.4) )
		return 2*desire;

	return desire;
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local UT_Shellcase s;
	local vector FireLoc;

	FireLoc = Owner.Location + CalcDrawOffset();
	s = Spawn(class'UT_ShellCase',, '', FireLoc + 20 * X + FireOffset.Y * Y + Z);
	if ( s != None )
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);

	if (B227_ShouldTraceFireThroughWarpZones())
		B227_WarpedTraceFire(self, B227_FireStartTrace, B227_FireEndTrace, 8, Other, HitLocation, HitNormal, X);

	if (Other == Level)
	{
		if ( bIsSlave || (SlaveEnforcer != None) )
			Spawn(class'UT_LightWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
		else
			Spawn(class'UT_WallHit',,, HitLocation+HitNormal, Rotator(HitNormal));
	}
	else if ((Other != self) && (Other != Owner) && (Other != None) )
	{
		if ( FRand() < 0.2 )
			X *= 5;
		Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 3000.0*X, MyDamageType);
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
		else
			Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);
	}
}

function bool HandlePickupQuery(Inventory Item)
{
	local Pawn P;
	local Enforcer Copy;

	if (Item.Class == Class && SlaveEnforcer == none)
	{
		P = Pawn(Owner);
		// spawn a double
		Copy = Item.Spawn(Class, P);
		if (Copy != none)
		{
			Copy.RespawnTime = 0;
			Copy.bHeldItem = true;
			Copy.AmbientGlow = 0;
			Copy.PickupAmmoCount = Weapon(Item).PickupAmmoCount;
			Copy.Instigator = Instigator;
			Copy.BecomeItem();
			ItemName = DoubleName;
			SlaveEnforcer = Copy;
			SetTwoHands();
			AIRating = 0.4;
			SlaveEnforcer.SetUpSlave(P.Weapon == self);
			SlaveEnforcer.SetDisplayProperties(Style, Texture, bUnlit, bMeshEnviromap);
			SetTwoHands();
			class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(P, class'PickupMessagePlus', 0, none, none, self.Class);
			Copy.PlaySound(Item.PickupSound);

			if (Level.Game.LocalLog != none)
				Level.Game.LocalLog.LogPickup(Item, P);
			if (Level.Game.WorldLog != none)
				Level.Game.WorldLog.LogPickup(Item, P);

			if (!Level.Game.ShouldRespawn(Item))
				Item.Destroy();
			else if (!Weapon(Item).bWeaponStay)
				Item.SetRespawn();

			return true;
		}
	}
	return super.HandlePickupQuery(Item);
}

function SetUpSlave(bool bBringUp)
{
	bIsSlave = true;
	ItemName = DoubleName;
	GiveAmmo(Pawn(Owner));
	AmbientGlow = 0;
	SetPhysics(PHYS_Trailer); // For playing sound from a proper location when the weapon is owned by other pawn
	if ( bBringUp )
		BringUp();
	else
		GotoState('Idle2');
}

function SetTwoHands()
{
	if (SlaveEnforcer == none)
		return;

	B227_bDoubleEnforcer = true;

	if (PlayerPawn(Owner) != none && PlayerPawn(Owner).Handedness == 2)
	{
		SetHand(2);
		return;
	}

	if (Mesh == mesh'AutoML')
		SetHand(1);
	else
		SetHand(-1);
}

function SetHand(float Hand)
{
	if (Hand == 2)
	{
		bHideWeapon = true;
		super.SetHand(Hand);
		return;
	}

	if (SlaveEnforcer != none)
	{
		if (Hand == 0)
			Hand = -1;
		SlaveEnforcer.SetHand(-1 * Hand);
	}
	bHideWeapon = false;
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh'AutoML';
	else
		Mesh = mesh'AutoMR';
}

function BringUp()
{
	if (SlaveEnforcer != none )
	{
		SetTwoHands();
		SlaveEnforcer.BringUp();
	}
	bBringingUp = true;
	Super.BringUp();
}

function TraceFire( float Accuracy )
{
	local vector RealOffset;

	RealOffset = FireOffset;
	FireOffset *= 0.35;
	if ( (SlaveEnforcer != None) || bIsSlave )
		Accuracy = FClamp(3*Accuracy,0.75,3);
	else if ( Bot(Owner) != none && !Bot(Owner).bNovice )
		Accuracy = FMax(Accuracy, 0.45);

	Super.TraceFire(Accuracy);
	FireOffset = RealOffset;
}

function Fire(float Value)
{
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
		GotoState('NormalFire');
		bCanClientFire = true;
		bPointing=True;
		ClientFire(value);
		if ( SlaveEnforcer != None )
			Pawn(Owner).PlayRecoil(2 * FiringSpeed);
		else if ( !bIsSlave )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		TraceFire(0.2);
	}
}

function PlayFiring()
{
	PlaySound(FireSound, SLOT_None,2.0*Pawn(Owner).SoundDampening);
	bMuzzleFlash++;
	PlayAnim('Shoot',0.5 + 0.31 * FireAdjust, 0.02);
}

function PlayAltFiring()
{
	PlayAnim('T1', 1.3, 0.05);
	bFirstFire = true;
}

function PlayRepeatFiring()
{
	if ( Affector != None )
		Affector.FireEffect();
	if ( PlayerPawn(Owner) != None )
	{
		PlayerPawn(Owner).ClientInstantFlash( -0.2, vect(325, 225, 95));
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	}
	bMuzzleFlash++;
	PlaySound(FireSound, SLOT_None,2.0*Pawn(Owner).SoundDampening);
	PlayAnim('Shot2', 0.7 + 0.3 * FireAdjust, 0.05);
}

function AltFire( float Value )
{
	bPointing=True;
	bCanClientFire = true;
	AltAccuracy = 0.4;
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.AmmoAmount>0)
	{
		if ( SlaveEnforcer != None )
			Pawn(Owner).PlayRecoil(3 * FiringSpeed);
		else if ( !bIsSlave )
			Pawn(Owner).PlayRecoil(1.5 * FiringSpeed);
		ClientAltFire(value);
		GotoState('AltFiring');
	}
}

state Active
{
	function bool PutDown()
	{
		if ( bWeaponUp || (AnimFrame < 0.75) )
			GotoState('DownWeapon');
		else
			bChangeWeapon = true;
		return True;
	}

	function BeginState()
	{
		bChangeWeapon = false;
	}

	function EndState()
	{
		Super.EndState();
		bBringingUp = false;
	}

Begin:
	FinishAnim();
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	bWeaponUp = True;
	bCanClientFire = true;
	Finish();
}

State DownWeapon
{
ignores Fire, AltFire, Animend;

	function BeginState()
	{
		Super.BeginState();
		if ( Slaveenforcer != none )
			Slaveenforcer.GoToState('DownWeapon');
	}
}

////////////////////////////////////////////////////////
state NormalFire
{
ignores Fire, AltFire, AnimEnd;

	function Timer()
	{
		if ( SlaveEnforcer != none )
			SlaveEnforcer.Fire(0);
	}

	function EndState()
	{
		Super.EndState();
		OldFlashCount = FlashCount;
	}

Begin:
	FlashCount++;
	if ( SlaveEnforcer != none )
		SetTimer(0.20, false);
	FinishAnim();
	if ( bIsSlave )
		GotoState('Idle');
	else
		Finish();
}

/* Weapon's client states are removed in this conversion
state ClientFiring
{
	simulated function bool ClientAltFire(float Value)
	{
		if ( bIsSlave )
			Global.ClientAltFire(Value);
		return false;
	}

	simulated function Timer()
	{
		if ( (SlaveEnforcer != none) && SlaveEnforcer.ClientFire(0) )
			return;
		SetTimer(0.5, false);
	}

	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None) || (Ammotype.AmmoAmount <= 0) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bIsSlave && !bCanClientFire )
			GotoState('');
		else if ( bFirstFire || (Pawn(Owner).bAltFire != 0) )
		{
			PlayRepeatFiring();
			bFirstFire = false;
		}
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}

	simulated function BeginState()
	{
		Super.BeginState();
		if ( SlaveEnforcer != None )
			SetTimer(0.2, false);
		else
			SetTimer(0.5, false);
	}

	simulated function EndState()
	{
		Super.EndState();
		if ( SlaveEnforcer != None )
			SlaveEnforcer.GotoState('');
	}
}

state ClientAltFiring
{
	simulated function bool ClientFire(float Value)
	{
		if ( bIsSlave )
			Global.ClientFire(Value);
		return false;
	}

	simulated function Timer()
	{
		if ( (SlaveEnforcer != none) && SlaveEnforcer.ClientAltFire(0) )
			return;
		SetTimer(0.5, false);
	}

	simulated function AnimEnd()
	{
		if ( Pawn(Owner) == None )
			GotoState('');
		else if ( Ammotype.AmmoAmount <= 0 )
		{
			PlayAnim('T2', 0.9, 0.05);
			GotoState('');
		}
		else if ( !bIsSlave && !bCanClientFire )
			GotoState('');
		else if ( bFirstFire || (Pawn(Owner).bAltFire != 0) )
		{
			PlayRepeatFiring();
			bFirstFire = false;
		}
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else
		{
			PlayAnim('T2', 0.9, 0.05);
			GotoState('');
		}
	}

	simulated function BeginState()
	{
		Super.BeginState();
		if ( SlaveEnforcer != None )
			SetTimer(0.2, false);
		else
			SetTimer(0.5, false);
	}

	simulated function EndState()
	{
		Super.EndState();
		if ( SlaveEnforcer != None )
			SlaveEnforcer.GotoState('');
	}
}
*/

state AltFiring
{
ignores Fire, AltFire, AnimEnd;

	function Timer()
	{
		if ( Slaveenforcer != none )
			Slaveenforcer.AltFire(0);
	}

	function EndState()
	{
		Super.EndState();
		OldFlashCount = FlashCount;
	}

Begin:
	if ( SlaveEnforcer != none )
		SetTimer(0.20, false);
	FinishAnim();
Repeater:
	if (AmmoType.UseAmmo(1))
	{
		FlashCount++;
		if ( SlaveEnforcer != None )
			Pawn(Owner).PlayRecoil(3 * FiringSpeed);
		else if ( !bIsSlave )
			Pawn(Owner).PlayRecoil(1.5 * FiringSpeed);
		TraceFire(AltAccuracy);
		PlayRepeatFiring();
		FinishAnim();
	}

	if ( AltAccuracy < 3 )
		AltAccuracy += 0.5;
	if ( bIsSlave )
	{
		if ( (Pawn(Owner).bAltFire!=0)
			&& AmmoType.AmmoAmount>0 )
			Goto('Repeater');
	}
	else if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( (Pawn(Owner).bAltFire!=0)
		&& AmmoType.AmmoAmount>0 )
	{
		if ( PlayerPawn(Owner) == None )
			Pawn(Owner).bAltFire = int( FRand() < AltReFireRate );
		Goto('Repeater');
	}
	PlayAnim('T2', 0.9, 0.05);
	FinishAnim();
	Finish();
}

simulated event RenderOverlays(canvas Canvas)
{
	local PlayerPawn PlayerOwner;
	local int realhand;

	B227_AdjustSlaveDisplayProperties();

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
			else if ( bIsSlave || (SlaveEnforcer != None) )
				PlayerOwner.Handedness = -1;
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
	if ( !bHideWeapon && ( (SlaveEnforcer != None) || bIsSlave ) )
	{
		if ( PlayerOwner == None )
			bMuzzleFlash = 0;

		Super.RenderOverlays(Canvas);
		if ( SlaveEnforcer != None )
		{
			if ( SlaveEnforcer.bBringingUp )
			{
				SlaveEnforcer.bBringingUp = false;
				SlaveEnforcer.PlaySelect();
			}
			SlaveEnforcer.RenderOverlays(Canvas);
		}
	}
	else
		Super.RenderOverlays(Canvas);

	if ( PlayerOwner != None )
		PlayerOwner.Handedness = realhand;
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

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

Begin:
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	//- LoopAnim('Sway',0.2, 0.1);
	// B227 note: Calling PlayAnim right after LoopAnim doesn't work in net game
	AnimSequence = '';
	if ( Pawn(Owner).bFire!=0 ) Global.Fire(0.0);
	if ( Pawn(Owner).bAltFire!=0 ) Global.AltFire(0.0);
	if (AnimSequence == '')
		LoopAnim('Sway', 0.2, 0.1);
}

/*
State ClientActive
{
	simulated function AnimEnd()
	{
		bBringingUp = false;
		if ( !bIsSlave )
		{
			Super.AnimEnd();
			if ( (SlaveEnforcer != None) && !IsInState('ClientActive') )
			{
				if ( (GetStateName() == 'None') || (GetStateName() == 'Enforcer') )
					SlaveEnforcer.GotoState('');
				else
					SlaveEnforcer.GotoState(GetStateName());
			}
		}
	}

	simulated function BeginState()
	{
		Super.BeginState();
		bBringingUp = false;
		if ( SlaveEnforcer != None )
			SlaveEnforcer.GotoState('ClientActive');
	}
}

State ClientDown
{
	simulated function AnimEnd()
	{
		if ( !bIsSlave )
			Super.AnimEnd();
	}

	simulated function EndState()
	{
		if ( SlaveEnforcer != None )
			SlaveEnforcer.GotoState('');
	}
}
*/

event TravelPostAccept()
{
	local Enforcer Copy;

	super.TravelPostAccept();

	if (B227_bDoubleEnforcer)
	{
		// spawn a double
		Copy = Spawn(Class, Owner);
		if (Copy != none)
		{
			Copy.PickupAmmoCount = 0;
			Copy.BecomeItem();
			ItemName = DoubleName;
			SlaveEnforcer = Copy;
			SetTwoHands();
			AIRating = 0.4;
			SlaveEnforcer.SetUpSlave(Pawn(Owner).Weapon == self);
			SlaveEnforcer.SetDisplayProperties(Style, Texture, bUnlit, bMeshEnviromap);
			SetTwoHands();
		}
	}
}

static function bool B227_CanDropSlaveEnforcer()
{
	return
		class'B227_Config'.default.bEnableExtensions &&
		class'B227_Config'.default.bDroppableSlaveEnforcer;
}

function B227_DropSlaveEnforcer()
{
	local vector X, Y, Z;
	local int AmmoAmount;

	if (AmmoType != none)
		AmmoAmount = AmmoType.AmmoAmount;
	SlaveEnforcer.bIsSlave = false;
	SlaveEnforcer.ItemName = ItemName;
	SlaveEnforcer.Velocity = Velocity;
	SlaveEnforcer.bTossedOut = bTossedOut;
	SlaveEnforcer.SetRotation(Rotation);

	GetAxes(Owner.Rotation, X, Y, Z);
	SlaveEnforcer.DropFrom(Owner.Location + 0.8 * Owner.CollisionRadius * X + 0.5 * Owner.CollisionRadius * Y);
	SlaveEnforcer.SetOwner(none);

	if (!SlaveEnforcer.IsInState('PickUp'))
		SlaveEnforcer.Destroy();
	else if (AmmoType != none)
	{
		SlaveEnforcer.PickupAmmoCount = AmmoAmount - AmmoAmount / 2;
		AmmoType.AmmoAmount = AmmoAmount / 2;
	}
}

simulated function B227_AdjustSlaveDisplayProperties()
{
	if (SlaveEnforcer != none)
	{
		if (bMeshEnviroMap == default.bMeshEnviroMap)
			SlaveEnforcer.bMeshEnviroMap = SlaveEnforcer.default.bMeshEnviroMap;
		else
			SlaveEnforcer.bMeshEnviroMap = bMeshEnviroMap;

		if (bUnlit == default.bUnlit)
			SlaveEnforcer.bUnlit = SlaveEnforcer.default.bUnlit;
		else
			SlaveEnforcer.bUnlit = bUnlit;

		if (ScaleGlow == default.ScaleGlow)
			SlaveEnforcer.ScaleGlow = SlaveEnforcer.default.ScaleGlow;
		else
			SlaveEnforcer.ScaleGlow = ScaleGlow;

		if (Style == default.Style)
			SlaveEnforcer.Style = SlaveEnforcer.default.Style;
		else
			SlaveEnforcer.Style = Style;

		if (Texture == default.Texture)
			SlaveEnforcer.Texture = SlaveEnforcer.default.Texture;
		else
			SlaveEnforcer.Texture = Texture;
	}
}

// End Class
//=============================================================================

defaultproperties
{
	hitdamage=17
	DoubleName="Double Enforcer"
	MuzzleFlashVariations(0)=Texture'Botpack.Skins.Muz1'
	MuzzleFlashVariations(1)=Texture'Botpack.Skins.Muz2'
	MuzzleFlashVariations(2)=Texture'Botpack.Skins.Muz3'
	MuzzleFlashVariations(3)=Texture'Botpack.Skins.Muz4'
	MuzzleFlashVariations(4)=Texture'Botpack.Skins.Muz5'
	DoubleSwitchPriority=2
	WeaponDescription="Classification: Light Pistol\n\nPrimary Fire: Accurate but slow firing instant hit.\n\nSecondary Fire: Sideways, or 'Gangsta' firing mode, shoots twice as fast and half as accurate as the primary fire.\n\nTechniques: Collect two for twice the damage."
	InstFlash=-0.200000
	InstFog=(X=325.000000,Y=225.000000,Z=95.000000)
	AmmoName=Class'Botpack.Miniammo'
	PickupAmmoCount=30
	bInstantHit=True
	bAltInstantHit=True
	FiringSpeed=1.500000
	FireOffset=(Y=-10.000000,Z=-4.000000)
	MyDamageType=shot
	shakemag=200.000000
	shakevert=4.000000
	AIRating=0.250000
	RefireRate=0.800000
	AltRefireRate=0.870000
	FireSound=Sound'Botpack.enforcer.E_Shot'
	AltFireSound=Sound'UnrealShare.AutoMag.shot'
	CockingSound=Sound'Botpack.enforcer.Cocking'
	SelectSound=Sound'Botpack.enforcer.Cocking'
	DeathMessage="%k riddled %o full of holes with the %w."
	NameColor=(R=200,G=200)
	bDrawMuzzleFlash=True
	MuzzleScale=1.000000
	FlashY=0.100000
	FlashO=0.020000
	FlashC=0.035000
	FlashLength=0.020000
	FlashS=128
	MFTexture=Texture'Botpack.Skins.Muz1'
	AutoSwitchPriority=2
	InventoryGroup=2
	PickupMessage="You picked up another Enforcer!"
	ItemName="Enforcer"
	PlayerViewOffset=(X=3.300000,Y=-2.000000,Z=-3.000000)
	PlayerViewMesh=LodMesh'Botpack.AutoML'
	PickupViewMesh=LodMesh'Botpack.MagPick'
	ThirdPersonMesh=LodMesh'Botpack.AutoHand'
	StatusIcon=Texture'Botpack.Icons.UseAutoM'
	bMuzzleFlashParticles=True
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'Botpack.muzzEF3'
	MuzzleFlashScale=0.080000
	MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy2'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Icon=Texture'Botpack.Icons.UseAutoM'
	bHidden=True
	Mesh=LodMesh'Botpack.MagPick'
	bNoSmooth=False
	CollisionRadius=24.000000
	CollisionHeight=12.000000
	Mass=15.000000
}
