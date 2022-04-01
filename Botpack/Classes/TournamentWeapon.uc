//=============================================================================
// TournamentWeapon.
//=============================================================================
class TournamentWeapon extends UTC_Weapon
	abstract
	config(Botpack);

var TournamentPickup Affector;
var float FireAdjust;
var localized string WeaponDescription;
var float InstFlash;
var vector InstFog;
var bool bCanClientFire;
var bool bForceFire, bForceAltFire;
var() float FireTime, AltFireTime; //used to synch server and client firing up
var float FireStartTime;

var() globalconfig bool B227_bAdjustNPCFirePosition;
var() globalconfig bool B227_bTraceFireThroughWarpZones;
var() globalconfig bool B227_bUseEnergyAmplifier;

function ForceFire()
{
	Fire(0);
}

function ForceAltFire()
{
	AltFire(0);
}

function SetWeaponStay()
{
	if ( Level.NetMode != NM_Standalone && Level.Game.IsA('DeathMatchPlus') )
		bWeaponStay = bWeaponStay || DeathMatchPlus(Level.Game).bMultiWeaponStay;
	else
		bWeaponStay = bWeaponStay || Level.Game.bCoopWeaponMode;
}

// Finish a firing sequence
function Finish()
{
	local Pawn PawnOwner;
	local bool bForce, bForceAlt;

	bForce = bForceFire;
	bForceAlt = bForceAltFire;
	bForceFire = false;
	bForceAltFire = false;

	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	PawnOwner = Pawn(Owner);
	if ( PawnOwner == None )
		return;
	if ( PlayerPawn(Owner) == None )
	{
		if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		{
			PawnOwner.StopFiring();
			GotoState('Idle');
			PawnOwner.SwitchToBestWeapon();
			if ( bChangeWeapon )
				GotoState('DownWeapon');
		}
		else if ( (PawnOwner.bFire != 0) && (FRand() < RefireRate) )
			Global.Fire(0);
		else if ( (PawnOwner.bAltFire != 0) && (FRand() < AltRefireRate) )
			Global.AltFire(0);
		else 
		{
			PawnOwner.StopFiring();
			GotoState('Idle');
		}
		return;
	}
	if ( ((AmmoType != None) && (AmmoType.AmmoAmount<=0)) || (PawnOwner.Weapon != self) )
		GotoState('Idle');
	else if ( (PawnOwner.bFire!=0) || bForce )
		Global.Fire(0);
	else if ( (PawnOwner.bAltFire!=0) || bForceAlt )
		Global.AltFire(0);
	else 
		GotoState('Idle');
}

//
// Toss this item out.
//
function DropFrom(vector StartLocation)
{
	bCanClientFire = false;
	bSimulatedPawnRep = true;
	SimAnim.X = 0;
	SimAnim.Y = 0;
	SimAnim.Z = 0;
	SimAnim.W = 0;
	if ( !SetLocation(StartLocation) )
		return; 
	AIRating = Default.AIRating;
	bMuzzleFlash = 0;
	if ( AmmoType != None )
	{
		PickupAmmoCount = AmmoType.AmmoAmount;
		AmmoType.AmmoAmount = 0;
	}
	RespawnTime = 0.0; //don't respawn
	SetPhysics(PHYS_Falling);
	RemoteRole = ROLE_DumbProxy;
	BecomePickup();
	NetPriority = 2.5;
	bCollideWorld = true;
	if (Pawn(Owner) != none)
	{
		SetRotation(Pawn(Owner).ViewRotation);
		Pawn(Owner).DeleteInventory(self);
	}
	Inventory = None;
	GotoState('PickUp', 'Dropped');
}

simulated function ClientPutDown()
{
	if (Level.NetMode == NM_Client)
	{
		bCanClientFire = false;
		bMuzzleFlash = 0;
		TweenDown();
		GotoState('ClientDown');
	}
}

function TweenToStill()
{
	TweenAnim('Still', 0.1);
}

