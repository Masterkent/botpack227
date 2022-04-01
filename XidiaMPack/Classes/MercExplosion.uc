// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// MercExplosion : for use with the mercenary thingy :)
// ===============================================================

class MercExplosion expands UT_SpriteBallExplosion;

var rotator RealRot;

replication{
  Reliable if (role==role_authority)
    RealRot;
}

simulated function PostBeginPlay(){
  Super.PostBeginPlay();
  LightRadius = 6;
  SetTimer(0.0,false);
  if (role<role_authority)
    return;
  RealRot=rotation;
  HurtRadius( 10 + Rand(5), 150, 'exploded', 10000, Location );
  drawscale/=RandRange(3.7,5.3);
}
simulated function Tick( float DeltaTime )
{
  local decal D;
  super.tick(deltatime);
  if ( Level.NetMode != NM_DedicatedServer )
    D=spawn(class'OdBlastMark',,,location,RealRot);
  if (D!=none){
    D.detachdecal();
    D.drawscale=1.4*drawscale;
    D.AttachToSurface();
  }
  Disable('tick');
}

defaultproperties
{
}
