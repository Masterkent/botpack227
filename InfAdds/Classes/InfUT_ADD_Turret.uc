//=============================================================================
// INFUT_ADD_Turret.
//
// written by N.Bogenrieder (aka Beppo)
//=============================================================================
class INFUT_ADD_Turret expands INFUT_ADD_Decoration
	abstract;

var(Inf_T_Ammo) class<UT_ShellCase> AmmoBeltConnClass;	// type of BeltConnector to eject
var(Inf_T_Ammo) class<UT_ShellCase> AmmoShellCaseClass;	// type of ShellCase to eject
var(Inf_T_Ammo) vector EjectBeltConnOffset;				// vector offset for spawning BeltConnectors
var(Inf_T_Ammo) vector EjectShellCaseOffset;			// vector offset for spawning ShellCases
var(Inf_T_Ammo) vector FireProjectileOffset;			// vector offset for spawning Projectiles (normally only X-axis needed)
var(Inf_T_Ammo) class<INFUT_ADD_BallisticProj> ProjectileClass;			// Projectile used for 'tracer' shots (non-hidden)
var(Inf_T_Ammo) class<INFUT_ADD_BallisticHidden> ProjectileClassHidden;	// Projectile used for 'normal' shots (hidden)
var(Inf_T_Ammo) float TracerFrequency;					// percentage for the chance of firing a tracer

var(Inf_T_Control) bool bControlPitch;					// Controler controls the pitch-axis (up-down)
var(Inf_T_Control) bool bControlYaw;					// Controler controls the yaw-axis	(left-right)
var(Inf_T_Control) float maxPitch;						// maximum pitch
var(Inf_T_Control) float maxYaw;						// maximum yaw
var(Inf_T_Control) float minPitch;						// minimum pitch
var(Inf_T_Control) float minYaw;						// minimum yaw

var(Inf_T_Destroy) bool bDestroyable;					// is this Turret destroyable?
var(Inf_T_Destroy) class<Fragment> DetFragmentClass;	// FragmentClass used for detonation
var(Inf_T_Destroy) texture DetFragmentTexture;			// FragmentTexture used for detonation
var(Inf_T_Destroy) float MaxDamage;						// if yes, how much damage can it take?
var(Inf_T_Destroy) name DestroyEvent;				  	// Event to Trigger if destroyed

var(Inf_T_Firing) float	FiringRate;				// pause between EACH shot
var(Inf_T_Firing) float	SampleRate;				// how often we sample Instigator's viewrotation
var(Inf_T_Firing) int	TrackingRate;			// how fast Cannon reacts on Instigator's viewchange

var(Inf_T_Misc) localized string ActivateMessage;					// if activated send this message to cControler/Instigator
var(Inf_T_Misc) localized string NoAmmoMessage;						// if no ammo is left send this message to cControler/Instigator
var(Inf_T_Misc)	float ReactivateTime;								// time to sleep after ammo has run out
var(Inf_T_Misc) class<INFUT_ADD_TurretWeapon> TurretWeaponClass;	// Weapon that is added to pawns inventory (the Fake one)

var(Inf_T_ShakeView) bool bShakeView;
var(Inf_T_ShakeView) float ShakeMag;					//100
var(Inf_T_ShakeView) float ShakeTime;					//0.1
var(Inf_T_ShakeView) float ShakeVert;					//5

var(Inf_T_Sounds) sound Sound_Activate;			// sound played on activation
var(Inf_T_Sounds) sound Sound_EmptyClip;		// sound played when turret has no ammo left
var(Inf_T_Sounds) sound Sound_Exploding;		// sound played if turret was destroyed
var(Inf_T_Sounds) sound Sound_Firing;			// firing sound ! =)
var(Inf_T_Sounds) sound Sound_Reloading;		// sound played between EACH shot (for slow firing turrets only)
var(Inf_T_Sounds) float SoundVol_Activate;		// volume for sound played on activation
var(Inf_T_Sounds) float SoundVol_EmptyClip;		// volume for sound played when turret has no ammo left
var(Inf_T_Sounds) float SoundVol_Exploding;		// volume for sound played if turret was destroyed
var(Inf_T_Sounds) float SoundVol_Firing;		// volume for firing sound ! =) multiplied by Pawns SoundDampening
var(Inf_T_Sounds) float SoundVol_Reloading;		// volume for sound played between EACH shot (for slow firing turrets only)