function BecomeItem()
{
	local Bot B;
	local Pawn P;

	Super.BecomeItem();
	B = Bot(Instigator);
	if ( (B != None) && B.bNovice && (B.Skill < 2) )
		FireAdjust = B.Skill * 0.5;
	else
		FireAdjust = 1.0;

	if (B227_ShouldAdjustNPCFirePosition() && Instigator != none && PlayerPawn(Instigator) == none)
		B227_AdjustNPCFirePosition();

	if ( (B != None) || Level.Game.bTeamGame || !Level.Game.IsA('DeathMatchPlus')
		|| DeathMatchPlus(Level.Game).bNoviceMode
		|| (DeathMatchPlus(Level.Game).NumBots > 4) )
		return;

	// let high skill bots hear pickup if close enough
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		B = Bot(p);
		if ( (B != None)
			&& (VSize(B.Location - Instigator.Location) < 800 + 100 * B.Skill) )
		{
			B.HearPickup(Instigator);
			return;
		}
	}
}

// [U227] Excluded
///simulated function AnimEnd()
///{
///	if ( (Level.NetMode == NM_Client) && (Mesh != PickupViewMesh) )
///		PlayIdleAnim();
///}

simulated function ForceClientFire()
{
	ClientFire(0);
}

simulated function ForceClientAltFire()
{
	ClientAltFire(0);
}

function bool ClientFire( float Value )
{
	if (PlayerPawn(Owner) != none)
	{
		if ( InstFlash != 0.0 )
			PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	}
	if ( Affector != None )
		Affector.FireEffect();
	PlayFiring();
	return true;
}

function Fire( float Value )
{
	if ( (AmmoType == None) && (AmmoName != None) )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
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
	}
}

function bool ClientAltFire( float Value )
{
	if (PlayerPawn(Owner) != none)
	{
		if ( InstFlash != 0.0 )
			PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	}
	if ( Affector != None )
		Affector.FireEffect();
	PlayAltFiring();
	return true;
}

function AltFire( float Value )
{
	if ( (AmmoType == None) && (AmmoName != None) )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1))
	{
		GotoState('AltFiring');
		bPointing=True;
		bCanClientFire = true;
		ClientAltFire(Value);
		if ( bRapidFire || (FiringSpeed > 0) )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		if ( bAltInstantHit )
			TraceFire(0.0);
		else
			ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
	}
}


function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',1.0,0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);
}

function PlayPostSelect()
{
	/*
	if ( Level.NetMode == NM_Client )
	{
		if ( (bForceFire || (PlayerPawn(Owner).bFire != 0)) && Global.ClientFire(0) )
			return;
		else if ( (bForceAltFire || (PlayerPawn(Owner).bAltFire != 0)) && Global.ClientAltFire(0) )
			return;
		GotoState('');
		AnimEnd();
	}
	*/
}

function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else
		PlayAnim('Down', 1.0, 0.05);
}

function PlayIdleAnim()
{
}

simulated function Landed(vector HitNormal)
{
	local rotator newRot;

	newRot = Rotation;
	newRot.pitch = 0;
	SetRotation(newRot);
}

function bool HandlePickupQuery( inventory Item )
{
	local int OldAmmo;
	local Pawn P;

	if (Item.Class == Class)
	{
		if ( Weapon(item).bWeaponStay && (!Weapon(item).bHeldItem || Weapon(item).bTossedOut) )
			return true;
		P = Pawn(Owner);
		if ( AmmoType != None )
		{
			OldAmmo = AmmoType.AmmoAmount;
			if ( AmmoType.AddAmmo(Weapon(Item).PickupAmmoCount) && (OldAmmo == 0) 
				&& (P.Weapon.class != item.class) && !P.bNeverSwitchOnPickup )
					WeaponSet(P);
		}
		class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(P, class'PickupMessagePlus', 0, none, none, self.Class);
		Item.PlaySound(Item.PickupSound);
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
		Item.SetRespawn();   
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

auto state Pickup
{
	ignores AnimEnd;

	// Landed on ground.
	simulated function Landed(Vector HitNormal)
	{
		local rotator newRot;

		newRot = Rotation;
		newRot.pitch = 0;
		SetRotation(newRot);
		if ( Role == ROLE_Authority )
		{
			bSimulatedPawnRep = false;
			SetTimer(2.0, false);
		}
	}
}

state ClientFiring
{
	simulated function bool ClientFire(float Value)
	{
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		return false;
	}

	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None)
			|| ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
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

	simulated function EndState()
	{
		AmbientSound = None;
	}
}

state ClientAltFiring
{
	simulated function bool ClientFire(float Value)
	{
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		return false;
	}
	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None)
			|| ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
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

	simulated function EndState()
	{
		AmbientSound = None;
	}
}

///////////////////////////////////////////////////////
state NormalFire
{
	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function Fire(float F) 
	{
	}
	function AltFire(float F) 
	{
	}

	function AnimEnd()
	{
		Finish();
	}

Begin:
	Sleep(0.0);
}

