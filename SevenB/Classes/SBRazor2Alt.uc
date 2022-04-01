// ===============================================================
// SevenB.SBRazor2Alt: controllable and a tad more powerful
// ===============================================================

class SBRazor2Alt extends Razor2Alt;

//bunch of code stolen from razorbladealt:

var vector GuidedVelocity; // [B227] unused
var rotator OldGuiderRotation, GuidedRotation;

simulated function PostBeginPlay()
{
  Super.PostBeginPlay();
  GuidedRotation = Rotation;
  OldGuiderRotation = Rotation;
}
auto state Flying
{
  function Tick(float DeltaTime)
  {
    local int DeltaYaw, DeltaPitch;
    local int YawDiff;

    if ( Level.NetMode == NM_Client )
      B227_ClientSyncMovement();
    else
    {
      if (PlayerPawn(Instigator) == none || Instigator.Health <= 0)
      {
        Disable('Tick');
        return;
      }
      else
      {
        DeltaYaw = (instigator.ViewRotation.Yaw & 65535) - (OldGuiderRotation.Yaw & 65535);
        DeltaPitch = (instigator.ViewRotation.Pitch & 65535) - (OldGuiderRotation.Pitch & 65535);
        if ( DeltaPitch < -32768 )
          DeltaPitch += 65536;
        else if ( DeltaPitch > 32768 )
          DeltaPitch -= 65536;
        if ( DeltaYaw < -32768 )
          DeltaYaw += 65536;
        else if ( DeltaYaw > 32768 )
          DeltaYaw -= 65536;

        YawDiff = (Rotation.Yaw & 65535) - (GuidedRotation.Yaw & 65535) - DeltaYaw;
        if ( DeltaYaw < 0 )
        {
          if ( ((YawDiff > 0) && (YawDiff < 16384)) || (YawDiff < -49152) )
            GuidedRotation.Yaw += DeltaYaw;
        }
        else if ( ((YawDiff < 0) && (YawDiff > -16384)) || (YawDiff > 49152) )
          GuidedRotation.Yaw += DeltaYaw;

        GuidedRotation.Pitch += DeltaPitch;

        Velocity += Vector(GuidedRotation) * 2000 * DeltaTime;
        speed = VSize(Velocity);
        Velocity = Velocity * FClamp(speed,600,950)/speed;
        //-GuidedVelocity = Velocity;
        OldGuiderRotation = instigator.ViewRotation;

        B227_SyncMovement();
      }
    }
    SetRotation(Rotator(Velocity) );
  }
}

defaultproperties
{
     Damage=94.000000
     MomentumTransfer=110000
     bNetTemporary=False
     bSimulatedPawnRep=True
}
