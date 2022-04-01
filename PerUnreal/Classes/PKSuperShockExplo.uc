//=============================================================================
// PKSuperShockExplo.
//=============================================================================
class PKSuperShockExplo expands Effects;

function MakeSound()
{
	PlaySound(sound'PKlaserexplo',SLOT_Misc,,,, 0.95+0.1 * FRand());
	PlaySound(sound'PKlaserexplo',SLOT_Interact,,,, 0.95+0.1 * FRand());
}

simulated function PostBeginPlay()
{
	Spawn(class'PKShockSpark',Self, '', Location + (10 + 10 * FRand()) * (VRand() + Vect(0,0,0.5)) );
	Spawn(class'PKShockSpark',Self, '', Location + (10 + 10 * FRand()) * (VRand() + Vect(0,0,0.5)) );
	Spawn(class'PKShockSpark',Self, '', Location + (10 + 10 * FRand()) * (VRand() + Vect(0,0,0.5)) );
	Spawn(class'PKShockSpark',Self, '', Location + (10 + 10 * FRand()) * (VRand() + Vect(0,0,0.5)) );
	Spawn(class'PKShockSpark',Self, '', Location + (10 + 10 * FRand()) * (VRand() + Vect(0,0,0.5)) );
	Spawn(class'PKShockSpark',Self, '', Location + (10 + 10 * FRand()) * (VRand() + Vect(0,0,0.5)) );

	if ( Level.NetMode != NM_Client )
		MakeSound();
	Super.PostBeginPlay();
}

simulated Function Timer()
{
}

defaultproperties
{
}
