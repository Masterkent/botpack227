// Weak shield that also obscures view
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellFireSmokeShield extends NCProtectSpell;

defaultproperties
{
     faildamage=2.000000
     Enchantment=Class'NaliChronicles.NCSmokeShield'
     mintime=0.100000
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant05'
     manapersecond=3.000000
     InfoTexture=Texture'NaliChronicles.Icons.FireSmokeShieldInfo'
     Book=3
     recycletime=1.000000
     casttime=2.000000
     magicsparkskin(0)=Texture'Botpack.Effects.gbProj1'
     magicsparkskin(1)=Texture'Botpack.Effects.jenergy3'
     magicsparkskin(2)=Texture'Botpack.FlakGlow.fglow_a00'
     magicsparkskin(3)=Texture'Botpack.UT_Explosions.exp1_a00'
     magicsparkskin(4)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(5)=FireTexture'UnrealShare.Effect1.FireEffect1pb'
     magicsparkskin(6)=FireTexture'UnrealShare.Effect1.FireEffect1p'
     magicsparkskin(7)=Texture'UnrealShare.MainEffect.e1_a00'
     magicsparkcolor=32.000000
     Difficulty=1.200000
     PickupMessage="You got the smoke-shield spell"
     ItemName="Smoke-shield"
     Icon=Texture'NaliChronicles.Icons.FireSmokeShield'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollf'
}
