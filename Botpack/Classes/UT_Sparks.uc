//=============================================================================
// UT_Sparks.
//=============================================================================
class UT_Sparks extends Effects;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayAnim('GravSpray');
}
	
simulated function Landed( vector HitNormal )
{
	Destroy();
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	Destroy();
}

simulated function ZoneChange( ZoneInfo NewZone )
{
	if ( NewZone.bWaterZone )
		Destroy();
}

defaultproperties
{
	Physics=PHYS_Falling
	RemoteRole=ROLE_None
	LifeSpan=1.000000
	AnimSequence=GravSpray
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=Texture'Botpack.Effects.Sparky'
	Mesh=LodMesh'Botpack.SparksM'
	DrawScale=0.100000
	bUnlit=True
	bParticles=True
	bCollideWorld=True
}
