//=============================================================================
// Ripper
// A human modification of the Skaarj Razorjack.
//=============================================================================
class Ripper extends TournamentWeapon;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
	return Spawn(ProjClass,,, Start,AdjustedAim);
}

function PlayFiring()
{
	LoopAnim( 'Fire', 0.7 + 0.6 * FireAdjust, 0.05 );
	PlaySound(class'Razor2'.Default.SpawnSound, SLOT_None,4.2);
}


function float RateSelf( out int bUseAltMode )
{
	local Pawn P;

	if ( (AmmoType != None) && (AmmoType.AmmoAmount <=0) )
		return -2;

	P = Pawn(Owner);
	if ( (P.Enemy == None ) || (P.Enemy.Location.Z < Owner.Location.Z - 60) || (FRand() < 0.5) )
		bUseAltMode = 1;
	else
		bUseAltMode = 0;

	if ( P.Enemy != None )
	{
		if ( Owner.Location.Z > P.Enemy.Location.Z + 140 )
		{
			bUseAltMode = 1;
			return (AIRating + 0.25);
		}
		else if ( P.Enemy.Location.Z > Owner.Location.Z + 160 )
			return (AIRating - 0.07);
	}
	return (AIRating + FRand() * 0.05);
}

function AltFire( float Value )
{
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1))
	{
		GotoState('AltFiring');
		bCanClientFire = true;
		bPointing=True;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		ClientAltFire(Value);
		ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
	}
}

function PlayAltFiring()
{
	LoopAnim('Fire', 0.4 + 0.3 * FireAdjust,0.05);
	PlaySound(class'Razor2Alt'.Default.SpawnSound, SLOT_None,4.2);
}

function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		LoopAnim('Idle', 0.3,0.4);
}

function float SuggestAttackStyle()
{
	return -0.2;
}

function float SuggestDefenseStyle()
{
	return -0.2;
}

state AltFiring
{
	function bool SplashJump()
	{
		return true;
	}
}

defaultproperties
{
	WeaponDescription="Classification: Ballistic Blade Launcher\n\nPrimary Fire: Razor sharp titanium disks are launched at a medium rate of speed. Shots will ricochet off of any surfaces.\n\nSecondary Fire: Explosive disks are launched at a slow rate of fire.\n\nTechniques: Aim for the necks of your opponents."
	InstFlash=-0.300000
	InstFog=(X=400.000000,Y=200.000000)
	AmmoName=Class'Botpack.BladeHopper'
	PickupAmmoCount=15
	bSplashDamage=True
	bRecommendAltSplashDamage=True
	bRapidFire=True
	FiringSpeed=2.000000
	FireOffset=(Y=-15.000000,Z=-13.000000)
	ProjectileClass=Class'Botpack.Razor2'
	AltProjectileClass=Class'Botpack.Razor2Alt'
	shakemag=120.000000
	AIRating=0.500000
	RefireRate=1.000000
	AltRefireRate=0.830000
	SelectSound=Sound'UnrealI.Razorjack.beam'
	DeathMessage="%k ripped a chunk of meat out of %o with the %w."
	NameColor=(R=0)
	AutoSwitchPriority=6
	InventoryGroup=6
	PickupMessage="You got the Ripper."
	ItemName="Ripper"
	PlayerViewOffset=(X=3.000000,Y=-1.600000,Z=-2.400000)
	PlayerViewMesh=LodMesh'Botpack.Razor2'
	PlayerViewScale=1.400000
	BobDamping=0.975000
	PickupViewMesh=LodMesh'Botpack.RazPick2'
	ThirdPersonMesh=LodMesh'Botpack.Razor3rd2'
	StatusIcon=Texture'Botpack.Icons.UseRazor'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Icon=Texture'Botpack.Icons.UseRazor'
	Mesh=LodMesh'Botpack.RazPick2'
	bNoSmooth=False
	CollisionRadius=34.000000
	CollisionHeight=7.000000
	Mass=50.000000
}
