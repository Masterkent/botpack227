//=============================================================================
// ImpactHammer.
//=============================================================================
class ImpactHammer extends TournamentWeapon;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var float ChargeSize, Count;
var() sound AltFireSound;
var() sound TensionSound;


function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;
	local Pawn P;

	bUseAltMode = 0;
	P = Pawn(Owner);

	if ( (P == None) || (P.Enemy == None) )
		return 0;

	EnemyDist = VSize(P.Enemy.Location - Owner.Location);
	if ( (EnemyDist < 750) && P.IsA('Bot') && Bot(P).bNovice && (P.Skill <= 2) && !P.Enemy.IsA('Bot') && (ImpactHammer(P.Enemy.Weapon) != None) )
		return FClamp(300/(EnemyDist + 1), 0.6, 0.75);

	if ( EnemyDist > 400 )
		return 0.1;
	if ( (P.Weapon != self) && (EnemyDist < 120) )
		return 0.25;

	return ( FMin(0.8, 81/(EnemyDist + 1)) );
}

function float SuggestAttackStyle()
{
	return 10.0;
}

function float SuggestDefenseStyle()
{
	return -2.0;
}

function PlayPostSelect()
{
	local Bot B;

	//-if ( Level.NetMode == NM_Client )
	//-{
	//-	Super.PlayPostSelect();
	//-	return;
	//-}

	B = Bot(Owner);

	if ( (B != None) && (B.Enemy != None) )
	{
		B.PlayFiring();
		B.bFire = 1;
		B.bAltFire = 0;
		Fire(1.0);
	}
}

function bool ClientFire( float Value )
{
	if ( bCanClientFire )
	{
		if (PlayerPawn(Owner) != none)
		{
			if ( InstFlash != 0.0 )
				PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}
		// [U227] Excluded
		///if ( Affector != None )
		///	Affector.FireEffect();
		B227_PlaySound(Misc1Sound, SLOT_Misc, 1.3*Pawn(Owner).SoundDampening);
		PlayAnim('Pull', 0.2, 0.05);
		return true;
	}
	return false;
}

function Fire( float Value )
{
	bPointing=True;
	bCanClientFire = true;
	ClientFire(Value);
	Pawn(Owner).PlayRecoil(FiringSpeed);
	GoToState('Firing');
}

function AltFire( float Value )
{
	bPointing=True;
	bCanClientFire = true;
	Pawn(Owner).PlayRecoil(FiringSpeed);
	TraceAltFire();
	ClientAltFire(value);
	GoToState('AltFiring');
}

/*
simulated function ClientWeaponEvent(name EventType)
{
	if ( EventType == 'FireBlast' )
	{
		PlayFiring();
		GotoState('ClientFireBlast');
	}
}
*/

function PlayFiring()
{
	if (Owner != None)
	{
		if ( Affector != None )
			Affector.FireEffect();
		PlaySound(FireSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening,,,);
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		PlayAnim( 'Fire', 0.65 );
	}
}

function PlayAltFiring()
{
	if (Owner != None)
	{
		if ( Affector != None )
			Affector.FireEffect();
		PlaySound(AltFireSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening,,,);
		LoopAnim( 'Fire', 0.65);
	}
}

state Firing
{
	function AltFire(float F)
	{
	}

	function Tick( float DeltaTime )
	{
		local Pawn P;
		local Rotator EnemyRot;
		local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
		local actor HitActor;

		if ( bChangeWeapon )
			GotoState('DownWeapon');

		if (  Bot(Owner) != None )
		{
			if ( Bot(Owner).Enemy == None )
				Bot(Owner).bFire = 0;
			else
				Bot(Owner).bFire = 1;
		}
		P = Pawn(Owner);
		if ( P == None )
		{
			AmbientSound = None;
			GotoState('');
			return;
		}
		else if( P.bFire==0 )
		{
			TraceFire(0);
			PlayFiring();
			GoToState('FireBlast');
			return;
		}

		ChargeSize += 0.75 * DeltaTime;

		Count += DeltaTime;
		if ( Count > 0.2 )
		{
			Count = 0;
			Owner.MakeNoise(P.SoundDampening);
		}
		SoundVolume = 255 * P.SoundDampening;

		if (ChargeSize > 1)
		{
			if ( !P.IsA('PlayerPawn') && (P.Enemy != None) )
			{
				EnemyRot = Rotator(P.Enemy.Location - P.Location);
				EnemyRot.Yaw = EnemyRot.Yaw & 65535;
				if ( (abs(EnemyRot.Yaw - (P.Rotation.Yaw & 65535)) > 8000)
					&& (abs(EnemyRot.Yaw - (P.Rotation.Yaw & 65535)) < 57535) )
					return;
				GetAxes(EnemyRot,X,Y,Z);
			}
			else
				GetAxes(P.ViewRotation, X, Y, Z);
			StartTrace = P.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
			if ( (Level.NetMode == NM_Standalone) && P.IsA('PlayerPawn') )
				EndTrace = StartTrace + 25 * X;
			else
				EndTrace = StartTrace + 60 * X;
			HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
			if ( (HitActor != None) && (HitActor.DrawType == DT_Mesh) )
			{
				ProcessTraceHit(HitActor, HitLocation, HitNormal, Normal(EndTrace - StartTrace), Y, Z);
				PlayFiring();
				GoToState('FireBlast');
			}
		}
	}

	function BeginState()
	{
		ChargeSize = 0.0;
		Count = 0.0;
	}

	function EndState()
	{
		Super.EndState();
		AmbientSound = None;
	}

Begin:
	FinishAnim();
	AmbientSound = TensionSound;
	SoundVolume = 255*Pawn(Owner).SoundDampening;
	LoopAnim('Shake', 0.9);
}

