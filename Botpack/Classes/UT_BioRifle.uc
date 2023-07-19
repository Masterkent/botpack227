//=============================================================================
// UT_BioRifle.
//=============================================================================
class UT_BioRifle extends TournamentWeapon;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var float ChargeSize, Count;
var bool bBurst;

function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;
	if ( (Owner != None) && (VSize(Owner.Velocity) > 10) )
		PlayAnim('Walking',0.3,0.3);
	else
		TweenAnim('Still', 1.0);
	Enable('AnimEnd');
}

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;
	local bool bRetreating;
	local vector EnemyDir;
	local vector EnemyDir2d;
	local float EnemyCollisionDist;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;
	bUseAltMode = 0;
	if ( Pawn(Owner).Enemy == None )
		return AIRating;

	EnemyDir = Pawn(Owner).Enemy.Location - Owner.Location;
	EnemyDist = VSize(EnemyDir);
	if ( EnemyDist > 1400 )
		return 0;

	// B227: low rating when the enemy is too close; also prevents division by zero
	EnemyDir2d = EnemyDir;
	EnemyDir2d.Z = 0;
	EnemyCollisionDist = VSize(EnemyDir2d) - Owner.CollisionRadius - Pawn(Owner).Enemy.CollisionRadius;
	EnemyCollisionDist = FMax(EnemyCollisionDist, Abs(EnemyDir.Z) - Owner.CollisionHeight - Pawn(Owner).Enemy.CollisionHeight);
	if (EnemyCollisionDist < 150)
		return 0.05 + EnemyDist * 0.001;

	bRetreating = ( ((EnemyDir/EnemyDist) Dot Owner.Velocity) < -0.6 );
	if ( (EnemyDist > 600) && (EnemyDir.Z > -0.4 * EnemyDist) )
	{
		// only use if enemy not too far and retreating
		if ( !bRetreating )
			return 0;

		return AIRating;
	}

	bUseAltMode = int( FRand() < 0.3 );

	if ( bRetreating || (EnemyDir.Z < -0.7 * EnemyDist) )
		return (AIRating + 0.18);
	return AIRating;
}

// return delta to combat style
function float SuggestAttackStyle()
{
	return -0.3;
}

function float SuggestDefenseStyle()
{
	return -0.4;
}

function AltFire( float Value )
{
	bPointing=True;
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
		GoToState('AltFiring');
		bCanClientFire = true;
		ClientAltFire(Value);
	}
}

function bool ClientAltFire(float Value)
{
	if (PlayerPawn(Owner) != none &&
		(Level.NetMode == NM_Standalone || PlayerPawn(Owner).Player.IsA('ViewPort')))
	{
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	}
	PlayAltFiring();
	if (Role < ROLE_Authority)
		GotoState('ClientAltFiring');
	InstFlash = default.InstFlash;
	return true;
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;
	local Projectile Proj;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustToss(ProjSpeed, Start, 0, True, (bWarn || (FRand() < 0.4)));
	class'B227_Projectile'.default.B227_DamageWeaponClass = Class;
	Proj = Spawn(ProjClass,,, Start,AdjustedAim);
	class'B227_Projectile'.default.B227_DamageWeaponClass = none;
	return Proj;
}

function PlayAltFiring()
{
	PlaySound(Sound'Botpack.BioRifle.BioAltRep', SLOT_Misc, 1.3*Pawn(Owner).SoundDampening);	 //loading goop
	PlayAnim('Charging',0.24,0.05);
}

/* Weapon's client states are removed in this conversion
///////////////////////////////////////////////////////
state ClientAltFiring
{
	simulated function Tick(float DeltaTime)
	{
		if ( bBurst )
			return;
		if ( !bCanClientFire || (Pawn(Owner) == None) )
			GotoState('');
		else if ( Pawn(Owner).bAltFire == 0 )
		{
			PlayAltBurst();
			bBurst = true;
		}
	}

	simulated function AnimEnd()
	{
		if ( bBurst )
		{
			bBurst = false;
			Super.AnimEnd();
		}
		else
			TweenAnim('Loaded', 0.5);
	}
}
*/

state AltFiring
{
	ignores AnimEnd;

	function Tick( float DeltaTime )
	{
		//SetLocation(Owner.Location);
		if ( ChargeSize < 4.1 )
		{
			Count += DeltaTime;
			if ( (Count > 0.5) && AmmoType.UseAmmo(1) )
			{
				ChargeSize += Count;
				Count = 0;
				if ( (PlayerPawn(Owner) == None) && (FRand() < 0.2) )
					GoToState('ShootLoad');
			}
		}
		if( (pawn(Owner).bAltFire==0) )
			GoToState('ShootLoad');
	}

	function BeginState()
	{
		ChargeSize = 0.0;
		Count = 0.0;
	}

	function EndState()
	{
		ChargeSize = FMin(ChargeSize, 4.1);
	}

Begin:
	FinishAnim();
}

