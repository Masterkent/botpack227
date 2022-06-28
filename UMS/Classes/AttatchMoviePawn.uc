class AttatchMoviePawn expands MoviePawn;

var() name AttatchToPawn;
var actor AttatchedTo;

function PreBeginPlay()
{
	local actor A;
	
	foreach AllActors(class'Actor', A)
	{
		if(A.Tag == AttatchToPawn)
		{
			AttatchedTo = A;
			log(self$": Attatched to"@AttatchedTo);
			break;
		}
	}
	enable('Tick');
}

function Tick(float DeltaTime)
{
	log(self$": Tick() called");
	if(AttatchedTo != none)
	{
		SetLocation(AttatchedTo.Location);
		SetRotation(AttatchedTo.Rotation);
	}
}

defaultproperties
{
}
