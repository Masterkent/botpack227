// A fire ball with a flaming trail
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCDevineBolt extends NCMagicProj;

var float Count;
var() texture dbTex[3];

state Flying
{
	function Tick(float DeltaTime) {
		local NCFirePuff b;

		Count += DeltaTime;
		if ( (Count>0.025) && (Level.NetMode!=NM_DedicatedServer) ) {
			b = Spawn(class'NaliChronicles.NCFirePuff');
			b.RemoteRole = ROLE_None;
			Texture = dbTex[Rand(3)];
			b.Texture = dbTex[Rand(3)];
			b.MainScale = DrawScale;
			b.LightSaturation=255;
			Count=0.0;
		}
		Super.Tick(DeltaTime);
	}

	function vector randomizeLoc() {
		local vector newloc;

		newloc = location;
		newloc.x += -5+(10*Frand());
		newloc.y += -5+(10*Frand());
		newloc.z += -5+(10*Frand());
	}

	simulated function ProcessTouch( Actor H, Vector HitLocation )
	{
		local int hitdamage;
		local vector hitDir;
		local NCFirePuff b;
		local int i;

		if (h != instigator && NCDevineBolt(h) == none)
		{
			DealOutExp(H);
			H.TakeDamage(damage,instigator,HitLocation,(30000.0 * Normal(Velocity)), 'burned');
			while (i < 3) {
				b = Spawn(class'NaliChronicles.NCFirePuff',,,randomizeLoc());
				b.RemoteRole = ROLE_None;
				b.Texture = dbTex[Rand(3)];
				b.MainScale = DrawScale*(1+(Frand()/2));
				b.LightSaturation=255;
				i++;
			}
			PlaySound(ImpactSound, SLOT_Misc, 1.2,,2000, 0.5+FRand());
			//Explode(HitLocation,vector(rotation));
		}
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Explode(Location, HitNormal);
	}

	function Explode(vector HitLocation, vector HitNormal) {
		local int i;
		local NCFirePuff b;

		if ( (Role == ROLE_Authority) && (FRand() < 0.5) )
			MakeNoise(1.0); //FIXME - set appropriate loudness
		while (i < 5) {
			b = Spawn(class'NaliChronicles.NCFirePuff',,,randomizeLoc());
			b.RemoteRole = ROLE_None;
			b.Texture = dbTex[Rand(3)];
			b.MainScale = DrawScale*(1+(Frand()/2));
			b.LightSaturation=LightSaturation;
			b.LightHue=LightHue;
			i++;
		}
		PlaySound(ImpactSound, SLOT_Misc, 1.2,,2000, 0.5+FRand());
		destroy();
	}

	function BeginState()
	{
		local rotator RandRot;

		Super.BeginState();
		Velocity = Vector(Rotation) * speed;
	}

	Begin:
	sleep(10.0);
	Explode(location,vector(rotation));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
}

defaultproperties
{
     dbTex(0)=Texture'UnrealShare.SKEffect.Skj_a01'
     dbTex(1)=Texture'UnrealShare.SKEffect.Skj_a02'
     dbTex(2)=Texture'UnrealShare.SKEffect.Skj_a03'
     speed=1000.000000
     Damage=2.000000
     MomentumTransfer=4000
     MyDamageType=Burned
     ImpactSound=Sound'UnrealShare.Generic.RespawnSound'
     ExplosionDecal=Class'Botpack.BlastMark'
     RemoteRole=ROLE_SimulatedProxy
     AmbientSound=Sound'NaliChronicles.SFX.DevineBolt'
     Style=STY_Translucent
     Texture=Texture'UnrealShare.SKEffect.Skj_a01'
     Mesh=LodMesh'UnrealShare.DispM1'
     DrawScale=0.600000
     AmbientGlow=215
     bUnlit=True
     bParticles=True
     SoundRadius=128
     SoundVolume=255
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=128
     LightSaturation=255
     LightRadius=16
     LightPeriod=50
}
