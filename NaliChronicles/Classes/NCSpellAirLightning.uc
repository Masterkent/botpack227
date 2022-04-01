// A simple air spell that fires a weak lightning bolt
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellAirLightning extends NCProjSpell;

defaultproperties
{
     Proj=Class'NaliChronicles.NCLightning'
     damagepersecond=90.000000
     sizepersecond=0.666666
     mintime=0.000001
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant01'
     manapersecond=0.666667
     InfoTexture=Texture'NaliChronicles.Icons.AirLightningInfo'
     Book=2
     recycletime=1.500000
     casttime=1.500000
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
     PickupMessage="You got the minor lightning spell"
     ItemName="Minor lightning"
     Icon=Texture'NaliChronicles.Icons.AirLightning'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolla'
}
