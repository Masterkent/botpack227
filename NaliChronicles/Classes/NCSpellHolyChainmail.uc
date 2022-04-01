// A better magic armor spell that covers the player with magical armor
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellHolyChainmail extends NCProtectSpell;

defaultproperties
{
     armorpersecond=25.000000
     faildamage=4.000000
     Enchantment=Class'NaliChronicles.NCHolyArmor'
     mintime=0.100000
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant02'
     manapersecond=3.000000
     InfoTexture=Texture'NaliChronicles.Icons.HolyChainmailInfo'
     Book=4
     recycletime=3.000000
     casttime=4.000000
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
     PickupMessage="You got the holy armor spell"
     ItemName="Holy Armor"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.HolyChainmail'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollh'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
