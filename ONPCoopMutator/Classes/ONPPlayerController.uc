//=============================================================================
// ONPPlayerController.
//=============================================================================
class ONPPlayerController expands Info;

var ONPGameRules GameRulesPtr;

var bool bShipLevel;
var name PlayerState;

replication
{
	reliable if (Role == ROLE_Authority && bNetOwner)
		bShipLevel,
		PlayerState;
}

static function ONPPlayerController FindFor(PlayerPawn Player)
{
	local ONPPlayerController Controller;

	if (Player == none)
		return none;

	foreach Player.AllActors(class'ONPPlayerController', Controller)
		if (Controller.Owner == Player)
			return Controller;
	return none;
}

function Initialize(ONPCoopMutator Mutator, ONPGameRules GameRules)
{
	GameRulesPtr = GameRules;
	bShipLevel = GameRules.LInfo.bjet;
}

simulated event Tick(float DeltaTime)
{
	if (PlayerPawn(Owner) != none)
	{
		UpdateServerPlayerState(PlayerPawn(Owner));
		UpdateClientPlayerState(PlayerPawn(Owner));
	}
	else if (Level.NetMode != NM_Client)
		Destroy();
}

function UpdateServerPlayerState(PlayerPawn Player)
{
	local ONPPlayerPawn ONPPlayer;

	ONPPlayer = ONPPlayerPawn(Player);

	if (GameRulesPtr.LInfo != none && GameRulesPtr.LInfo.bjet && ONPPlayer != none)
	{
		PlayerState = ONPPlayer.GetStateName();
		
		if (!ONPPlayer.bReadyToPlay || ONPPlayer.ReachedExit != none)
			SetPlayerWaiting(ONPPlayer);
		else if (ONPPlayer.IsInState('PlayerWalking') || ONPPlayer.IsInState('PlayerWaiting'))
			InitPlayerFlight(ONPPlayer);
	}
}

simulated function UpdateClientPlayerState(PlayerPawn Player)
{
	if (Level.NetMode != NM_Client)
		return;
	if (Player.IsInState('PlayerShip') && PlayerState != 'PlayerShip' && PlayerState != '')
		Player.GotoState(PlayerState);
	if (bShipLevel)
		Player.DesiredFOV = 125;
}

function SetPlayerWaiting(tvplayer Player)
{
	Player.Weapon = none;
	if (!Player.IsInState('PlayerWaiting'))
		Player.GotoState('PlayerWaiting');
}

function InitPlayerFlight(tvplayer Player)
{
	local ONPPlayerInteraction InteractionPtr;

	if (Player != none && GameRulesPtr.LInfo != none && GameRulesPtr.LInfo.bjet)
	{
		PlayerState = 'PlayerShip';
		Player.GotoState(PlayerState);
		Player.bFire = 0;
		Player.bAltFire = 0;

		Player.MinSpeed = 30 * Level.Game.Difficulty + 580;
		Player.MaxSpeed = Player.default.MaxSpeed;
		Player.AirSpeed = Player.MinSpeed;

		InteractionPtr = class'ONPPlayerInteraction'.static.FindFor(Player);
		if (InteractionPtr != none)
			InteractionPtr.SetClientRealSpeed(Player.AirSpeed);
	}
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
