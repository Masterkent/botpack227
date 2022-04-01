// A spell that creates a meteor shower
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellFireMeteorshower extends NCEnchantSpell;

defaultproperties
{
     Range=2500.000000
     faildamage=6.000000
     EnchantEffect=Class'NaliChronicles.NCFireEnchantEffect'
     Enchantment=Class'NaliChronicles.NCPawnEnchantMeteorshower'
     bTargeted=False
     bNoExp=True
     bSemiTargeted=True
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant06'
     manapersecond=3.400000
     InfoTexture=Texture'NaliChronicles.Icons.FireMeteorshowerInfo'
     Book=3
     recycletime=3.500000
     casttime=5.000000
     magicsparkskin(0)=Texture'Botpack.Effects.gbProj1'
     magicsparkskin(1)=Texture'Botpack.Effects.jenergy3'
     magicsparkskin(2)=Texture'Botpack.FlakGlow.fglow_a00'
     magicsparkskin(3)=Texture'Botpack.UT_Explosions.exp1_a00'
     magicsparkskin(4)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(5)=FireTexture'UnrealShare.Effect1.FireEffect1pb'
     magicsparkskin(6)=FireTexture'UnrealShare.Effect1.FireEffect1p'
     magicsparkskin(7)=Texture'UnrealShare.MainEffect.e1_a00'
     magicsparkcolor=32.000000
     Difficulty=0.800000
     PickupMessage="You got the meteor shower spell"
     ItemName="Meteor shower"
     PickupViewMesh=LodMesh'NaliChronicles.spellbook'
     Icon=Texture'NaliChronicles.Icons.FireMeteorshower'
     Skin=Texture'NaliChronicles.Skins.Jspellbook'
     Mesh=LodMesh'NaliChronicles.spellbook'
}
