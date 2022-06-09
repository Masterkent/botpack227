//=============================================================================
// RadarHUD.
//
// script by N.Bogenrieder (Beppo)
// original radar script by
// Chris "Catalyst" Robbers
//
// this HUD can be used for projectiles or other
//=============================================================================
class RadarHUD expands UnrealHUD;


struct	sPalette
{
	var()	color	Black;
};
//const	Dot = Texture'nbspecialt.radardot';
var		texture Dot;
var()   texture RadarTexture[4];
var()	sPalette		Palette;

var HUD oHUD;

simulated function PostRender( canvas Canvas )
{
//	oHUD.PostRender(Canvas);
	if ( PlayerPawn(Owner) != None )
	{
		if ( PlayerPawn(Owner).PlayerReplicationInfo == None )
			return;
		if ( PlayerPawn(Owner).bShowMenu )
		{
			DisplayMenu(Canvas);
			return;
		}
		else
		{
//			DrawRadar(Canvas, Canvas.ClipX - 128, 16);
//			DrawRadar(Canvas, 0.5 * Canvas.ClipX - 64, 0.5 * Canvas.ClipY - 64);
			oHUD.PostRender(Canvas);
			DrawRadar(Canvas, 0.5 * Canvas.ClipX - 64, 16);
		}
	}
}

simulated function DrawRadarBackground(Canvas canvas, int X, int Y)
{
	Canvas.SetPos(X,Y);
	Canvas.Style = ERenderStyle.STY_Translucent;
	if (Level.Game.IsA('TeamGame'))
		Canvas.DrawIcon(RadarTexture[PlayerPawn(Owner).PlayerReplicationInfo.Team], 1.0);
	else
		Canvas.DrawIcon(RadarTexture[0], 1.0);
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetPos(X + 2, Y + 114);
}

simulated function DrawRadarBlips(Canvas canvas, int RadarX, int RadarY)
{
	local pawn blip;
	local int CenterX, CenterY;
	local vector RelLoc;
	local float d, x, y, arc;
	local actor Viewer;

	CenterX = RadarX + 64;
	CenterY = RadarY + 64;
	Viewer = Owner;
	if (PlayerPawn(Owner).ViewTarget != none)
		Viewer = PlayerPawn(Owner).ViewTarget;

	// mark pawn blips
	foreach RadiusActors(class'pawn', blip, 100 * 62, Viewer.Location)
		if (blip != Viewer)
		{
			if (   blip.bHidden
				|| blip.Health <= 0)
				continue;
			else
			{
				Canvas.DrawColor = Palette.Black;
				if (Level.Game.IsA('TeamGame'))
					if ( (blip.IsA('Bots'))	|| (blip.IsA('PlayerPawn')) )
						if (oHUD.IsA('UnrealHUD'))
							Canvas.DrawColor = UnrealHUD(oHUD).default.AltTeamColor[blip.PlayerReplicationInfo.Team];
			}

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

			Canvas.DrawIcon(Dot, 3.0);
		}
}

simulated function DrawRadar(canvas Canvas, int X, int Y)
{
	DrawRadarBackground(canvas, X, Y);
	DrawRadarBlips(canvas, X, Y);
}

defaultproperties
{
}
