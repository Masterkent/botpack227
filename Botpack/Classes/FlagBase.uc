//=============================================================================
// FlagBase.
//=============================================================================
class FlagBase extends NavigationPoint;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var() byte Team;
var() Sound TakenSound;

function PostBeginPlay()
{
	local CTFFlag myFlag;

	Super.PostBeginPlay();
	LoopAnim('newflag');
	if ( !Level.Game.IsA('CTFGame') )
		return;

	bHidden = false;
	if ( Team == 0 )
	{
		Skin=texture'JpflagR';	
		myFlag = Spawn(class'RedFlag');
	}
	else if ( Team == 1 )
		myFlag = Spawn(class'CTFFlag');

	myFlag.HomeBase = self;
	myFlag.Team = Team;
	CTFReplicationInfo(Level.Game.GameReplicationInfo).FlagList[Team] = myFlag;
}

function PlayAlarm()
{
	SetTimer(5.0, false);
	AmbientSound = TakenSound;
}

function Timer()
{
	AmbientSound = None;
}

defaultproperties
{
	TakenSound=Sound'Botpack.CTF.flagtaken'
	bStatic=False
	bNoDelete=True
	bAlwaysRelevant=True
	DrawType=DT_Mesh
	Skin=Texture'Botpack.Skins.JpflagB'
	Mesh=LodMesh'Botpack.newflag'
	DrawScale=1.300000
	SoundRadius=255
	SoundVolume=255
	CollisionRadius=60.000000
	CollisionHeight=60.000000
	bCollideActors=True
	NetUpdateFrequency=3.000000
}
