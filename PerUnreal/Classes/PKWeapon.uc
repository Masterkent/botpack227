//=============================================================================
// TournamentWeapon.
//=============================================================================
class PKWeapon extends UTC_Weapon
	abstract;

var TournamentPickup Affector;
var float FireAdjust;
var localized string WeaponDescription;
var float InstFlash;
var vector InstFog;
var bool bCanClientFire;
var bool bForceFire, bForceAltFire;
var() float FireTime, AltFireTime; //used to synch server and client firing up
var float FireStartTime;

Replication
{
	Reliable if ( bNetOwner && (Role == ROLE_Authority) )
		Affector, bCanClientFire;
}

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

//
// Toss this item out.
//
function DropFrom(vector StartLocation)
{
	bCanClientFire = false;
	bSimulatedPawnRep = true;
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
	if ( Pawn(Owner) != None )
		Pawn(Owner).DeleteInventory(self);
	Inventory = None;
	GotoState('PickUp', 'Dropped');
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

function AnimEnd()
{
	if ( (Level.NetMode == NM_Client) && (Mesh != PickupViewMesh) )
		PlayIdleAnim();
}

function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',1.0,0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening,,, Level.TimeDilation-0.1*FRand());
}

function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else
		PlayAnim('Down', 1.0, 0.05);
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
		class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(P, class'PickupMessagePlus', 0, None, None, Self.Class);
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

State DownWeapon
{
ignores Fire, AltFire, AnimEnd;

	function BeginState()
	{
		Super.BeginState();
		bCanClientFire = false;
	}
}

defaultproperties
{
}
