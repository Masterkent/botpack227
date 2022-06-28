//=============================================================================
//
// MovingLight.uc
//
// by Hugh Macdonald
//
//=============================================================================

class MovingLight extends Light;

var() name FollowActor;
var() vector FollowOffset;
var actor Following;
var bool bFollowing;

function PreBeginPlay()
{
	Following = FindActor(FollowActor);
	if(Following != NONE && bMovable && !bStatic)
		bFollowing = true;
}

function Tick(float DeltaTime)
{
	if(bFollowing)
	{
		SetLocation(Following.Location + FollowOffset);
	}
}

function Actor FindActor(name ActorName)
{
    local Actor A;

    foreach AllActors(class 'Actor', A)
        if (ActorName == A.Tag || ActorName == A.Name)
               return A;
    //If there is no matching actor, return none.
    return NONE;
}

defaultproperties
{
}
