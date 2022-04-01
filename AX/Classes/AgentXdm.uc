//=============================================================================
// Agent X DeathMatchPlus.
//=============================================================================
class AgentXDM extends DeathMatchPlus;

function PreCacheReferences()
{
	//never called - here to force precaching of meshes

	spawn(class'TMale2');
	spawn(class'TFemale1');
	spawn(class'TFemale2');
	spawn(class'ppk');
	spawn(class'famasg2');
     	spawn(class'shottie');
      	spawn(class'axpellet');
	spawn(class'Famasg2');
	spawn(class'Asm4');
	spawn(class'ak47');
	spawn(class'glaun');
	spawn(class'rocketl');
	spawn(class'Sniper');
}

defaultproperties
{
     HUDType=Class'AX.axHUD'
     BeaconName="AgentXDM"
     GameName="AgentX DeathMatch"
     MutatorClass=Class'AX.AgentXArena'
}
