class WallCrack expands UnrealShare.Scorch;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

simulated function BeginPlay()
{
	if ( FRand() < 0.5 )
		Texture = texture'Botpack.WallCrack1';
	else
		Texture = texture'Botpack.WallCrack2';
}

defaultproperties
{
	bImportant=False
	MultiDecalLevel=0
	Texture=Texture'Botpack.WallCrack1'
	DrawScale=0.400000
}
