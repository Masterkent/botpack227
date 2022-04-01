// A huge flaming meteor... death and destruction
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCMeteor extends NCMagicProj;

var NCMeteorTrail trail;
var float SmokeRate;
var bool bKillInst;

state Flying
{
	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
						vector momentum, name damageType ) {
		Explode(Location,Vector(Rotation));
	}

	function ProcessTouch (Actor Other, vector HitLocation)
	{
		If ( (Other!=Instigator || bKillInst) && (NCMeteor(Other) == none) ) {
			//DealOutExp(Other);
			//Other.TakeDamage(damage,instigator,hitlocation,vector(rotation*MomentumTransfer),MyDamageType);
			Explode(HitLocation,Normal(HitLocation-Other.Location));
		}
	}

	function Explode(vector HitLocation, vector HitNormal) {
		local UT_SpriteBallExplosion s;
		local int i;
		local int j;
		local float decision;
		local float newdama;

		s = spawn(class'UT_SpriteBallExplosion',,,HitLocation + HitNormal*16);
 		s.RemoteRole = ROLE_None;
		newdama = damage;
		while (newdama > damage*0.7) {
			newdama -= 16;
			i++;
		}
		ExpHurtRadius(newdama,Damage*0.75, MyDamageType, MomentumTransfer, HitLocation );
		while (j <= i) {
			decision = Frand();
			if (decision < 0.25)
				Spawn( class 'UTChunk2',, '', HitLocation + HitNormal*16);
			else if (decision < 0.5)
				Spawn( class 'UTChunk3',, '', HitLocation + HitNormal*16);
			else if (decision < 0.75)
				Spawn( class 'UTChunk4',, '', HitLocation + HitNormal*16);
			else
				Spawn( class 'UTChunk1',, '', HitLocation + HitNormal*16);
			j++;
		}
		destroy();
	}

	function BeginState()
	{
		Super.BeginState();
		Timer();
		DesiredRotation.Pitch = Rotation.Pitch + Rand(2000) - 1000;
		DesiredRotation.Roll = Rotation.Roll + Rand(2000) - 1000;
		DesiredRotation.Yaw = Rotation.Yaw + Rand(2000) - 1000;
		if (FRand() < 0.5)
			RotationRate.Pitch = Rand(180000);
		if ( (RotationRate.Pitch == 0) || (FRand() < 0.8) )
			RotationRate.Roll = Max(0, 50000 + Rand(200000) - RotationRate.Pitch);
		Velocity = vector(Rotation) * speed;
		trail = Spawn(class'NCMeteorTrail',self,,location);
	}

	simulated function Timer()
	{
		local ut_SpriteSmokePuff b;

		if ( Region.Zone.bWaterZone || (Level.NetMode == NM_DedicatedServer) )
			Return;

		if ( Level.bHighDetailMode )
		{
			Spawn(class'LightSmokeTrail');
			SmokeRate = 152/Speed;
		}
		else
		{
			SmokeRate = 0.15 + FRand()*0.01;
			b = Spawn(class'ut_SpriteSmokePuff');
			b.RemoteRole = ROLE_None;
		}
		SetTimer(SmokeRate, false);
	}

	Begin:
	LifeSpan=Default.LifeSpan;
	//sleep(2.0);
	//setPhysics(PHYS_Falling);
}

function destroyed() {
	if (trail != none)
		trail.destroy();
	super.destroyed();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
}

defaultproperties
{
     speed=10000.000000
     MaxSpeed=20000.000000
     Damage=5.000000
     MomentumTransfer=80000
     MyDamageType=RocketDeath
     ImpactSound=Sound'UnrealI.Titan.Rockhit'
     ExplosionDecal=Class'Botpack.BlastMark'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=25.000000
     Mesh=LodMesh'NaliChronicles.meteor'
     DrawScale=0.100000
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     bProjTarget=True
     bFixedRotationDir=True
}
