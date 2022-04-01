// ===============================================================
// SevenB.SBpbolt: new skins!
// and different light hue
// ===============================================================

class SBpbolt extends pbolt;
//hit:
#exec OBJ LOAD FILE="SevenBResources.u" PACKAGE=SevenB

//cap:

//actual beam:

simulated function CheckBeam(vector X, float DeltaTime)
{
  local actor HitActor;
  local vector HitLocation, HitNormal;
  local float DamageMult;

	if (B227_BeamStarter != none)
		DamageMult = FMax(1, B227_BeamStarter.B227_DamageMult);
	else
	{
		DamageMult = 1;
		if (SBStarterbolt(self) != none)
			B227_BeamStarter = self;
	}

  // check to see if hits something, else spawn or orient child

  HitActor = Trace(HitLocation, HitNormal, Location + BeamSize * X, Location, true);
  if ( (HitActor != None)  && (HitActor != Instigator)
    && (HitActor.bProjTarget || (HitActor == Level) || (HitActor.bBlockActors && HitActor.bBlockPlayers))
    && ((Pawn(HitActor) == None) || Pawn(HitActor).AdjustHitLocation(HitLocation, Velocity)) )
  {
    if ( Level.Netmode != NM_Client )
    {
      if ( DamagedActor == None )
      {
        AccumulatedDamage = FMin(0.5 * (Level.TimeSeconds - LastHitTime), 0.1);
        HitActor.TakeDamage(damage * AccumulatedDamage * DamageMult, instigator,HitLocation,
          (MomentumTransfer * X * AccumulatedDamage), MyDamageType);
        AccumulatedDamage = 0;
      }
      else if ( DamagedActor != HitActor )
      {
        DamagedActor.TakeDamage(damage * AccumulatedDamage * DamageMult, instigator,HitLocation,
          (MomentumTransfer * X * AccumulatedDamage), MyDamageType);
        AccumulatedDamage = 0;
      }
      LastHitTime = Level.TimeSeconds;
      DamagedActor = HitActor;
      AccumulatedDamage += DeltaTime;
      if ( AccumulatedDamage > 0.22 )
      {
        if ( DamagedActor.IsA('Carcass') && (FRand() < 0.09) )
          AccumulatedDamage = 70/damage;
        DamagedActor.TakeDamage(damage * AccumulatedDamage * DamageMult, instigator,HitLocation,
          (MomentumTransfer * X * AccumulatedDamage), MyDamageType);
        AccumulatedDamage = 0;
      }
    }
    if ( HitActor.bIsPawn)
    {
      if ( WallEffect != None )
        WallEffect.Destroy();
    }
    else if ( (WallEffect == None) || WallEffect.bDeleteMe )
    {
      WallEffect = Spawn(class'PlasmaHit',,, HitLocation - 5 * X);
      WallEffect.Texture=Texture'SevenB.RedBoltCap.pfpEnd_a00';
      WallEffect.LightHue=10;
    }
    else if ( !WallEffect.IsA('PlasmaHit') )
    {
      WallEffect.Destroy();
      WallEffect = Spawn(class'PlasmaHit',,, HitLocation - 5 * X);
      WallEffect.Texture=Texture'SevenB.RedBoltCap.pfpEnd_a00';
      WallEffect.LightHue=10;
    }
    else
      WallEffect.SetLocation(HitLocation - 5 * X);

    if ( (WallEffect != None) && (Level.NetMode != NM_DedicatedServer) )
      Spawn(ExplosionDecal,,,HitLocation,rotator(HitNormal));

    if ( PlasmaBeam != None )
    {
      AccumulatedDamage += PlasmaBeam.AccumulatedDamage;
      PlasmaBeam.Destroy();
      PlasmaBeam = None;
    }

    return;
  }
  else if ( (Level.Netmode != NM_Client) && (DamagedActor != None) )
  {
    DamagedActor.TakeDamage(damage * AccumulatedDamage * DamageMult, instigator, DamagedActor.Location - X * 1.2 * DamagedActor.CollisionRadius,
      (MomentumTransfer * X * AccumulatedDamage), MyDamageType);
    AccumulatedDamage = 0;
    DamagedActor = None;
  }


  if ( Position >= 11 ) //longer beam!
  {
    if ( (WallEffect == None) || WallEffect.bDeleteMe )
    {
      WallEffect = Spawn(class'PlasmaCap',,, Location + (BeamSize - 4) * X);
      WallEffect.Texture=Texture'SevenB.RedBoltHit.pfphit_a00';
      WallEffect.LightHue=10;
    }
    else if ( WallEffect.IsA('PlasmaHit') )
    {
      WallEffect.Destroy();
      WallEffect = Spawn(class'PlasmaCap',,, Location + (BeamSize - 4) * X);
      WallEffect.Texture=Texture'SevenB.RedBoltHit.pfphit_a00';
      WallEffect.LightHue=10;
    }
    else
      WallEffect.SetLocation(Location + (BeamSize - 4) * X);
  }
  else
  {
    if ( WallEffect != None )
    {
      WallEffect.Destroy();
      WallEffect = None;
    }
    if ( PlasmaBeam == None )
    {
      PlasmaBeam = Spawn(class'SBPBolt',,, Location + BeamSize * X);
      PlasmaBeam.Position = Position + 1;
      PlasmaBeam.B227_BeamStarter = B227_BeamStarter;
    }
    else
      PlasmaBeam.UpdateBeam(self, X, DeltaTime);

    B227_ModifyLighting(PlasmaBeam);
  }
}

defaultproperties
{
     SpriteAnim(0)=Texture'SevenB.Skins.sbpbolt0'
     SpriteAnim(1)=Texture'SevenB.Skins.sbpbolt1'
     SpriteAnim(2)=Texture'SevenB.Skins.sbpbolt2'
     SpriteAnim(3)=Texture'SevenB.Skins.sbpbolt3'
     SpriteAnim(4)=Texture'SevenB.Skins.sbpbolt4'
     Damage=170.000000
     MyDamageType=exploded
     Texture=Texture'SevenB.Skins.sbpbolt0'
     Skin=Texture'SevenB.Skins.sbpbolt0'
}
