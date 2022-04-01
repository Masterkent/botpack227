// A drop of rain
// Code by Sergey 'Eater' Levin, 2002

class NCRainDrop extends Projectile;

var NaliMage NaliOwner;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetRotation(rot(16384,0,0));
	Velocity = vect(0,0,0);
}

auto state Flying
{
	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		PlaySound(ImpactSound, SLOT_Interact);
		Other.TakeDamage(damage,NaliOwner,hitlocation,vector(rotation*100),'slimed');
		if ((NaliOwner != None) && (other != naliowner) && (pawn(other) != none) && (nali(other) == none) && (naliwarrior(other) == none))
			NaliOwner.GainExp(2,damage);
		Destroy();
	}

	simulated function Landed(vector HitNormal)
	{
		HitWall(HitNormal, None);
	}

	function MakeSound()
	{
		PlaySound(ImpactSound, SLOT_Misc);
	}

	simulated function HitWall (vector HitNormal, actor Wall)
	{
		local waterring w;

		MakeSound();
		w = Spawn(Class'waterring',,,location+HitNormal*4,rotator(HitNormal));
		w.DrawScale = 0.05;
		w.RemoteRole = ROLE_None;
		destroy();
	}

Begin:
	SetPhysics(PHYS_Falling);
}

defaultproperties
{
     Damage=2.000000
     ImpactSound=Sound'UnrealShare.General.Drip1'
     bNetTemporary=False
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=10.000000
     Texture=Texture'UnrealShare.Belt_fx.ShieldBelt.newblue'
     Mesh=LodMesh'UnrealShare.bolt1'
     DrawScale=0.500000
     bMeshEnviroMap=True
}
