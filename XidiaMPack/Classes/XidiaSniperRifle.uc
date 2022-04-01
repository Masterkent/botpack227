// ===============================================================
// XidiaMPack.XidiaSniperRifle: simply for the water thing.
// ===============================================================

class XidiaSniperRifle expands SniperRifle;

function SetSwitchPriority(pawn Other)   //priority stuff
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

//water code:
state Idle
{
  function Fire( float Value )
  {
    if (owner.region.zone.bwaterzone)
      return;
    if ( AmmoType == None )
    {
      // ammocheck
      GiveAmmo(Pawn(Owner));
    }
    if (AmmoType.UseAmmo(1))
    {
      GotoState('NormalFire');
      bCanClientFire = true;
      bPointing=True;
      if ( Owner.IsA('Bot') )
      {
        // simulate bot using zoom
        if ( Bot(Owner).bSniping && (FRand() < 0.65) )
          AimError = AimError/FClamp(StillTime, 1.0, 8.0);
        else if ( VSize(Owner.Location - OwnerLocation) < 6 )
          AimError = AimError/FClamp(0.5 * StillTime, 1.0, 3.0);
        else
          StillTime = 0;
      }
      Pawn(Owner).PlayRecoil(FiringSpeed);
      TraceFire(0.0);
      AimError = Default.AimError;
      ClientFire(Value);
    }
  }


Begin:
  bPointing=False;
  if ( AmmoType.AmmoAmount<=0 )
    Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
  if ( Pawn(Owner).bFire!=0 && !owner.region.zone.bwaterzone) Fire(0.0);
  Disable('AnimEnd');
  PlayIdleAnim();
}

simulated function bool clientfire(float value){
  if (owner.region.zone.bwaterzone){
    PlayIdleAnim();
    GotoState('');
    return false;
  }
  else
    return super.clientfire(value);
}

function Fire( float Value ) {
  if (owner.region.zone.bwaterzone){
    GotoState('Idle');
    return;
  }
  else
    super.Fire(value);
}

defaultproperties
{
     InventoryGroup=10
}
