//=============================================================================
// SpecialControlCannon.
//
// script by N.Bogenrieder (Beppo)
//
//=============================================================================
class SpecialControlCannon expands Decoration;

// this class is based upon the Decoration.Cannon
// Cannon controled by a Pawn with Fire and AltFire
// use a Trigger to activate it!
// The Trigger.Instigator controls the cannon.
// This Cannon was originally designed for Players only...
// but even Bots or ScriptedPawns can control it now.
//
//=============================================================================

var(Cannon) float SampleTime; 			// How often we sample Instigator's viewrotation
var(Cannon) int   TrackingRate;			// How fast Cannon reacts on Instigator's viewchange
var(Cannon) float Drop;					// How far down to drop spawning of projectile
var(Cannon) float Health;
var(Cannon) sound FireSound;
var(Cannon) sound AltFireSound;
var(Cannon) sound ActivateSound;
var(Cannon) sound ExplodeSound;
var() bool bDestroyable;
var() enum EProjectileType	// select a specific type of projectile
{
	Proj_Default,	// use default projectile
	Proj_Class,		// use projectile of ProjectileClass
} ProjectileType;
 // use these projectiles if Proj_Class
var() class<projectile> Fire_ProjectileClass; // Fire
var() class<projectile> AltFire_ProjectileClass; // AltFire
var() localized string ActivateMessage; // if activated send this message to cControler/Instigator
var() float AltFireRate; // ReloadTime for AltFire
var() float FireRate; // ReloadTime for Fire
var() sound AltReloadSound;
var() sound ReloadSound;
var() bool bDontPlayActivateAnim;

var() bool bWaitAltFireRelease;
var() bool bWaitFireRelease;

var(SpecialInstantHit) bool bInstantHit;
var(SpecialInstantHit) float InstantHitDamage;
var(SpecialInstantHit) class<effects> FireEffect;
var(SpecialInstantHit) class<effects> WallHitEffect;
var(SpecialInstantHit) class<effects> PawnHitEffect;
var(SpecialInstantHit) class<effects> OtherHitEffect;
var(SpecialInstantHit) float InstantHitAccuracy;
var(SpecialInstantHit) enum EIHMode
{
	IHM_Fire_and_AltFire,
	IHM_Fire,
	IHM_AltFire,
} InstantHitMode;
var(SpecialInstantHit) float AltInstantHitAccuracy;

var actor cControler;
var weapon cWeapon;
var NoWeaponNoFire NoWeapon;
var actor a;
var float TimePassed, TimeToCheck;
var bool bShoot, bSwitchWeapon;
var bool bActive;
var float FirePositionOffset;
var name oAnim;
var bool bFireIH, bAltFireIH, btActIsPlayer;

function Shoot(int FMode) {}   // To resolve error 'virtual function 'shoot' not found'

function PostBeginPlay()
{
	oAnim = AnimSequence;
	Super.PostBeginPlay();
	bActive = False;

	bFireIH = False;
	bAltFireIH = False;

	if (bInstantHit)
	{
		switch InstantHitMode
		{
			case IHM_Fire_and_AltFire:
				bFireIH = True;
				bAltFireIH = True;
				break;
			case IHM_Fire:
				bFireIH = True;
				break;
			case IHM_AltFire:
				bAltFireIH = True;
				break;
		}
	}
}

function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
					Vector momentum, name damageType)
{
	Instigator = InstigatedBy;
	if (Health<0) Return;
	if ( Instigator != None )
		MakeNoise(1.0);
	if (bDestroyable)	Health -= NDamage;
	if (Health <0) {
		PlaySound(ExplodeSound, SLOT_None,5.0);
		skinnedFrag(class'Fragment1',texture'JCannon1', Momentum,1.0,17);
		Destroy();
	}
}

