// A fire ball with a flaming trail
// Code by Sergey 'Eater' Levin, 2002

class NCLavaball extends Projectile;

var float Count;
var() texture fbTex[9];
var NaliMage NaliOwner;

auto state Flying
{
	function Tick(float DeltaTime) {
		local NCFirePuff b;

		Count += DeltaTime;
		if ( (Count>0.0125) && (Level.NetMode!=NM_DedicatedServer) ) {
			b = Spawn(class'NaliChronicles.NCFirePuff');
			b.RemoteRole = ROLE_None;
			Texture = fbTex[Rand(9)];
			b.Texture = fbTex[Rand(9)];
			b.MainScale = DrawScale;
			Count=0.0;
		}
		Super.Tick(DeltaTime);
	}

	simulated function ProcessTouch( Actor H, Vector HitLocation )
	{
		local int hitdamage;
		local vector hitDir;

		if (NCPawnEnchantFlameGyser(h) == None && NCLavaball(h) == none)
		{
			Explode(HitLocation,vector(rotation));
		}
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Explode(Location, HitNormal);
	}

	simulated function Landed( Vector HitNormal )
	{
		Explode(Location,HitNormal);
	}

	function Explode(vector HitLocation, vector HitNormal) {
		local FlameExplosion s;

		if ( (Role == ROLE_Authority) && (FRand() < 0.5) )
			MakeNoise(1.0); //FIXME - set appropriate loudness
		s = Spawn(class'FlameExplosion',,,HitLocation+HitNormal*9);
		s.RemoteRole = ROLE_None;
		s.DrawScale = DrawScale*7;
		PlaySound(ImpactSound, SLOT_Misc, 0.5,,, 0.5+FRand());
		ExpHurtRadius(Damage,100, 'exploded', MomentumTransfer, HitLocation );
		destroy();
	}

	function BeginState()
	{
		local rotator RandRot;

		Super.BeginState();

		if ( Role == ROLE_Authority )
		{
			RandRot = Rotation;
			RandRot.Pitch = 16384;
			RandRot.Pitch += FRand() * 2000 - 1000;
			RandRot.Yaw += FRand() * 2000 - 1000;
			RandRot.Roll += FRand() * 2000 - 1000;
			Velocity = Vector(RandRot) * (Speed*FRand());
			if (Region.zone.bWaterZone)
				Velocity *= 0.65;
		}
	}

	Begin:
	sleep(10.0);
	Explode(location,vector(rotation));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
}

final function ExpHurtRadius( float DamageAmount, float DamageRadius, name DamageName, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( Victims != self )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageName
			);
			if (NaliMage(Victims) == None && Nali(Victims) == none && NaliWarrior(Victims) == none && Pawn(victims) != none)
				NaliOwner.GainExp(3,damageScale * DamageAmount);
		}
	}
	bHurtEntry = false;
}

defaultproperties
{
     fbTex(0)=Texture'UnrealShare.s_Exp004'
     fbTex(1)=Texture'UnrealShare.s_Exp005'
     fbTex(2)=Texture'UnrealShare.s_Exp006'
     fbTex(3)=Texture'UnrealShare.s_Exp007'
     fbTex(4)=Texture'UnrealShare.s_Exp008'
     fbTex(5)=Texture'UnrealShare.s_Exp009'
     fbTex(6)=Texture'UnrealShare.s_Exp010'
     fbTex(7)=Texture'UnrealShare.s_Exp011'
     fbTex(8)=Texture'UnrealShare.s_Exp012'
     speed=1500.000000
     Damage=16.000000
     MomentumTransfer=4000
     MyDamageType=Burned
     ImpactSound=Sound'UnrealShare.General.Expl03'
     ExplosionDecal=Class'Botpack.BlastMark'
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     AmbientSound=Sound'Botpack.RocketLauncher.RocketFly1'
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'UnrealShare.s_Exp004'
     DrawScale=0.200000
     AmbientGlow=215
     Fatness=0
     bUnlit=True
     SoundRadius=14
     SoundVolume=255
     SoundPitch=100
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=16
     LightHue=32
     LightSaturation=8
     LightRadius=16
     LightPeriod=50
}
