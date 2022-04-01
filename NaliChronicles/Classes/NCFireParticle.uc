// A fire particle, used in flames and for special effects
// Code by Sergey 'Eater' Levin, 2001

class NCFireParticle extends AnimSpriteEffect;

var() float RisingRate;
var() float Damage;

simulated function BeginPlay()
{
	Velocity = Vect(0,0,1)*RisingRate;
	if (Texture == None) Texture = Texture'S_Actor';
}

function Touch(Actor Other) {
	if (damage>0)
		Other.TakeDamage(Damage, None, Location, vect(0,0,0), 'burned');
	destroy();
}

defaultproperties
{
     RisingRate=50.000000
     bNetOptional=True
     Physics=PHYS_Projectile
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=1.500000
     DrawType=DT_SpriteAnimOnce
     Style=STY_Translucent
     DrawScale=2.000000
     bCollideActors=True
     LightBrightness=10
     LightHue=0
     LightSaturation=255
     LightRadius=7
     bCorona=False
}