function ControlWeaponStart()
{
	// put pawns weapon down and replace it with NoWeapon
	// the if() is needed in case that the player controls
	// more than one controlmover
	bSwitchWeapon = False;
	NoWeapon = spawn(class'NoWeaponNoFire', cControler);

	if	( Pawn(cControler).Weapon.class != NoWeapon.class )
	{
		cWeapon = Pawn(cControler).Weapon;
		NoWeapon.SetOwner(cControler);

		Pawn(cControler).Weapon.TweenDown();
		Pawn(cControler).Weapon = NoWeapon;
		Pawn(cControler).PendingWeapon = NoWeapon;
		Pawn(cControler).Weapon.BringUp();
		bSwitchWeapon = True;
	}
	// if the tActor is firing stop firing
	Pawn(cControler).bFire = 0;
	Pawn(cControler).bAltFire = 0;
	// if the tActor is a playerpawn
	// end zoom just for the case the player is holding
	// a rifle (or other weapon) in zoom mode
	if ( cControler.IsA('PlayerPawn') )
		PlayerPawn(cControler).EndZoom();
}

function ControlWeaponEnd()
{
	if (Pawn(cControler).Health <= 0)
	{
		Pawn(cControler).Weapon = None;
		Pawn(cControler).PendingWeapon = None;
	}
	// reactivate pawns weapon
	// the if() is needed in case that the player controls
	// more than one controlmover
	else if (bSwitchWeapon)
	{
		Pawn(cControler).Weapon.TweenDown();
		Pawn(cControler).Weapon = cWeapon;
		Pawn(cControler).PendingWeapon = cWeapon;
		Pawn(cControler).Weapon.BringUp();
	}
	NoWeapon.SetOwner(None);
	NoWeapon.Destroy();
	NoWeapon = None;

	bSwitchWeapon = False;
	// if the tActor is firing stop firing
	Pawn(cControler).bFire = 0;
	Pawn(cControler).bAltFire = 0;
	cWeapon = None;
	Instigator = None;
}


function Trigger( actor Other, pawn EventInstigator )
{
	if (!bActive)
	{
		cControler = Other;
		Instigator = EventInstigator;

		ControlWeaponStart();

		if ( Pawn(cControler)!=None && Pawn(cControler).bIsPlayer )
			cControler.Instigator.ClientMessage( ActivateMessage );
		GotoState( 'ActivateCannon');
		bActive = True;
	}
}

function UnTrigger( actor Other, pawn EventInstigator )
{
	ResetVarsAndEnd();
}

function ResetVarsAndEnd()
{
	if (bActive)
	{
		ControlWeaponEnd();
		cControler = None;
		GotoState('Deactivate');
	}
}

function bool CheckcControler()
{
	if	(  (Pawn(cControler).Health <= 0)
		|| (Pawn(cControler) == None)
		|| (Pawn(cControler).bHidden) )
		return True;
	else
		return False;
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local rotator AdjustedAim;

	GetAxes(Rotation,X,Y,Z);
	StartTrace = Location+Vector(DesiredRotation)*FirePositionOffset - Vect(0,0,1)*Drop;
	AdjustedAim = DesiredRotation;
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (10000 * X);
	Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
	ProcessTraceHit(Other, HitLocation, HitNormal, X,Y,Z);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int rndDam;

	if (Other == Level)
	{
		if (WallHitEffect != None)
			Spawn(WallHitEffect,,, HitLocation+HitNormal*9, Rotator(HitNormal));
	}
	else if ( (Other!=self) && (Other!=Owner) && (Other != None) )
	{
		if ( !Other.IsA('Pawn') && !Other.IsA('Carcass') )
		{
			if (OtherHitEffect != None)
				spawn(OtherHitEffect,,,HitLocation+HitNormal*9, Rotator(HitNormal));
		}
		else
		{
			if (PawnHitEffect != None)
				spawn(PawnHitEffect,,,HitLocation+HitNormal*9, Rotator(HitNormal));
		}
		if ( Other.IsA('ScriptedPawn') && (FRand() < 0.2) )
			Pawn(Other).WarnTarget(Pawn(cControler), 500, X);
		rndDam = InstantHitDamage + Rand(6);
		if ( FRand() < 0.2 )
			X *= 2;
		Other.TakeDamage(rndDam, Pawn(cControler), HitLocation, rndDam*500.0*X, 'shot');
	}
}

