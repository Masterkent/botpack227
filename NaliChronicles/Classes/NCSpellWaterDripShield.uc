// A simple magic armor spell that gives the player a "drip shield"
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellWaterDripShield extends NCProtectSpell;

defaultproperties
{
     armorpersecond=40.000000
     faildamage=3.000000
     Enchantment=Class'NaliChronicles.NCDripShield'
     mintime=0.100000
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant05'
     manapersecond=3.000000
     InfoTexture=Texture'NaliChronicles.Icons.WaterDripshieldInfo'
     Book=1
     recycletime=1.500000
     casttime=2.000000
     magicsparkskin(0)=Texture'Botpack.ASMDAlt.ASMDAlt_a00'
     magicsparkskin(1)=Texture'Botpack.Effects.jenergy2'
     magicsparkskin(2)=Texture'Botpack.FlareFX.utflare1'
     magicsparkskin(3)=Texture'Botpack.FlareFX.utflare8'
     magicsparkskin(4)=Texture'Botpack.FlareFX.utflare3'
     magicsparkskin(5)=Texture'Botpack.FlareFX.utflare4'
     magicsparkskin(6)=Texture'Botpack.FlareFX.utflare5'
     magicsparkskin(7)=Texture'Botpack.FlareFX.utflare6'
     magicsparkcolor=152.000000
     Difficulty=1.200000
     PickupMessage="You got the drip-shield spell"
     ItemName="Drip-shield"
     Icon=Texture'NaliChronicles.Icons.WaterDripshield'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollw'
}
