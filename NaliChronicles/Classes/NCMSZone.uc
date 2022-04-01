// A zone that supports multiple sky boxes
// Code by Sergey 'Eater' Levin

class NCMSZone extends ZoneInfo;

var() name skyTag;

simulated function LinkToSkybox() {
	local SkyZoneInfo sky;
	foreach allactors(class'SkyZoneInfo',sky,skyTag) {
		SkyZone = sky;
	}
}

defaultproperties
{
     skyTag=SkyZoneInfo
}
