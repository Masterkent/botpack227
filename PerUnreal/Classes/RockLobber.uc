//=============================================================================
// RockLobber.
//=============================================================================
class RockLobber extends PKWeapon;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

//-------------------------------------------------------
// AI related functions

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist, rating;
	local vector EnemyDir;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;
	if ( Pawn(Owner).Enemy == None )
	{
		bUseAltMode = 0;
		return AIRating;
	}
	EnemyDir = Pawn(Owner).Enemy.Location - Owner.Location;
	EnemyDist = VSize(EnemyDir);
	rating = FClamp(AIRating - (EnemyDist - 450) * 0.001, 0.2, AIRating);
	if ( EnemyDist > 600 )
	{
		if ( EnemyDir.Z < -0.5 * EnemyDist )
		{
			bUseAltMode = 1;
			return (AIRating - 0.3);
		}
		bUseAltMode = 0;
	}
	else if ( (EnemyDist < 300) || (EnemyDir.Z > 30) )
		bUseAltMode = 0;
	else
		bUseAltMode = int( FRand() < 0.65 );
	return rating;
}

// return delta to combat style
function float SuggestAttackStyle()
{
	return 0.4;
}

function float SuggestDefenseStyle()
{
	return -0.3;
}

//-------------------------------------------------------

function Fire( float Value )
{
	local Vector Start, X,Y,Z;
	local vector Momentum;

	//bFireMem = false;
	//bAltFireMem = false;
	if (AmmoType.UseAmmo(1))
	{
		CheckVisibility();
		Owner.PlaySound(FireSound, SLOT_None,,,, Level.TimeDilation-0.2*FRand());
		Owner.PlaySound(FireSound, SLOT_None,,,, Level.TimeDilation-0.6+0.2*FRand());
		PlayAnim( 'Fire', 0.9, 0.05);
		bPointing=True;
		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		GetAxes(Pawn(Owner).viewrotation,X,Y,Z);
		Start = Owner.Location + CalcDrawOffset();
		Start = Start + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		Momentum = Owner.Velocity - 200 * X + 20 * Z;
		AdjustedAim = pawn(owner).AdjustAim(ProjectileSpeed, Start, AimError, True, bWarnTarget);
		Spawn( class 'PKrock1',,, Start, AdjustedAim);
		if ( PlayerPawn(Owner) != None )
		{
			PlayerPawn(Owner).SetPhysics(PHYS_Falling);
			PlayerPawn(Owner).Velocity = (Momentum);
			PlayerPawn(Owner).ClientInstantFlash( -0.4, vect(650, 450, 190));
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}
		GoToState('NormalFire');
	}
}

function AltFire( float Value )
{
	local Vector Start, X,Y,Z;
	local vector Momentum;

	//bFireMem = false;
	//bAltFireMem = false;
	if (AmmoType.UseAmmo(1))
	{
		CheckVisibility();
		Owner.PlaySound(FireSound, SLOT_None,,,, Level.TimeDilation-0.2*FRand());
		Owner.PlaySound(FireSound, SLOT_None,,,, Level.TimeDilation-0.5+0.2*FRand());
		Owner.PlaySound(FireSound, SLOT_None,,,, Level.TimeDilation-0.8+0.2*FRand());
		PlayAnim('Fire', 0.3, 0.05);
		bPointing=True;
		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		GetAxes(Pawn(Owner).viewrotation,X,Y,Z);
		Start = Owner.Location + CalcDrawOffset();
		Start = Start + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		Momentum = Owner.Velocity - 400 * X + 40 * Z;
		AdjustedAim = pawn(owner).AdjustToss(AltProjectileSpeed, Start, AimError, True, bAltWarnTarget);	//TIM - syntax fixme
		Spawn( class 'PKrock2',,, Start, AdjustedAim);
		if ( PlayerPawn(Owner) != None )
		{
			PlayerPawn(Owner).SetPhysics(PHYS_Falling);
			PlayerPawn(Owner).Velocity = (Momentum);
			PlayerPawn(Owner).ClientInstantFlash( -0.4, vect(650, 450, 190));
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}
		GoToState('AltFiring');
	}
}

