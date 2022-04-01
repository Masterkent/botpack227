//=============================================================================
// Machinegun.
//=============================================================================
class PKMgun extends TournamentWeapon;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

var() int hitdamage;
var bool bOutOfAmmo, bFiredShot;
var float ShotAccuracy;
var() texture MuzzleFlashVariations[10];
var(Sounds) sound 	Gunshot[8];

function PostBeginPlay()
{
local int rnd;

	super.PostBeginPlay();

	rnd = Rand(8);
	FireSound = Gunshot[rnd];
}

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;
	if ( Pawn(Owner).Enemy == None )
	{
		bUseAltMode = 0;
		return AIRating;
	}

	EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	bUseAltMode = int( 600 * FRand() > EnemyDist - 140 );
	return AIRating;
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local PKShellcase s;
	local vector realLoc;

	realLoc = Owner.Location + CalcDrawOffset();
	s = Spawn(class'PKShellcase',, '', realLoc + 16 * X -10 * Z + 5 * Y + FireOffset.Y * Y + Z);
	if ( s != None )
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*120);
	if (Other == Level)
	{
			Spawn(class'PKWallHit2',,, HitLocation+HitNormal, Rotator(HitNormal));
	}
	else if ((Other != self) && (Other != Owner) && (Other != None) )
	{
		if ( FRand() < 0.2 )
			X *= 5;
		Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 3000.0*X, MyDamageType);
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
		{
			if ( FRand() < 0.2 )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
			else return;
		}
		else
			Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);

	}
}

function FlashOff()
{
	AmbientGlow = 0;
}

function GenerateBullet()
{
	AmbientGlow = 250;

	bFiredShot = true;

	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ClientInstantFlash( -0.2, vect(325, 225, 95));
	if ( AmmoType.UseAmmo(1) )
		TraceFire(ShotAccuracy);
	else
		GotoState('FinishFire');
}

function TraceFire( float Accuracy )
{
	local vector RealOffset;

	RealOffset = FireOffset;
	FireOffset *= 0.35;
	Super.TraceFire(Accuracy);
	FireOffset = RealOffset;
}

function Fire( float Value )
{
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(0) )
	{
		Pawn(Owner).PlayRecoil(FiringSpeed);
		bCanClientFire = true;
		bPointing=True;
		ClientFire(value);
		ShotAccuracy = 1.6;
		GotoState('NormalFire');
	}
	else GoToState('Idle');
}

function AltFire( float Value )
{
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(0) )
	{
		Pawn(Owner).PlayRecoil(FiringSpeed);
		bCanClientFire = true;
		bPointing=True;
		ClientAltFire(value);
		ShotAccuracy = 0.01;
		GotoState('AltFiring');
	}
	else GoToState('Idle');
}

function PlayFiring()
{
	PlayAnim( 'FireOne', 1.0 );
	PlaySound(FireSound,,,,, Level.TimeDilation-0.1*FRand());
	bMuzzleFlash++;

	Default.MuzzleScale = 0.75 + 1.0 * FRand();

	if ( !Level.bDropDetail )
		MFTexture = MuzzleFlashVariations[Rand(10)];
	else
		MFTexture = MuzzleFlashVariations[Rand(5)];
}

function PlayAltFiring()
{
	PlayAnim( 'FireOne', 0.9 );
	PlaySound(FireSound,,,,, Level.TimeDilation-0.1*FRand());
	bMuzzleFlash++;

	Default.MuzzleScale = 0.75 + 1.0 * FRand();

	if ( !Level.bDropDetail )
		MFTexture = MuzzleFlashVariations[Rand(10)];
	else
		MFTexture = MuzzleFlashVariations[Rand(5)];
}

///////////////////////////////////////////////////////
state NormalFire
{
Begin:
	GenerateBullet();
	FlashCount++;
	Sleep(0.10);;
	Finish();
}

///////////////////////////////////////////////////////////////
state AltFiring
{
Begin:
	GenerateBullet();
	FlashCount++;
	Sleep(0.14);
	Finish();
}

