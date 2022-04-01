class SBMapFixBase expands Info;

#exec obj load file="Botpack.u"

var string CurrentMap;

replication
{
	reliable if (Role == ROLE_Authority)
		CurrentMap;
}

function Init(string CurrentMap)
{
	self.CurrentMap = CurrentMap;
}

function Tick(float DeltaTime)
{
	Disable('Tick');
}


simulated function Actor LoadLevelActor(string ActorName, optional bool bMayFail)
{
	return Actor(DynamicLoadObject(outer.name $ "." $ ActorName, class'Actor', bMayFail));
}

simulated function Mover LoadLevelMover(string MoverName)
{
	return Mover(DynamicLoadObject(outer.name $ "." $ MoverName, class'Mover'));
}

simulated function EliminateStaticActor(string ActorName)
{
	local Actor A;
	A = LoadLevelActor(ActorName);
	A.SetCollision(false);
	A.bProjTarget = false;
	A.DrawType = DT_None;
}

defaultproperties
{
	RemoteRole=ROLE_None
}
