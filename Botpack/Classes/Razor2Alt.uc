//=============================================================================
// RazorBladeAlt.
//=============================================================================
class Razor2Alt extends Razor2;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Level.bDropDetail )
		LightType = LT_None;
}

auto state Flying
{
	function ProcessTouch(Actor Other, Vector HitLocation)
	{
		if (Other != Instigator)
		{
			Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
			B227_SetupProjectileExplosion(, HitLocation);
			MakeNoise(1.0);
 			Destroy();
		}
	}

	event HitWall(vector HitNormal, Actor Wall)
	{
		super(B227_Projectile).HitWall(HitNormal, Wall);
	}

	function Explode(vector HitLocation, vector HitNormal)
	{
		B227_SetupProjectileExplosion(Location, HitLocation, HitNormal);
		BlowUp(HitLocation);

 		Destroy();
	}

	function BlowUp(vector HitLocation)
	{
		local actor Victims;
		local float damageScale, dist;
		local vector dir;

		if( bHurtEntry )
			return;

		bHurtEntry = true;
		foreach VisibleCollidingActors( class 'Actor', Victims, 180, HitLocation )
		{
			if( Victims != self )
			{
				dir = Victims.Location - HitLocation;
				dist = FMax(1,VSize(dir));
				dir = dir/dist;
				dir.Z = FMin(0.45, dir.Z); 
				damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/180);
				Victims.TakeDamage
				(
					damageScale * Damage,
					Instigator, 
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					damageScale * MomentumTransfer * dir,
					MyDamageType
				);
			} 
		}
		bHurtEntry = false;
		MakeNoise(1.0);
	}
}

static function B227_Explode(
	Actor Context,
	vector Location,
	vector HitLocation,
	vector HitNormal,
	rotator Direction)
{
	local RipperPulse s;

	if (bool(HitNormal))
	{
		s = Context.Spawn(class'RipperPulse',,, HitLocation + HitNormal * 16);
		if (s != none)
			s.RemoteRole = ROLE_None;
		B227_SpawnDecal(Context, default.ExplosionDecal, Location, HitNormal);
	}
	else
	{
		s = Context.Spawn(class'RipperPulse',,, HitLocation);
		if (s != none)
			s.RemoteRole = ROLE_None;
	}
}

defaultproperties
{
	Damage=34.000000
	MomentumTransfer=87000
	MyDamageType=RipperAltDeath
	SpawnSound=Sound'Botpack.ripper.RazorAlt'
	ExplosionDecal=Class'Botpack.RipperMark'
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=23
	LightRadius=3
	B227_bReplicateExplosion=True
}
