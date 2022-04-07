class Relic expands UTC_Mutator
	abstract;

#exec OBJ LOAD FILE="relicsResources.u" PACKAGE=relics

var class<RelicInventory> RelicClass;
var int NumPoints;
var bool Initialized;
var RelicInventory SpawnedRelic;
var int NavPoint;

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
			SpawnedRelic.Destroy();
		}
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
