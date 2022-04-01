//=============================================================================
// SpinnerProjectile.
//=============================================================================
class SpinnerProjectile expands Projectile;

//#exec TEXTURE IMPORT NAME=SpProjPal FILE=Models\SpProjPal.pcx GROUP=SpEffect
#exec OBJ LOAD FILE="XidiaMPackResources.u" PACKAGE=XidiaMPack

//#exec AUDIO IMPORT FILE="Sounds\SpinnerShot.wav" NAME="SpinnerShot" GROUP="Spinner"
//#exec AUDIO IMPORT FILE="Sounds\SpinnerImpact.wav" NAME="SpinnerImpact" GROUP="Spinner"

auto simulated state Flying
{
  simulated function ProcessTouch( Actor Other, Vector HitLocation )
  {
    if ( Spinner( Other ) == None )
      Explode( HitLocation, Normal(Velocity) );
  }

  simulated function MakeSound()
  {
    if( Level.NetMode != NM_DedicatedServer )
    {
      PlaySound( ImpactSound );
    }
    if (role==role_authority)
      MakeNoise( 1.0 );
  }

  simulated function Explode( vector HitLocation, vector HitNormal )
  {
    local EnergyBurst e;

    MakeSound();
    if (role==role_authority)
      HurtRadiusProj( Damage * DrawScale, 240 * DrawScale, 'corroded', MomentumTransfer * DrawScale, Location );
    if( Level.NetMode != NM_DedicatedServer )
    {
      e = spawn( class 'EnergyBurst', , , HitLocation + HitNormal * 9 );
      e.RemoteRole = ROLE_None;
    }
    Destroy();
  }

  simulated function BeginState()
  {
    if(role==role_authority){
     if (ScriptedPawn( Instigator ) != None )
      Speed = ScriptedPawn( Instigator ).ProjectileSpeed;
      Velocity = Vector( Rotation ) * speed;
      Velocity.z += 210;  // Lob vertical component
    }
    if( Level.NetMode != NM_DedicatedServer )
    {
      PlaySound( SpawnSound );
    }
    if( Region.zone.bWaterZone )
      Velocity *= 0.7;
  }

Begin:
  Sleep( LifeSpan - 0.3 ); //self destruct after 7.0 seconds
  Explode( Location, vect(0,0,0) );
}

defaultproperties
{
     speed=300.000000
     MaxSpeed=500.000000
     Damage=30.000000
     MomentumTransfer=20000
     SpawnSound=Sound'XidiaMPack.Spinner.Fire'
     ImpactSound=Sound'XidiaMPack.Spinner.Hit'
     ExplosionDecal=Class'olweapons.ODbiomark'
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=7.300000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'XidiaMPack.SpEffect.e8_a00'
     DrawScale=0.500000
     bUnlit=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=149
     LightHue=165
     LightSaturation=186
     LightRadius=4
     bBounce=True
}
