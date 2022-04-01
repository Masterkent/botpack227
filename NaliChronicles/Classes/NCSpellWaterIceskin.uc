// A better magic armor spell that gives the player "ice skin"
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellWaterIceskin extends NCProtectSpell;

defaultproperties
{
     armorpersecond=20.000000
     faildamage=4.000000
     Enchantment=Class'NaliChronicles.NCIceSkin'
     mintime=0.100000
     manapersecond=3.666666
     InfoTexture=Texture'NaliChronicles.Icons.WaterIceskinInfo'
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
     PickupMessage="You got the ice skin spell"
     ItemName="Ice skin"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.WaterIceskin'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollw'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
