//=============================================================================
// ElevatorBotInfo.
//
// script by N.Bogenrieder (Beppo)
//
//=============================================================================
class ElevatorBotInfo expands Info;

struct	sBI
{
	var BotInventorySpot BI;
	var() vector Loc;
	var() bool bUseIt;
};
struct	sBI2
{
	var BotInventorySpot BI;
	var() vector Loc;
	var() bool bMoveUp;
};

var() sBI OutTriggers[8];
var() sBI2 InTriggers[2];
var() name ElevatorTag;

var() float SleepTime;
var() float TriggerDesireability;

var int i;
var bool bUpDown, bUseUpDown;

function PostBeginPlay()
{
local ElevatorMoverInsideButtons EMIB;

	for(i=0; i<8; i++)
		if(OutTriggers[i].bUseIt)
		{
			OutTriggers[i].BI = Spawn(class'BotInventorySpot',,,OutTriggers[i].Loc);
			OutTriggers[i].BI.MaxDesireability = TriggerDesireability;
			OutTriggers[i].BI.oMaxDesireability = TriggerDesireability;
			OutTriggers[i].BI.TurnOFF();
			
		}

	foreach allactors (class'ElevatorMoverInsideButtons', EMIB, ElevatorTag)
		break;		

	for(i=0; i<2; i++)
	{
		InTriggers[i].BI = Spawn(class'BotInventorySpot',,,InTriggers[i].Loc);
		InTriggers[i].BI.MaxDesireability = TriggerDesireability;
		InTriggers[i].BI.oMaxDesireability = TriggerDesireability;
		InTriggers[i].BI.TurnOFF();
		InTriggers[i].BI.SetBase(EMIB);
	}
	bUseUpDown = False;

	TurnOnElevIntern(EMIB.KeyNum);
}

function TurnOffIn(bool bUp)
{
	bUpDown = bUp;
}
function TurnOffInIntern(bool bUp)
{
	if (bUseUpDown)
		for(i=0; i<2; i++)
			if( bUp == InTriggers[i].bMoveUp)
				InTriggers[i].BI.TurnOFF();
}
function TurnOnElev(int Ignore)
{
	i = Ignore;
	GotoState('SleepNow');
}
function TurnOnElevIntern(int Ignore)
{
	for(i=0; i<2; i++)
		InTriggers[i].BI.TurnON();

	for(i=0; i<8; i++)
		if(OutTriggers[i].bUseIt)
			OutTriggers[i].BI.TurnON();
	OutTriggers[Ignore].BI.TurnOFF();
}
function TurnOffElev()
{
	for(i=0; i<2; i++)
		InTriggers[i].BI.TurnOFF();
	for(i=0; i<8; i++)
		if(OutTriggers[i].bUseIt)
			OutTriggers[i].BI.TurnOFF();
	GotoState('SleepNow');
}

auto state Waiting
{
Begin:
}

state SleepNow
{
Begin:
	Sleep(SleepTime);
	TurnOnElevIntern(i);
	TurnOffInIntern(bUpDown);
	GotoState('Waiting');
}

defaultproperties
{
     InTriggers(0)=(bMoveUp=True)
     SleepTime=8.000000
     TriggerDesireability=1.000000
}
