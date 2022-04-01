// Fires 3 fireballs
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellFireFirestrike extends NCProjSpell;

function vector getprojloc(int i) { // this can be modified in later subclasses
	local vector newloc, X,Y,Z;

	GetAxes(Pawn(Owner).viewrotation,X,Y,Z);
	newloc = owner.location + CalcDrawOffset();
	if (i == 0)
		newloc += -34*Z + 20*X + 8*Y;
	else if (i == 1)
		newloc += -34*Z + 20*X + (-8)*Y;
	else if (i == 2)
		newloc += -26*Z + 20*X;

	return newloc;
}

defaultproperties
{
     Proj=Class'NaliChronicles.NCFireball'
     damagepersecond=60.000000
     sizepersecond=0.200000
     mintime=0.000001
     numProjectiles=3
     inaccuracy=256.000000
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant04'
     InfoTexture=Texture'NaliChronicles.Icons.FireFirestrikeInfo'
     Book=3
     casttime=3.000000
     magicsparkskin(0)=Texture'Botpack.Effects.gbProj1'
     magicsparkskin(1)=Texture'Botpack.Effects.jenergy3'
     magicsparkskin(2)=Texture'Botpack.FlakGlow.fglow_a00'
     magicsparkskin(3)=Texture'Botpack.UT_Explosions.exp1_a00'
     magicsparkskin(4)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(5)=FireTexture'UnrealShare.Effect1.FireEffect1pb'
     magicsparkskin(6)=FireTexture'UnrealShare.Effect1.FireEffect1p'
     magicsparkskin(7)=Texture'UnrealShare.MainEffect.e1_a00'
     magicsparkcolor=32.000000
     PickupMessage="You got the fire strike spell"
     ItemName="Fire strike"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.FireFirestrike'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollf'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
