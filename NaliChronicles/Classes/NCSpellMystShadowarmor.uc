// A better magic armor spell that covers the player with magical armor
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellMystShadowarmor extends NCProtectSpell;

defaultproperties
{
     armorpersecond=25.000000
     faildamage=4.000000
     Enchantment=Class'NaliChronicles.NCShadowArmor'
     mintime=0.100000
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant06'
     manapersecond=2.500000
     InfoTexture=Texture'NaliChronicles.Icons.MystShadowarmorInfo'
     Book=5
     recycletime=3.000000
     casttime=4.000000
     magicsparkskin(0)=Texture'Botpack.utsmoke.s3r_a00'
     magicsparkskin(1)=Texture'Botpack.utsmoke.us10_a00'
     magicsparkskin(2)=Texture'Botpack.utsmoke.US3_A00'
     magicsparkskin(3)=Texture'Botpack.utsmoke.us4_a00'
     magicsparkskin(4)=Texture'Botpack.utsmoke.us5_a00'
     magicsparkskin(5)=Texture'Botpack.Effects.jenergy2'
     magicsparkskin(6)=Texture'Botpack.Effects.jenergy3'
     magicsparkskin(7)=FireTexture'UnrealShare.Effect16.fireeffect16'
     magicspark=Class'NaliChronicles.NCDarkSpark'
     magicsparkcolor=0.000000
     PickupMessage="You got the shadow armor spell"
     ItemName="Shadow Armor"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.MystShadowarmor'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolld'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