state ShootLoad
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

	function Timer()
	{
		local rotator R;
		local vector start, X,Y,Z;

		class'B227_Projectile'.default.B227_DamageWeaponClass = Class;

		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
		R = Owner.Rotation;
		R.Yaw = R.Yaw + Rand(8000) - 4000;
		R.Pitch = R.Pitch + Rand(1000) - 500;
		Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		Spawn(AltProjectileClass,,, Start,R);

		R = Owner.Rotation;
		R.Yaw = R.Yaw + Rand(8000) - 4000;
		R.Pitch = R.Pitch + Rand(1000) - 500;
		Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		Spawn(AltProjectileClass,,, Start,R);

		class'B227_Projectile'.default.B227_DamageWeaponClass = none;
	}

	function AnimEnd()
	{
		Finish();
	}

	function BeginState()
	{
		Local Projectile Gel;

		Gel = ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
		Gel.DrawScale = 1.0 + 0.8 * ChargeSize;
		PlayAltBurst();
		if (Affector != none)
			Affector.FireEffect();
	}

Begin:
}


// Finish a firing sequence
function Finish()
{
	local bool bForce, bForceAlt;

	bForce = bForceFire;
	bForceAlt = bForceAltFire;
	bForceFire = false;
	bForceAltFire = false;

	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( PlayerPawn(Owner) == None )
	{
		Pawn(Owner).bAltFire = 0;
		Super.Finish();
	}
	else if ( (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) )
		GotoState('Idle');
	else if ( (Pawn(Owner).bFire!=0) || bForce )
		Global.Fire(0);
	else if ( (Pawn(Owner).bAltFire!=0) || bForceAlt )
		Global.AltFire(0);
	else
		GotoState('Idle');
}

function PlayAltBurst()
{
	if ( Owner.IsA('PlayerPawn') )
		PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
	PlaySound(FireSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening);	//shoot goop
	PlayAnim('Fire',0.4, 0.05);
}

function PlayFiring()
{
	PlaySound(AltFireSound, SLOT_None, 1.7*Pawn(Owner).SoundDampening);	//fast fire goop
	LoopAnim('Fire',0.65 + 0.4 * FireAdjust, 0.05);
}

defaultproperties
{
	WeaponDescription="Classification: Toxic Rifle\n\nPrimary Fire: Wads of Tarydium byproduct are lobbed at a medium rate of fire.\n\nSecondary Fire: When trigger is held down, the BioRifle will create a much larger wad of byproduct. When this wad is launched, it will burst into smaller wads which will adhere to any surfaces.\n\nTechniques: Byproducts will adhere to walls, floors, or ceilings. Chain reactions can be caused by covering entryways with this lethal green waste."
	InstFlash=-0.150000
	InstFog=(X=139.000000,Y=218.000000,Z=72.000000)
	AmmoName=Class'Botpack.BioAmmo'
	PickupAmmoCount=25
	bAltWarnTarget=True
	bRapidFire=True
	FiringSpeed=1.000000
	FireOffset=(X=12.000000,Y=-11.000000,Z=-6.000000)
	ProjectileClass=Class'Botpack.UT_BioGel'
	AltProjectileClass=Class'Botpack.BioGlob'
	AIRating=0.600000
	RefireRate=0.900000
	AltRefireRate=0.700000
	FireSound=Sound'UnrealI.BioRifle.GelShot'
	AltFireSound=Sound'UnrealI.BioRifle.GelShot'
	CockingSound=Sound'UnrealI.BioRifle.GelLoad'
	SelectSound=Sound'UnrealI.BioRifle.GelSelect'
	DeathMessage="%o drank a glass of %k's dripping green load."
	NameColor=(R=0,B=0)
	AutoSwitchPriority=3
	InventoryGroup=3
	PickupMessage="You got the GES BioRifle."
	ItemName="GES Bio Rifle"
	PlayerViewOffset=(X=1.700000,Y=-0.850000,Z=-0.950000)
	PlayerViewMesh=LodMesh'Botpack.BRifle2'
	BobDamping=0.972000
	PickupViewMesh=LodMesh'Botpack.BRifle2Pick'
	ThirdPersonMesh=LodMesh'Botpack.BRifle23'
	StatusIcon=Texture'Botpack.Icons.UseBio'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Icon=Texture'Botpack.Icons.UseBio'
	Mesh=LodMesh'Botpack.BRifle2Pick'
	bNoSmooth=False
	CollisionHeight=19.000000
}
