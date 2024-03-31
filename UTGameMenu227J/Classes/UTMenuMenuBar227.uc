class UTMenuMenuBar227 expands UMenuMenuBar;

function Created()
{
	local GameInfo Game;
	local string OldGameUMenuType;
	local string OldGameOptionsMenuType;

	GameUMenuDefault = "UTGameMenu227.UTGameMenu227";
	OptionsUMenuDefault = "UTGameMenu227.UTMenuOptionsMenu227";

	Game = GetLevel().Game;
	if (Game != none)
	{
		OldGameUMenuType = Game.default.GameUMenuType;
		OldGameOptionsMenuType = Game.default.GameOptionsMenuType;
		Game.default.GameUMenuType = GameUMenuDefault;
		Game.default.GameOptionsMenuType = OptionsUMenuDefault;
		super.Created();
		Game.default.GameUMenuType = OldGameUMenuType;
		Game.default.GameOptionsMenuType = OldGameOptionsMenuType;
	}
	else
		super.Created();
}

defaultproperties
{
	GameUMenuDefault="UTGameMenu227.UTGameMenu227"
	OptionsUMenuDefault="UTGameMenu227.UTMenuOptionsMenu227"
}
