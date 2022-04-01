//=============================================================================
// PKstarterbolt.
//=============================================================================
class PKStarterBolt extends StarterBolt;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SoundPitch=byte(default.soundpitch*level.timedilation-10*FRand());
}

defaultproperties
{
	AmbientSound=None
	SoundVolume=100
	B227_PBoltClass=Class'PKPBolt'
}
