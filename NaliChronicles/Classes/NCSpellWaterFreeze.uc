// A spell that temporarily freezes the enemy (or friendly) creature, health-dependant
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellWaterFreeze extends NCEnchantSpell;

defaultproperties
{
     Range=1500.000000
     faildamage=3.000000
     EnchantEffect=Class'NaliChronicles.NCWaterEnchantEffect'
     Enchantment=Class'NaliChronicles.NCPawnEnchantFreeze'
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant02'
     manapersecond=0.666667
     InfoTexture=Texture'NaliChronicles.Icons.WaterFreezeInfo'
     Book=1
     casttime=3.000000
     magicsparkskin(0)=Texture'Botpack.ASMDAlt.ASMDAlt_a00'
     magicsparkskin(1)=Texture'Botpack.Effects.jenergy2'
     magicsparkskin(2)=Texture'Botpack.FlareFX.utflare1'
     magicsparkskin(3)=Texture'Botpack.FlareFX.utflare8'
     magicsparkskin(4)=Texture'Botpack.FlareFX.utflare3'
     magicsparkskin(5)=Texture'Botpack.FlareFX.utflare4'
     magicsparkskin(6)=Texture'Botpack.FlareFX.utflare5'
     magicsparkskin(7)=Texture'Botpack.FlareFX.utflare6'
     magicsparkcolor=152.000000
     Difficulty=1.200000
     PickupMessage="You got the freeze spell"
     ItemName="Freeze"
     Icon=Texture'NaliChronicles.Icons.WaterFreeze'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollw'
}
