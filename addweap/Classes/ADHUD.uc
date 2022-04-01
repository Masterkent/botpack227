//=============================================================================
//
//
//=================================;============================================
class ADHUD extends challengeHUD;

var()  float MinGroundSpeed;

simulated function DrawStatus(Canvas Canvas)
{
	local float StatScale, ChestAmount, ThighAmount, H1, H2, X, Y, DamageTime;
	Local int ArmorAmount,CurAbs,i;
	Local inventory Inv,BestArmor;
	local bool bChestArmor, bShieldbelt, bThighArmor, bJumpBoots, bHasDoll;
	local Bot BotOwner;
	local TournamentPlayer TPOwner;
	local texture Doll, DollBelt;
	local CombatFemale CombatFowner;
	local CombatMale CombatMowner;
	local float handstatus,legstatus,torsostatus;


	ArmorAmount = 0;
	CurAbs = 0;
	i = 0;
	BestArmor=None;

	for( Inv=PawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if (Inv.bIsAnArmor)
		{
			if ( Inv.IsA('UT_Shieldbelt') )
				bShieldbelt = true;
			else if ( Inv.IsA('Thighpads') )
			{
				ThighAmount += Inv.Charge;
				bThighArmor = true;
			}
			else
			{
				bChestArmor = true;
				ChestAmount += Inv.Charge;
			}
			ArmorAmount += Inv.Charge;
		}
		else if ( Inv.IsA('UT_JumpBoots') )
			bJumpBoots = true;
		else
		{
			i++;
			if ( i > 100 )
				break; // can occasionally get temporary loops in netplay
		}
	}

	if ( True )
	{
		TPOwner = TournamentPlayer(PawnOwner);
		if ( Canvas.ClipX < 400 )
			bHasDoll = false;
		else if ( TPOwner != None)
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
                         Canvas.DrawText("Torso:status: "$Int(TorsoStatus)$" %");

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




			Doll = TPOwner.StatusDoll;
			DollBelt = TPOwner.StatusBelt;
			bHasDoll = true;
		}
		else
		{
			BotOwner = Bot(PawnOwner);
			if ( BotOwner != None )
			{
				Doll = BotOwner.StatusDoll;
				DollBelt = BotOwner.StatusBelt;
				bHasDoll = true;
			}
		}
		if ( bHasDoll )
		{
			Canvas.Style = ERenderStyle.STY_Translucent;
			StatScale = Scale * StatusScale;
			X = Canvas.ClipX - 128 * StatScale;
			Canvas.SetPos(X, 0);
			if (PawnOwner.DamageScaling > 2.0)
				Canvas.DrawColor = PurpleColor;
			else
				Canvas.DrawColor = HUDColor;
			Canvas.DrawTile(Doll, 128*StatScale, 256*StatScale, 0, 0, 128.0, 256.0);
			Canvas.DrawColor = HUDColor;
			if ( bShieldBelt )
			{
				Canvas.DrawColor = BaseColor;
				Canvas.DrawColor.B = 0;
				Canvas.SetPos(X, 0);
				Canvas.DrawIcon(DollBelt, StatScale);
			}
			if ( bChestArmor )
			{
				ChestAmount = FMin(0.01 * ChestAmount,1);
				Canvas.DrawColor = B227_MultiplyColor(HUDColor, ChestAmount);
				Canvas.SetPos(X, 0);
				Canvas.DrawTile(Doll, 128*StatScale, 64*StatScale, 128, 0, 128, 64);
			}
			if ( bThighArmor )
			{
				ThighAmount = FMin(0.02 * ThighAmount,1);
				Canvas.DrawColor = B227_MultiplyColor(HUDColor, ThighAmount);
				Canvas.SetPos(X, 64*StatScale);
				Canvas.DrawTile(Doll, 128*StatScale, 64*StatScale, 128, 64, 128, 64);
			}
			if ( bJumpBoots )
			{
				Canvas.DrawColor = HUDColor;
				Canvas.SetPos(X, 128*StatScale);
				Canvas.DrawTile(Doll, 128*StatScale, 64*StatScale, 128, 128, 128, 64);
			}
			Canvas.Style = Style;
			if ( (PawnOwner == PlayerOwner) && Level.bHighDetailMode && !Level.bDropDetail )
			{
				for ( i=0; i<4; i++ )
				{
					DamageTime = Level.TimeSeconds - HitTime[i];
					if ( DamageTime < 1 )
					{
						Canvas.SetPos(X + HitPos[i].X * StatScale, HitPos[i].Y * StatScale);
						if ( (HUDColor.G > 100) || (HUDColor.B > 100) )
							Canvas.DrawColor = RedColor;
						else
							Canvas.DrawColor = B227_MultiplyColor(B227_SubtractColor(WhiteColor, HudColor), FMin(1, 2 * DamageTime));
						Canvas.DrawColor.R = 255 * FMin(1, 2 * DamageTime);
						Canvas.DrawTile(Texture'BotPack.HudElements1', StatScale * HitDamage[i] * 25, StatScale * HitDamage[i] * 64, 0, 64, 25.0, 64.0);
					}
				}
			}
		}
	}
	Canvas.DrawColor = HUDColor;
	if ( bHideStatus && bHideAllWeapons )
	{
		X = 0.5 * Canvas.ClipX;
		Y = Canvas.ClipY - 64 * Scale;
	}
	else
	{
		X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
		Y = 64 * Scale;
	}
	Canvas.SetPos(X,Y);
	if ( PawnOwner.Health < 50 )
	{
		H1 = 1.5 * TutIconBlink;
		H2 = 1 - H1;
		Canvas.DrawColor = B227_AddColor(B227_MultiplyColor(WhiteColor, H2), B227_MultiplyColor(B227_SubtractColor(HUDColor, WhiteColor), H1));
	}
	else
		Canvas.DrawColor = HUDColor;
	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 128, 128, 128.0, 64.0);

	if ( PawnOwner.Health < 50 )
	{
		H1 = 1.5 * TutIconBlink;
		H2 = 1 - H1;
		Canvas.DrawColor = B227_AddColor(B227_MultiplyColor(Canvas.DrawColor, H2), B227_MultiplyColor(B227_SubtractColor(WhiteColor, Canvas.DrawColor), H1));
	}
	else
		Canvas.DrawColor = WhiteColor;

	DrawBigNum(Canvas, Max(0, PawnOwner.Health), X + 4 * Scale, Y + 16 * Scale, 1);

	Canvas.DrawColor = HUDColor;
	if ( bHideStatus && bHideAllWeapons )
	{
		X = 0.5 * Canvas.ClipX - 128 * Scale;
		Y = Canvas.ClipY - 64 * Scale;
	}
	else
	{
		X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
		Y = 0;
	}
	Canvas.SetPos(X, Y);
	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 0, 192, 128.0, 64.0);
	if ( bHideStatus && bShieldBelt )
		Canvas.DrawColor = GoldColor;
	else
		Canvas.DrawColor = WhiteColor;
	DrawBigNum(Canvas, Min(150,ArmorAmount), X + 4 * Scale, Y + 16 * Scale, 1);
}

defaultproperties
{
     MinGroundSpeed=120.000000
}
