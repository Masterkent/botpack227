// A better magic armor spell that covers the player with magical armor
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellHolyDevineProtection extends NCProtectSpell;

defaultproperties
{
     armorpersecond=20.000000
     faildamage=4.000000
     Enchantment=Class'NaliChronicles.NCDevineProtection'
     mintime=0.100000
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant04'
     manapersecond=3.000000
     InfoTexture=Texture'NaliChronicles.Icons.HolyDevineProtectionInfo'
     Book=4
     recycletime=4.500000
     casttime=6.000000
     magicsparkskin(0)=Texture'UnrealShare.Effects.T_PBurst'
     magicsparkskin(1)=Texture'Botpack.RipperPulse.HEexpl1_a01'
     magicsparkskin(2)=Texture'Botpack.RipperPulse.HEexpl1_a03'
     magicsparkskin(3)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(4)=Texture'UnrealShare.DBEffect.de_A00'
     magicsparkskin(5)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(6)=Texture'UnrealShare.Effects.T_PBurst'
     magicsparkskin(7)=Texture'UnrealShare.SKEffect.Skj_a00'
     magicspark=Class'NaliChronicles.NCHolySpark'
     magicsparkcolor=152.000000
     Difficulty=0.800000
     PickupMessage="You got the devine protection spell"
     ItemName="Devine protection"
     PickupViewMesh=LodMesh'NaliChronicles.spellbook'
     Icon=Texture'NaliChronicles.Icons.HolyDevineProtection'
     Skin=Texture'NaliChronicles.Skins.Jspellbook'
     Mesh=LodMesh'NaliChronicles.spellbook'
}
