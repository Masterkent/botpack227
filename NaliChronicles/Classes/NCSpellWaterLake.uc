// A spell that creates a small lake with deadly creatures that bite any who pass by
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellWaterLake extends NCEnchantSpell;

defaultproperties
{
     Range=1500.000000
     faildamage=3.000000
     EnchantEffect=Class'NaliChronicles.NCWaterEnchantEffect'
     Enchantment=Class'NaliChronicles.NCPawnEnchantLake'
     bTargeted=False
     bNoExp=True
     manapersecond=3.500000
     InfoTexture=Texture'NaliChronicles.Icons.WaterLakeInfo'
     Book=1
     recycletime=3.000000
     casttime=4.000000
     magicsparkskin(0)=Texture'Botpack.ASMDAlt.ASMDAlt_a00'
     magicsparkskin(1)=Texture'Botpack.Effects.jenergy2'
     magicsparkskin(2)=Texture'Botpack.FlareFX.utflare1'
     magicsparkskin(3)=Texture'Botpack.FlareFX.utflare8'
     magicsparkskin(4)=Texture'Botpack.FlareFX.utflare3'
     magicsparkskin(5)=Texture'Botpack.FlareFX.utflare4'
     magicsparkskin(6)=Texture'Botpack.FlareFX.utflare5'
     magicsparkskin(7)=Texture'Botpack.FlareFX.utflare6'
     magicsparkcolor=152.000000
     PickupMessage="You got the magical lake spell"
     ItemName="Magical lake"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.WaterLake'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollw'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
