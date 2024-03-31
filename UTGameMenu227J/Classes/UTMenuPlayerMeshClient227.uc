class UTMenuPlayerMeshClient227 extends UMenuDialogClientWindow;

var UWindowSmallButton FaceButton;

var UTMeshActor227 MeshActor;
var rotator ViewRotator;
var bool bIsTournamentPlayer;
var bool bFace;
var name IdleAnimName;

var float MouseDragX;

function WindowShown()
{
	Super.WindowShown();
	InitMeshActor();
}

function Created()
{
	Super.Created();

	InitMeshActor();
	ViewRotator = rot(0, 32768, 0);

	FaceButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 0, WinHeight - 16, 48, 16));
	FaceButton.Text = class'UMenuPlayerMeshClient'.default.FaceText;
	FaceButton.bAlwaysOnTop = True;
	FaceButton.bIgnoreLDoubleclick = True;
}

function bool InitMeshActor()
{
	if (MeshActor == none || MeshActor.bDeleteMe)
	{
		MeshActor = GetEntryLevel().Spawn(class'UTMeshActor227', GetEntryLevel());
		if (MeshActor == none)
			return false;
		MeshActor.Mesh = GetPlayerOwner().Mesh;
		MeshActor.Skin = GetPlayerOwner().Skin;
		MeshActor.NotifyClient = Self;
	}
	return true;
}

function Resized()
{
	Super.Resized();

	FaceButton.WinTop = WinHeight - 16;
}

function BeforePaint(Canvas C, float X, float Y)
{
	SetButtonAutoWidth(FaceButton, C);
}

function Paint(Canvas C, float X, float Y)
{
	local vector ViewOffset;
	local float MeshScale;

	C.Style = GetPlayerOwner().ERenderStyle.STY_Modulated;
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
	C.Style = GetPlayerOwner().ERenderStyle.STY_Normal;

	if (MeshActor != None && MeshActor.Mesh != none)
	{
		ViewOffset.Z = GetMeshZOffset(MeshActor.Mesh);
		MeshScale = GetMeshScale(MeshActor.Mesh);
		if (bFace)
			DrawClippedScaledActor(C, MeshActor, false, ViewRotator, ViewOffset + vect(15, 0, -1.5), MeshScale, 0.75, 7);
		else
			DrawClippedScaledActor(C, MeshActor, false, ViewRotator, ViewOffset + vect(15, 0, 0), MeshScale, 0.6, 14.4);
	}
}

function float GetMeshZOffset(Mesh Mesh)
{
	switch (Mesh.Name)
	{
		case 'sktrooper':
		case 'Nali2':
			return -0.4;

		default:
			if (bIsTournamentPlayer)
				return -0.2;
			return 0;
	}
}

function float GetMeshScale(Mesh Mesh)
{
	switch (Mesh.Name)
	{
		case 'sktrooper':
			return 0.86;

		case 'Nali2':
			return 0.92;

		default:
			return 1.0;
	}
}

final function DrawClippedScaledActor(
	Canvas C,
	Actor A,
	bool WireFrame,
	rotator RotOffset,
	vector LocOffset,
	float Scale,
	float StretchingAspectRatio,
	float FOV)
{
	local float X, Y, W, H;
	local float OldDrawScale;
	local float OldFOV;

	X = C.OrgX + ClippingRegion.X * Root.GUIScale;
	Y = C.OrgY + ClippingRegion.Y * Root.GUIScale;
	W = ClippingRegion.W * Root.GUIScale;
	H = ClippingRegion.H * Root.GUIScale;

	if (H < 1.0)
		return;

	if (W / H > StretchingAspectRatio)
		FOV = ATan(Tan(FOV * Pi / 360) * W / H / StretchingAspectRatio) * 360 / Pi;

	OldDrawScale = A.DrawScale;
	A.DrawScale *= Scale;

	A.SetRotation(RotOffset);
	A.SetLocation(LocOffset);

	OldFOV = GetPlayerOwner().FOVAngle;
	GetPlayerOwner().FOVAngle = FOV;
	C.DrawClippedActor(A, WireFrame, W, H, X, Y, true);
	GetPlayerOwner().FOVAngle = OldFOV;

	A.DrawScale = OldDrawScale;
}

