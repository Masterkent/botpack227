// A fire spell that fires a huge flaming meteor
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellFireMeteor extends NCProjSpell;

function vector getprojloc(int i) { // this can be modified in later subclasses
	local vector newloc, X,Y,Z;

	GetAxes(Pawn(Owner).viewrotation,X,Y,Z);
	newloc = owner.location + CalcDrawOffset();
	newloc += -32*Z + 36*X;

	return newloc;
}

defaultproperties
{
     Proj=Class'NaliChronicles.NCMeteor'
     damagepersecond=90.000000
     sizepersecond=0.250000
     mintime=1.000000
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant05'
     manapersecond=1.750000
     InfoTexture=Texture'NaliChronicles.Icons.FireMeteorInfo'
     Book=3
     recycletime=2.500000
     casttime=4.000000
     magicsparkskin(0)=Texture'Botpack.Effects.gbProj1'
     magicsparkskin(1)=Texture'Botpack.Effects.jenergy3'
     magicsparkskin(2)=Texture'Botpack.FlakGlow.fglow_a00'
     magicsparkskin(3)=Texture'Botpack.UT_Explosions.exp1_a00'
     magicsparkskin(4)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(5)=FireTexture'UnrealShare.Effect1.FireEffect1pb'
     magicsparkskin(6)=FireTexture'UnrealShare.Effect1.FireEffect1p'
     magicsparkskin(7)=Texture'UnrealShare.MainEffect.e1_a00'
     magicsparkcolor=32.000000
     PickupMessage="You got the meteor spell"
     ItemName="Meteor"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.FireMeteor'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollf'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
