// A spell that creates a huge storm
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellAirStorm extends NCEnchantSpell;

defaultproperties
{
     Range=2500.000000
     faildamage=6.000000
     EnchantEffect=Class'NaliChronicles.NCAirEnchantEffect'
     Enchantment=Class'NaliChronicles.NCPawnEnchantStorm'
     bTargeted=False
     bNoExp=True
     bSemiTargeted=True
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant06'
     manapersecond=3.000000
     InfoTexture=Texture'NaliChronicles.Icons.AirStormInfo'
     Book=2
     recycletime=3.500000
     casttime=5.000000
     magicsparkskin(0)=Texture'Botpack.RipperPulse.HEexpl1_a00'
     magicsparkskin(1)=Texture'Botpack.ShockExplo.asmdex_a00'
     magicsparkskin(2)=Texture'Botpack.UT_Explosions.Exp5_a00'
     magicsparkskin(3)=Texture'Botpack.utsmoke.US3_A00'
     magicsparkskin(4)=Texture'UnrealShare.DBEffect.de_A00'
     magicsparkskin(5)=FireTexture'UnrealShare.Effect17.fireeffect17'
     magicsparkskin(6)=FireTexture'UnrealShare.Effect2.FireEffect2'
     magicsparkskin(7)=Texture'UnrealShare.Effects.SmokeE3'
     magicsparkcolor=152.000000
     Difficulty=0.800000
     PickupMessage="You got the storm spell"
     ItemName="Storm"
     PickupViewMesh=LodMesh'NaliChronicles.spellbook'
     Icon=Texture'NaliChronicles.Icons.AirStorm'
     Skin=Texture'NaliChronicles.Skins.Jspellbook'
     Mesh=LodMesh'NaliChronicles.spellbook'
}