/* Weapon's client states are removed in this conversion
state ClientFiring
{
	simulated function AnimEnd()
	{
		AmbientSound = TensionSound;
		SoundVolume = 255*Pawn(Owner).SoundDampening;
		LoopAnim('Shake', 0.9);
		Disable('AnimEnd');
	}
}
*/

state FireBlast
{
	function Fire(float F)
	{
	}
	function AltFire(float F)
	{
	}

Begin:
	///if (Level.NetMode != NM_Standalone && PlayerPawn(Owner) != none && ViewPort(PlayerPawn(Owner).Player) == none)
	///	ClientWeaponEvent('FireBlast');
	FinishAnim();
	Finish();
}

/* Weapon's client states are removed in this conversion
state ClientFireBlast
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
		if ( Pawn(Owner) == None )
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
}
*/

function TraceFire(float accuracy)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, AimError, False, False);
	EndTrace = StartTrace + 120.0 * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	if ( (Other == None) || (Other == Owner) || (Other == self) || (Owner == None))
		return;

	ChargeSize = FMin(ChargeSize, 1.5);
	if ( (Other == Level) || Other.IsA('Mover') )
	{
		ChargeSize = FMax(ChargeSize, 1.0);
		if ( VSize(HitLocation - Owner.Location) < 80 )
			Spawn(class'ImpactMark',,, HitLocation+HitNormal, Rotator(HitNormal));
		Owner.TakeDamage(36.0, Pawn(Owner), HitLocation, -69000.0 * ChargeSize * X, MyDamageType);
	}
	if ( Other != Level )
	{
		if ( Other.bIsPawn && (VSize(HitLocation - Owner.Location) > 90) )
			return;
		Other.TakeDamage(60.0 * ChargeSize, Pawn(Owner), HitLocation, 66000.0 * ChargeSize * X, MyDamageType);
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
	}
}

function TraceAltFire()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local actor Other;
	local Projectile P;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, AimError, False, False);
	EndTrace = StartTrace + 180 * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);
	ProcessAltTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);

	// push aside projectiles
	ForEach VisibleCollidingActors(class'Projectile', P, 550, Owner.Location)
		if ( ((P.Physics == PHYS_Projectile) || (P.Physics == PHYS_Falling))
			&& (Normal(P.Location - Owner.Location) Dot X) > 0.9 )
		{
			P.speed = VSize(P.Velocity);
			if ( P.Velocity Dot Y > 0 )
				P.Velocity = P.Speed * Normal(P.Velocity + (750 - VSize(P.Location - Owner.Location)) * Y);
			else
				P.Velocity = P.Speed * Normal(P.Velocity - (750 - VSize(P.Location - Owner.Location)) * Y);
		}
}

function ProcessAltTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local vector realLoc;
	local float scale;

	if ( (Other == None) || (Other == Owner) || (Other == self) || (Owner == None) )
		return;

	realLoc = Owner.Location + CalcDrawOffset();
	scale = VSize(realLoc - HitLocation)/180;
	if ( (Other == Level) || Other.IsA('Mover') )
	{
		Owner.TakeDamage(24.0 * scale, Pawn(Owner), HitLocation, -40000.0 * X * scale, MyDamageType);
	}
	else
	{
		Other.TakeDamage(20 * scale, Pawn(Owner), HitLocation, 30000.0 * X * scale, MyDamageType);
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
	}
}

function PlayIdleAnim()
{
	local Bot B;

	B = Bot(Owner);

	if ( (B != None) && (B.Enemy != None) )
	{
		B.PlayFiring();
		B.bFire = 1;
		B.bAltFire = 0;
		Fire(1.0);
	}
	else if ( Mesh != PickupViewMesh )
		TweenAnim( 'Still', 1.0);
}

defaultproperties
{
	AltFireSound=Sound'Botpack.ASMD.ImpactFire'
	TensionSound=Sound'Botpack.ASMD.ImpactLoop'
	WeaponDescription="Classification: Melee Piston\n\nPrimary Fire: When trigger is held down, touch opponents with this piston to inflict massive damage.\n\nSecondary Fire: Damages opponents at close range and has the ability to deflect projectiles.\n\nTechniques: Shoot at the ground while jumping to jump extra high."
	InstFog=(X=475.000000,Y=325.000000,Z=145.000000)
	bMeleeWeapon=True
	bRapidFire=True
	MyDamageType=impact
	RefireRate=1.000000
	AltRefireRate=1.000000
	FireSound=Sound'Botpack.ASMD.ImpactAltFireRelease'
	SelectSound=Sound'Botpack.ASMD.ImpactPickup'
	Misc1Sound=Sound'Botpack.ASMD.ImpactAltFireStart'
	DeathMessage="%o got smeared by %k's piston."
	NameColor=(G=192,B=0)
	PickupMessage="You got the Impact Hammer."
	ItemName="Impact Hammer"
	PlayerViewOffset=(X=3.800000,Y=-1.600000,Z=-1.800000)
	PlayerViewMesh=LodMesh'Botpack.ImpactHammer'
	PickupViewMesh=LodMesh'Botpack.ImpPick'
	ThirdPersonMesh=LodMesh'Botpack.ImpactHandm'
	StatusIcon=Texture'Botpack.Icons.UseHammer'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Icon=Texture'Botpack.Icons.UseHammer'
	Mesh=LodMesh'Botpack.ImpPick'
	bNoSmooth=False
	SoundRadius=50
	SoundVolume=200
}