state ActivateCannon
{
	function Timer()
	{
		if (CheckcControler())
		{
			ResetVarsAndEnd();
			return;
		}

		DesiredRotation = Pawn(cControler).ViewRotation;
		DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;

		// performance... if to much background-activity
		// cause else no animation will be played
		// depends on samplerate... so only play anim if
		// last anim finished !!
		if	( AnimFrame == 0.0 )
		{
		if (DesiredRotation.Pitch - 65535 < -20000 ) TweenAnim('Angle0', 0.25);
		else if (DesiredRotation.Pitch - 65535 < -6000 ) TweenAnim('Angle4', 0.25);
		else if (DesiredRotation.Pitch - 65535 < -4000 ) TweenAnim('Angle3', 0.25);
		else if (DesiredRotation.Pitch - 65535 < -2000 ) TweenAnim('Angle2', 0.25);
		else TweenAnim('Angle1', 0.25);
		}

		bRotateToDesired = True;

		// to prevent firing with multiple weapons
		// if cControler changes weapon
		if (Pawn(cControler).Weapon.class != NoWeapon.class)
		{
			ResetVarsAndEnd();
			return;
		}

		if (bShoot) {
			if (Pawn(cControler).bFire == 1) Shoot(1);
			else if (Pawn(cControler).bAltFire == 1) Shoot(2);
		}
		SetTimer(SampleTime,True);
	}

	function Tick( float DeltaTime )
	{
		if (CheckcControler())
		{
			ResetVarsAndEnd();
			return;
		}

		TimePassed += DeltaTime;
		if	(	(TimePassed > TimeToCheck)
			&&	( (Pawn(cControler).bFire == 0)    || (!bWaitFireRelease) )
			&&	( (Pawn(cControler).bAltFire == 0) || (!bWaitAltFireRelease) )
			)
		{
			bShoot = True;
			Disable('Tick');
		}
	}

	function Shoot(int FMode)
	{
		local projectile pp;

		if (CheckcControler())
		{
			ResetVarsAndEnd();
			return;
		}

		if (FMode == 1) PlaySound(FireSound, SLOT_None,5.0);
		else PlaySound(AltFireSound, SLOT_None,5.0);

		if	( DesiredRotation.Pitch - 65535 < -20000 )
			PlayAnim('FAngle0', 0.25);
		else if	( DesiredRotation.Pitch - 65535 < -6000 )
			PlayAnim('FAngle4', 0.25);
		else if	( DesiredRotation.Pitch - 65535 < -4000 )
			PlayAnim('FAngle3', 0.25);
		else if	( DesiredRotation.Pitch - 65535 < -2000 )
			PlayAnim('FAngle2', 0.25);
		else PlayAnim('FAngle1', 0.25);

		FirePositionOffset = 100;

		if(bInstantHit && ProjectileType == Proj_Default)
		{
			TraceFire(InstantHitAccuracy);
			if (FireEffect != None)
				Spawn (FireEffect,,,Location+Vector(DesiredRotation)*FirePositionOffset - Vect(0,0,1)*Drop,DesiredRotation);
		}
		else
		{

			switch( ProjectileType )
			{
				case Proj_Default:
					pp = Spawn (class'CannonBolt',,,Location+Vector(DesiredRotation)*FirePositionOffset - Vect(0,0,1)*Drop,DesiredRotation);
					break;
				case Proj_Class:
					if (FMode == 1)
					{
						if(bFireIH)
						{
							TraceFire(InstantHitAccuracy);
							if (FireEffect != None)
								Spawn (FireEffect,,,Location+Vector(DesiredRotation)*FirePositionOffset - Vect(0,0,1)*Drop,DesiredRotation);
						}
						else
						{
							if ( Fire_ProjectileClass != None )
								pp = Spawn (Fire_ProjectileClass,,,Location+Vector(DesiredRotation)*FirePositionOffset - Vect(0,0,1)*Drop,DesiredRotation);
							else
								pp = Spawn (class'CannonBolt',,,Location+Vector(DesiredRotation)*FirePositionOffset - Vect(0,0,1)*Drop,DesiredRotation);
						}
					}
					else
					{
						if(bAltFireIH)
						{
							TraceFire(AltInstantHitAccuracy);
							if (FireEffect != None)
								Spawn (FireEffect,,,Location+Vector(DesiredRotation)*FirePositionOffset - Vect(0,0,1)*Drop,DesiredRotation);
						}
						else
						{
							if ( AltFire_ProjectileClass != None )
								pp = Spawn (AltFire_ProjectileClass,,,Location+Vector(DesiredRotation)*FirePositionOffset - Vect(0,0,1)*Drop,DesiredRotation);
							else
								pp = Spawn (class'CannonBolt',,,Location+Vector(DesiredRotation)*FirePositionOffset - Vect(0,0,1)*Drop,DesiredRotation);
						}
					}
					break;
			}
			pp.Instigator = Pawn(cControler);
		}

		if (FMode == 1) PlaySound(ReloadSound, SLOT_None,5.0);
		else PlaySound(AltReloadSound, SLOT_None,5.0);

		if (FMode == 1) TimeToCheck = FireRate;
		else TimeToCheck = AltFireRate;
		TimePassed = 0;
		bShoot = False;
		Enable('Tick');
	}


Begin:
	Disable('Tick');
	bShoot = True;
	if (!bDontPlayActivateAnim) PlayAnim('Activate',0.5);
	PlaySound(ActivateSound, SLOT_None, 2.0);
	if (!bDontPlayActivateAnim) FinishAnim();
	AnimFrame = 0;
	SetTimer(SampleTime,True);
	RotationRate.Yaw = TrackingRate;
	SetPhysics(PHYS_Rotating);
}

