// A a spell that fires multiple ice shards
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellWaterIcestrike extends NCProjSpell;

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
	else if (i == 3)
		newloc += -12.5*Z + 20*X + 6*Y;
	else if (i == 4)
		newloc += -12.5*Z + 20*X + (-6)*Y;

	return newloc;
}

defaultproperties
{
     Proj=Class'NaliChronicles.NCIceshard'
     damagepersecond=15.000000
     sizepersecond=0.333333
     mintime=0.000001
     numProjectiles=5
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant04'
     manapersecond=1.000000
     InfoTexture=Texture'NaliChronicles.Icons.WaterIcestrikeInfo'
     Book=1
     casttime=3.000000
     magicsparkskin(0)=Texture'Botpack.ASMDAlt.ASMDAlt_a00'
     magicsparkskin(1)=Texture'Botpack.Effects.jenergy2'
     magicsparkskin(2)=Texture'Botpack.FlareFX.utflare1'
     magicsparkskin(3)=Texture'Botpack.FlareFX.utflare8'
     magicsparkskin(4)=Texture'Botpack.FlareFX.utflare3'
     magicsparkskin(5)=Texture'Botpack.FlareFX.utflare4'
     magicsparkskin(6)=Texture'Botpack.FlareFX.utflare5'
     magicsparkskin(7)=Texture'Botpack.FlareFX.utflare6'
     magicsparkcolor=152.000000
     PickupMessage="You got the ice strike spell"
     ItemName="Ice strike"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.WaterIcestrike'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollw'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
