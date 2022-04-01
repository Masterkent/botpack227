class HugeStinger extends INFIL_UTM2_50;

#exec OBJ LOAD FILE="..\Textures\KKSkins.utx"

#exec OBJ LOAD FILE="KKPackageResources.u" PACKAGE=KKPackage

var() int AmmoAmount;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
    settimer(0.01, True);

	oRot = Rotation;
	cAmmoAmount = AmmoAmount;

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

defaultproperties
{
     AmmoAmount=500
     AmmoBeltConnClass=None
     AmmoShellCaseClass=None
     ProjectileClass=Class'KKPackage.KKStingerProjectile'
     ProjectileClassHidden=Class'KKPackage.KKStingerProjectile2'
     ActivateMessage="You control the Stinger"
     NoAmmoMessage="Stinger has run out of ammo !"
     Sound_Activate=Sound'UnrealShare.Stinger.StingerLoad'
     Sound_EmptyClip=Sound'UnrealShare.Stinger.StingerLoad'
     Sound_Firing=Sound'UnrealShare.Stinger.StingerFire'
     MuzzleEffectClass=Class'KKPackage.StgMuzzle'
     MuzzleDrawScale=2.000000
     MuzzleOffset=(X=210.000000,Z=12.000000)
     bDirectional=True
     Mesh=Mesh'KKPackage.ststingerg'
     DrawScale=1.000000
}
