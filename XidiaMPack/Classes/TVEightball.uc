// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVEightball : This simply does a hack to stop locking on followers.
// ===============================================================

class TVEightball expands UT_Eightball;

function Actor CheckTarget()
{
  local Actor A;
  local pawn p;
  if (!Instigator.bIsPlayer&&Instigator.skill==0)
    return None;
  if (!Owner.IsA('PlayerPawn'))
    return Super.CheckTarget();
  if (tvplayer(Owner) != none && tvplayer(Owner).playermod==1) //no locking in cutscenes.
    return None;
  for (p=level.pawnlist;p!=none;p=p.nextpawn)
    if (p.bisplayer||p.Isa('nali')||p.Isa('cow')||p.Isa('bird1')||p.IsA('NaliRabbit'))
      p.bProjTarget=!p.bProjTarget;
  A=Super.CheckTarget();
  for (p=level.pawnlist;p!=none;p=p.nextpawn)
    if (p.bisplayer||p.Isa('nali')||p.Isa('cow')||p.Isa('bird1')||p.IsA('NaliRabbit'))
      p.bProjTarget=!p.bProjTarget;
  return A;
}

function float SuggestAttackStyle()
{
  if (Pawn(Owner).Enemy==none)
    return  -0.2;
  return Super.SuggestAttackStyle();
}
//change scale around for teh hell of it ;p
simulated function PostRender( canvas Canvas )
{
	local float XScale;

	bOwnsCrossHair = bLockedOn;
	if ( bOwnsCrossHair )
	{
		// if locked on, draw special crosshair
		XScale = class'UTC_HUD'.static.B227_CrosshairSize(Canvas, 730.0);
		Canvas.SetPos(0.5 * (Canvas.ClipX - Texture'Crosshair6'.USize * XScale), 0.5 * (Canvas.ClipY - Texture'Crosshair6'.VSize * XScale));
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawIcon(Texture'Crosshair6', XScale);
	}
}

//some bot/scriptedpawn crap:
function Fire( float Value )
{
  local TournamentPlayer TP;

  bPointing=True;
  if ( AmmoType == None )
  {
    // ammocheck
    GiveAmmo(Pawn(Owner));
  }
  if ( AmmoType.UseAmmo(1) )
  {
    TP = TournamentPlayer(Instigator);
    bCanClientFire = true;
    bInstantRocket = bAlwaysInstant || ( (TP != None) && TP.bInstantRocket );
    if ( bInstantRocket )
    {
      bFireLoad = True;
      RocketsLoaded = 1;
      GotoState('');
      GotoState('FireRockets', 'Begin');
    }
    else if ( !Instigator.IsA('playerpawn') && (Instigator.bIsPlayer || Instigator.skill>0 ))
    {
      if ( LockedTarget != None )
      {
        bFireLoad = True;
        RocketsLoaded = 1;
        Instigator.bFire = 0;
        bPendingLock = true;
        GotoState('');
        GotoState('FireRockets', 'Begin');
        return;
      }
      else if ( (NewTarget != None) && !NewTarget.IsA('StationaryPawn')
        && (FRand() < 0.8)
        && (VSize(Instigator.Location - NewTarget.Location) > 400 + 400 * (1.25 - TimerCounter) + 1300 * FRand()) )
      {
        Instigator.bFire = 0;
        bPendingLock = true;
        GotoState('Idle','PendingLock');
        return;
      }
      else if ( (!Instigator.Isa('bot')||!Bot(Instigator).bNovice)
          && (FRand() < 0.7)
          && IsInState('Idle') && (Instigator.Enemy != None)
          && ((Instigator.Enemy == Instigator.Target) || (Instigator.Target == None))
          && !Instigator.Enemy.IsA('StationaryPawn')
          && (VSize(Instigator.Location - Instigator.Enemy.Location) > 700 + 1300 * FRand())
          && (VSize(Instigator.Location - Instigator.Enemy.Location) < 2000) )
      {
        NewTarget = CheckTarget();
        OldTarget = NewTarget;
        if ( NewTarget == Instigator.Enemy )
        {
          if ( TimerCounter > 0.6 )
            SetTimer(1.0, true);
          Instigator.bFire = 0;
          bPendingLock = true;
          GotoState('Idle','PendingLock');
          return;
        }
      }
      bPendingLock = false;
      GotoState('NormalFire');
    }
    else
      GotoState('NormalFire');
  }
}

function SetSwitchPriority(pawn Other)         //uses master priority
{
  local int i;
  local name temp, carried;

  if ( PlayerPawn(Other) != None )
  {
    for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == 'UT_Eightball' )
      {
        AutoSwitchPriority = i;
        return;
      }
    // else, register this weapon
    carried = 'UT_Eightball';
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
