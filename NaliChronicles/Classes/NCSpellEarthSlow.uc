// A spell that slows down enemies
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellEarthSlow extends NCEnchantSpell;

defaultproperties
{
     Range=1500.000000
     faildamage=3.000000
     EnchantEffect=Class'NaliChronicles.NCEarthEnchantEffect'
     Enchantment=Class'NaliChronicles.NCPawnEnchantSlow'
     mintime=0.250000
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant02'
     manapersecond=2.000000
     InfoTexture=Texture'NaliChronicles.Icons.EarthSlowInfo'
     recycletime=1.500000
     casttime=2.500000
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
     PickupMessage="You got the mire spell"
     ItemName="Mire"
     Icon=Texture'NaliChronicles.Icons.EarthSlow'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolle'
}
