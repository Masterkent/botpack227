// A spell that sets the target on fire
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellFireBurn extends NCEnchantSpell;

defaultproperties
{
     Range=1500.000000
     faildamage=3.000000
     EnchantEffect=Class'NaliChronicles.NCFireEnchantEffect'
     Enchantment=Class'NaliChronicles.NCPawnEnchantBurn'
     bNoExp=True
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant02'
     manapersecond=2.000000
     InfoTexture=Texture'NaliChronicles.Icons.FireBurnInfo'
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
     Difficulty=1.200000
     PickupMessage="You got the burn spell"
     ItemName="Burn"
     Icon=Texture'NaliChronicles.Icons.FireBurn'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollf'
}
