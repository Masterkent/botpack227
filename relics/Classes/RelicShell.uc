class RelicShell expands Effects;

function Timer()
{
	Texture = None;
}

defaultproperties
{
     bAnimByOwner=True
     bOwnerNoSee=True
     bNetTemporary=False
     bTrailerSameRotation=True
     Physics=PHYS_Trailer
     RemoteRole=ROLE_SimulatedProxy
     LODBias=0.500000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=None
     ScaleGlow=0.500000
     AmbientGlow=64
     Fatness=157
     bUnlit=True
     bMeshEnviroMap=True
}