// these following vars can be interpreted as some sort of automatic aiming error !!
var(Inf_T_ShakeMesh) bool bAffectPlayerView;	// if bShakeMesh enabled, should the playerview get kicked too?
var(Inf_T_ShakeMesh) bool bShakeMesh;			// should the Mesh/Turret shake or not
var(Inf_T_ShakeMesh) float ShakeMeshMultiplier;	// multiply the random float values with this factor (random float between 0 and 1)

var(Inf_T_Muzzle) class<CannonMuzzle> MuzzleEffectClass;	// spawn a firing effect if needed (using MuzzleOffset)
var(Inf_T_Muzzle) float MuzzleDrawScale;					// drawscale of the muzzle
var(Inf_T_Muzzle) vector MuzzleOffset;						// vector offset for displaying the MuzzleEffect

// INTERN USED !!
var actor			A;							// used only for triggering the EndEvent
var INFUT_ADD_TurretWeapon	FakeWeapon;			// The real TurretWeapon that is added to the pawns inventory
var pawn			cControler;					// current controler (a pawn)
var float			TimePassed;					// used for the firing rate
var float			TimeToCheck;				// also used for the firing rate
var bool			bShoot;						// is the turret able to shoot? (also used for firing rate)
var bool			bActive;					// is the turret under control or not
var bool 			bChkPitch, bChkYaw, bChkMinMax;	// internal used bool-vars for performance issues
var rotator			oRot;						// original Rotation of the Turret (for resetting multiplied rotations)
var bool			bEmptyClip;					// Turret has run out of ammo
var bool			bMessageSend;				// only display the activatemessage once !
var class<LocalMessage> ActivateMessageClass;	// the standard ActivateMessageClass for Inf_Turrets!
var class<LocalMessage> NoAmmoMessageClass;		// the standard NoAmmoMessageClass for Inf_Turrets!
var Actor 			MuzzFlash;	 				// The MuzzleEffect for firing
var bool			bReactivate;				// For Infiltration type games for reactivating the turrets after they were destroyed
												// (not yet implemented)
var int				cAmmoAmount;				// curent AmmoAmount left
var Inventory		Inv;						// used for deleteinventory

replication
{
	reliable if ( Role == Role_Authority && bNetOwner)
		cControler, FakeWeapon, MuzzFlash, bEmptyClip, bActive, bShoot, cAmmoAmount;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
    settimer(0.01, True);

	oRot = Rotation;
	cAmmoAmount = TurretWeaponClass.default.PickupAmmoCount;

	BuildMuzzle();

	if (ShakeMeshMultiplier <= 0.0)
		ShakeMeshMultiplier = default.ShakeMeshMultiplier;
	// just for performance...
	bChkMinMax = False;	bChkPitch = False; bChkYaw = False;
	if	(!bControlPitch)	{maxPitch = 0;	minPitch = 0;}
	if	(!bControlYaw)		{maxYaw = 0;	minYaw = 0;}
	if	(	(maxPitch != 0)
		||	(minPitch != 0) )
		bChkPitch = True;
	if	(	(maxYaw != 0)
		||	(minYaw != 0) )
		bChkYaw = True;
	if	( bChkPitch || bChkYaw )
		bChkMinMax = True;
}

function BuildMuzzle()
{
	if (MuzzFlash != None)
		return;
	// Spawn the MuzzleEffect and give all needed infos to it
	if (MuzzleEffectClass != None)
	{
		MuzzFlash = Spawn(MuzzleEffectClass);
		MuzzFlash.SetBase(self);
		if (MuzzleDrawScale <= 0.0) MuzzleDrawScale = default.MuzzleDrawScale;
		MuzzFlash.DrawScale = MuzzleDrawScale;
	}
}

