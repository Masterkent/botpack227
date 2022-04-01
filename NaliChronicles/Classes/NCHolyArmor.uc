// A better magical armor
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCHolyArmor extends NCProtectEffect;

defaultproperties
{
     timeBeforeDecay=240.000000
     decayTimePerArmor=0.750000
     newHandSkin=Texture'NaliChronicles.Skins.handskinholy'
     NewSkin=Texture'NaliChronicles.Skins.NaliHolyArmor'
     Charge=100
     ArmorAbsorption=95
     Icon=Texture'NaliChronicles.Icons.HolyChainmailBarIcon'
}
