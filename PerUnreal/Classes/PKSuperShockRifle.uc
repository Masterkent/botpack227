//=============================================================================
// PKSuperShockRifle.
//=============================================================================
class PKSuperShockRifle extends PKShockRifle;

var() sound ShockFireSound;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

var(Sounds) sound 	LaserSound[9];

function PostBeginPlay()
{
	local int rnd;

	super.PostBeginPlay();

	rnd = Rand(9);
	ShockFireSound = LaserSound[rnd];
}

function Fire( float Value )
{
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

function AltFire( float Value )
{
	local actor HitActor;
	local vector HitLocation, HitNormal, Start;

	if ( Owner == None )
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
	local bool bNovice;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	P = Pawn(Owner);

	bUseAltMode = 0;
	return AIRating;
}

function PlayFiring()
{
	PlaySound(ShockFireSound,,,,, Level.TimeDilation-0.2*FRand());
	LoopAnim('Fire1', 0.20 + 0.20 * FireAdjust,0.05);
}

function PlayAltFiring()
{
	PlaySound(ShockFireSound,,,,, Level.TimeDilation-0.2*FRand());
	LoopAnim('Fire1', 0.20 + 0.20 * FireAdjust,0.05);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	if (Other==None)
	{
		HitNormal = -X;
		HitLocation = Owner.Location + X*10000.0;
	}

	SpawnEffect(HitLocation, Owner.Location + CalcDrawOffset() + (FireOffset.X + 20) * X + FireOffset.Y * Y + FireOffset.Z * Z);

	Spawn(class'PKSuperRing2',,, HitLocation+HitNormal*8,rotator(HitNormal));

	if ( (Other != self) && (Other != Owner) && (Other != None) )
		Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 60000.0*X, MyDamageType);
}


function SpawnEffect(vector HitLocation, vector SmokeLocation)
{
	local PKSuperShockBeam Smoke,shock;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if ( NumPoints < 1 )
		return;
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);

	Smoke = Spawn(class'PKSuperShockBeam',,,SmokeLocation,SmokeRotation);
	Smoke.MoveAmount = DVector/NumPoints;
	Smoke.NumPuffs = NumPoints - 1;
}

defaultproperties
{
     LaserSound(0)=Sound'PerUnreal.SuperShockRifle.PKlaser1'
     LaserSound(1)=Sound'PerUnreal.SuperShockRifle.PKlaser2'
     LaserSound(2)=Sound'PerUnreal.SuperShockRifle.PKlaser3'
     LaserSound(3)=Sound'PerUnreal.SuperShockRifle.PKlaser4'
     LaserSound(4)=Sound'PerUnreal.SuperShockRifle.PKlaser5'
     LaserSound(5)=Sound'PerUnreal.SuperShockRifle.PKlaser6'
     LaserSound(6)=Sound'PerUnreal.SuperShockRifle.PKlaser7'
     LaserSound(7)=Sound'PerUnreal.SuperShockRifle.PKlaser8'
     LaserSound(8)=Sound'PerUnreal.SuperShockRifle.PKlaser9'
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
