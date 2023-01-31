//=============================================================================
// RingExplosion3.
//=============================================================================
class UT_RingExplosion3 extends ut_RingExplosion;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var bool B227_bSpawnDecal;

replication
{
	reliable if (Role == ROLE_Authority)
		B227_bSpawnDecal;
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim( 'Explo', 0.15, 0.0 );
		SpawnEffects();
	}	
	if ( Instigator != None )
		MakeNoise(0.5);
}

simulated function SpawnExtraEffects()
{
	if (B227_bSpawnDecal)
		Spawn(class'EnergyImpact');
	bExtraEffectsSpawned = true;
}

defaultproperties
{
	Skin=Texture'Botpack.Effects.BlueRing'
	DrawScale=1.250000
	bExtraEffectsSpawned=False
}
