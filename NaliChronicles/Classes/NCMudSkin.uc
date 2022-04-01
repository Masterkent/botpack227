// A simple magical armor
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCMudSkin extends NCProtectEffect;

defaultproperties
{
     timeBeforeDecay=30.000000
     decayTimePerArmor=0.500000
     newHandSkin=Texture'NaliChronicles.Skins.handskinmud'
     NewSkin=Texture'NaliChronicles.Skins.NaliMudSkin'
     Charge=60
     ArmorAbsorption=80
     AbsorptionPriority=2
     Icon=Texture'NaliChronicles.Icons.EarthMudskinBarIcon'
}
