//=============================================================================
// scorch
//=============================================================================
class Scorch expands Decal;

var bool bAttached, bStartedLife, bImportant;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if (class'UnrealShare.Scorch'.default.decalLifeSpan < 0)
		SetTimer(1.0, false); //Default
	else
		LifeSpan = FMax(0, class'UnrealShare.Scorch'.default.DecalLifeSpan); // Stay around as long as the user wants in seconds. 0 = Forever.
}

simulated function Timer()
{
	// Check for nearby players, if none then destroy self

	if ( !bAttached )
	{
		Destroy();
		return;
	}

	if ( !bStartedLife )
	{
		RemoteRole = ROLE_None;
		bStartedLife = true;
		if ( Level.bDropDetail )
			SetTimer(5.0 + 2 * FRand(), false);
		else
			SetTimer(18.0 + 5 * FRand(), false);
		return;
	}
	if ( Level.bDropDetail && (MultiDecalLevel < 6) )
	{
		if ( (Level.TimeSeconds - LastRenderedTime > 0.35)
			|| (!bImportant && (FRand() < 0.2)) )
			Destroy();
		else
		{
			SetTimer(1.0, true);
			return;
		}
	}
	else if ( Level.TimeSeconds - LastRenderedTime < 1 )
	{
		SetTimer(5.0, true);
		return;
	}
	Destroy();
}

defaultproperties
{
     bAttached=True
     bImportant=True
}
