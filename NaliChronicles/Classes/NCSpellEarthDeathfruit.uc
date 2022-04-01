// An earth spell that fires a fruit that explodes, planting flesh-eating plants that create more fruit
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellEarthDeathfruit extends NCProjSpell;

function vector getprojloc(int i) { // this can be modified in later subclasses
	local vector newloc, X,Y,Z;

	GetAxes(Pawn(Owner).viewrotation,X,Y,Z);
	newloc = owner.location + CalcDrawOffset();
	newloc += -24*Z + 28*X;

	return newloc;
}

defaultproperties
{
     Proj=Class'NaliChronicles.NCDeathfruit'
     damagepersecond=125.000000
     sizepersecond=0.250000
     mintime=1.000000
     manapersecond=2.400000
     InfoTexture=Texture'NaliChronicles.Icons.EarthDeathfruitInfo'
     recycletime=3.500000
     casttime=5.000000
     magicsparkskin(0)=Texture'Botpack.BoltCap.pEnd_a02'
     magicsparkskin(1)=Texture'Botpack.BoltHit.phit_a02'
     magicsparkskin(2)=Texture'Botpack.GoopEx.ge1_a00'
     magicsparkskin(3)=Texture'Botpack.GoopEx.ge1_a02'
     magicsparkskin(4)=Texture'Botpack.PlasmaExplo.pblst_a03'
     magicsparkskin(5)=Texture'Botpack.PlasmaExplo.pblst_a00'
     magicsparkskin(6)=Texture'Botpack.PlasmaExplo.pblst_a02'
     magicsparkskin(7)=Texture'Botpack.BoltCap.pEnd_a00'
     magicsparkcolor=170.000000
     Difficulty=0.800000
     PickupMessage="You got the death fruit spell"
     ItemName="Death fruit"
     PickupViewMesh=LodMesh'NaliChronicles.spellbook'
     Icon=Texture'NaliChronicles.Icons.EarthDeathfruit'
     Skin=Texture'NaliChronicles.Skins.Jspellbook'
     Mesh=LodMesh'NaliChronicles.spellbook'
}
