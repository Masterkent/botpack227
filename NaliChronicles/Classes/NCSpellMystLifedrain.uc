// Drains health from target and transfers it to player
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellMystLifedrain extends NCEnchantSpell;

defaultproperties
{
     Range=1500.000000
     faildamage=4.000000
     EnchantEffect=Class'NaliChronicles.NCDarkEnchantEffect'
     Enchantment=Class'NaliChronicles.NCPawnEnchantLifedrain'
     bNoExp=True
     manapersecond=5.500000
     InfoTexture=Texture'NaliChronicles.Icons.MystLifedrainInfo'
     Book=5
     recycletime=1.500000
     casttime=2.000000
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
     PickupMessage="You got the life drain spell"
     ItemName="Life drain"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.MystLifedrain'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolld'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
