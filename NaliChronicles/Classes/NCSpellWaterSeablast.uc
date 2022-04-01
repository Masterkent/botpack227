// A water spell that fires a mass of sea-stuff
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellWaterSeablast extends NCProjSpell;

defaultproperties
{
     Proj=Class'NaliChronicles.NCSeaBlast'
     damagepersecond=75.000000
     sizepersecond=1.000000
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant04'
     manapersecond=1.250000
     InfoTexture=Texture'NaliChronicles.Icons.WaterSeablastInfo'
     Book=1
     recycletime=2.500000
     casttime=4.000000
     magicsparkskin(0)=Texture'Botpack.ASMDAlt.ASMDAlt_a00'
     magicsparkskin(1)=Texture'Botpack.Effects.jenergy2'
     magicsparkskin(2)=Texture'Botpack.FlareFX.utflare1'
     magicsparkskin(3)=Texture'Botpack.FlareFX.utflare8'
     magicsparkskin(4)=Texture'Botpack.FlareFX.utflare3'
     magicsparkskin(5)=Texture'Botpack.FlareFX.utflare4'
     magicsparkskin(6)=Texture'Botpack.FlareFX.utflare5'
     magicsparkskin(7)=Texture'Botpack.FlareFX.utflare6'
     magicsparkcolor=170.000000
     PickupMessage="You got the sea blast spell"
     ItemName="Sea Blast"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.WaterSeablast'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollw'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
