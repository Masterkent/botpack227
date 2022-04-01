//=============================================================================
// SuperShockRifle.
//=============================================================================
class SuperShockRifle extends ShockRifle;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

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
	local Pawn P;

	if (AmmoType != none && AmmoType.AmmoAmount <= 0)
		return -2;

	P = Pawn(Owner);

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
