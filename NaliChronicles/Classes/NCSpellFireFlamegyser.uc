// A spell that creates a gyser that spouts flames
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellFireFlamegyser extends NCEnchantSpell;

defaultproperties
{
     Range=1500.000000
     faildamage=3.000000
     EnchantEffect=Class'NaliChronicles.NCFireEnchantEffect'
     Enchantment=Class'NaliChronicles.NCPawnEnchantFlamegyser'
     bTargeted=False
     bNoExp=True
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant04'
     manapersecond=3.000000
     InfoTexture=Texture'NaliChronicles.Icons.FireFlamegyserInfo'
     Book=3
     casttime=3.000000
     magicsparkskin(0)=Texture'Botpack.Effects.gbProj1'
     magicsparkskin(1)=Texture'Botpack.Effects.jenergy3'
     magicsparkskin(2)=Texture'Botpack.FlakGlow.fglow_a00'
     magicsparkskin(3)=Texture'Botpack.UT_Explosions.exp1_a00'
     magicsparkskin(4)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(5)=FireTexture'UnrealShare.Effect1.FireEffect1pb'
     magicsparkskin(6)=FireTexture'UnrealShare.Effect1.FireEffect1p'
     magicsparkskin(7)=Texture'UnrealShare.MainEffect.e1_a00'
     magicsparkcolor=32.000000
     PickupMessage="You got the volcano spell"
     ItemName="Volcano"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.FireFlamegyser'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollf'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
