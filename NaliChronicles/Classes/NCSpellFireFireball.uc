// A simple fire spell that fires a fancy little fireball
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellFireFireball extends NCProjSpell;

function vector getprojloc(int i) { // this can be modified in later subclasses
	local vector newloc, X,Y,Z;

	GetAxes(Pawn(Owner).viewrotation,X,Y,Z);
	newloc = owner.location + CalcDrawOffset();
	newloc += -34*Z + 20*X;

	return newloc;
}

defaultproperties
{
     Proj=Class'NaliChronicles.NCFireball'
     damagepersecond=90.000000
     sizepersecond=0.300000
     mintime=0.000001
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant02'
     manapersecond=3.000000
     InfoTexture=Texture'NaliChronicles.Icons.FireFireballInfo'
     Book=3
     recycletime=1.500000
     casttime=2.000000
     magicsparkskin(0)=Texture'Botpack.Effects.gbProj1'
     magicsparkskin(1)=Texture'Botpack.Effects.jenergy3'
     magicsparkskin(2)=Texture'Botpack.FlakGlow.fglow_a00'
     magicsparkskin(3)=Texture'Botpack.UT_Explosions.exp1_a00'
     magicsparkskin(4)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(5)=FireTexture'UnrealShare.Effect1.FireEffect1pb'
     magicsparkskin(6)=FireTexture'UnrealShare.Effect1.FireEffect1p'
     magicsparkskin(7)=Texture'UnrealShare.MainEffect.e1_a00'
     magicsparkcolor=32.000000
     Difficulty=1.200000
     PickupMessage="You got the fire ball spell"
     ItemName="Fire ball"
     Icon=Texture'NaliChronicles.Icons.FireFireball'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollf'
}
