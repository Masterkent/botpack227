// A spell that causes enemies to spin about, taking damage
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellAirWhirlwind extends NCEnchantSpell;

defaultproperties
{
     Range=1500.000000
     faildamage=3.000000
     EnchantEffect=Class'NaliChronicles.NCAirEnchantEffect'
     Enchantment=Class'NaliChronicles.NCPawnEnchantWhirlwind'
     mintime=0.250000
     bTargeted=False
     bNoExp=True
     manapersecond=2.000000
     InfoTexture=Texture'NaliChronicles.Icons.AirWhirlwindInfo'
     Book=2
     casttime=2.000000
     magicsparkskin(0)=Texture'Botpack.RipperPulse.HEexpl1_a00'
     magicsparkskin(1)=Texture'Botpack.ShockExplo.asmdex_a00'
     magicsparkskin(2)=Texture'Botpack.UT_Explosions.Exp5_a00'
     magicsparkskin(3)=Texture'Botpack.utsmoke.US3_A00'
     magicsparkskin(4)=Texture'UnrealShare.DBEffect.de_A00'
     magicsparkskin(5)=FireTexture'UnrealShare.Effect17.fireeffect17'
     magicsparkskin(6)=FireTexture'UnrealShare.Effect2.FireEffect2'
     magicsparkskin(7)=Texture'UnrealShare.Effects.SmokeE3'
     magicsparkcolor=152.000000
     Difficulty=1.200000
     PickupMessage="You got the whirlwind spell"
     ItemName="Whirlwind"
     Icon=Texture'NaliChronicles.Icons.AirWhirlwind'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolla'
}