function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
					Vector momentum, name damageType)
{
	local Pawn OldInstigator;

	if ( MaxDamage < 0)
		return;

	OldInstigator = Instigator;
	Instigator = InstigatedBy;
	if ( Instigator != None )
		MakeNoise(1.0);
	Instigator = OldInstigator;

	if ( bDestroyable ) MaxDamage -= NDamage;
	if ( MaxDamage < 0 )
	{
		if (!bReactivate)
			MuzzFlash.Destroy();
		if (Sound_Exploding != None)
			PlaySound(Sound_Exploding, SLOT_None, SoundVol_Exploding);
		skinnedFrag(DetFragmentClass, DetFragmentTexture, Momentum,1.0,17);
		if (FakeWeapon != None)
			B227_DeleteFakeWeapon(Pawn(FakeWeapon.Owner));
		if (!bReactivate)
		{
			if (DestroyEvent!='')
				foreach AllActors( class 'Actor', A, DestroyEvent )
					A.Trigger( Self, instigatedBy );

			Destroy();
		}
		else
		{
			GotoState( 'WaitForReactivation' );
		}
	}
}

function ControlWeaponStart()
{
	// spawn FakeWeapon and Muzzle again if needed !!

	// Give the FakeWeapon all needed infos!
	FakeWeapon = cControler.spawn(TurretWeaponClass);
	FakeWeapon.PickupAmmoCount = cAmmoAmount;
	FakeWeapon.B227_Turret = self;

	// put pawns weapon down and replace it with FakeWeapon
	if (TurretWeaponClass != None && TurretWeaponClass.default.AmmoName != None)
	{
		for (Inv = cControler.Inventory; Inv != none; Inv = Inv.Inventory)
			if (Inv.Class == TurretWeaponClass.default.AmmoName)
				Inv.Destroy();
		for (Inv = cControler.Inventory; Inv != none; Inv = Inv.Inventory)
			if (Inv.Class == TurretWeaponClass)
				Inv.Destroy();
	}

//	cControler.SetBase(Self);

	FakeWeapon.GiveTo( cControler );
	FakeWeapon.Instigator = cControler;
	if ( FakeWeapon.AmmoType == None || FakeWeapon.AmmoType.AmmoAmount <= 0)
		FakeWeapon.GiveAmmo( cControler );

	if (cControler.Weapon == None)
	{
		cControler.SwitchToBestWeapon();
	}
	else
	{
		cControler.PendingWeapon = FakeWeapon;
		cControler.Weapon.PutDown();
	}

	// if the tActor is firing stop firing
	cControler.bFire = 0;
	cControler.bAltFire = 0;
	// if the tActor is a playerpawn
	// end zoom just for the case the player is holding
	// a rifle (or other weapon) in zoom mode
	if ( cControler.IsA('PlayerPawn') )
		PlayerPawn(cControler).EndZoom();
}

simulated function ControlWeaponEnd()
{
	if (cControler == None)
	{
		if (FakeWeapon != None)
			FakeWeapon.Destroy();
		return;
	}
	if (cControler.Health <= 0)
	{
		if (cControler.Weapon != None)
			cControler.Weapon = None;
		if (cControler.PendingWeapon != None)
			cControler.PendingWeapon = None;
		Instigator = None;
		B227_DeleteFakeWeapon(cControler);
		return;
	}

	B227_DeleteFakeWeapon(cControler);

	// if the tActor is firing stop firing
	cControler.bFire = 0;
	cControler.bAltFire = 0;
	Instigator = None;
}

