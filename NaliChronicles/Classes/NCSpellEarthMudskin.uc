// A simple magic armor spell that gives the player "mud skin"
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellEarthMudskin extends NCProtectSpell;

defaultproperties
{
     armorpersecond=20.000000
     faildamage=3.000000
     Enchantment=Class'NaliChronicles.NCMudSkin'
     mintime=0.100000
     manapersecond=2.000000
     InfoTexture=Texture'NaliChronicles.Icons.EarthMudskinInfo'
     recycletime=2.500000
     casttime=3.000000
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
     PickupMessage="You got the mud skin spell"
     ItemName="Mud Skin"
     Icon=Texture'NaliChronicles.Icons.EarthMudskin'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolle'
}
