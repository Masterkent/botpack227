// ===============================================================
// SevenB.Sevengrenade: just some defaults...  also insta-blast on wall contact!
// Used for the grenade launcher
// ===============================================================

class Sevengrenade expands ut_grenade;


///////////////////////////////////////////////////////
function BlowUp(vector HitLocation)
{
  HurtRadiusProj(damage, 300, MyDamageType, MomentumTransfer, HitLocation);
  MakeNoise(1.0);
}

simulated singular function HitWall( vector HitNormal, actor Wall )
{
  //-local UT_SpriteBallExplosion s;
  BlowUp(Location);
  B227_SetupProjectileExplosion(Location, Location, HitNormal);
  /*-if ( Level.NetMode != NM_DedicatedServer )
  {
    spawn(class'Botpack.BlastMark',,,,rotator(HitNormal));
      s = spawn(class'UT_SpriteBallExplosion');
    s.RemoteRole = ROLE_None;
    s.drawscale=1.5;
  }*/
  Destroy();
}

/*-simulated function Explosion(vector HitLocation)
{
  local UT_SpriteBallExplosion s;

  BlowUp(HitLocation);
  if ( Level.NetMode != NM_DedicatedServer )
  {
    spawn(class'Botpack.BlastMark',,,,rot(16384,0,0));
      s = spawn(class'UT_SpriteBallExplosion',,,HitLocation);
    s.RemoteRole = ROLE_None;
    s.drawscale=1.5;
  }
   Destroy();
}*/

static function B227_Explode(Actor Context, vector Location, vector HitLocation, vector HitNormal, rotator Direction)
{
	local UT_SpriteBallExplosion s;

	if (Context.Level.NetMode != NM_DedicatedServer)
	{
		if (VSize(HitNormal) == 0)
			HitNormal = vector(rot(16384, 0, 0));
		B227_SpawnDecal(Context, class'Botpack.BlastMark', Location, HitNormal);

		s = Context.Spawn(class'UT_SpriteBallExplosion',,, HitLocation);
		if (s != none)
		{
			s.RemoteRole = ROLE_None;
			s.DrawScale = 1.5;
		}
	}
}

defaultproperties
{
     speed=900.000000
     MaxSpeed=1400.000000
     Damage=109.000000
     MomentumTransfer=67000
     DrawScale=0.010000
}