////////////////////////////////////////////////////////
state AltFiring
{
	function Fire(float F) 
	{
	}

	function AltFire(float F) 
	{
	}

	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function AnimEnd()
	{
		Finish();
	}

Begin:
	Sleep(0.0);
}

state Active
{
	ignores animend;

	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function EndState()
	{
		Super.EndState();
		bForceFire = false;
		bForceAltFire = false;
	}

Begin:
	FinishAnim();
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	bWeaponUp = True;
	PlayPostSelect();
	FinishAnim();
	bCanClientFire = true;
	Finish();
}

State ClientActive
{
	simulated function ForceClientFire()
	{
		Global.ClientFire(0);
	}

	simulated function ForceClientAltFire()
	{
		Global.ClientAltFire(0);
	}

	simulated function bool ClientFire(float Value)
	{
		bForceFire = true;
		return bForceFire;
	}

	simulated function bool ClientAltFire(float Value)
	{
		bForceAltFire = true;
		return bForceAltFire;
	}

	simulated function AnimEnd()
	{
		if ( Owner == None )
		{
			Global.AnimEnd();
			GotoState('');
		}
		else if (PlayerPawn(Owner) != none && PlayerPawn(Owner).PendingWeapon != none)
			GotoState('ClientDown');
		else if ( bWeaponUp )
		{
			if ( (bForceFire || (PlayerPawn(Owner).bFire != 0)) && Global.ClientFire(0) )
				return;
			else if ( (bForceAltFire || (PlayerPawn(Owner).bAltFire != 0)) && Global.ClientAltFire(0) )
				return;
			PlayIdleAnim();
			GotoState('');
		}
		else
		{
			PlayPostSelect();
			bWeaponUp = true;
		}
	}

	simulated function BeginState()
	{
		bForceFire = false;
		bForceAltFire = false;
		bWeaponUp = false;
		PlaySelect();
	}

	simulated function EndState()
	{
		bForceFire = false;
		bForceAltFire = false;
	}
}

State ClientDown
{
	simulated function ForceClientFire()
	{
		Global.ClientFire(0);
	}

	simulated function ForceClientAltFire()
	{
		Global.ClientAltFire(0);
	}

	simulated function bool ClientFire(float Value)
	{
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		return false;
	}

	simulated function Tick(float DeltaTime)
	{
	}
		
	simulated function AnimEnd()
	{
		GotoState('');
	}

	simulated function BeginState()
	{
		Disable('Tick');
	}
}

State DownWeapon
{
ignores Fire, AltFire, AnimEnd;

	function BeginState()
	{
		Super.BeginState();
		bCanClientFire = false;
	}
}


function float B227_AmplifyDamage(int UseCharge)
{
	local Amplifier Amp;

	Amp = B227_FindActiveAmplifier();
	if (Amp != none)
		return Amp.UseCharge(UseCharge);
	return 1;
}

static function bool B227_ShouldAdjustNPCFirePosition()
{
	return class'B227_Config'.default.bEnableExtensions && default.B227_bAdjustNPCFirePosition;
}

static function bool B227_ShouldTraceFireThroughWarpZones()
{
	return class'B227_Config'.default.bEnableExtensions && default.B227_bTraceFireThroughWarpZones;
}

static function bool B227_ShouldUseEnergyAmplifier()
{
	return class'B227_Config'.default.bEnableExtensions && default.B227_bUseEnergyAmplifier;
}

function B227_AdjustNPCFirePosition();

// Auxiliary
function Amplifier B227_FindActiveAmplifier()
{
	local Inventory Inv;
	local int i;

	if (Pawn(Owner) == none)
		return none;
	for (Inv = Owner.Inventory; Inv != none && i < 1000; Inv = Inv.Inventory)
	{
		if (Inv.bActive && Amplifier(Inv) != none)
			return Amplifier(Inv);
		++i;
	}
	return none;
}

function class<Actor> B227_BotpackVersionClass()
{
	return class'Botpack.B227_Version'; // makes class B227_Version loaded
}


defaultproperties
{
	FireAdjust=1.000000
	MyDamageType=Unspecified
	AltDamageType=Unspecified
	PickupMessageClass=Class'Botpack.PickupMessagePlus'
	B227_bAdjustNPCFirePosition=True
	B227_bTraceFireThroughWarpZones=True
	B227_bUseEnergyAmplifier=True
}
