// A simple magical armor
// Code by Sergey 'Eater' Levin

class NCSmokeShield extends NCProtectEffect;

var NCSmokeShieldEffect myEffect;

function Destroyed()
{
	myEffect.destroy();
	Super.Destroyed();
}

function GiveTo(Pawn Other)
{
	myEffect = Spawn(Class'NaliChronicles.NCSmokeShieldEffect',,,other.location,other.rotation);
	myEffect.setOwner(Other);
	Super.GiveTo(Other);
}

defaultproperties
{
     timeBeforeDecay=30.000000
     decayTimePerArmor=0.500000
     Charge=100
     ArmorAbsorption=70
     AbsorptionPriority=11
     Icon=Texture'NaliChronicles.Icons.FireSmokeShieldBarIcon'
}
