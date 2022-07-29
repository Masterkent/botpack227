class B227_PermissiveAccessManager expands AdminAccessManager
	transient;

var AdminAccessManager AdminAccessManager;
var int Count;

function bool CanExecuteCheat( PlayerPawn Other, name N )
{
	return true;
}

function bool CanExecuteCheatStr( PlayerPawn Other, name N, string Parms )
{
	return true;
}

static function bool GetInstance(LevelInfo Level, out B227_PermissiveAccessManager AccessManager)
{
	if (AccessManager != none)
		return true;
	if (TournamentGameInfo(Level.Game) != none && TournamentGameInfo(Level.Game).B227_PermissiveAccessManager != none)
	{
		AccessManager = TournamentGameInfo(Level.Game).B227_PermissiveAccessManager;
		return true;
	}

	foreach Level.AllActors(class'B227_PermissiveAccessManager', AccessManager)
		break;

	if (AccessManager == none)
		AccessManager = Level.Spawn(class'B227_PermissiveAccessManager');
	if (TournamentGameInfo(Level.Game) != none)
		TournamentGameInfo(Level.Game).B227_PermissiveAccessManager = AccessManager;

	return AccessManager != none;
}

static function PushAdminAccess(LevelInfo Level, out B227_PermissiveAccessManager AccessManager)
{
	if (GetInstance(Level, AccessManager))
	{
		if (AccessManager.Count++ == 0)
		{
			AccessManager.AdminAccessManager = Level.Game.GetAccessManager();
			Level.Game.AccessManager = AccessManager;
		}
	}
}

static function PopAdminAccess(LevelInfo Level, out B227_PermissiveAccessManager AccessManager)
{
	if (GetInstance(Level, AccessManager))
	{
		if (--AccessManager.Count == 0)
			Level.Game.AccessManager = AccessManager.AdminAccessManager;
	}
}
