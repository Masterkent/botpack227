//=============================================================================
// SuperShockRifle.
//=============================================================================
class SuperShockRifle extends ShockRifle;

#exec MESH IMPORT MESH=sshockm ANIVFILE=MODELS\ASMD2_a.3D DATAFILE=MODELS\ASMD2_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=sshockm X=0 Y=0 Z=0 YAW=64 PITCH=0
#exec MESH SEQUENCE MESH=sshockm SEQ=All       STARTFRAME=0  NUMFRAMES=52
#exec MESH SEQUENCE MESH=sshockm SEQ=Select    STARTFRAME=0  NUMFRAMES=15 RATE=30 GROUP=Select
#exec MESH SEQUENCE MESH=sshockm SEQ=Still     STARTFRAME=15 NUMFRAMES=1
#exec MESH SEQUENCE MESH=sshockm SEQ=Down      STARTFRAME=17 NUMFRAMES=7  RATE=27
#exec MESH SEQUENCE MESH=sshockm SEQ=Still2    STARTFRAME=28 NUMFRAMES=2
#exec MESH SEQUENCE MESH=sshockm SEQ=Fire1     STARTFRAME=30 NUMFRAMES=10  RATE=22
#exec MESH SEQUENCE MESH=sshockm SEQ=Fire2     STARTFRAME=40 NUMFRAMES=10  RATE=24
#exec TEXTURE IMPORT NAME=SASMD_t FILE=MODELS\ASMDS.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=SASMD_t1 FILE=MODELS\ASMDS1.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=SASMD_t2 FILE=MODELS\ASMD2.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=SASMD_t3 FILE=MODELS\ASMDS3.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=SASMD_t4 FILE=MODELS\ASMDS4.PCX GROUP="Skins" LODSET=2
#exec MESHMAP SCALE MESHMAP=sshockm X=0.004 Y=0.003 Z=0.008
#exec MESHMAP SETTEXTURE MESHMAP=sshockm NUM=0 TEXTURE=SASMD_t1
#exec MESHMAP SETTEXTURE MESHMAP=sshockm NUM=1 TEXTURE=SASMD_t2
#exec MESHMAP SETTEXTURE MESHMAP=sshockm NUM=2 TEXTURE=SASMD_t3
#exec MESHMAP SETTEXTURE MESHMAP=sshockm NUM=3 TEXTURE=SASMD_t4

#exec MESH IMPORT MESH=SASMD2hand ANIVFILE=MODELS\ASMDhand_a.3D DATAFILE=MODELS\asmdhand_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=SASMD2hand X=25 Y=600 Z=-40 YAW=64 PITCH=0
#exec MESH SEQUENCE MESH=SASMD2hand SEQ=All   STARTFRAME=0  NUMFRAMES=10
#exec MESH SEQUENCE MESH=SASMD2hand SEQ=Still STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=SASMD2hand SEQ=Fire1 STARTFRAME=1  NUMFRAMES=9  RATE=24
#exec MESH SEQUENCE MESH=SASMD2hand SEQ=Fire2 STARTFRAME=1  NUMFRAMES=9  RATE=24
#exec MESHMAP SCALE MESHMAP=SASMD2hand X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=SASMD2hand NUM=1 TEXTURE=SASMD_t

var() bool B227_bUseAmmo;

function Fire(float Value)
{
	if (B227_bUseAmmo && AmmoType != none && !AmmoType.UseAmmo(1))
		return;
	GotoState('NormalFire');
	bCanClientFire = true;
	bPointing=True;
	ClientFire(value);
	if ( bRapidFire || (FiringSpeed > 0) )
		Pawn(Owner).PlayRecoil(FiringSpeed);
	if ( bInstantHit )
		TraceFire(0.0);
	else
		ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
}

function AltFire(float Value)
{
	if (Owner == none)
		return;

	if (B227_bUseAmmo && AmmoType != none && !AmmoType.UseAmmo(1))
		return;
	GotoState('AltFiring');
	Pawn(Owner).PlayRecoil(FiringSpeed);
	bCanClientFire = true;
	bPointing=True;
	TraceFire(0.0);
	ClientAltFire(value);
}

function float RateSelf( out int bUseAltMode )
{
	if (AmmoType != none && AmmoType.AmmoAmount <= 0)
		return -2;

	bUseAltMode = 0;
	return AIRating;
}

simulated function PlayFiring()
{
	B227_PlaySound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	LoopAnim('Fire1', 0.20 + 0.20 * FireAdjust,0.05);
}

simulated function PlayAltFiring()
{
	B227_PlaySound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	LoopAnim('Fire1', 0.20 + 0.20 * FireAdjust,0.05);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	B227_SpawnBeamEffects(Other, HitLocation, HitNormal, X, Y, Z);

	if (ShockProj(Other) != none)
		ShockProj(Other).SuperExplosion();
	else
		Spawn(class'ut_SuperRing2',,, HitLocation+HitNormal*8,rotator(HitNormal));

	if ( (Other != self) && (Other != Owner) && (Other != None) ) 
		Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 60000.0*X, MyDamageType);
}

static function B227_SpawnShockBeam(Actor Spawner, vector BeamLocation, rotator BeamRotation, vector MoveAmount, int NumPuffs)
{
	local SuperShockBeam Beam;

	Beam = Spawner.Spawn(class'SuperShockBeam',,, BeamLocation, BeamRotation);
	if (Beam == none)
		return;
	Beam.MoveAmount = MoveAmount;
	Beam.NumPuffs = NumPuffs;
}

defaultproperties
{
	hitdamage=1000
	InstFog=(X=800.000000,Z=0.000000)
	AmmoName=Class'Botpack.SuperShockCore'
	aimerror=650.000000
	DeathMessage="%k electrified %o with the %w."
	PickupMessage="You got the enhanced Shock Rifle."
	ItemName="Enhanced Shock Rifle"
	PlayerViewMesh=LodMesh'Botpack.sshockm'
	ThirdPersonMesh=LodMesh'Botpack.SASMD2hand'
	MultiSkins(1)=Texture'Botpack.SASMD_t'
}
