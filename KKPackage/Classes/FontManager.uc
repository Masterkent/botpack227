class FontManager extends Object;

static function font DynamicGetFont(string height)
{
	return Font(DynamicLoadObject("LadderFonts.UTLadder"@height, class'Font'));
}

static function font HugeFont(float Width)
{
	if (Width < 512)
		return Font'SmallFont';
	else if (Width < 640)
		return Font(DynamicLoadObject("LadderFonts.UTLadder16", class'Font'));
	else if (Width < 800)
		return Font(DynamicLoadObject("LadderFonts.UTLadder20", class'Font'));
	else if (Width < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder22", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder30", class'Font'));
}

static function font BigFont(float Width)
{
	if (Width < 512)
		return Font'SmallFont';
	else if (Width < 640)
		return Font(DynamicLoadObject("LadderFonts.UTLadder16", class'Font'));
	else if (Width < 800)
		return Font(DynamicLoadObject("LadderFonts.UTLadder18", class'Font'));
	else if (Width < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder20", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder22", class'Font'));
}

static function font MediumFont(float Width)
{
	if (Width < 512)
		return Font'SmallFont';
	else if (Width < 800)
		return Font(DynamicLoadObject("LadderFonts.UTLadder16", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder22", class'Font'));
}


static function font SmallFont(float Width)
{
	if (Width < 640)
		return Font'SmallFont';
	else if (Width < 800)
		return Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
	else if (Width < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder14", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder16", class'Font'));
}

static function font SmallestFont(float Width)
{
	if (Width < 640)
		return Font'SmallFont';
	else if (Width < 800)
		return Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
	else if (Width < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder12", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder14", class'Font'));
}

static function font AReallySmallFont(float Width)
{
	if (Width < 800)
		return Font'SmallFont';
	else if (Width < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder8", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
}

static function font GetStaticACompletelyUnreadableFont(float Width)
{
	if (Width < 800)
		return Font'SmallFont';
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder8", class'Font'));
}

defaultproperties
{
}
