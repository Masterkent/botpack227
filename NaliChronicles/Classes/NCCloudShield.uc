// Blocks view but good protection
// Code by Sergey 'Eater' Levin

class NCCloudShield extends NCProtectEffect;

var NCCloudShieldEffect myEffect;

function Destroyed()
{
	myEffect.destroy();
	Super.Destroyed();
}

function GiveTo(Pawn Other)
{
	myEffect = Spawn(Class'NaliChronicles.NCCloudShieldEffect',,,other.location,other.rotation);
	myEffect.setOwner(Other);
	Super.GiveTo(Other);
}

defaultproperties
{
     timeBeforeDecay=50.000000
     decayTimePerArmor=0.750000
     Charge=100
     ArmorAbsorption=90
     Icon=Texture'NaliChronicles.Icons.AirCloudshieldBarIcon'
}