state DeActivate
{
Begin:
	if (!bDontPlayActivateAnim) TweenAnim('Activate',3.0);
	else TweenAnim(oAnim,1.0);
	if (Event!='')
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, Pawn(cControler) );

	bActive = False;
}

defaultproperties
{
     SampleTime=0.200000
     TrackingRate=40000
     Drop=60.000000
     Health=100.000000
     FireSound=Sound'UnrealI.Krall.Krasht2'
     AltFireSound=Sound'UnrealShare.Eightball.EightAltFire'
     ActivateSound=Sound'UnrealI.Cannon.CannonActivate'
     ExplodeSound=Sound'UnrealI.Cannon.CannonExplode'
     ProjectileType=Proj_Class
     Fire_ProjectileClass=Class'UnrealI.EliteKrallBolt'
     AltFire_ProjectileClass=Class'UnrealShare.Rocket'
     ActivateMessage="You control the cannon !"
     AltFireRate=0.800000
     FireRate=0.300000
     AltReloadSound=Sound'UnrealShare.Eightball.Loading'
     InstantHitDamage=8.000000
     FireEffect=Class'UnrealShare.BlackSmoke'
     WallHitEffect=Class'UnrealShare.LightWallHitEffect'
     OtherHitEffect=Class'UnrealShare.SpriteSmokePuff'
     InstantHitAccuracy=0.400000
     AltInstantHitAccuracy=0.800000
     bStatic=False
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealI.CannonM'
     CollisionRadius=44.000000
     CollisionHeight=44.000000
     bCollideActors=True
     bCollideWorld=True
     bProjTarget=True
     RotationRate=(Yaw=50000)
}
