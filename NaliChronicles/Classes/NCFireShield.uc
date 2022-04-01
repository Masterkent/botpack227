// A magical armor that burns all who come close (HAHAHAHA!)
// Code by Sergey 'Eater' Levin, 2002

class NCFireShield extends NCProtectEffect;

var NCFireShieldHurter myEffect;

function damCaused(float dama) {
	if (dama < 0.4) return;
	NaliMage(Owner).GainExp(3,fMax(dama/5,1));
	charge -= dama/5;
}

function Destroyed()
{
	myEffect.destroy();
	Super.Destroyed();
}

function GiveTo(Pawn Other)
{
	myEffect = Spawn(Class'NaliChronicles.NCFireShieldHurter',other,,other.location,rot(0,0,0));
	myEffect.armor = self;
	Super.GiveTo(Other);
}

defaultproperties
{
     timeBeforeDecay=20.000000
     decayTimePerArmor=0.500000
     Charge=75
     ArmorAbsorption=25
     AbsorptionPriority=11
     Icon=Texture'NaliChronicles.Icons.FireFlameshieldBarIcon'
}
