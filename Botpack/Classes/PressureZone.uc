//=============================================================================
// PressureZone.
//=============================================================================
class PressureZone extends ZoneInfo;

var() float  KillTime;					// How long to kill the player?
var() float  StartFlashScale;			// Fog values for client death sequence
var() Vector StartFlashFog;
var() float  EndFlashScale;
var() Vector EndFlashFog;
var() float  DieFOV;					// Field of view when dead (interpolates)
var() float  DieDrawScale;				// Drawscale when dead
var   float  TimePassed;
var() byte   DieFatness;				// Fatness when dead
var   bool   bTriggered;				// Ensure that it doesn't update until it should
var	  bool	 bScreamed;

function BeginPlay()
{
	Super.BeginPlay();
	Disable('Tick');
	bTriggered = false;
	DieFOV = FClamp( DieFOV, 1, 170 );
	DieFatness = Clamp( DieFatness, 1, 255 );
}

function Trigger( actor Other, pawn EventInstigator )
{
	local Pawn p;

	// The pressure zone has been triggered to kill something

	Instigator = EventInstigator;

	if (Bot(Instigator) != none && !Instigator.bDeleteMe && Instigator.Health > 0)
	{
		// taunt the victim
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if( (P.Region.Zone == self) && (P.Health > 0) )
			{
				Instigator.Target = P;
				Instigator.GotoState('VictoryDance');
			}
	}

	// Engage Tick so that death may be slow and dramatic
	TimePassed = 0;
	bTriggered = true;
	bScreamed = false;
	Disable('Trigger');
	Enable('Tick');
}

function Tick( float DeltaTime )
{
	local float  		ratio;
	local PlayerPawn	pPawn;
	local Pawn P;
	local B227_VacuumZoneInfluence Influence;
	local int Health;

	if( !bTriggered )
	{
		Disable('Tick');
		return;
	}

	TimePassed += DeltaTime;
	ratio = FMin(1.0, TimePassed/KillTime);

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		// Ensure player hasn't been dispatched through other means already (suicide?)
		if (P.Region.Zone == self &&
			P.Health > 0 &&
			!P.IsA('Spectator') &&
			(P.PlayerReplicationInfo == none || !P.PlayerReplicationInfo.bIsSpectator))
		{
			// Fatness
			P.Fatness   = byte( P.default.Fatness + Int( (Float(DieFatness)-P.default.Fatness) * ratio ));
			P.DrawScale = 1 + (DieDrawScale-1) * ratio;

			Influence = class'B227_VacuumZoneInfluence'.static.GetInstance(P, self, TimePassed < KillTime);

			// Maybe scream?
			if (Influence != none &&
				!Influence.bScreamed &&
				P.bIsPlayer &&
				ratio > 0.2 &&
				ratio < 1.0 &&
				FRand() < 2 * DeltaTime)
			{
				// Scream now (from the terrible pain)
				bScreamed = true;
				Influence.bScreamed = true;
				P.PlaySound( P.Die, SLOT_Talk );
			}

			// Fog & Field of view
			pPawn = PlayerPawn(P);
			if( pPawn != None && Influence != none )
			{
				Influence.curScale = (EndFlashScale - StartFlashScale) * ratio + StartFlashScale;
				Influence.curFog = (EndFlashFog - StartFlashFog) * ratio + StartFlashFog;
				Influence.curFog *= 1000;
				Influence.curFOV = (DieFOV - pPawn.default.FOVAngle) * ratio + pPawn.default.FOVAngle;
			}
			if (TimePassed >= KillTime)
			{
				if (Instigator != none && Instigator != P)
					Level.Game.SpecialDamageString = DamageString;
				else
					Level.Game.SpecialDamageString = class'VacuumZone'.default.DamageString;
				if (P.ReducedDamageType != 'All' && P.GetStateName() != 'CheatFlying')
				{
					Health = P.Health;
					P.Health = -1000; // make sure gibs
					P.Died(Instigator, 'SpecialDamage', P.Location);
					if (P.Health > 0) // if death was prevented
						P.Health = Health;
				}
				MakeNormal(P);
				if (Influence != none)
					Influence.Destroy();
			}
		}
	}

	if (TimePassed >= KillTime)
	{
		Disable('Tick');
		Enable('Trigger');
		bTriggered = false;
	}
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

defaultproperties
{
	DamageType=SpecialDamage
	DamageString="%o was depressurized by %k."
	bStatic=False
}
