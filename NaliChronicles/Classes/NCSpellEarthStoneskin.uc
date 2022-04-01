// A better magic armor spell that gives the player "stone skin"
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellEarthStoneskin extends NCProtectSpell;

defaultproperties
{
     armorpersecond=25.000000
     faildamage=4.000000
     Enchantment=Class'NaliChronicles.NCStoneSkin'
     mintime=0.100000
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant02'
     manapersecond=2.500000
     InfoTexture=Texture'NaliChronicles.Icons.EarthStoneskinInfo'
     recycletime=3.000000
     casttime=4.000000
     magicsparkskin(0)=Texture'Botpack.BoltCap.pEnd_a02'
     magicsparkskin(1)=Texture'Botpack.BoltHit.phit_a02'
     magicsparkskin(2)=Texture'Botpack.GoopEx.ge1_a00'
     magicsparkskin(3)=Texture'Botpack.GoopEx.ge1_a02'
     magicsparkskin(4)=Texture'Botpack.PlasmaExplo.pblst_a03'
     magicsparkskin(5)=Texture'Botpack.PlasmaExplo.pblst_a00'
     magicsparkskin(6)=Texture'Botpack.PlasmaExplo.pblst_a02'
     magicsparkskin(7)=Texture'Botpack.BoltCap.pEnd_a00'
     magicsparkcolor=170.000000
     PickupMessage="You got the stone skin spell"
     ItemName="Stone skin"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.EarthStoneskin'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolle'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
