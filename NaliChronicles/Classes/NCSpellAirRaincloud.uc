// A spell that creates a cloud over the enemy that rains, damaging it
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellAirRaincloud extends NCEnchantSpell;

defaultproperties
{
     Range=1500.000000
     faildamage=4.000000
     EnchantEffect=Class'NaliChronicles.NCAirEnchantEffect'
     Enchantment=Class'NaliChronicles.NCPawnEnchantRaincloud'
     bNoExp=True
     manapersecond=2.000000
     InfoTexture=Texture'NaliChronicles.Icons.AirRaincloudInfo'
     Book=2
     recycletime=2.500000
     casttime=4.000000
     magicsparkskin(0)=Texture'Botpack.RipperPulse.HEexpl1_a00'
     magicsparkskin(1)=Texture'Botpack.ShockExplo.asmdex_a00'
     magicsparkskin(2)=Texture'Botpack.UT_Explosions.Exp5_a00'
     magicsparkskin(3)=Texture'Botpack.utsmoke.US3_A00'
     magicsparkskin(4)=Texture'UnrealShare.DBEffect.de_A00'
     magicsparkskin(5)=FireTexture'UnrealShare.Effect17.fireeffect17'
     magicsparkskin(6)=FireTexture'UnrealShare.Effect2.FireEffect2'
     magicsparkskin(7)=Texture'UnrealShare.Effects.SmokeE3'
     magicsparkcolor=152.000000
     PickupMessage="You got the rain cloud spell"
     ItemName="Rain cloud"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.AirRaincloud'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolla'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
