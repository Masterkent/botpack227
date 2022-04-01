class TargetShadow expands Decal;

function AttachToSurface()
{
}

simulated function Tick(float DeltaTime)
{
	if (TranslocatorTarget(Owner) == none)
	{
		Destroy();
		return;
	}

	DetachDecal();
	if (!TranslocatorTarget(Owner).B227_bIsMoving)
		return;

	SetLocation(Owner.Location);
	AttachDecal(320);
}

defaultproperties
{
	MultiDecalLevel=0
	Rotation=(Pitch=16384)
	Texture=Texture'Botpack.energymark'
	DrawScale=0.200000
}
