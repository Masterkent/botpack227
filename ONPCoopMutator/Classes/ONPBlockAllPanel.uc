class ONPBlockAllPanel expands BlockAll;

var int RepPitch, RepYaw;

replication
{
	reliable if (Role == ROLE_Authority)
		RepPitch, RepYaw;
}

simulated event PostNetBeginPlay()
{
	local rotator Rotation;

	Rotation.Pitch = RepPitch;
	Rotation.Yaw = RepYaw;
	SetRotation(Rotation);
	SetLocation(Location);
}

function SetScale(float Scale)
{
	DrawScale = Scale;
	SetCollisionSize(default.CollisionRadius * Scale, default.CollisionHeight * Scale);
	SetLocation(Location);

	RepPitch = Rotation.Pitch;
	RepYaw = Rotation.Yaw;
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