class ONPBlockAllPanel expands BlockAll;

function SetScale(float Scale)
{
	DrawScale = Scale;
	SetCollisionSize(default.CollisionRadius * Scale, default.CollisionHeight * Scale);
	SetLocation(Location);
}

defaultproperties
{
	bAlwaysRelevant=True
	bNetTemporary=True
	bStatic=False
	bUseMeshCollision=True
	bWorldGeometry=True
	CollisionHeight=57
	CollisionRadius=57
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.IPanel'
	RemoteRole=ROLE_SimulatedProxy
}