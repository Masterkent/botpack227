//=============================================================================
// UTIntro.
//=============================================================================
class UTIntro extends TournamentGameInfo;

var bool bOpened;
var int TickCount;

var config string CityIntroHUDClass;

event PreBeginPlay()
{
	if( CityIntroHUDClass!="" && Left(string(Level), 9) ~="cityintro" )
	{
		HUDType = class<HUD>( DynamicLoadObject(CityIntroHUDClass, class'Class') );
		Log("Using CityIntro HUD: "$HUDType);
	}
	Super.PreBeginPlay();
}

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn NewPlayer;
	local SpectatorCam Cam;

	// Don't allow player to be a spectator
	if( !SpawnClass.Default.bCollideActors )
		SpawnClass = class'TMale2';

	bRatedGame = true;
	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	bRatedGame = false;
	NewPlayer.bHidden = True;

	foreach AllActors(class'SpectatorCam', Cam)
		NewPlayer.ViewTarget = Cam;

	return NewPlayer;
}

/* AcceptInventory()
Examine the passed player's inventory, and accept or discard each item
* AcceptInventory needs to gracefully handle the case of some inventory
being accepted but other inventory not being accepted (such as the default
weapon).  There are several things that can go wrong: A weapon's
AmmoType not being accepted but the weapon being accepted -- the weapon
should be killed off. Or the player's selected inventory item, active
weapon, etc. not being accepted, leaving the player weaponless or leaving
the HUD inventory rendering messed up (AcceptInventory should pick another
applicable weapon/item as current).
*/
function AcceptInventory(pawn PlayerPawn)
{
	local inventory Inv;
	local LadderInventory LadderObj;

	// DeathMatchPlus accepts LadderInventory
	for( Inv=PlayerPawn.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if (Inv.IsA('LadderInventory'))
		{
			LadderObj = LadderInventory(Inv);
		}
		else
			Inv.Destroy();
	}
	PlayerPawn.Weapon = None;
	PlayerPawn.SelectedItem = None;
}

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
}

function float PlaySpawnEffect(inventory Inv);

function bool SetPause( BOOL bPause, PlayerPawn P )
{
	return False;
}

auto state Startup
{
	function Tick(float DeltaTime)
	{
		///local Pawn P; // [U227] Excluded

		if( Level.LevelAction == LEVACT_Connecting )
		{
			bOpened = True;
			Disable('Tick');
			return;
		}

		TickCount++;
		if(TickCount < 2)
			return;

		bOpened = True;
		Disable('Tick');
	}
}

function bool CanSpectate( pawn Viewer, actor ViewTarget )
{
	return false;
}

defaultproperties
{
	bGameEnded=True
	DefaultWeapon=None
	RulesMenuType="UTMenu.UTRulesSClient"
	SettingsMenuType="UTMenu.UTRulesSClient"
	GameUMenuType="UTMenu.UTGameMenu"
	MultiplayerUMenuType="UTMenu.UTMultiplayerMenu"
	GameOptionsMenuType="UTMenu.UTOptionsMenu"
	HUDType=Class'Botpack.CHNullHUD'
}
