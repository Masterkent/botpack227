class HugeFlak extends INFIL_UTM2_50;

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

function FireTracer(bool bHidden)
{
	local Vector X,Y,Z, OffSet, OffsetForMuzzle;
	local INFUT_ADD_BallisticProj p;
	local INFUT_ADD_BallisticHidden h;
	local Rotator StartRot, AltRotation;
	local Projectile S;
	local int i;

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

	/*if (bHidden)
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
		//if (ProjectileClass != None)
		//{
		//	p = Spawn (ProjectileClass,cControler,, OffSet, Rotation);
		//	if (p != None)
		//		p.shooter = cControler;
		//}
	}*/
        for(i=0; i<5; i++)
        {
        	AltRotation = Rotation;
				AltRotation.Pitch += FRand()*3000-1500;
				AltRotation.Yaw += FRand()*3000-1500;
	      AltRotation.Roll += FRand()*9000-4500;
                Spawn( class 'UTChunk2',, '', OffSet - 2 * VRand(),AltRotation);
         	Spawn( class 'UTChunk3',, '', OffSet - 2 * VRand(),AltRotation);
         	Spawn( class 'UTChunk4',, '', OffSet - 2 * VRand(),AltRotation);
         	Spawn( class 'UTChunk1',, '', OffSet - 2 * VRand(),AltRotation);
        }

}

defaultproperties
{
     AmmoAmount=500
     AmmoBeltConnClass=None
     AmmoShellCaseClass=None
     ProjectileClass=Class'KKPackage.KKUTFlakShell'
     ProjectileClassHidden=Class'KKPackage.KKUTFlakShell2'
     ActivateMessage="You control the Flak"
     NoAmmoMessage="Flak has run out of ammo !"
     Sound_Activate=Sound'KKPackage.Sounds.flakuse'
     Sound_EmptyClip=Sound'KKPackage.Sounds.flakuse'
     Sound_Firing=Sound'KKPackage.Sounds.flakshoot'
     MuzzleEffectClass=Class'KKPackage.FLKMuzzle'
     MuzzleDrawScale=0.500000
     MuzzleOffset=(X=56.104481,Z=20.000000)
     bDirectional=True
     Mesh=Mesh'KKPackage.stflakc'
     DrawScale=0.500000
}
