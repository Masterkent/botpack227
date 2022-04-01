// A better magic armor spell that covers the player with magical armor
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellWaterSeaShield extends NCProtectSpell;

defaultproperties
{
     armorpersecond=30.000000
     faildamage=4.000000
     Enchantment=Class'NaliChronicles.NCSeashield'
     mintime=0.100000
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant01'
     manapersecond=3.000000
     InfoTexture=Texture'NaliChronicles.Icons.WaterSeashieldInfo'
     Book=1
     recycletime=4.000000
     casttime=5.000000
     magicsparkskin(0)=Texture'Botpack.ASMDAlt.ASMDAlt_a00'
     magicsparkskin(1)=Texture'Botpack.Effects.jenergy2'
     magicsparkskin(2)=Texture'Botpack.FlareFX.utflare1'
     magicsparkskin(3)=Texture'Botpack.FlareFX.utflare8'
     magicsparkskin(4)=Texture'Botpack.FlareFX.utflare3'
     magicsparkskin(5)=Texture'Botpack.FlareFX.utflare4'
     magicsparkskin(6)=Texture'Botpack.FlareFX.utflare5'
     magicsparkskin(7)=Texture'Botpack.FlareFX.utflare6'
     magicsparkcolor=170.000000
     Difficulty=0.800000
     PickupMessage="You got the sea shield spell"
     ItemName="Sea shield"
     PickupViewMesh=LodMesh'NaliChronicles.spellbook'
     Icon=Texture'NaliChronicles.Icons.WaterSeashield'
     Skin=Texture'NaliChronicles.Skins.Jspellbook'
     Mesh=LodMesh'NaliChronicles.spellbook'
}