///////////////////////////////////////////////////////////
function PlayIdleAnim()
{
	PlayAnim('Still');
}

state Idle
{

Begin:
	if (Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount>0) Fire(0.0);
	if (Pawn(Owner).bAltFire!=0 && AmmoType.AmmoAmount>0) AltFire(0.0);
	LoopAnim('Still');
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	Disable('AnimEnd');
}

function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',0.4,0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc,,,, Level.TimeDilation-0.1*FRand());
}

defaultproperties
{
     hitdamage=9
     MuzzleFlashVariations(0)=Texture'Botpack.Skins.Muz1'
     MuzzleFlashVariations(1)=Texture'Botpack.Skins.Muz2'
     MuzzleFlashVariations(2)=Texture'Botpack.Skins.Muz3'
     MuzzleFlashVariations(3)=Texture'Botpack.Skins.Muz4'
     MuzzleFlashVariations(4)=Texture'Botpack.Skins.Muz5'
     MuzzleFlashVariations(5)=Texture'Botpack.Skins.Muz6'
     MuzzleFlashVariations(6)=Texture'Botpack.Skins.Muz7'
     MuzzleFlashVariations(7)=Texture'Botpack.Skins.Muz8'
     MuzzleFlashVariations(8)=Texture'Botpack.Skins.Muz9'
     MuzzleFlashVariations(9)=Texture'Botpack.Skins.Muz9'
     Gunshot(0)=Sound'PerUnreal.mgun.PKmgun1'
     Gunshot(1)=Sound'PerUnreal.mgun.PKmgun2'
     Gunshot(2)=Sound'PerUnreal.mgun.PKmgun3'
     Gunshot(3)=Sound'PerUnreal.mgun.PKmgun4'
     Gunshot(4)=Sound'PerUnreal.mgun.PKmgun5'
     Gunshot(5)=Sound'PerUnreal.mgun.PKmgun6'
     Gunshot(6)=Sound'PerUnreal.mgun.PKmgun7'
     Gunshot(7)=Sound'PerUnreal.mgun.PKmgun8'
     AmmoName=Class'PerUnreal.PKMiniammo'
     PickupAmmoCount=100
     bInstantHit=True
     bAltInstantHit=True
     FireOffset=(X=12.000000,Y=-10.000000,Z=-15.000000)
     shakemag=120.000000
     AIRating=0.400000
     RefireRate=0.800000
     FireSound=Sound'PerUnreal.mgun.PKmgun1'
     SelectSound=Sound'PerUnreal.mgun.PKmgselect'
     DeathMessage="%o was gunned down by %k's %w."
     bDrawMuzzleFlash=True
     MuzzleScale=2.000000
     FlashY=0.160000
     FlashO=0.014000
     FlashC=0.020000
     FlashLength=0.040000
     FlashS=128
     MFTexture=Texture'Botpack.Skins.Muz9'
     AutoSwitchPriority=2
     InventoryGroup=2
     PickupMessage="You picked up a Machine gun"
     ItemName="Machine gun"
     PlayerViewOffset=(X=1.500000,Y=-2.000000,Z=-3.500000)
     PlayerViewMesh=LodMesh'PerUnreal.mgun'
     PlayerViewScale=0.200000
     PickupViewMesh=LodMesh'PerUnreal.mgunpick'
     ThirdPersonMesh=LodMesh'PerUnreal.mgun'
     StatusIcon=Texture'Botpack.Icons.UseAutoM'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzPF3'
     MuzzleFlashScale=0.180000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy'
     PickupSound=Sound'PerUnreal.Misc.PKpickup'
     Skin=Texture'PerUnreal.Skins.Jmgun1'
     Mesh=LodMesh'PerUnreal.mgun'
     bNoSmooth=False
     SoundRadius=64
     SoundVolume=255
     CollisionRadius=27.000000
     CollisionHeight=8.000000
}