function Trigger( actor Other, pawn EventInstigator )
{
	if (!Other.IsA('Pawn'))
		return;
	if ( !Pawn(Other).bIsPlayer )
		return;
	if ( bEmptyClip )
	{
		SendNoAmmoMessage(Other);
		return;
	}
	if	(	!bActive
		||	(cControler.IsA('Bot') && Other.IsA('PlayerPawn'))
		)
	{
		// if a Bot controls the Turret and a PlayerPawn wants to get it the bot is forced to let it go!
		if ( bActive )
		{
			if (MuzzFlash != None)
				MuzzFlash.bHidden = True;
			ControlWeaponEnd();
		}
		cControler = Pawn(Other);
		bActive = True;
		Instigator = EventInstigator;
		GotoState( 'ActivateCannon' );
	}
}

function UnTrigger( actor Other, pawn EventInstigator )
{
	if (Other.IsA('Pawn'))
	{
		if 	(	( Pawn(Other) == cControler )
			||	( cControler == None )	)
			ResetVarsAndEnd();
	}
}

function ResetVarsAndEnd()
{
//	if (bActive)
//	{
		SetTimer(0.0,False);
		bShoot = False;
		if (MuzzFlash != None)
			MuzzFlash.bHidden = True;
		ControlWeaponEnd();
		if (!IsInState('WaitForNewAmmo'))
			GotoState('Deactivate');
//	}
}

function bool CheckcControler()
{
	if	(  (cControler == None)
		|| (cControler.Health <= 0)
		|| (cControler.PlayerReplicationInfo.bIsSpectator)
		|| (cControler.IsInState('PlayerSpectating'))
		|| (cControler.bHidden))
		return True;
	else
		return False;
}

// min-max check splitted for performance
function MinMaxCorrection(out rotator tRot)
{
	if ( bChkPitch ) MinMaxPitch(tRot);
	if ( bChkYaw ) MinMaxYaw(tRot);
}
function MinMaxPitch(out rotator tRot)
{
	if (maxPitch != 0)
	{
		if ( tRot.Pitch > maxPitch )
		{
			tRot.Pitch = maxPitch;
		}
	}
	if (minPitch != 0)
	{
		if ( tRot.Pitch < minPitch )
		{
			tRot.Pitch = minPitch;
		}
	}
}
function MinMaxYaw(out rotator tRot)
{
	if (maxYaw != 0)
	{
		if ( tRot.Yaw > maxYaw )
		{
			tRot.Yaw = maxYaw;
		}
	}
	if (minYaw != 0)
	{
		if ( tRot.Yaw < minYaw )
		{
			tRot.Yaw = minYaw;
		}
	}
}

function ResetMultipliedYaw(out rotator tRot)
{
// reset multiplied Rotation.Yaw
	while ( tRot.Yaw < (-32768 + oRot.Yaw) )
		tRot.Yaw += 65536;
	while ( tRot.Yaw > (32768 + oRot.Yaw) )
		tRot.Yaw -= 65536;
	while ( tRot.Pitch < -32768 )
		tRot.Pitch += 65536;
	while ( tRot.Pitch > 32768 )
		tRot.Pitch -= 65536;
	ResetMultipliedPlayerRotation(oRot);
}

function ResetMultipliedPlayerRotation(rotator tRot)
{
	local float DeltaYaw;
// reset multiplied Rotation.Yaw of the cControler
	DeltaYaw = cControler.ViewRotation.Yaw;
	while ( DeltaYaw < (-32768 + tRot.Yaw) )
		DeltaYaw += 65536;
	while ( DeltaYaw > (32768 + tRot.Yaw) )
		DeltaYaw -= 65536;
	if ( DeltaYaw != cControler.ViewRotation.Yaw)
		cControler.ViewRotation.Yaw = DeltaYaw;
}

