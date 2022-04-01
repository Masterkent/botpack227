// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// RealTimeLight: A light that is affected by the computers current time.
// Note: I have no idea what the hell the calulations to compute brightness are.
// Give me "official" calculations or live with this linear, non-day based crap :P
// Note that it is based on client's side
// ============================================================

class RealTimeLight expands Light;
var () byte NightBrightness;
var () byte NoonBrightness;

simulated function prebeginplay(){
timer();
}

simulated function timer(){
local float hourz;
local byte brightness;
hourz=level.Hour+float(level.minute)/60.0;
brightness=min((11-abs(hourz-12))*(noonbrightness/11),nightbrightness); //too lazy to simplify
log ("realtimelight has brightness"@brightness@"at"@hourz);
//VolumeBrightness=brightness;
LightBrightness=brightness;
}

defaultproperties
{
     NightBrightness=20
     NoonBrightness=200
     RemoteRole=ROLE_SimulatedProxy
}
