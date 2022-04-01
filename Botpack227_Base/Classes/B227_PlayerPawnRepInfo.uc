class B227_PlayerPawnRepInfo expands Info;

var float LastPlaySound;

replication
{
	reliable if (Role == ROLE_Authority)
		ClientReliablePlaySound;
	unreliable if (Role == ROLE_Authority && !bDemoRecording)
		ClientPlaySound;
}

static function bool GetInstance(PlayerPawn P, out B227_PlayerPawnRepInfo PR)
{
	if (P == none)
		return false;
	foreach P.ChildActors(class'B227_PlayerPawnRepInfo', PR)
		return true;
	PR = P.Spawn(class'B227_PlayerPawnRepInfo', P);
	return PR != none;
}

simulated function bool GetPlayerOwner(out PlayerPawn PlayerOwner)
{
	PlayerOwner = PlayerPawn(Owner);
	return PlayerOwner != none;
}

simulated function ClientPlaySound(sound ASound, optional bool bInterrupt)
{
	local Actor SoundPlayer;
	local PlayerPawn PlayerOwner;

	if (!GetPlayerOwner(PlayerOwner))
		return;

	LastPlaySound = Level.TimeSeconds;	// so voice messages won't overlap
	if (PlayerOwner.ViewTarget != none)
		SoundPlayer = PlayerOwner.ViewTarget;
	else
		SoundPlayer = PlayerOwner;

	SoundPlayer.PlaySound(ASound, SLOT_None, 16.0, bInterrupt);
	SoundPlayer.PlaySound(ASound, SLOT_Interface, 16.0, bInterrupt);
	SoundPlayer.PlaySound(ASound, SLOT_Misc, 16.0, bInterrupt);
	SoundPlayer.PlaySound(ASound, SLOT_Talk, 16.0, bInterrupt);
}

simulated function ClientReliablePlaySound(sound ASound, optional bool bInterrupt)
{
	ClientPlaySound(ASound, bInterrupt);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
