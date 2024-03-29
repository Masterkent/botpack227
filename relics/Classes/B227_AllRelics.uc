// Use all available relics
class B227_AllRelics expands Relic;

struct RelicInventoryInfo
{
	var class<RelicInventory> RelicClass;
	var RelicInventory SpawnedRelic;
	var float RespawnTimer;
};

var array<RelicInventoryInfo> Relics;
var int NumRelics;

event PostBeginPlay()
{
	local NavigationPoint NP;
	local int i;

	if (Initialized)
		return;
	Initialized = True;

	// Calculate number of navigation points.
	for (NP = Level.NavigationPointList; NP != None; NP = NP.NextNavigationPoint)
	{
		if (PathNode(NP) != none && (NP.bStatic || NP.bNoDelete))
			NumPoints++;
	}

	AddRelicInventoryInfo(class'RelicDeathInventory');
	AddRelicInventoryInfo(class'RelicDefenseInventory');
	AddRelicInventoryInfo(class'RelicRedemptionInventory');
	AddRelicInventoryInfo(class'RelicRegenInventory');
	AddRelicInventoryInfo(class'RelicSpeedInventory');
	AddRelicInventoryInfo(class'RelicStrengthInventory');

	for (i = 0; i < NumRelics; ++i)
		B227_SpawnRelic(Relics[i].RelicClass);

	Spawn(class'B227_RelicGameRules');
	SetTimer(5.0, True);

	if (Level.NetMode != NM_Standalone)
		AddToPackagesMap(string(Class.Outer.Name));
}

event Timer()
{
	local int i;

	for (i = 0; i < NumRelics; ++i)
		if ( (Relics[i].SpawnedRelic != None) && (Relics[i].SpawnedRelic.Owner == None) )
		{
			Relics[i].SpawnedRelic.IdleTime += 5;
			if ( Relics[i].SpawnedRelic.IdleTime >= 30 )
			{
				Relics[i].SpawnedRelic.IdleTime = 0;
				Spawn(class'RelicSpawnEffect', Relics[i].SpawnedRelic,, Relics[i].SpawnedRelic.Location, Relics[i].SpawnedRelic.Rotation);
				B227_bMoveRelic = true;
				Relics[i].SpawnedRelic.Destroy();
				B227_bMoveRelic = false;
			}
		}
}

event Tick(float DeltaTime)
{
	local int i;

	for (i = 0; i < NumRelics; ++i)
		if (Relics[i].RespawnTimer > 0)
		{
			Relics[i].RespawnTimer = FMax(0, FMin(Relics[i].RespawnTimer, Relics[i].RelicClass.default.B227_RespawnTime) - DeltaTime);
			if (Relics[i].RespawnTimer == 0)
				B227_SpawnRelic(Relics[i].RelicClass);
		}
}

function AddRelicInventoryInfo(class<RelicInventory> RelicClass)
{
	Relics[NumRelics++].RelicClass = RelicClass;
}

function AddSpawnedRelic(RelicInventory RelicInv)
{
	local int i;

	if (RelicInv == none)
		return;

	for (i = 0; i < NumRelics; ++i)
		if (Relics[i].RelicClass == RelicInv.Class)
		{
			Relics[i].SpawnedRelic = RelicInv;
			return;
		}
}

function bool HasSpawnedRelic(RelicInventory RelicInv)
{
	local int i;

	for (i = 0; i < NumRelics; ++i)
		if (Relics[i].SpawnedRelic == RelicInv)
			return true;
	return false;
}

function B227_SetRespawnTimer(class<RelicInventory> RelicClass)
{
	local int i;

	for (i = 0; i < NumRelics; ++i)
		if (Relics[i].RelicClass == RelicClass)
		{
			Relics[i].RespawnTimer = RelicClass.default.B227_RespawnTime;
			return;
		}
}

function B227_SetSpawnedRelic(RelicInventory RelicInv)
{
	local int i;

	if (RelicInv != none)
	{
		for (i = 0; i < NumRelics; ++i)
			if (Relics[i].RelicClass == RelicInv.Class)
			{
				Relics[i].SpawnedRelic = RelicInv;
				RelicInv.B227_Relics = self;
				return;
			}
	}
}
