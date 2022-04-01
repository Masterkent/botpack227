// A spell that makes worms attack the enemy
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellEarthWorms extends NCEnchantSpell;

defaultproperties
{
     Range=1500.000000
     faildamage=4.000000
     EnchantEffect=Class'NaliChronicles.NCEarthEnchantEffect'
     Enchantment=Class'NaliChronicles.NCPawnEnchantWorms'
     bNoExp=True
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant05'
     manapersecond=3.000000
     InfoTexture=Texture'NaliChronicles.Icons.EarthWormsInfo'
     recycletime=2.500000
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
     PickupMessage="You got the earth worms spell"
     ItemName="Earth worms"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.EarthWorms'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolle'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
