// Adds to a player's casting skill
// Code by Sergey 'Eater' Levin, 2001

// leaf - 20%, magic - 35%, dark - 30%, power - 15%
// for vial: 3 leaf, 2 power, 5 dark, 5 magic

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSkillBottle extends NCSkillVial;

defaultproperties
{
     maxcount=5
     infotex=Texture'NaliChronicles.Icons.skillbottleInfo'
     ExpireMessage="This bottle is empty"
     PickupMessage="You got a casting potion bottle"
     ItemName="casting potion bottle"
     PickupViewMesh=LodMesh'NaliChronicles.manabottle'
     Charge=25
     Icon=Texture'NaliChronicles.Icons.skillbottle'
     Skin=Texture'NaliChronicles.Skins.Jskillbottle'
     Mesh=LodMesh'NaliChronicles.manabottle'
}
