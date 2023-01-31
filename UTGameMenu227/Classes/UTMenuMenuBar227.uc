class UTMenuMenuBar227 expands UMenuMenuBar;

function Created()
{
	local string OldGameUMenuType;

	if (GetLevel().Game != none)
	{
		OldGameUMenuType = GetLevel().Game.default.GameUMenuType;
		GetLevel().Game.default.GameUMenuType = GameUMenuDefault;
		super.Created();
		GetLevel().Game.default.GameUMenuType = OldGameUMenuType;
	}
	else
		super.Created();
}

defaultproperties
{
	GameUMenuDefault="UTGameMenu227.UTGameMenu227"
}
