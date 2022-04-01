//=============================================================================
// UT_ShieldBeltEffect.
//=============================================================================
class UT_ShieldBeltEffect extends Effects;

var Texture LowDetailTexture;
var int FatnessOffset;

var bool B227_bLowDetail;

simulated function Destroyed()
{
	B227_RestoreOwnerDisplayProperties();
	super.Destroyed();
}

simulated function PostBeginPlay()
{
	if (!Level.bHighDetailMode && (Level.NetMode == NM_Standalone || Level.NetMode == NM_Client))
		B227_SetLowDetailMode();
}

simulated function Timer()
{
	local int TeamNum;

	bHidden = true;
	if (Pawn(Owner) == none || Owner.bMeshEnviromap || Owner.Style == STY_Translucent)
		return;
	if (Pawn(Owner).PlayerReplicationInfo == none)
		TeamNum = 3;
	else
		TeamNum = Min(3, Pawn(Owner).PlayerReplicationInfo.Team);
	LowDetailTexture = class'UT_Shieldbelt'.Default.TeamTextures[TeamNum];
	if ( Level.NetMode == NM_Client )
	{
		Owner.Texture = LowDetailTexture;
		Owner.bMeshEnviromap = true;
	}
	else
		Owner.SetDisplayProperties(Owner.Style, LowDetailTexture, false, true);
}

simulated function Tick(float DeltaTime)
{
	local int IdealFatness;

	if (Owner == none)
		return;

	if (Level.NetMode == NM_DedicatedServer)
	{
		bHidden = Owner.bHidden || Owner.Style == STY_Translucent; // controls network replication
		return;
	}

	if (B227_bLowDetail)
	{
		if (!Level.bHighDetailMode)
			return;
		B227_RestoreOwnerDisplayProperties();
		SetTimer(0, false);
	}
	else if (!Level.bHighDetailMode)
	{
		B227_SetLowDetailMode();
		return;
	}

	IdealFatness = Owner.Fatness; // Convert to int for safety.
	IdealFatness += FatnessOffset;

	if ( Fatness > IdealFatness )
		Fatness = Max(IdealFatness, Fatness - 130 * DeltaTime);
	else
		Fatness = Min(IdealFatness, 255);

	bHidden = Owner.bHidden || Owner.Style == STY_Translucent;
	DrawScale = Owner.DrawScale;
	Mesh = Owner.Mesh;
	PrePivot = Owner.PrePivot;
}

simulated function B227_SetLowDetailMode()
{
	Timer();
	bHidden = true;
	SetTimer(1.0, true);
	B227_bLowDetail = true;
}

simulated function B227_RestoreOwnerDisplayProperties()
{
	if (B227_bLowDetail &&
		Owner != none &&
		LowDetailTexture != none &&
		Owner.Texture == LowDetailTexture)
	{
		if (Level.NetMode == NM_Client)
		{
			Owner.Texture = Owner.default.Texture;
			Owner.bMeshEnviromap = Owner.default.bMeshEnviromap;
		}
		else
			Owner.SetDefaultDisplayProperties();
	}
}

defaultproperties
{
	LowDetailTexture=Texture'UnrealShare.Belt_fx.ShieldBelt.newgold'
	FatnessOffset=29
	bAnimByOwner=True
	bOwnerNoSee=True
	bNetTemporary=False
	bTrailerSameRotation=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=FireTexture'UnrealShare.Belt_fx.ShieldBelt.N_Shield'
	ScaleGlow=0.500000
	AmbientGlow=64
	Fatness=157
	bUnlit=True
	bMeshEnviroMap=True
}
