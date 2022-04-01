// A simply earth spell that fires a mud ball
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellEarthMudball extends NCProjSpell;

defaultproperties
{
     Proj=Class'NaliChronicles.NCMudBall'
     damagepersecond=60.000000
     sizepersecond=2.000000
     mintime=0.000001
     manapersecond=1.000000
     InfoTexture=Texture'NaliChronicles.Icons.EarthMudballInfo'
     recycletime=0.250000
     magicsparkskin(0)=Texture'Botpack.BoltCap.pEnd_a02'
     magicsparkskin(1)=Texture'Botpack.BoltHit.phit_a02'
     magicsparkskin(2)=Texture'Botpack.GoopEx.ge1_a00'
     magicsparkskin(3)=Texture'Botpack.GoopEx.ge1_a02'
     magicsparkskin(4)=Texture'Botpack.PlasmaExplo.pblst_a03'
     magicsparkskin(5)=Texture'Botpack.PlasmaExplo.pblst_a00'
     magicsparkskin(6)=Texture'Botpack.PlasmaExplo.pblst_a02'
     magicsparkskin(7)=Texture'Botpack.BoltCap.pEnd_a00'
     magicsparkcolor=170.000000
     Difficulty=1.200000
     PickupMessage="You got the mud ball spell"
     ItemName="Mud ball"
     Icon=Texture'NaliChronicles.Icons.EarthMudball'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolle'
}
