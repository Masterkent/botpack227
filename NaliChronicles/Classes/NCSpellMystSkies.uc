// The raging skies spell - the ultimate in titan destruction
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellMystSkies extends NCEnchantSpell;

defaultproperties
{
     Range=2000.000000
     EnchantEffect=Class'NaliChronicles.NCDarkEnchantEffect'
     Enchantment=Class'NaliChronicles.NCPawnEnchantSkies'
     mintime=5.000000
     bTargeted=False
     bNoExp=True
     bSemiTargeted=True
     manapersecond=3.000000
     InfoTexture=Texture'NaliChronicles.Icons.MystSkiesInfo'
     Book=5
     recycletime=6.500000
     casttime=8.000000
     magicsparkskin(0)=Texture'Botpack.utsmoke.s3r_a00'
     magicsparkskin(1)=Texture'Botpack.utsmoke.us10_a00'
     magicsparkskin(2)=Texture'Botpack.utsmoke.US3_A00'
     magicsparkskin(3)=Texture'Botpack.utsmoke.us4_a00'
     magicsparkskin(4)=Texture'Botpack.utsmoke.us5_a00'
     magicsparkskin(5)=Texture'Botpack.Effects.jenergy2'
     magicsparkskin(6)=Texture'Botpack.Effects.jenergy3'
     magicsparkskin(7)=FireTexture'UnrealShare.Effect16.fireeffect16'
     magicspark=Class'NaliChronicles.NCDarkSpark'
     magicsparkcolor=0.000000
     Difficulty=0.800000
     PickupMessage="You got the raging skies spell"
     ItemName="Raging skies"
     PickupViewMesh=LodMesh'NaliChronicles.spellbook'
     Icon=Texture'NaliChronicles.Icons.MystSkies'
     Skin=Texture'NaliChronicles.Skins.Jspellbook'
     Mesh=LodMesh'NaliChronicles.spellbook'
}
