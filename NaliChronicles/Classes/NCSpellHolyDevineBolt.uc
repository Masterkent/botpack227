// A "devine" projectile that's uh... devine
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellHolyDevineBolt extends NCProjSpell;

function vector getprojloc(int i) { // this can be modified in later subclasses
	local vector newloc, X,Y,Z;

	GetAxes(Pawn(Owner).viewrotation,X,Y,Z);
	newloc = owner.location + CalcDrawOffset();
	newloc += -32*Z + -30*X;

	return newloc;
}

defaultproperties
{
     Proj=Class'NaliChronicles.NCDevineBolt'
     damagepersecond=150.000000
     sizepersecond=0.200000
     mintime=0.000001
     manapersecond=4.000000
     InfoTexture=Texture'NaliChronicles.Icons.HolyDevineBoltInfo'
     Book=4
     recycletime=1.250000
     casttime=2.000000
     magicsparkskin(0)=Texture'UnrealShare.Effects.T_PBurst'
     magicsparkskin(1)=Texture'Botpack.RipperPulse.HEexpl1_a01'
     magicsparkskin(2)=Texture'Botpack.RipperPulse.HEexpl1_a03'
     magicsparkskin(3)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(4)=Texture'UnrealShare.DBEffect.de_A00'
     magicsparkskin(5)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(6)=Texture'UnrealShare.Effects.T_PBurst'
     magicsparkskin(7)=Texture'UnrealShare.SKEffect.Skj_a00'
     magicspark=Class'NaliChronicles.NCHolySpark'
     magicsparkcolor=152.000000
     PickupMessage="You got the devine bolt spell"
     ItemName="Devine bolt"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.HolyDevineBolt'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollh'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
