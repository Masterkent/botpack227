// Weak Nali projectile
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCNaliBullet extends Projectile;

var bool bLighting;
var float DelayTime;
var bool bVelocInit;
var float Count;
var RocketTrail Trail;

function destroyed() {
	if (Trail != none) Trail.destroy();
	super.destroyed();
}

/////////////////////////////////////////////////////
auto state Flying
{
	function Tick(float DeltaTime) {
		local actor b;

		Super.Tick(DeltaTime);
		if (bVelocInit) setRotation(rotator(velocity));
		Count += DeltaTime;
		if ( (Count>0.1) && (Level.NetMode!=NM_DedicatedServer) ) {
			b = Spawn(class'SpriteSmokePuff');
			b.DrawScale = 0.5;
			b.RemoteRole = ROLE_None;
			Count=0.0;
		}
	}

	simulated function ProcessTouch( Actor Other, Vector HitLocation )
	{
		local int hitdamage;
		local vector hitDir;

		if (Other != instigator && StingerProjectile(Other) == none)
		{
			if ( Role == ROLE_Authority )
			{
				hitDir = Normal(Velocity);
				if ( FRand() < 0.2 )
					hitDir *= 5;
				Other.TakeDamage(damage, instigator,HitLocation,
					(MomentumTransfer * hitDir), 'shot');
			}
			if (Trail != none) Trail.destroy();
			Destroy();
		}
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Super.HitWall(HitNormal, Wall);
		if (FRand()<0.3)
			PlaySound(ImpactSound, SLOT_Misc, 0.5,,, 0.5+FRand());
		else
			PlaySound(MiscSound, SLOT_Misc, 0.6,,,1.0);

		MakeNoise(0.3);
	  	SetPhysics(PHYS_None);
		SetCollision(false,false,false);
		RemoteRole = ROLE_None;
		Mesh = mesh'Burst';
		SetRotation( RotRand() );
		if (Trail != none) Trail.destroy();
		PlayAnim   ( 'Explo', 0.9 );
	}

	simulated function Timer()
	{
		local bubble1 b;
		if (Level.NetMode!=NM_DedicatedServer)
		{
	 		b=spawn(class'Bubble1');
 			b.DrawScale= 0.1 + FRand()*0.2;
 			b.SetLocation(Location+FRand()*vect(2,0,0)+FRand()*Vect(0,2,0)+FRand()*Vect(0,0,2));
 			b.buoyancy = b.mass+(FRand()*0.4+0.1);
 		}
		DelayTime+=FRand()*0.1+0.1;
		SetTimer(DelayTime,False);
	}

	simulated function ZoneChange( Zoneinfo NewZone )
	{
		if (NewZone.bWaterZone)
		{
			Velocity=0.7*Velocity;
			DelayTime=0.03;
			SetTimer(DelayTime,False);
			if (Trail != none) Trail.destroy();
			SetPhysics(PHYS_Falling);
		}
	}

	function BeginState()
	{
		local rotator RandRot;

		Velocity = Vector(Rotation) * speed;
		RandRot.Pitch = FRand() * 200 - 100;
		RandRot.Yaw = FRand() * 200 - 100;
		RandRot.Roll = FRand() * 200 - 100;
		Velocity = Velocity >> RandRot;
		if( Region.zone.bWaterZone ) {
			Velocity=0.7*Velocity;
			SetPhysics(PHYS_Falling);
		}
		else {
			Trail = Spawn(class'RocketTrail',self);
			Trail.drawscale *= 0.3;
		}
		bVelocInit = True;
	}

	Begin:
	sleep(0.25);
	if (Trail != none) Trail.destroy();
	SetPhysics(PHYS_Falling);
}

///////////////////////////////////////////////////////
simulated function Explode(vector HitLocation, vector HitNormal)
{
}

simulated function AnimEnd()
{
	Destroy();
}

defaultproperties
{
     speed=1600.000000
     Damage=16.000000
     MomentumTransfer=4000
     ImpactSound=Sound'UnrealShare.Stinger.Ricochet'
     MiscSound=Sound'UnrealShare.Razorjack.BladeHit'
     ExplosionDecal=Class'Botpack.Pock'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=30.000000
     AnimRate=1.000000
     Mesh=LodMesh'NaliChronicles.nalibullet'
     AmbientGlow=215
     bNoSmooth=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=80
     LightHue=152
     LightSaturation=32
     LightRadius=5
     LightPeriod=50
     bBounce=True
     Mass=2.000000
}
