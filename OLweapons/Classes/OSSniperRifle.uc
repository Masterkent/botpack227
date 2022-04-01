// ============================================================
// OLweapons.OSSniperRifle
// Psychic_313: unchanged
// ============================================================

class OSSniperRifle expands SniperRifle;
  /*hack so HUD doesn't change color in SP...
simulated function PostRender( canvas Canvas )
{
  local PlayerPawn P;
  local float Scale;

  Super(tournamentweapon).PostRender(Canvas);
  P = PlayerPawn(Owner);
  if ( (P != None) && (P.DesiredFOV != P.DefaultFOV) )
  {
    bOwnsCrossHair = true;
    Scale = Canvas.ClipX/640;
    Canvas.SetPos(0.5 * Canvas.ClipX - 128 * Scale, 0.5 * Canvas.ClipY - 128 * Scale );
    if ( Level.bHighDetailMode )
      Canvas.Style = ERenderStyle.STY_Translucent;
    else
      Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.DrawIcon(Texture'RReticle', Scale);
    Canvas.SetPos(0.5 * Canvas.ClipX + 64 * Scale, 0.5 * Canvas.ClipY + 96 * Scale);
    if (P.MyHUD.HUDConfigWindowType=="UTMenu.UTChallengeHUDConfig"){
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;
    Canvas.DrawColor.B = 0; }
    Scale = P.DefaultFOV/P.DesiredFOV;
    Canvas.DrawText("X"$int(Scale)$"."$int(10 * Scale - 10 * int(Scale)));
  }
  else
    bOwnsCrossHair = false;
}                 */
function SetSwitchPriority(pawn Other)         //uses master priority
{
  local int i;
  local name temp, carried;

  if ( PlayerPawn(Other) != None )
  {
    for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == 'SniperRifle' )
      {
        AutoSwitchPriority = i;
        return;
      }
    // else, register this weapon
    carried = 'SniperRifle';
    for ( i=AutoSwitchPriority; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++ )
    {
      if ( PlayerPawn(Other).WeaponPriority[i] == '' )
      {
        PlayerPawn(Other).WeaponPriority[i] = carried;
        return;
      }
      else if ( i<ArrayCount(PlayerPawn(Other).WeaponPriority)-1 )
      {
        temp = PlayerPawn(Other).WeaponPriority[i];
        PlayerPawn(Other).WeaponPriority[i] = carried;
        carried = temp;
      }
    }
  }
}

defaultproperties
{
}
