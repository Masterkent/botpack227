class UTC_HUD expands HUD
	config(Botpack);

var color WhiteColor;
var UTC_Mutator HUDMutator;
var PlayerPawn PlayerOwner; // always the actual owner

struct HUDLocalizedMessage
{
	var Class<LocalMessage> Message;
	var int Switch;
	var PlayerReplicationInfo RelatedPRI;
	var Object OptionalObject;
	var float EndOfLife;
	var float LifeTime;
	var bool bDrawing;
	var int numLines;
	var string StringMessage;
	var color DrawColor;
	var font StringFont;
	var float XL, YL;
	var float YPos;
};

var globalconfig bool B227_bVerticalCrosshairScaling;

event Destroyed()
{
	while (HUDMutator != none)
	{
		HUDMutator.Destroy();
		HUDMutator = HUDMutator.NextHUDMutator;
	}
}

function ClearMessage(out HUDLocalizedMessage M)
{
	UTSF_ClearMessage(self, M);
}

static function UTSF_ClearMessage(HUD this, out HUDLocalizedMessage M)
{
	M.Message = None;
	M.Switch = 0;
	M.RelatedPRI = None;
	M.OptionalObject = None;
	M.EndOfLife = 0;
	M.StringMessage = "";
	if (UTC_HUD(this) != none)
		M.DrawColor = UTC_HUD(this).WhiteColor;
	else
		M.DrawColor = default.WhiteColor;
	M.XL = 0;
	M.bDrawing = false;
}

function CopyMessage(out HUDLocalizedMessage M1, HUDLocalizedMessage M2)
{
	UTSF_CopyMessage(M1, M2);
}

static function UTSF_CopyMessage(out HUDLocalizedMessage M1, HUDLocalizedMessage M2)
{
	M1.Message = M2.Message;
	M1.Switch = M2.Switch;
	M1.RelatedPRI = M2.RelatedPRI;
	M1.OptionalObject = M2.OptionalObject;
	M1.EndOfLife = M2.EndOfLife;
	M1.StringMessage = M2.StringMessage;
	M1.DrawColor = M2.DrawColor;
	M1.XL = M2.XL;
	M1.YL = M2.YL;
	M1.YPos = M2.YPos;
	M1.bDrawing = M2.bDrawing;
	M1.LifeTime = M2.LifeTime;
	M1.numLines = M2.numLines;
}

simulated function LocalizedMessage(
	class<LocalMessage> Message,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject,
	optional string CriticalString);

static function UTSF_LocalizedMessage(
	HUD this,
	class<LocalMessage> Message,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject,
	optional string CriticalString)
{
	if (UTC_HUD(this) != none)
		UTC_HUD(this).LocalizedMessage(Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString);
	else
	{
		if (Message.default.bIsSpecial)
		{
			if (CriticalString == "")
				CriticalString = Message.static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		}
		else if (Message.default.bComplexString)
			CriticalString = Message.static.AssembleString(this, Switch, RelatedPRI_1, CriticalString);
		else
			CriticalString = Message.static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

		this.Message(RelatedPRI_1, CriticalString, Message.default.B227_MessageName);
	}
}

function bool ProcessKeyEvent(int Key, int Action, float Delta)
{
	return false;
}

static function bool UTSF_ProcessKeyEvent(HUD this, int Key, int Action, float Delta)
{
	if (UTC_HUD(this) != none)
		return UTC_HUD(this).ProcessKeyEvent(Key, Action, Delta);
	return false;
}

function UTC_GameReplicationInfo B227_GRI()
{
	return UTC_GameReplicationInfo(PlayerOwner.GameReplicationInfo);
}

function UTC_PlayerReplicationInfo B227_OwnerPRI()
{
	return UTC_PlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo);
}

function UTC_Mutator B227_FindHUDMutator(class<UTC_Mutator> MutatorClass, optional bool bIsBaseClass)
{
	local UTC_Mutator Mutator;

	if (MutatorClass == none)
		return none;

	if (bIsBaseClass)
	{
		for (Mutator = HUDMutator; Mutator != none; Mutator = Mutator.NextHUDMutator)
			if (ClassIsChildOf(Mutator.Class, MutatorClass))
				return Mutator;
	}
	else
	{
		for (Mutator = HUDMutator; Mutator != none; Mutator = Mutator.NextHUDMutator)
			if (Mutator.Class == MutatorClass)
				return Mutator;
	}
	return none;
}

function UTC_Mutator B227_AddHUDMutator(class<UTC_Mutator> MutatorClass)
{
	local UTC_Mutator Mutator;

	if (MutatorClass == none)
		return none;

	Mutator = Spawn(MutatorClass);
	if (Mutator != none)
	{
		Mutator.RegisterHUDMutator();
		if (Mutator.bHUDMutator)
			return Mutator;
		Mutator.Destroy(); // Failed to register the mutator for this HUD
	}

	return none;
}

static function float B227_CrosshairSize(Canvas Canvas, float Divider)
{
	if (default.B227_bVerticalCrosshairScaling)
		return FMin(Canvas.SizeX, Canvas.SizeY * 4 / 3) / Divider;
	return Canvas.SizeX / Divider;
}

static function float B227_ScaledFontScreenWidth(Canvas Canvas)
{
	return FMin(Canvas.SizeX, Canvas.SizeY * 4 / 3);
}

static function color B227_MultiplyColor(color Color, float Factor)
{
	if (Factor < 0)
		Factor = 0;
	return MakeColor(
		FMin(Color.R * Factor, 255),
		FMin(Color.G * Factor, 255),
		FMin(Color.B * Factor, 255),
		FMin(Color.A * Factor, 255));
}

static function color B227_AddColor(color C1, color C2)
{
	return MakeColor(
		Min(C1.R + C2.R, 255),
		Min(C1.G + C2.G, 255),
		Min(C1.B + C2.B, 255),
		Min(C1.A + C2.A, 255));
}

static function color B227_SubtractColor(color C1, color C2)
{
	return MakeColor(
		Max(C1.R - C2.R, 0),
		Max(C1.G - C2.G, 0),
		Max(C1.B - C2.B, 0),
		Max(C1.A - C2.A, 0));
}

defaultproperties
{
     HudMode=1
     HUDConfigWindowType="UMenu.UMenuHUDConfigCW"
     WhiteColor=(G=128,B=255)
     bHidden=True
     RemoteRole=ROLE_SimulatedProxy
     B227_bVerticalCrosshairScaling=True
}
