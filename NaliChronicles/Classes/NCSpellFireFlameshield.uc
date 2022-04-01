// A magic armor that puts a shield of flames, offering little protection but great destructive power
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellFireFlameshield extends NCProtectSpell;

defaultproperties
{
     armorpersecond=25.000000
     faildamage=4.000000
     Enchantment=Class'NaliChronicles.NCFireShield'
     mintime=0.100000
     bHarmless=False
     manapersecond=4.666666
     InfoTexture=Texture'NaliChronicles.Icons.FireFlameshieldInfo'
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
     PickupMessage="You got the fire shield spell"
     ItemName="Flame shield"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.FireFlameshield'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollf'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