function Tick(float Delta)
{
	if (bMouseDown)
	{
		ViewRotator.Yaw -= (Root.MouseX - MouseDragX) * (48000.f / WinHeight);
		MouseDragX = Root.MouseX;
		ViewRotator.Yaw = ViewRotator.Yaw & 65535;
	}
}

function ClearSkins()
{
	local int i;

	MeshActor.Skin = None;
	for (i=0; i<4; i++)
		MeshActor.MultiSkins[i] = None;
}

function SetSkin(texture NewSkin)
{
	ClearSkins();
	MeshActor.Skin = NewSkin;
}

function SetMesh(mesh NewMesh, float DScaling )
{
	if (!InitMeshActor())
		return;

	MeshActor.bMeshEnviroMap = False;
	MeshActor.DrawScale = MeshActor.Default.DrawScale*DScaling*0.7;
	MeshActor.Mesh = NewMesh;
	if (MeshActor.Mesh != none)
	{
		if (SkeletalMesh(NewMesh) != none)
			MeshActor.LinkSkelAnim(none);
		if (MeshActor.HasAnim('Breath1'))
			IdleAnimName = 'Breath1';
		else if (MeshActor.HasAnim('Breath'))
			IdleAnimName = 'Breath';
		else if (MeshActor.HasAnim('Breath3'))
			IdleAnimName = 'Breath3';
		else
		{
			MeshActor.AnimRate = 0;
			return;
		}
		MeshActor.PlayAnim(IdleAnimName, 0.5, 0.f);
	}
}

function SetNoAnimMesh(mesh NewMesh)
{
	MeshActor.bMeshEnviroMap = False;
	MeshActor.DrawScale = MeshActor.Default.DrawScale;
	MeshActor.Mesh = NewMesh;
	if ( SkeletalMesh(NewMesh)!=None )
		MeshActor.LinkSkelAnim(None);
	MeshActor.AnimRate = 0;
}

function SetMeshString(string NewMesh)
{
	SetMesh(mesh(DynamicLoadObject(NewMesh, Class'Mesh')), 35.0 / 39.0);
}

function SetNoAnimMeshString(string NewMesh)
{
	SetNoAnimMesh(mesh(DynamicLoadObject(NewMesh, Class'Mesh')));
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	if (MeshActor != None)
	{
		MeshActor.NotifyClient = None;
		MeshActor.Destroy();
		MeshActor = None;
	}
}

function LMouseDown(float X, float Y)
{
	super.LMouseDown(X, Y);
	MouseDragX = Root.MouseX;
}

function Notify(UWindowDialogControl C, byte E)
{
	switch (E)
	{
		case DE_Click:
			switch (C)
			{
				case FaceButton:
					FacePressed();
					break;
			}
			break;
	}
}

function FacePressed()
{
	bFace = !bFace;
	if (bFace)
		FaceButton.Text = class'UMenuPlayerMeshClient'.default.BodyText;
	else
		FaceButton.Text = class'UMenuPlayerMeshClient'.default.FaceText;
}

function LeftPressed()
{
	ViewRotator.Yaw += 128;
}

function RightPressed()
{
	ViewRotator.Yaw -= 128;
}

function AnimEnd(UTMeshActor227 MyMesh)
{
	MyMesh.PlayAnim(IdleAnimName, 0.4);
}

static function SetButtonAutoWidth(UWindowSmallButton Button, Canvas C)
{
	local float W, H;

	C.Font = Button.Root.Fonts[Button.Font];

	Button.TextSize(C, Button.RemoveAmpersand(Button.Text), W, H);

	if (Button.WinWidth < W + 10)
		Button.WinWidth = W + 10;
}
