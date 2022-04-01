class ONPClientAdjustments expands Info;

simulated function PostBeginPlay()
{
	ClientSideAjustments();
}

simulated function ClientSideAjustments()
{
	Client_AdjustTrees();
}

simulated function Client_AdjustTrees()
{
	local Tree A;
	foreach AllActors(class'Tree', A)
		if (A.class == class'tree5' || A.class == class'tree6')
		{
			//replace palm trees w/ new mesh
			A.Mesh = class'leetpalm'.default.Mesh;
			A.Prepivot.Z -= 16 * A.DrawScale;
			A.MultiSkins[0] = Texture'Jdmisgay12';
			A.SetCollisionSize(0.8 * A.CollisionRadius, A.default.CollisionHeight * A.DrawScale);
			if (A.class == class'tree5')
				A.DrawScale *= 3.3;
			else
				A.DrawScale *= 3.85;			
		}
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
}
