class BloodSplat expands UnrealShare.Scorch;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var texture Splats[10];

simulated function BeginPlay()
{
	if ( class'GameInfo'.Default.bLowGore || (Level.bDropDetail && (FRand() < 0.35)) )
	{
		destroy();
		return;
	}
	if ( Level.bDropDetail )
		Texture = splats[Rand(5)];
	else
		Texture = splats[Rand(10)];
}

defaultproperties
{
	Splats(0)=Texture'Botpack.BloodSplat1'
	Splats(1)=Texture'Botpack.BloodSplat2'
	Splats(2)=Texture'Botpack.BloodSplat3'
	Splats(3)=Texture'Botpack.BloodSplat4'
	Splats(4)=Texture'Botpack.BloodSplat5'
	Splats(5)=Texture'Botpack.BloodSplat6'
	Splats(6)=Texture'Botpack.BloodSplat7'
	Splats(7)=Texture'Botpack.BloodSplat8'
	Splats(8)=Texture'Botpack.BloodSplat9'
	Splats(9)=Texture'Botpack.BloodSplat10'
	bImportant=False
	MultiDecalLevel=0
	Texture=Texture'Botpack.BloodSplat1'
	DrawScale=0.350000
}
