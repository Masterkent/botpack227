// A better magical armor
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCStoneSkin extends NCProtectEffect;

defaultproperties
{
     timeBeforeDecay=60.000000
     decayTimePerArmor=0.750000
     newHandSkin=Texture'NaliChronicles.Skins.handskinstone'
     NewSkin=Texture'NaliChronicles.Skins.NaliStoneSkin'
     Charge=100
     ArmorAbsorption=90
     AbsorptionPriority=7
     Icon=Texture'NaliChronicles.Icons.EarthStoneskinBarIcon'
}
