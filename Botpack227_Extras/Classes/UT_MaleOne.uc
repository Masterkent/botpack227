class UT_MaleOne extends UT_Male;

simulated function PlayMetalStep()
{
	local sound step;
	local float decision;

	if ( !bIsWalking && (Level.Game != None) && (Level.Game.Difficulty > 1) && ((Weapon == None) || !Weapon.bPointing) )
		MakeNoise(0.05 * Level.Game.Difficulty);
	if ( Level.NetMode==NM_DedicatedServer )
		Return;

	if( Level.FootprintManager==None || !Level.FootprintManager.Static.OverrideFootstep(Self,step,WetSteps) )
	{
		decision = FRand();
		if ( decision < 0.34 )
			step = sound'MetWalk1';
		else if (decision < 0.67 )
			step = sound'MetWalk2';
		else
			step = sound'MetWalk3';
	}
	if( step==None )
		return;
	if ( bIsWalking )
		PlaySound(step, SLOT_Interact, 0.5, false, 400.0, 1.0);
	else PlaySound(step, SLOT_Interact, 1, false, 1000.0, 1.0);
}

defaultproperties
{
	CarcassType=Class'UnrealI.MaleOneCarcass'
	MenuName="Male 1"
	Skin=Texture'UnrealShare.Skins.Kurgan'
	Mesh=LodMesh'UnrealI.Male1'
	VoiceType="BotPack.VoiceMaleOne"
}
