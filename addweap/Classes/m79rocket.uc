//=============================================================================
// WarShell.
//=============================================================================
class m79rocket extends Warshell;

var float CannonTimer, SmokeRate;
var	redeemertrail trail;

simulated function Timer()
{
	local ut_SpriteSmokePuff b;

	if ( Trail == None )
		Trail = Spawn(class'RedeemerTrail',self);

	CannonTimer += SmokeRate;
	if ( CannonTimer > 0.6 )
	{
		WarnCannons();
		CannonTimer -= 0.6;
	}

	if ( Region.Zone.bWaterZone || (Level.NetMode == NM_DedicatedServer) )
	{
		SetTimer(SmokeRate, false);
		Return;
	}

	if ( Level.bHighDetailMode )
	{
		if ( Level.bDropDetail )
			Spawn(class'LightSmokeTrail');
		else
			Spawn(class'UTSmokeTrail');
		SmokeRate = 152/Speed;
	}
	else
	{
		SmokeRate = 0.15;
		b = Spawn(class'ut_SpriteSmokePuff');
		b.RemoteRole = ROLE_None;
	}
	SetTimer(SmokeRate, false);
}

simulated function Destroyed()
{
	if ( Trail != None )
		Trail.Destroy();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	SmokeRate = 0.3;
	SetTimer(0.3,false);
}


auto state Flying
{

	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local waterring w;

		if ( NewZone.bWaterZone != Region.Zone.bWaterZone )
		{
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
			w.DrawScale = 0.2;
			w.RemoteRole = ROLE_None;
		}
	}

	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( (Other != instigator) && (Other != class'ut_SpriteSmokePuff' ))
			{
			Explode(HitLocation,Normal(HitLocation-Other.Location));
			}
	}

	function Explode(vector HitLocation, vector HitNormal)
	{
		if ( Role < ROLE_Authority )
			return;

		HurtRadius(Damage,250.0, MyDamageType, MomentumTransfer, HitLocation );
		spawn(class'm79ShockWave',,,HitLocation+ HitNormal*16);
		B227_SetupProjectileExplosion(Location,, HitNormal);
		RemoteRole = ROLE_SimulatedProxy;
		Destroy();
	}

	function BeginState()
	{
		local vector InitialDir;

		initialDir = vector(Rotation);
		if ( Role == ROLE_Authority )
			Velocity = speed*initialDir;
		Acceleration = initialDir*50;
	}
}

defaultproperties
{
     speed=1800.000000
     Damage=500.000000
     MyDamageType=GrenadeDeath
}
