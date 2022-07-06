class B227_Config expands Info
	config(Botpack);

var() config bool bEnableExtensions;
var() config bool bEnableExtras;
var() config bool bFixLoaded;
var() config bool bModifyProjectilesLighting;

defaultproperties
{
	bEnableExtensions=True
	bEnableExtras=True
	bFixLoaded=True
	bModifyProjectilesLighting=True
}
