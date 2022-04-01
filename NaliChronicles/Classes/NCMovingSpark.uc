// A special fx projectile
// Code by Sergey 'Eater' Levin, 2002

class NCMovingSpark extends Projectile;

var float travelDist;

auto state Flying
{
	simulated function ProcessTouch( Actor H, Vector HitLocation )
	{

	}

	function vector randomizeLoc() {
		local vector newloc;

		newloc = location;
		newloc.x += -5+(10*Frand());
		newloc.y += -5+(10*Frand());
		newloc.z += -5+(10*Frand());
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
			b.Texture = Texture;
			b.MainScale = DrawScale*(1+(Frand()/2));
			b.LightSaturation=LightSaturation;
			b.LightHue=LightHue;
			b.LightBrightness=LightBrightness;
			i++;
		}
		PlaySound(ImpactSound, SLOT_Misc, 2.0,,2000, 0.5+FRand());
		destroy();
	}

	function BeginState()
	{
		//local rotator RandRot;

		Super.BeginState();
		//Velocity = Vector(Rotation) * speed;
		//SetTimer(0.2,true);
	}
}

function launch() {
	Velocity = Vector(Rotation)*speed;
	LifeSpan = travelDist/speed;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
}

defaultproperties
{
     speed=30.000000
     MomentumTransfer=4000
     MyDamageType=Burned
     ImpactSound=Sound'UnrealShare.Generic.RespawnSound'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=20.000000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'UnrealShare.Effects.T_PBurst'
     DrawScale=0.500000
     AmbientGlow=215
     bUnlit=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=128
     LightSaturation=255
     LightRadius=16
     LightPeriod=50
}
