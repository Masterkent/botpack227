// An earth spell that fires a rather massive boulder
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellEarthBoulder extends NCProjSpell;

defaultproperties
{
     Proj=Class'NaliChronicles.NCBoulder'
     damagepersecond=80.000000
     sizepersecond=1.500000
     mintime=1.000000
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant05'
     manapersecond=1.500000
     InfoTexture=Texture'NaliChronicles.Icons.EarthBoulderInfo'
     recycletime=2.500000
     casttime=4.000000
     magicsparkskin(0)=Texture'Botpack.BoltCap.pEnd_a02'
     magicsparkskin(1)=Texture'Botpack.BoltHit.phit_a02'
     magicsparkskin(2)=Texture'Botpack.GoopEx.ge1_a00'
     magicsparkskin(3)=Texture'Botpack.GoopEx.ge1_a02'
     magicsparkskin(4)=Texture'Botpack.PlasmaExplo.pblst_a03'
     magicsparkskin(5)=Texture'Botpack.PlasmaExplo.pblst_a00'
     magicsparkskin(6)=Texture'Botpack.PlasmaExplo.pblst_a02'
     magicsparkskin(7)=Texture'Botpack.BoltCap.pEnd_a00'
     magicsparkcolor=170.000000
     PickupMessage="You got the boulder spell"
     ItemName="Boulder"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.EarthBoulder'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolle'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
