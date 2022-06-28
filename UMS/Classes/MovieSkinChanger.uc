//=============================================================================
// MovieSkinChanger.
//=============================================================================
class MovieSkinChanger expands UMS;

var() string PawnName;
var pawn MyPawn;
var() int SkinScript[50];
var() int SkinTargets[50];
var() float WaitTimes[50];
var() texture MySkins[80];
var bool bRolling;
var int CurrentCommand;
var float WaitTime;

//MovieSkinChanger will start using the SkinScript if triggered.
event Trigger( Actor other, Pawn instigator )
{
	MyPawn = FindPawn(PawnName);
	bRolling = true;
}

//Grab the next command from the SkinScript and execute it.
function ExecuteNextCommand()
{
	SetSkin();
	
	//Now wait the appropriate amount of time before doing the next
	//command.
	WaitTime = WaitTimes[CurrentCommand];
	GotoState('Waiting');
	
	CurrentCommand++;
	
	if(CurrentCommand > 50)
		GoBackToMyTrailer();
}

//Destroys the MovieSkinChanger - used for cleaning up level.
function GoBackToMyTrailer()
{
	Destroy();
}

//State used to wait.
auto state Waiting
{
Begin:
StartWaiting:
	Sleep(WaitTime);
	GotoState('Rolling');
}

//State used to execute commands.
state Rolling
{
Begin:
	if(!bRolling)
		GotoState('Waiting');
ExecuteCommand:
	if(bRolling)
		ExecuteNextCommand();
CheckForWait:
	Goto'Begin';
}

function SetSkin()
{
	local int ElementNum, DesiredSkin;
	
	ElementNum = SkinTargets[CurrentCommand];
	DesiredSkin = SkinScript[CurrentCommand];
	
	//Negative SkinScript or ElementNum means to destroy this MovieSkinChanger
	if(DesiredSkin < 0 || ElementNum < 0)
	{
		GoBackToMyTrailer();
		return;
	}
		
	if(ElementNum >= 0 && ElementNum <= 7)
		MyPawn.MultiSkins[ElementNum] = MySkins[DesiredSkin];
	else
		MyPawn.Skin = MySkins[DesiredSkin];
}

function MoviePawn FindPawn(string PawnName)
{
	local MoviePawn P;

	foreach AllActors(class'MoviePawn', P)
		if (PawnName ~= string(P.Tag ))
		   	return P;
	//If there is no matching pawn, return none.
	return NONE;
}

defaultproperties
{
}
