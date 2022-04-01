// A simple magical armor
// Code by Sergey 'Eater' Levin

class NCWindShield extends NCProtectEffect;

var NCShieldEffect myEffect;

function Destroyed()
{
	if (myEffect != none) {
		myEffect.destroy();
	}
	Super.Destroyed();
}

function GiveTo(Pawn Other)
{
	myEffect = Spawn(Class'NaliChronicles.NCShieldEffect',,,other.location,other.rotation);
	myEffect.setOwner(Other);
	myEffect.Texture = Texture'UnrealShare.SEffect3.SmokeEffect3';
	myEffect.Mesh = Other.mesh;
	myEffect.DrawScale = Other.DrawScale;
	Super.GiveTo(Other);
}

defaultproperties
{
     timeBeforeDecay=30.000000
     decayTimePerArmor=0.500000
     Charge=100
     ArmorAbsorption=40
     Icon=Texture'NaliChronicles.Icons.AirWindshieldBarIcon'
}
