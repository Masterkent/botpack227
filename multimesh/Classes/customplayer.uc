//=============================================================================
// CustomPlayer.
//=============================================================================
class CustomPlayer extends TournamentMale
	abstract;

var() mesh FallBackMesh;
var() string Author;
var() string AuthorInfo;
var() string DefaultFace, TeamSkin, DefaultCustomPackage;

static function SetMyMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
	local string MeshName, FacePackage, SkinItem, FaceItem, SkinPackage;

	MeshName = SkinActor.GetItemName(string(SkinActor.Mesh));

	SkinItem = SkinActor.GetItemName(SkinName);
	FaceItem = SkinActor.GetItemName(FaceName);
	FacePackage = Left(FaceName, Len(FaceName) - Len(FaceItem));
	SkinPackage = Left(SkinName, Len(SkinName) - Len(SkinItem));
	log(SkinItem@FaceItem@FacePackage@SkinPackage);

	if(SkinPackage == "")
	{
		SkinPackage=default.DefaultCustomPackage;
		SkinName=SkinPackage$SkinName;
	}
	if(FacePackage == "")
	{
		FacePackage=default.DefaultCustomPackage;
		FaceName=FacePackage$FaceName;
	}

	// Set the fixed skin element.  If it fails, go to default skin & no face.
	if(!SetSkinElement(SkinActor, default.FixedSkin, SkinName$string(default.FixedSkin+1), default.DefaultSkinName$string(default.FixedSkin+1)))
	{
		SkinName = default.DefaultSkinName;
		FaceName = "";
	}

	// Set the face - if it fails, set the default skin for that face element.
	SetSkinElement(SkinActor, default.FaceSkin, FacePackage$SkinItem$String(default.FaceSkin+1)$FaceItem, SkinName$String(default.FaceSkin+1));

	// Set the team elements
	if( TeamNum != 255 )
	{
		SetSkinElement(SkinActor, default.TeamSkin1, SkinName$string(default.TeamSkin1+1)$"T_"$String(TeamNum), SkinName$string(default.TeamSkin1+1));
		SetSkinElement(SkinActor, default.TeamSkin2, SkinName$string(default.TeamSkin2+1)$"T_"$String(TeamNum), SkinName$string(default.TeamSkin2+1));
	}
	else
	{
		SetSkinElement(SkinActor, default.TeamSkin1, SkinName$string(default.TeamSkin1+1), "");
		SetSkinElement(SkinActor, default.TeamSkin2, SkinName$string(default.TeamSkin2+1), "");
	}

	// Set the talktexture
	if(Pawn(SkinActor) != None)
	{
		if(FaceName != "")
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(FacePackage$SkinItem$"5"$FaceItem, class'Texture'));
		else
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = None;
	}
}

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
	local string MeshName;
	local Texture NewSkin;

	if ( SkinActor.Mesh == Default.FallBackMesh )
	{
		Super.SetMultiSkin(SkinActor, "CommandoSkins.cmdo", "Blake", TeamNum);
		return;
	}

	if ( SkinName == "" )
		SkinName = default.DefaultSkinName;

	if ( default.bisMultiSkinned )
	{
		if ( FaceName == "" )
			FaceName = default.DefaultFace;

		log("set multiskin "$SkinName@FaceName);
		//Super.
		SetMyMultiSkin(SkinActor, SkinName, FaceName, TeamNum);
		return;
	}

	// only one skin for mesh

	MeshName = SkinActor.GetItemName(string(SkinActor.Mesh));
	if( TeamNum != 255 )
		SkinName = default.DefaultCustomPackage$default.TeamSkin$String(TeamNum);

	if( !SetSkinElement(SkinActor, 0, SkinName, default.DefaultSkinName) )
		SkinName = default.DefaultSkinName;

	NewSkin = Texture(DynamicLoadObject(SkinName, class'Texture'));
	if ( NewSkin != None )
		SkinActor.Skin = NewSkin;
	else
	{
		log("Failed to load "$SkinName);
		if(default.DefaultSkinName != "")
		{
			NewSkin = Texture(DynamicLoadObject(default.DefaultSkinName, class'Texture'));
			SkinActor.Skin = NewSkin;
		}
	}

	// Set the talktexture
	if( Pawn(SkinActor) != None )
	{
		if ( (SkinName != Default.DefaultSkinName) && (TeamNum == 255) )
		{
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(SkinName$"-Face", class'Texture'));
			if ( Pawn(SkinActor).PlayerReplicationInfo.TalkTexture == None )
				Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(default.DefaultFace, class'Texture'));
		}
		else
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(default.DefaultFace, class'Texture'));
	}
}

static function GetMultiSkin( Actor SkinActor, out string SkinName, out string FaceName )
{
	local string FullSkinName, ShortSkinName;

	if ( default.bisMultiSkinned
		|| (SkinActor.Mesh == Default.FallBackMesh) )
	{
		Super.GetMultiSkin(SkinActor,SkinName,FaceName);
		return;
	}

	// only one skin
	FaceName = "";

	FullSkinName  = String(SkinActor.Skin);
	ShortSkinName = SkinActor.GetItemName(FullSkinName);
	SkinName = Left(FullSkinName, Len(FullSkinName) - Len(ShortSkinName)) $ Left(ShortSkinName, 4);
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetMyMesh();
}

function SetMesh()
{
	SetMyMesh();
}

function SetMyMesh()
{
	if (Role != ROLE_Authority)
		return;

	DrawType = DT_Mesh;

	if ( class'MultiMeshMenu'.default.bForceDefaultMesh
		|| ((Mesh == None) && (Default.Mesh == None)) )
	{
		bIsMultiSkinned = true;
		Mesh = FallBackMesh;
		Super.SetMultiSkin(self, "CommandoSkins.cmdo", "Blake", PlayerReplicationInfo.Team);
		return;
	}

	if ( Default.Mesh != none )
		Mesh = Default.Mesh;

	if ( bIsMultiSkinned )
	{
		if ( MultiSkins[1] == None )
		{
			if ( bIsPlayer && (PlayerReplicationInfo != None) )
				SetMultiSkin(self, "","", PlayerReplicationInfo.team);
			else
				SetMultiSkin(self, "","", 0);
		}
	}
	else if ( Skin == None )
		Skin = Default.Skin;
}

// don't make assumptions deaths will also work as certain type of hit anim
function PlayGutHit(float tweentime)
{
	if ( AnimSequence == 'GutHit' )
	{
		if (FRand() < 0.5)
			TweenAnim('LeftHit', tweentime);
		else
			TweenAnim('RightHit', tweentime);
	}
	else
		TweenAnim('GutHit', tweentime);
}

function PlayHeadHit(float tweentime)
{
	if ( AnimSequence == 'HeadHit' )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('HeadHit', tweentime);
}

function PlayLeftHit(float tweentime)
{
	if ( AnimSequence == 'LeftHit' )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('LeftHit', tweentime);
}

function PlayRightHit(float tweentime)
{
	if ( AnimSequence == 'RightHit' )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('RightHit', tweentime);
}

defaultproperties
{
     FallBackMesh=LodMesh'Botpack.Commando'
     FaceSkin=1
     TeamSkin1=2
     TeamSkin2=3
     DefaultSkinName="CommandoSkins.cmdo"
     DefaultPackage="CommandoSkins."
     LandGrunt=Sound'UnrealShare.Male.MLand3'
     JumpSound=Sound'Botpack.Male.TMJump3'
     SelectionMesh="Botpack.SelectionMale1"
     SpecialMesh="Botpack.TrophyMale1"
     MenuName="Custom Player"
     Mesh=LodMesh'Botpack.Commando'
}
