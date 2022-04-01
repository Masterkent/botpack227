//=============================================================================
// ChallengeCTFHUD.
//=============================================================================
class ADCTFHUD extends ChallengeCTFHUD;


//-var CTFFlag MyFlag;
var () float MinGroundSpeed;

function Timer()
{
	Super.Timer();

	/*-
	if ( (PlayerOwner == None) || (PawnOwner == None) )
		return;
	if ( PawnOwner.PlayerReplicationInfo.HasFlag != None )
		PlayerOwner.ReceiveLocalizedMessage( class'CTFMessage2', 0 );
	if ( (MyFlag != None) && !MyFlag.bHome )
		PlayerOwner.ReceiveLocalizedMessage( class'CTFMessage2', 1 );
	*/
}

simulated function PostRender( canvas Canvas )
{
	local TournamentPlayer TPOwner;
        local CombatFemale CombatFowner;
	local CombatMale CombatMowner;
	local float handstatus,legstatus,torsostatus;

	Super.PostRender( Canvas );

	if ( true )
	{
		TPOwner = TournamentPlayer(PawnOwner);

		if ( TPOwner != None)
		{
			 Canvas.DrawColor = HUDColor;
			 CombatFowner=CombatFemale(PawnOwner);
			 if ( CombatFowner != None)
			 {
			 CombatFowner=CombatFemale(PawnOwner);
			 Canvas.SetPos(Canvas.ClipX-140 , 0.20 * Canvas.ClipY);
     			 Canvas.Style = ERenderStyle.STY_Translucent;
    			 Canvas.Font = Canvas.SmallFont;
     			 Canvas.DrawText(" Combat HUD");
			 Legstatus=((CombatFowner.GroundSpeed-MinGroundSpeed) / (CombatFowner.Default.GroundSpeed-MinGroundSpeed) )*100;
			 Canvas.SetPos(Canvas.ClipX-140 , 0.22 * Canvas.ClipY);
                         Canvas.DrawText("Legs :status:  "$Int(legstatus)$" %");
			 Handstatus=((3-CombatFowner.WeaponAccuracyIndex)/3*100);
			 Canvas.SetPos(Canvas.ClipX-140 , 0.24 * Canvas.ClipY);
                         Canvas.DrawText("Arms :status:  "$Int(Handstatus)$" %");
			 Torsostatus=CombatFowner.Health;
			 Canvas.SetPos(Canvas.ClipX-140 , 0.26 * Canvas.ClipY);
                         Canvas.DrawText("Torso :status: "$Int(TorsoStatus)$" %");

			 }
		         else
		 	 {
                         CombatMowner=CombatMale(PawnOwner);
			 Canvas.SetPos(0.86 * Canvas.ClipX , 0.20 * Canvas.ClipY);
     			 Canvas.Style = ERenderStyle.STY_Translucent;
    			 Canvas.Font = Canvas.SmallFont;
     			 Canvas.DrawText(" Combat status");
			 Legstatus=((CombatMowner.GroundSpeed-MinGroundSpeed) / (CombatMowner.Default.GroundSpeed-MinGroundSpeed) )*100;
			 Canvas.SetPos(Canvas.ClipX-140 , 0.22 * Canvas.ClipY);
                         Canvas.DrawText("Legs status:  "$Int(legstatus)$" %");
			 Handstatus=((3-CombatMowner.WeaponAccuracyIndex)/3*100);
			 Canvas.SetPos(Canvas.ClipX-140 , 0.24 * Canvas.ClipY);
                         Canvas.DrawText("Arms status:  "$Int(Handstatus)$" %");
			 Torsostatus=CombatMowner.Health;
			 Canvas.SetPos(Canvas.ClipX-140 , 0.26 * Canvas.ClipY);
                         Canvas.DrawText("Torso status: "$Int(TorsoStatus)$" %");

			 }

                     }

	      }

}

simulated function DrawTeam(Canvas Canvas, TeamInfo TI)
{
	local float XL, YL;

	if ( (TI != None) && (TI.Size > 0) )
	{
		Canvas.DrawColor = TeamColor[TI.TeamIndex];
		DrawBigNum(Canvas, int(TI.Score), Canvas.ClipX - 144 * Scale, Canvas.ClipY - 336 * Scale - (150 * Scale * TI.TeamIndex), 1);
	}
}

defaultproperties
{
     MinGroundSpeed=120.000000
}
