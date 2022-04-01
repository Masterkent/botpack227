class BioMark expands UnrealShare.Scorch;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

simulated function BeginPlay()
{
	if ( !Level.bDropDetail && (FRand() < 0.5) )
		Texture = texture'Botpack.biosplat2';
	Super.BeginPlay();
}

defaultproperties
{
	MultiDecalLevel=2
	Texture=Texture'Botpack.biosplat'
	DrawScale=0.650000
}