function SendNoAmmoMessage( actor Other )
{
	if ( NoAmmoMessageClass == None )
		Pawn(Other).ClientMessage( NoAmmoMessage, 'Pickup' );
	else
		class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Pawn(Other), NoAmmoMessageClass, 0, None, None, self.class);
}
function PlayEmptyClip()
{
	if (Sound_EmptyClip != None)
		PlaySound(Sound_EmptyClip, SLOT_None, SoundVol_EmptyClip);
}
function PlayFiring()
{
	if (Sound_Firing != None)
		cControler.PlaySound(Sound_Firing, SLOT_None, SoundVol_Firing * cControler.SoundDampening);
}
function PlayReloading()
{
	if (Sound_Reloading != None)
		PlaySound(Sound_Reloading, SLOT_None, SoundVol_Reloading);
}
function PlayActivate()
{
	if (Sound_Activate != None)
		PlaySound(Sound_Activate, SLOT_None, SoundVol_Activate);
}

state ActivateCannon
{
//ignores Trigger;

	function BeginState()
	{
		local rotator tmpRot;

		Disable('Tick');
		bShoot = True;
		PlayActivate();
		SetTimer(SampleRate,True);
		RotationRate.Yaw = TrackingRate;
//		SetPhysics(PHYS_Rotating);

		// reset multiplied Rotation
		tmpRot = Rotation;
		ResetMultipliedYaw(tmpRot);

		DesiredRotation = tmpRot;
		SetRotation( tmpRot );

		ControlWeaponStart();

		if ( cControler.bIsPlayer && !bMessageSend )
		{
			bMessageSend = True;
			if ( ActivateMessageClass == None )
				cControler.ClientMessage( ActivateMessage, 'Pickup' );
			else
				class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(cControler, ActivateMessageClass, 0, None, None, self.class);
		}
	}

	function Timer()
    {
		local Rotator tmpRot;

		if (CheckcControler())
		{
			ResetVarsAndEnd();
			return;
		}

		// to prevent firing with multiple weapons if cControler changes weapon
		if (cControler.Weapon.class != TurretWeaponClass)
		{
			if (MuzzFlash != None)
				MuzzFlash.bHidden = True;
			return;
		}

		// reset multiplied Rotation
		tmpRot = Rotation;
		ResetMultipliedYaw(tmpRot);

		if (bControlPitch)
			tmpRot.Pitch = cControler.ViewRotation.Pitch;
		if (bControlYaw)
			tmpRot.Yaw = cControler.ViewRotation.Yaw;

		// Pitch correction cause Viewrotation <0 starts by 65535
		if (tmpRot.Pitch > 32768)
			tmpRot.Pitch = (65535 - tmpRot.Pitch) * -1;

		// check the min-max vars
		if (bChkMinMax) MinMaxCorrection(tmpRot);

		DesiredRotation = tmpRot;
		SetRotation( tmpRot );

		if (bShoot)
		{
			if	(	(cControler.bFire != 0)
				||	(cControler.bAltFire != 0)
				)
			{
				if (MuzzFlash != None)
					MuzzFlash.bHidden = False;
				Shoot();
			}
		}
		SetTimer(SampleRate,True);
	}

	function Tick( float DeltaTime )
	{
		if (CheckcControler())
		{
			ResetVarsAndEnd();
			return;
		}

		if	(	(cControler.bFire != 0)
			||	(cControler.bAltFire != 0)
			)
		{
			if (MuzzFlash != None)
				MuzzFlash.bHidden = False;
		}
		else
		{
			if (MuzzFlash != None)
				MuzzFlash.bHidden = True;
		}

		TimePassed += DeltaTime;
		if ( TimePassed > TimeToCheck )
		{
			bShoot = True;
			Disable('Tick');
		}
	}

	function Shoot()
	{
		local rotator tmpRot;
		local float tmpVal, KickPitch, KickYaw;

		if (CheckcControler())
		{
			ResetVarsAndEnd();
			return;
		}

		if (!FakeWeapon.AmmoType.UseAmmo(1))
		{
			PlayEmptyClip();
			bEmptyClip = True;
			cAmmoAmount = 0;
			ResetVarsAndEnd();
			return;
		}

		cAmmoAmount = FakeWeapon.AmmoType.AmmoAmount;

		// shake the mesh (this also includes an automatic aim error)
		if (bShakeMesh)
		{
			tmpRot = Rotation;
			tmpVal = FRand()*ShakeMeshMultiplier;
			if (FRand() > 0.5)
			{
				tmpRot.Pitch += tmpVal;
				if (bAffectPlayerView)
					KickPitch = tmpVal;
			}
			else
			{
				tmpRot.Pitch -= tmpVal;
				if (bAffectPlayerView)
					KickPitch = tmpVal * -1;
			}
			tmpVal = FRand()*ShakeMeshMultiplier;
			if (FRand() > 0.5)
			{
				tmpRot.Yaw += tmpVal;
				if (bAffectPlayerView)
					KickYaw = tmpVal;
			}
			else
			{
				tmpRot.Yaw -= tmpVal;
				if (bAffectPlayerView)
					KickYaw = tmpVal * -1;
			}
			if (bAffectPlayerView)
			{
				FakeWeapon.KickPitch = KickPitch;
				FakeWeapon.KickYaw = KickYaw;
				FakeWeapon.bKick = True;
			}
			DesiredRotation = tmpRot;
			SetRotation( tmpRot );
		}

		PlayFiring();
		if (frand() < TracerFrequency)
			FireTracer(False);
		else
			FireTracer(True);

		if (bShakeView && cControler.IsA('PlayerPawn'))
			PlayerPawn(cControler).ShakeView(ShakeTime, ShakeMag, ShakeVert);

		PlayReloading();
		TimeToCheck = FiringRate;
		TimePassed = 0;
		bShoot = False;
		Enable('Tick');
	}
}

