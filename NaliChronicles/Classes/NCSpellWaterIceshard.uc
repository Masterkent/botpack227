// A simple water spell that fires an ice shard
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellWaterIceshard extends NCProjSpell;

defaultproperties
{
     Proj=Class'NaliChronicles.NCIceshard'
     damagepersecond=50.000000
     sizepersecond=1.000000
     mintime=0.000001
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant01'
     manapersecond=1.000000
     InfoTexture=Texture'NaliChronicles.Icons.WaterIceshardInfo'
     Book=1
     recycletime=0.250000
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
     PickupMessage="You got the ice shard spell"
     ItemName="Ice shard"
     Icon=Texture'NaliChronicles.Icons.WaterIceshard'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollw'
}
