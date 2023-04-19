//=============================================================================
// VacuumZone.
//=============================================================================
class VacuumZone extends ZoneInfo;

var() float  KillTime;					// How long to kill the player?
var() float  StartFlashScale;			// Fog values for client death sequence
var() Vector StartFlashFog;
var() float  EndFlashScale;
var() Vector EndFlashFog;
var() float  DieFOV;					// Field of view when dead (interpolates)
var() float  DieDrawScale;				// Drawscale when dead

function BeginPlay()
{
	Super.BeginPlay();
	Disable('Tick');
	DieFOV = FClamp( DieFOV, 1, 170 );
}

event ActorEntered( actor Other )
{
	local Pawn P;

	Super.ActorEntered(Other);

	if ( Other.bIsPawn )
	{
		P = Pawn(Other);

		// Maybe scream?
		if (P.bIsPlayer &&
			Spectator(P) == none &&
			P.PlayerReplicationInfo != none &&
			!P.PlayerReplicationInfo.bIsSpectator &&
			P.Health > 0)
		{
			// Scream now (from the terrible pain)
			P.PlaySound( P.Die, SLOT_Talk );
		}

		if (Spectator(P) == none)
			class'B227_VacuumZoneInfluence'.static.GetInstance(P, self, true);
	}
}

function Tick( float DeltaTime )
{
	// B227: pawns are updated in B227_VacuumZoneInfluence
}

function MakeNormal(Pawn P)
{
	// set the fatness back to normal
	P.Fatness = P.Default.Fatness;
	P.DrawScale = P.Default.DrawScale;
}

// When an actor leaves this zone.
event ActorLeaving( actor Other )
{
	if( Other.bIsPawn )
		MakeNormal(Pawn(Other));
	Super.ActorLeaving(Other);
}

function B227_AdjustDamageString()
{
	local int KillerIndex, VictimIndex;

	if (UTC_GameInfo(Level.Game) != none)
		return;

	KillerIndex = InStr(DamageString, "%k");
	VictimIndex = InStr(DamageString, "%o");

	if (KillerIndex > 0 || VictimIndex > 0)
	{
		DamageString = "";
		return;
	}

	if (KillerIndex == 0 || VictimIndex == 0)
	{
		DamageString = Mid(DamageString, 2);
		while (Left(DamageString, 1) == " ")
			DamageString = Mid(DamageString, 1);
	}
}

defaultproperties
{
	KillTime=2.500000
	StartFlashScale=1.000000
	EndFlashScale=1.000000
	DieFOV=90.000000
	DieDrawScale=1.000000
	DamageType=SpecialDamage
	DamageString="%o was depressurized"
	bStatic=False
}
