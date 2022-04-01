// Creates a "sanctuary" where the player can hide from monsters
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellHolySanctuary extends NCEnchantSpell;

defaultproperties
{
     Range=1500.000000
     faildamage=3.000000
     EnchantEffect=Class'NaliChronicles.NCHolyEnchantEffect'
     Enchantment=Class'NaliChronicles.NCPawnEnchantSanctuary'
     mintime=3.500000
     bTargeted=False
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant01'
     manapersecond=2.500000
     InfoTexture=Texture'NaliChronicles.Icons.HolySanctuaryInfo'
     Book=4
     recycletime=2.500000
     casttime=4.000000
     magicsparkskin(0)=Texture'UnrealShare.Effects.T_PBurst'
     magicsparkskin(1)=Texture'Botpack.RipperPulse.HEexpl1_a01'
     magicsparkskin(2)=Texture'Botpack.RipperPulse.HEexpl1_a03'
     magicsparkskin(3)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(4)=Texture'UnrealShare.DBEffect.de_A00'
     magicsparkskin(5)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(6)=Texture'UnrealShare.Effects.T_PBurst'
     magicsparkskin(7)=Texture'UnrealShare.SKEffect.Skj_a00'
     magicspark=Class'NaliChronicles.NCHolySpark'
     magicsparkcolor=152.000000
     PickupMessage="You got the sanctuary spell"
     ItemName="Sanctuary"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.HolySanctuary'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollh'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
