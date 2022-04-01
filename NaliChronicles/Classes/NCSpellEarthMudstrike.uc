// A spell that fires multiple mud balls
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellEarthMudstrike extends NCProjSpell;

function vector getprojloc(int i) { // this can be modified in later subclasses
	local vector newloc, X,Y,Z;

	GetAxes(Pawn(Owner).viewrotation,X,Y,Z);
	newloc = owner.location + CalcDrawOffset();
	if (i == 0)
		newloc += -8.5*Z + 20*X + 4*Y;
	else if (i == 1)
		newloc += -8.5*Z + 20*X + (-4)*Y;
	else if (i == 2)
		newloc += -12.5*Z + 20*X;

	return newloc;
}

defaultproperties
{
     Proj=Class'NaliChronicles.NCMudBall'
     damagepersecond=30.000000
     sizepersecond=1.000000
     mintime=0.000001
     numProjectiles=3
     inaccuracy=512.000000
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant04'
     manapersecond=1.500000
     InfoTexture=Texture'NaliChronicles.Icons.EarthMudstrikeInfo'
     casttime=2.000000
     magicsparkskin(0)=Texture'Botpack.BoltCap.pEnd_a02'
     magicsparkskin(1)=Texture'Botpack.BoltHit.phit_a02'
     magicsparkskin(2)=Texture'Botpack.GoopEx.ge1_a00'
     magicsparkskin(3)=Texture'Botpack.GoopEx.ge1_a02'
     magicsparkskin(4)=Texture'Botpack.PlasmaExplo.pblst_a03'
     magicsparkskin(5)=Texture'Botpack.PlasmaExplo.pblst_a00'
     magicsparkskin(6)=Texture'Botpack.PlasmaExplo.pblst_a02'
     magicsparkskin(7)=Texture'Botpack.BoltCap.pEnd_a00'
     magicsparkcolor=170.000000
     PickupMessage="You got the mud strike spell"
     ItemName="Mud strike"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.EarthMudstrike'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolle'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
