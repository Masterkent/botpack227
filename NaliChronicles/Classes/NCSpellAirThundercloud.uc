// An air spell that fires a thundercloud
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellAirThundercloud extends NCProjSpell;

function vector getprojloc(int i) { // this can be modified in later subclasses
	local vector newloc, X,Y,Z;

	GetAxes(Pawn(Owner).viewrotation,X,Y,Z);
	newloc = owner.location + CalcDrawOffset();
	newloc += -26*Z + 60*X;

	return newloc;
}

defaultproperties
{
     Proj=Class'NaliChronicles.NCThundercloud'
     damagepersecond=150.000000
     sizepersecond=1.000000
     mintime=0.000001
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant05'
     manapersecond=2.000000
     InfoTexture=Texture'NaliChronicles.Icons.AirThundercloudInfo'
     Book=2
     casttime=3.000000
     magicsparkskin(0)=Texture'Botpack.RipperPulse.HEexpl1_a00'
     magicsparkskin(1)=Texture'Botpack.ShockExplo.asmdex_a00'
     magicsparkskin(2)=Texture'Botpack.UT_Explosions.Exp5_a00'
     magicsparkskin(3)=Texture'Botpack.utsmoke.US3_A00'
     magicsparkskin(4)=Texture'UnrealShare.DBEffect.de_A00'
     magicsparkskin(5)=FireTexture'UnrealShare.Effect17.fireeffect17'
     magicsparkskin(6)=FireTexture'UnrealShare.Effect2.FireEffect2'
     magicsparkskin(7)=Texture'UnrealShare.Effects.SmokeE3'
     magicsparkcolor=152.000000
     Difficulty=0.900000
     PickupMessage="You got the thundercloud spell"
     ItemName="Thundercloud"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.AirThundercloud'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolla'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
