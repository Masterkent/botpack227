class B227_Speech expands Mutator;

event BeginPlay()
{
	Spawn(class'B227_SpeechGR');

	if (Level.NetMode != NM_Standalone)
	{
		AddToPackagesMap(string(Class.Outer.Name));
		if (class'B227_SpeechGR'.static.LoadVoicePack("multimesh.NaliVoice") != none)
			AddToPackagesMap("multimesh");
	}
}

function string GetHumanName()
{
	return "UT Speech Menu B227";
}