state DeActivate
{
//ignores Trigger, Untrigger;
	function BeginState()
	{
		if (TurretWeaponClass != None && TurretWeaponClass.default.AmmoName != None)
		{
			Inv = cControler.FindInventoryType(TurretWeaponClass.default.AmmoName);
			if (Inv != None)
				cControler.DeleteInventory( Inv );
			Inv = cControler.FindInventoryType(TurretWeaponClass);
			if (Inv != None)
				cControler.DeleteInventory( Inv );
		}
	}
Begin:
	if (Event!='')
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, cControler );
	if( bEmptyClip )
		GotoState('WaitForNewAmmo');
	else
		GotoState('WaitForNewPlayer');
}

function FireTracer(bool bHidden)
{
	local Vector X,Y,Z, OffSet, OffsetForMuzzle;
	local INFUT_ADD_BallisticProj p;
	local INFUT_ADD_BallisticHidden h;

	cControler.MakeNoise(cControler.SoundDampening);
	GetAxes(Rotation,X,Y,Z);
	OffSet = Location + X * FireProjectileOffset.X + Y * FireProjectileOffset.Y + Z * FireProjectileOffset.Z;
	OffsetForMuzzle = Location + X * MuzzleOffset.X + Y * MuzzleOffset.Y + Z * MuzzleOffset.Z;

	spawn(class'WeaponLight', self, '', OffSet, Rotation);
	SpawnShellcase(X,Y,Z);

	if (MuzzFlash != None)
	{
		MuzzFlash.SetLocation(OffsetForMuzzle);
		MuzzFlash.SetRotation(Rotation);
	}

	if (bHidden)
	{
		if (ProjectileClassHidden != None)
		{
			h = Spawn (ProjectileClassHidden,cControler,, OffSet, Rotation);
			if (h != None)
				h.shooter = cControler;
		}
	}
	else
	{
		if (ProjectileClass != None)
		{
			p = Spawn (ProjectileClass,cControler,, OffSet, Rotation);
			if (p != None)
				p.shooter = cControler;
		}
	}
}

