// A simple magic armor spell that gives the player a "wind shield"
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellAirWindShield extends NCProtectSpell;

defaultproperties
{
     faildamage=1.500000
     Enchantment=Class'NaliChronicles.NCWindShield'
     mintime=0.100000
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant05'
     manapersecond=3.000000
     InfoTexture=Texture'NaliChronicles.Icons.AirWindshieldInfo'
     Book=2
     recycletime=1.500000
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
     PickupMessage="You got the wind-shield spell"
     ItemName="Wind-shield"
     Icon=Texture'NaliChronicles.Icons.AirWindshield'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolla'
}