/////////////////////////////////////////////////////////////
state AltFiring
{
Begin:
	FinishAnim();
	PlayAnim('Eject',1.5, 0.05);
	Owner.PlaySound(Misc2Sound, SLOT_None,1.0*Pawn(Owner).SoundDampening,,, Level.TimeDilation-0.1*FRand());
	FinishAnim();
if (AmmoType.AmmoAmount < 1)
	Finish();
else
	PlayAnim('Loading',0.6, 0.05);
	Owner.PlaySound(CockingSound, SLOT_None,1.0*Pawn(Owner).SoundDampening,,, Level.TimeDilation+0.2*FRand());
	FinishAnim();
	Finish();
}

state NormalFire
{
Begin:
	FinishAnim();
	PlayAnim('Eject',1.5, 0.05);
	Owner.PlaySound(Misc2Sound, SLOT_None,1.0*Pawn(Owner).SoundDampening,,, Level.TimeDilation-0.1*FRand());
	FinishAnim();
if (AmmoType.AmmoAmount < 1)
	Finish();
else
	PlayAnim('Loading',0.6, 0.05);
	Owner.PlaySound(CockingSound, SLOT_None,1.0*Pawn(Owner).SoundDampening,,, Level.TimeDilation+0.2*FRand());
	FinishAnim();
	Finish();
}
///////////////////////////////////////////////////////////

function TweenDown()
{
	if ( GetAnimGroup(AnimSequence) == 'Select' )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else
	{
		if (AmmoType.AmmoAmount<=0)	PlayAnim('Down2',1.0, 0.05);
		else PlayAnim('Down',1.0, 0.05);
	}
}


function PlayIdleAnim()
{
		LoopAnim('Sway',0.01,0.3);
}

function PlayPostSelect()
{
	PlayAnim('Loading', 1.3, 0.05);
	Owner.PlaySound(CockingSound, SLOT_None,1.0*Pawn(Owner).SoundDampening,,, Level.TimeDilation+0.5+0.2*FRand());
}

defaultproperties
{
     AmmoName=Class'PerUnreal.RockAmmo'
     PickupAmmoCount=6
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     FireOffset=(X=50.000000,Y=-5.000000,Z=-8.800000)
     ProjectileClass=Class'PerUnreal.PKRock1'
     AltProjectileClass=Class'PerUnreal.PKRock2'
     shakemag=350.000000
     shaketime=0.150000
     shakevert=16.000000
     AIRating=0.800000
     FireSound=Sound'PerUnreal.RockLobber.RockLobb'
     AltFireSound=Sound'PerUnreal.RockLobber.RockLobb'
     CockingSound=Sound'PerUnreal.RockLobber.RockLoad'
     SelectSound=Sound'PerUnreal.RockLobber.RockSelect'
     Misc2Sound=Sound'PerUnreal.RockLobber.RockClick'
     DeathMessage="%o was crushed to pieces by %k's %w."
     AutoSwitchPriority=6
     InventoryGroup=6
     PickupMessage="You got the Rock Lobber"
     ItemName="Rock Lobber"
     RespawnTime=6.000000
     PlayerViewOffset=(X=2.100000,Y=-1.800000,Z=-1.750000)
     PlayerViewMesh=LodMesh'UnrealI.flak'
     PlayerViewScale=2.000000
     PickupViewMesh=LodMesh'UnrealI.FlakPick'
     ThirdPersonMesh=LodMesh'UnrealI.Flak3rd'
     StatusIcon=Texture'Botpack.Icons.UseRazor'
     PickupSound=Sound'PerUnreal.Misc.PKpickup'
     Mesh=LodMesh'UnrealI.FlakPick'
     bNoSmooth=False
     CollisionRadius=27.000000
     CollisionHeight=23.000000
}
