// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// Tvscorekeeper : Scorekeeper for ONP. handles the VERY different scoring system...
// This was going to be placed under the new playerpawn, but if it is here, it saves co-op traveling memory...
// ===============================================================

class Tvscorekeeper expands scorekeeper;

struct WeaponUsage{ //weapon holding stuct
  var float TimeHeld;
  var int DamageInstigated;
};

var travel int Humans;  //killed humans
var travel int ENali;  //killed eVIL nali
var travel int DamageTaken; //damage self taken
var travel int FriendlyDamage; //damage friendlies took from player
var travel int DamageInstigated; //damage self instigated on others.
var travel int KilledFollowers; //total followers killed (by anyone)
var travel int KilledByFollowers; //creatures killed by the followers
var travel float AccumTime; //accumulated time            Note: current time is stored in playerpawn!
//items that are only in high score stats... not shown in game:
var travel float Times[36]; //per-level times
var travel int TotalLevelSecrets; //all level secrets in ONP
var travel int TotalSecretsFound; //all secrets found in ONP
var travel WeaponUsage Weapons[12]; //ordered by inv group. 10=translocator (its damage=other), 11=SuperShockRifle

//non-traveling
var float PointsFloat; //held points float to be added later (points is always integer but this holds subpoints until ready to add)

function AddPoints(float points){ //handles point fractions
  local int newpts;
  pointsFloat+=points;
  newpts=int(pointsfloat);
  Score+=newpts;
  pointsfloat-=newpts;
}
//note: this function now only adds per-creature kills and nothing more! (all else handled by gameinfo!)
function scoreit(pawn WhatDied){
  if (WhatDied.IsA('Brute'))
    Brutes++;
  else if (WhatDied.IsA('Gasbag'))
    Gasbags++;
  else if (WhatDied.IsA('Krall')||Whatdied.IsA('Spinner'))
    Krall++;
  else if (WhatDied.IsA('Mercenary')||WhatDied.Isa('followingMercenary')||WhatDied.IsA('ScriptedHybrid'))
    Mercs++;
  else if (WhatDied.IsA('Queen')||WhatDied.IsA('Warlord'))
    hugeguys++;
  else if (WhatDied.IsA('Slith'))
    Sliths++;
  else if (WhatDied.IsA('Titan'))
    Titans++;
  else if (WhatDied.IsA('Skaarjtrooper'))
    Skaarjt++;
  else if (WhatDied.IsA('Skaarjwarrior'))
    Skaarjw++;
  else if (WhatDied.IsA('nalirabbit')||WhatDied.IsA('cow'))
    Animals++;
  else if (WhatDied.IsA('Brute'))
    Brutes++;
  else if (WhatDied.IsA('ScriptedXan2'))
    Nali++;
  else if (WhatDied.IsA('NaliTrooper')) //evil
    ENali++;
  else if (WhatDied.IsA('tentacle'))
    tentacles++;
  else if ((WhatDied.IsA('ParentBlob'))||(Whatdied.Isa('Bloblet'))) //never checked..
    blobs++;
  else if (WhatDied.IsA('BiterfishSchool')||Whatdied.Isa('biterfish')||Whatdied.Isa('devilfish')||Whatdied.Isa('squid'))
    fish++;
  else if (WhatDied.IsA('manta'))
    mantas++;
  else if (WhatDied.IsA('fly'))  //not in ONP.
    flies++;
  else if (WhatDied.IsA('pupae'))
    pupae++;
  else if (WhatDied.IsA('ScriptedHuman'))
    Humans++;
}

defaultproperties
{
}
