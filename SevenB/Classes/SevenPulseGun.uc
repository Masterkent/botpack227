// ===============================================================
// SevenB.SevenPulseGun: more power and new gfx
// ===============================================================

class SevenPulseGun extends OSPulseGun;

//first person:
#exec OBJ LOAD FILE="SevenBResources.u" PACKAGE=SevenB

//3rd person:

//pickup:

//muzzle flash:

//skin swapping:
simulated event RenderOverlays(canvas Canvas)         //muzzle stuff.....
{
  multiskins[1]=texture'Botpack.Ammocount.Ammoled';  //swap skin so it is displayed only in 1st person
  Super.RenderOverlays(Canvas);
  multiskins[1]=texture'SBPulse3rd_01';
}

function BecomePickup()
{
	super.BecomePickup();
	multiskins[1]=texture'SBPulsePickup_01';
}

function float RateSelf( out int bUseAltMode )
{
  local Pawn P;

  if ( AmmoType.AmmoAmount <=0 )
    return -2;

  P = Pawn(Owner);
  if ( (P.Enemy == None) || (Owner.IsA('Bot') && Bot(Owner).bQuickFire) )
  {
    bUseAltMode = 0;
    return AIRating;
  }

  if ( P.Enemy.IsA('StationaryPawn') )
  {
    bUseAltMode = 0;
    return (AIRating + 0.4);
  }
  else
    bUseAltMode = int( 850 > VSize(P.Enemy.Location - Owner.Location) ); //we have a longer beam now

  AIRating *= FMin(Pawn(Owner).DamageScaling, 1.5);
  return AIRating;
}

function BecomeItem()
{
	super.BecomeItem();
	multiskins[1]=texture'SBPulse3rd_01';
}

function float SuggestAttackStyle()
{
  if (Pawn(Owner).Enemy==none)
    return 0;
  return Super.SuggestAttackStyle();
}

//faster ammo depletion
state AltFiring
{
  ignores AnimEnd;

  function Tick(float DeltaTime)
  {
    local Pawn P;

    P = Pawn(Owner);
    if ( P == None )
    {
      GotoState('Pickup');
      return;
    }
    if ( (P.bAltFire == 0) || (P.IsA('Bot')
          && ((P.Enemy == None) || (Level.TimeSeconds - Bot(P).LastSeenTime > 5))) )
    {
      P.bAltFire = 0;
      Finish();
      return;
    }

    Count += Deltatime;
    if ( Count > 0.14 )
    {
      if ( Owner.IsA('PlayerPawn') )
        PlayerPawn(Owner).ClientInstantFlash( InstFlash,InstFog);
      if ( Affector != None )
        Affector.FireEffect();
      Count -= 0.14;
      if (AmmoType.UseAmmo(1))
      {
          if (PlasmaBeam != none)
              PlasmaBeam.B227_DamageMult = B227_AmplifyDamage(Max(1, PlasmaBeam.Damage * 0.24));
          SoundVolume = P.SoundDampening * 255;
      }
      else
        Finish();
    }
  }

}

function B227_AdjustNPCFirePosition()
{
	if (B227_ShouldGuideBeam())
		super.B227_AdjustNPCFirePosition();
}

defaultproperties
{
     AmmoName=Class'SevenB.SBPAmmo'
     ProjectileClass=Class'SevenB.SBPlasmaSphere'
     AltProjectileClass=Class'SevenB.SBStarterbolt'
     AIRating=0.500000
     bAmbientGlow=False
     PickupMessage="You got the Plasma Rifle"
     ItemName="Plasma Rifle"
     MuzzleFlashTexture=Texture'SevenB.Skins.SBMuzzyPulse'
     MultiSkins(1)=Texture'SevenB.Skins.SBPulsePickup_01'
     MultiSkins(2)=Texture'SevenB.Skins.SBPulseGun_02'
     MultiSkins(3)=Texture'SevenB.Skins.SBPulseGun_03'
     RotationRate=(Yaw=0)
}
