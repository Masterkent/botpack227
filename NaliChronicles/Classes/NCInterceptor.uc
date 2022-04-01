// Intercepts projectiles (visual only)
// Code by Sergey 'Eater' Levin, 2002

class NCInterceptor extends Projectile;

var vector targetLoc;
var vector startLoc;

function Launch() {
	setRotation(rotator(targetLoc-location));
	startLoc = location;
	velocity = 1000*vector(rotation);
}

function Tick(float DeltaTime) {
	if (VSize(location-startLoc) > VSize(targetLoc-startLoc))
		destroy();
}

auto state Flying
{
	function BeginState() {
		velocity = vect(0,0,0);
	}

	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		// ignore
	}

	function MakeSound()
	{
		PlaySound(ImpactSound, SLOT_Misc, 0.7,,256, 0.5+FRand());
	}
}

defaultproperties
{
     ImpactSound=Sound'UnrealShare.Generic.RespawnSound'
     bNetTemporary=False
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=10.000000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'UnrealShare.SKEffect.Skj_a00'
     DrawScale=0.500000
     AmbientGlow=215
     bUnlit=True
}
