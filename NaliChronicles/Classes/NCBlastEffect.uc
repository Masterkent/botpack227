// Column effect
// Sergey 'Eater' Levin, 2002

class NCBlastEffect extends Effects;

var int NumPuffs;
var() float MaxLifeSpan;
var float starttime;
var NCPawnEnchantSkies enchant;

simulated function Tick( float DeltaTime )
{
	ScaleGlow = (Lifespan/MaxLifespan)*1.0;
	AmbientGlow = ScaleGlow * 210;
}


simulated function launch()
{
	LifeSpan = MaxLifeSpan;
	setRotation(rot(49152,0,0));
	starttime = level.timeseconds;
	SetTimer(0.05, false);
}

simulated function Timer()
{
	local NCBlastEffect r;
	local vector newloc;

	if (NumPuffs>0)
	{
		newloc = location;
		newloc.z -= 50;
		r = Spawn(class'NCBlastEffect',,,newloc);
		r.RemoteRole = ROLE_None;
		r.NumPuffs = NumPuffs -1;
		r.MaxLifeSpan = MaxLifeSpan - (level.timeseconds-starttime);
		r.enchant = enchant;
		r.launch();
	}
	else {
		if (enchant != none)
			enchant.blast();
	}
}

defaultproperties
{
     MaxLifeSpan=3.000000
     Physics=PHYS_Rotating
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=3.000000
     Rotation=(Roll=20000)
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=Texture'UnrealShare.s_Exp005'
     Mesh=LodMesh'Botpack.Shockbm'
     DrawScale=0.500000
     bUnlit=True
     bParticles=True
     bFixedRotationDir=True
     RotationRate=(Roll=1000000)
     DesiredRotation=(Roll=20000)
}
