//=============================================================================
// pkexplospark.
//=============================================================================
class PKExploSpark extends Effects;

function PostBeginPlay()
{
	Velocity = (Vector(Rotation) + VRand()) * 200 * FRand();
}

simulated function Tick(float LifeSpan)
{

		ScaleGlow = ScaleGlow - 3.0 * LifeSpan;
		DrawScale = DrawScale - 4.0 * LifeSpan;
		if (DrawScale < 0.4)
			Destroy();
}

auto state Explode
{
	simulated function ZoneChange( ZoneInfo NewZone )
	{
		if ( NewZone.bWaterZone )
			Destroy();
	}

	simulated function Landed( vector HitNormal )
	{
	SetPhysics(PHYS_None);
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
	SetPhysics(PHYS_None);
	}
}

defaultproperties
{
     Physics=PHYS_Falling
     RemoteRole=ROLE_None
     LifeSpan=1.000000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'PerUnreal.Skins.RockMuz'
     DrawScale=1.800000
     AmbientGlow=255
     bUnlit=True
     bCollideWorld=True
     bBounce=True
     NetPriority=2.000000
}
