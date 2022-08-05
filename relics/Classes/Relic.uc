class Relic expands UTC_Mutator
	abstract;

#exec OBJ LOAD FILE="relicsResources.u" PACKAGE=relics

var class<RelicInventory> RelicClass;
var int NumPoints;
var bool Initialized;
var RelicInventory SpawnedRelic;
var int NavPoint;

var float B227_RespawnTimer;
var bool B227_bMoveRelic;

function PostBeginPlay()
{
	local NavigationPoint NP;

	if (Initialized)
		return;
	Initialized = True;

	// Calculate number of navigation points.
	for (NP = Level.NavigationPointList; NP != None; NP = NP.NextNavigationPoint)
	{
		if (PathNode(NP) != none && (NP.bStatic || NP.bNoDelete))
			NumPoints++;
	}

	SpawnRelic(0);
	SetTimer(5.0, True);

	if (Level.NetMode != NM_Standalone)
		AddToPackagesMap(string(Class.Outer.Name));
}

function SpawnRelic(int RecurseCount)
{
	B227_SpawnRelic(RelicClass, RecurseCount);
}

// B227 note: use exec command TossRelic instead
/*-
function Mutate(string MutateString, PlayerPawn Sender)
{
	local Inventory S;

	if (MutateString ~= "TossRelic")
	{
		S = Sender.FindInventoryType(RelicClass);
		if (S != None)
		{
			RelicInventory(S).DropInventory();
			Sender.DeleteInventory(S);
		}
	}

	if ( NextMutator != None )
		class'UTC_Mutator'.static.UTSF_Mutate(NextMutator, MutateString, Sender);
}
*/

function Timer()
{
	if ( (SpawnedRelic != None) && (SpawnedRelic.Owner == None) )
	{
		SpawnedRelic.IdleTime += 5;
		if ( SpawnedRelic.IdleTime >= 30 )
		{
			SpawnedRelic.IdleTime = 0;
			Spawn(class'RelicSpawnEffect', SpawnedRelic,, SpawnedRelic.Location, SpawnedRelic.Rotation);
			B227_bMoveRelic = true;
			SpawnedRelic.Destroy();
			B227_bMoveRelic = false;
		}
	}
}

event Tick(float DeltaTime)
{
	if (B227_RespawnTimer > 0)
	{
		B227_RespawnTimer = FMax(0, FMin(B227_RespawnTimer, RelicClass.default.B227_RespawnTime) - DeltaTime);
		if (B227_RespawnTimer == 0)
			B227_SpawnRelic(RelicClass);
	}
}

function B227_SpawnRelic(class<RelicInventory> RelicClass, optional int RecurseCount)
{
	local int PointCount;
	local NavigationPoint NP;
	local RelicInventory Touching;

	NavPoint = Rand(NumPoints);
	for (NP = Level.NavigationPointList; NP != None; NP = NP.NextNavigationPoint)
	{
		if (PathNode(NP) != none && (NP.bStatic || NP.bNoDelete))
		{
			if (PointCount == NavPoint)
			{
				// check that there are no other relics here
				if ( RecurseCount < 3 )
					ForEach VisibleCollidingActors(class'RelicInventory', Touching, 40, NP.Location)
					{
						B227_SpawnRelic(RelicClass, RecurseCount + 1);
						return;
					}

				// Spawn it here.
				B227_SetSpawnedRelic(Spawn(RelicClass, , , NP.Location));
				return;
			}
			PointCount++;
		}
	}
}

function B227_RespawnRelic(class<RelicInventory> RelicClass)
{
	if (RelicClass.default.B227_RespawnTime > 0 && !B227_bMoveRelic)
		B227_SetRespawnTimer(RelicClass);
	else
		B227_SpawnRelic(RelicClass);
}

function B227_SetRespawnTimer(class<RelicInventory> RelicClass)
{
	B227_RespawnTimer = RelicClass.default.B227_RespawnTime;
}

function B227_SetSpawnedRelic(RelicInventory RelicInv)
{
	if (RelicInv != none)
	{
		SpawnedRelic = RelicInv;
		SpawnedRelic.MyRelic = self;
	}
}

defaultproperties
{
}
