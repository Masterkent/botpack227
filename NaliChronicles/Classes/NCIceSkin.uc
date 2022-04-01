// A better magical armor
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCIceSkin extends NCProtectEffect;

defaultproperties
{
     timeBeforeDecay=40.000000
     decayTimePerArmor=0.500000
     newHandSkin=Texture'NaliChronicles.Skins.handskinIce'
     NewSkin=Texture'NaliChronicles.Skins.NaliIceSkin'
     Charge=60
     ArmorAbsorption=99
     AbsorptionPriority=9
     Icon=Texture'NaliChronicles.Icons.WaterIceskinBarIcon'
}