function SpawnShellcase(vector X,vector Y,vector Z)
{
	local UT_shellcase s;
	local vector eShell, eBelt;

	eShell = Location + X * EjectShellCaseOffset.X + Y * EjectShellCaseOffset.Y + Z * EjectShellCaseOffset.Z;
	eBelt = Location + X * EjectBeltConnOffset.X + Y * EjectBeltConnOffset.Y + Z * EjectBeltConnOffset.Z;

	if (AmmoShellCaseClass != None)
	{
		s = Spawn(AmmoShellCaseClass,cControler,, eShell, Rotation);
		if ( s != None )
			s.Eject(((FRand()*0.5+0.8)*X + (FRand()*0.5+1.0)*Y + (FRand()*0.5+1.0) * Z * 10));
	}
	if (AmmoBeltConnClass != None)
	{
		s = Spawn(AmmoBeltConnClass,cControler,, eBelt, Rotation);
		if ( s != None )
			s.Eject(((FRand()*0.5+0.8)*X + (FRand()*0.5+1.0)*Y*40 + (FRand()*0.5+1.0) * Z * 20));
	}
}

state WaitForNewAmmo
{
ignores UnTrigger;

	function float PlayMySpawnEffect(actor Act)
	{
		spawn( class 'EnhancedReSpawn',Act,, Act.Location );
		return 0.3;
	}

	simulated function EndState()
	{
		cAmmoAmount = TurretWeaponClass.default.PickupAmmoCount;
		bEmptyClip = False;
		bShoot = False;
	}

Begin:
	Sleep( ReactivateTime );
	Sleep( PlayMySpawnEffect(self) );
	GotoState('WaitForNewPlayer');
}

// null state
auto state WaitForNewPlayer
{
	function BeginState()
	{
		setTimer(0.0,False);
		bActive = False;
		cControler = None;
		bMessageSend = False;
		bShoot = False;
	}
}

// null state for roundchanges after fakedestroy (no yet implemented in Infiltration game-types)
state WaitForReactivation
{
ignores Trigger, Untrigger;
	function BeginState()
	{
		setTimer(0.0,False);
		bActive = False;
		cControler = None;
		bMessageSend = False;
		bShoot = False;
	}
}


function B227_DeleteFakeWeapon(Pawn WeaponOwner)
{
	local Actor Ammo;

	if (FakeWeapon == none)
		return;
	if (FakeWeapon.AmmoName != none && WeaponOwner != none)
	{
		// B227 note: mods may allow ammo to be owned by a dead player with cleared inventory list
		foreach WeaponOwner.ChildActors(FakeWeapon.AmmoName, Ammo)
			if (Ammo.Class == FakeWeapon.AmmoName)
				Ammo.Destroy();
	}
	FakeWeapon.Destroy();
	FakeWeapon = none;
	if (WeaponOwner != none)
		WeaponOwner.SwitchToBestWeapon();
}

//	 RemoteRole=Dump_Proxy

defaultproperties
{
     TracerFrequency=0.250000
     bControlPitch=True
     bControlYaw=True
     DetFragmentClass=Class'UnrealShare.Fragment1'
     MaxDamage=100.000000
     FiringRate=0.080000
     SampleRate=0.010000
     TrackingRate=40000
     ActivateMessage="You control the Turret !"
     NoAmmoMessage="No Ammo !"
     ReactivateTime=10.000000
     shakemag=100.000000
     shaketime=0.100000
     shakevert=5.000000
     Sound_Exploding=Sound'Botpack.General.Expl04'
     SoundVol_Activate=5.000000
     SoundVol_EmptyClip=5.000000
     SoundVol_Exploding=2.000000
     SoundVol_Firing=10.000000
     SoundVol_Reloading=5.000000
     bAffectPlayerView=True
     bShakeMesh=True
     ShakeMeshMultiplier=100.000000
     MuzzleEffectClass=Class'InfAdds.INFUT_ADD_CannonMuzzle'
     MuzzleDrawScale=0.125000
     ActivateMessageClass=Class'InfAdds.INFUT_ADD_TurretActivateMessage'
     NoAmmoMessageClass=Class'InfAdds.INFUT_ADD_TurretNoAmmoMessage'
     bStatic=False
     bAlwaysRelevant=True
     DrawType=DT_Mesh
     CollisionRadius=64.000000
     CollisionHeight=32.000000
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bProjTarget=True
}
