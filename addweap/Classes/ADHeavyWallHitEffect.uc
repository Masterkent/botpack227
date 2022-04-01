//=============================================================================
//
//=============================================================================
class ADHeavyWallHitEffect extends UT_HeavyWallHitEffect;

#exec OBJ LOAD FILE="addweapResources.u" PACKAGE=addweap

simulated function SpawnSound()
{
	local float decision;

	decision = FRand();
	if ( decision < 0.5 )
		PlaySound(sound'adric',, 4,,1000);
		else if ( decision < 0.75 )
		PlaySound(sound'adricochet',, 4,,800);
	else
		PlaySound(sound'Impact2',, 4,,1000);
}

defaultproperties
{
}
