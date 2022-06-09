//=============================================================================
// NOWeaponAtAll.
//
// script by N.Bogenrieder (Beppo)
//
// YOU CAN USE THIS WEAPON AS A DEFAULT WEAPON !!!
// SO YOU HAVE NO WEAPON AT THE START OF THE GAME !!!
//
//=============================================================================
class NOWeaponAtAll expands Weapon;

//const					Pen = Texture'Pen';

function Fire( float Value ) {}
function AltFire( float Value ) {}
function BringUp()
{
	if ( Owner.IsA('PlayerPawn') )
		PlayerPawn(Owner).EndZoom();	
	bWeaponUp = false;
	GotoState('Active');
}
/*simulated function PostRender( canvas Canvas )
{
	Super.PostRender(Canvas);
	PlayerPawn(Owner).MyHud.DrawCrossHair(Canvas, 0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8);
	DrawRadar(Canvas, Canvas.ClipX - 128, 16);
}

simulated function DrawRadarBackground(Canvas canvas, int X, int Y)
{
	Canvas.SetPos(X,Y);
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawIcon(Texture'radar', 1.0);
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetPos(X + 2, Y + 114);
}

simulated function DrawRadarBlips(Canvas canvas, int RadarX, int RadarY)
{
	local actor blip;
	local int CenterX, CenterY;
	local vector RelLoc;
	local float d, x, y, arc;
	local actor Viewer;
	local UnrealHUD UHUD;
	
	CenterX = RadarX + 64;
	CenterY = RadarY + 64;
	Viewer = Owner;
	if (PlayerPawn(Owner).ViewTarget != none)
		Viewer = PlayerPawn(Owner).ViewTarget;
		
	// mark pawn blips
	foreach RadiusActors(class'actor', blip, 100 * 62, Viewer.Location)
		if (blip != Viewer)
		{
			if (blip.IsA('ControlRocket'))
				Canvas.DrawColor = UHUD.AltTeamColor[1];
			else if (blip.IsA('Pawn'))
			{
				if (   Pawn(blip).bHidden
					|| Pawn(blip).Health <= 0)
					continue;
				else
					Canvas.DrawColor = UHUD.TeamColor[Pawn(blip).PlayerReplicationInfo.Team];
			}
			else continue;
			
			// calculate the corresponding 3D pos. on a 2D area
			// WARNING: heavy math ahead!
			RelLoc = Viewer.Location - blip.Location;
			arc = (Viewer.Rotation.Yaw - 16384) / 182.04 / 360;
			d = arc * 2 * PI;
			x =  RelLoc.X * cos(d) + RelLoc.Y * sin(d);
			y = -RelLoc.X * sin(d) + RelLoc.Y * cos(d);
			x /= 100;
			y /= 100;
			x += CenterX - 1;
			y += CenterY - 1;
			Canvas.SetPos(x,y);

			Canvas.DrawIcon(Pen, 3.0);
			Canvas.DrawColor = UHUD.AltTeamColor[3];
		}
}

simulated function DrawRadar(canvas Canvas, int X, int Y)
{
	DrawRadarBackground(canvas, X, Y);
	DrawRadarBlips(canvas, X, Y);
}*/

state Active
{
	function Fire(float F) 
	{
	}

	function AltFire(float F) 
	{
	}

	function bool PutDown()
	{
		if ( bWeaponUp )
			GotoState('DownWeapon');
		else
			bChangeWeapon = true;
		return True;
	}

	function BeginState()
	{
		bChangeWeapon = false;
	}

Begin:
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	bWeaponUp = True;
}

defaultproperties
{
     PickupAmmoCount=50
     bOwnsCrosshair=True
     PickupMessage="You have no weapon"
     ItemName="NoWeaponAtAll"
     RespawnTime=0.000000
     bHidden=True
     DrawType=DT_Sprite
}
