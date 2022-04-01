// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// NoammoDpistol : Simply a dispersion pistol that doesn't use ammo.
// ===============================================================

class NoammoDpistol expands OLDpistol;

function Fire( float Value )
{
  GotoState('NormalFire');
  bPointing=True;
  bCanClientFire = true;
  ClientFire(Value);
  if ( bRapidFire || (FiringSpeed > 0) )
    Pawn(Owner).PlayRecoil(FiringSpeed);
  ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
  local Vector Start, X,Y,Z;
  local DispersionAmmo da;
  local float Mult;

  Owner.MakeNoise(Pawn(Owner).SoundDampening);

  if (Amp!=None) Mult = Amp.UseCharge(80);
  else Mult=1.0;

  GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
  Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
  AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, (3.5*FRand()-1<PowerLevel));
  if ( PowerLevel == 0)
  {
    da = DispersionAmmo(Spawn(ProjClass,,, Start,AdjustedAim));
  }
  else
  {
    if ( (PowerLevel==1))
      da = Spawn(class'olweapons.OSDAmmo2',,, Start,AdjustedAim);
    if ( (PowerLevel==2))
      da = Spawn(class'olweapons.OSDAmmo3',,, Start,AdjustedAim);
    if ( (PowerLevel==3))
      da = Spawn(class'olweapons.OSDAmmo4',,, Start ,AdjustedAim);
    if ( (PowerLevel>=4))
      da = Spawn(class'olweapons.OSDAmmo5',,, Start,AdjustedAim);
  }
  if ( (da != None) && (Mult>1.0) )
    da.InitSplash(Mult);
  return da;
}

state AltFiring
{
ignores AltFire, animend;


  function Tick( float DeltaTime )
  {
    if ( Level.NetMode == NM_StandAlone || (Level.Netmode == NM_listenserver&&playerpawn(owner)!=none&&playerpawn(owner).player.isa('viewport')))   //don't let this happen in netgames....  (that is called by clientaltfire)
    {
      PlayerViewOffset.X = WeaponPos.X + FRand()*ChargeSize*7;
      PlayerViewOffset.Y = WeaponPos.Y + FRand()*ChargeSize*7;
      PlayerViewOffset.Z = WeaponPos.Z + FRand()*ChargeSize*7;
    }
    ChargeSize += DeltaTime;
    if( (pawn(Owner).bAltFire==0)) GoToState('ShootLoad');
  }
Begin:
  //Owner.Playsound(Misc1Sound,SLOT_Misc, Pawn(Owner).SoundDampening*4.0);
  Sleep(2.0 + 0.6 * PowerLevel);
  GoToState('ShootLoad');
}

//to avoid ammo type checking:
function float RateSelf( out int bUseAltMode )
{
  local float rating;

  if ( Amp != None )
    rating = 6 * AIRating;
  else
    rating = AIRating;

  if ( Pawn(Owner).Enemy == None )
  {
    bUseAltMode = 0;
    return rating * (PowerLevel + 1);
  }
  bUseAltMode = int( FRand() < 0.3 );
    // splash damage should be used if we are higher than the target, but definitely not if we're lower...
  if (( Owner.Location.Z > Pawn(owner).Enemy.Location.Z + 120 ))
    bUseAltMode = 1;
  else if ( Pawn(owner).Enemy.Location.Z > Owner.Location.Z + 120 )
    bUseAltMode = 0;
  if (powerlevel>2) //always use primary if the power is high...
    bUseAltMode = 0;
  return rating * (PowerLevel + 1);
}
function bool HandlePickupQuery( inventory Item )
{
  if ( Item.IsA('osDispersionPowerup') || (String(Item.Class)~="oldskool.osweaponpowerup") )
  {
    Pawn(Owner).ClientMessage(Item.PickupMessage, 'Pickup');
    Item.PlaySound (PickupSound);
    if ( PowerLevel<4 )
    {
      ShakeVert = Default.ShakeVert + PowerLevel;
      PowerUpSound = Item.ActivateSound;
      if ( Pawn(Owner).Weapon == self )
      {
        PowerLevel++;
        GotoState('PowerUp');
      }
      else if ( (Pawn(Owner).Weapon != Self) && !Pawn(Owner).bNeverSwitchOnPickup )
      {
        Pawn(Owner).Weapon.PutDown();
        Pawn(Owner).PendingWeapon = self;
        GotoState('PowerUp', 'Waiting');
      }
      else PowerLevel++;
    }
    Item.SetRespawn();
    return true;
  }
  else
    return Super(TournamentWeapon).HandlePickupQuery(Item);
}

function PlayFiring()
{
  PlaySound(AltFireSound, SLOT_None, 1.8*Pawn(Owner).SoundDampening,,,1.2);
  if ( PlayerPawn(Owner) != None )
    PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
  if (PowerLevel==0)
    PlayAnim('Shoot1',0.4,0.2);
  else if (PowerLevel==1)
    PlayAnim('Shoot2',0.3,0.2);
  else if (PowerLevel==2)
    PlayAnim('Shoot3',0.2, 0.2);
  else if (PowerLevel==3)
    PlayAnim('Shoot4',0.1,0.2);
  else if (PowerLevel==4)
    PlayAnim('Shoot5',0.1,0.2);
}

state PowerUp
{
  ignores fire, altfire, clientfire, clientaltfire;
  Begin:
  if (PowerLevel<5)
  {
    PlayPowerUp();
    bcanclientfire=true;
    FinishAnim();
    if ( bChangeWeapon )
      GotoState('DownWeapon');
    else
    Finish();
  }
  Waiting:
}

defaultproperties
{
     AmmoName=None
     PickupAmmoCount=1
}
