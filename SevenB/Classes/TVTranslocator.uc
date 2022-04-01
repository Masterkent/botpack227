// ============================================================
// XidiaMPack.TVTranslocator: special one bounces off enemies, as no telefrags are allowed.
// ============================================================

class TVTranslocator expands Translocator;
var int transpriority;
function ThrowTarget()
{
  local Vector Start, X,Y,Z;

  if (Level.Game.LocalLog != None)
    Level.Game.LocalLog.LogSpecialEvent("throw_translocator", Pawn(Owner).PlayerReplicationInfo.PlayerID);
  if (Level.Game.WorldLog != None)
    Level.Game.WorldLog.LogSpecialEvent("throw_translocator", Pawn(Owner).PlayerReplicationInfo.PlayerID);

  if ( Owner.IsA('Bot') )
    bBotMoveFire = true;
  Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
  Pawn(Owner).ViewRotation = Pawn(Owner).AdjustToss(TossForce, Start, 0, true, true);
  GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
  TTarget = Spawn(class'TVTranslocatorTarget',,, Start);
  if (TTarget!=None)
  {
    bTTargetOut = true;
    TTarget.Master = self;
    if ( Owner.IsA('Bot') )
      TTarget.SetCollisionSize(0,0);
    TTarget.Throw(Pawn(Owner), MaxTossForce, Start);
  }
  else GotoState('Idle');
}
function SetSwitchPriority(pawn Other)         //uses master priority
{
  local int i;
  local name temp, carried;

  if ( PlayerPawn(Other) != None )
  {
    for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == 'Translocator' )
      {
        AutoSwitchPriority = i;
        return;
      }
    // else, register this weapon
    carried = 'Translocator';
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
     RespawnTime=30.000000
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
}
