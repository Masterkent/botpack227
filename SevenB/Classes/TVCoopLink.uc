// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVCoopLink : Uplink that sends query for specific gametype
// ===============================================================

class TVCoopLink expands UBrowserGSpyLink;

// States
state FoundSecretState
{
Begin:
  Enable('Tick');
  SendBufferedData("\\list\\\\gamename\\"$GameName$"\\gametype\\tvcoop\\final\\");
  WaitFor("ip\\", 30, NextIP);
}

defaultproperties
{
}
