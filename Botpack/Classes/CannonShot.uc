//=============================================================================
// CannonShot.
//=============================================================================
class CannonShot extends B227_Projectile;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var() texture SpriteAnim[6];
var int i;

simulated function Timer()
{
	if ( Level.Netmode != NM_DedicatedServer )
		Texture = SpriteAnim[i];
	i++;
	if (i>=6) i=0;
}

simulated function PostBeginPlay()
{
	if ( Level.bDropDetail )
		LightType = LT_None;
	if ( Level.NetMode != NM_DedicatedServer )
	{
		Texture = SpriteAnim[0];
		i=1;
		SetTimer(0.15,True);
	}
	if ( Role == ROLE_Authority )
	{
		PlaySound(SpawnSound);
		Velocity = Vector(Rotation) * speed;
		MakeNoise ( 1.0 );
	}
	Super.PostBeginPlay();
}

auto state Flying
{


simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if (Other != instigator)
	{
		if ( Role == ROLE_Authority )
			Other.TakeDamage(Damage, instigator,HitLocation,
					15000.0 * Normal(velocity), 'burned');
		Explode(HitLocation, Vect(0,0,0));
	}
}

function Explode(vector HitLocation, vector HitNormal)
{
	if (FRand() < 0.5)
		MakeNoise(1.0); 
	B227_SetupProjectileExplosion(Location, HitLocation, HitNormal);
	Destroy();
}

Begin:
	Sleep(3);
	Explode(Location, Vect(0,0,0));
}

static function B227_Explode(Actor Context, vector Location, vector HitLocation, vector HitNormal, rotator Direction)
{
	local UT_SpriteBallExplosion s;

	if (Context.Level.NetMode == NM_DedicatedServer)
		return;

	s = Context.Spawn(class'UT_SpriteBallExplosion',,, HitLocation + HitNormal * 9);
	if (s != none)
		s.RemoteRole = ROLE_None; // Clients will still hear extra explosion sound when playing on a listen server.
								  // Fixing this issue would require modification of UT_SpriteBallExplosion that
								  // may affect a lot of classes that use it.

	B227_SpawnDecal(Context, default.ExplosionDecal, Location, HitNormal);
}

defaultproperties
{
	SpriteAnim(0)=Texture'UnrealI.Effects.gbProj0'
	SpriteAnim(1)=Texture'UnrealI.Effects.gbProj1'
	SpriteAnim(2)=Texture'UnrealI.Effects.gbProj2'
	SpriteAnim(3)=Texture'UnrealI.Effects.gbProj3'
	SpriteAnim(4)=Texture'UnrealI.Effects.gbProj4'
	SpriteAnim(5)=Texture'UnrealI.Effects.gbProj5'
	speed=2100.000000
	Damage=12.000000
	ImpactSound=Sound'UnrealShare.flak.expl2'
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=3.500000
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'UnrealI.Effects.gbProj0'
	DrawScale=1.800000
	Fatness=0
	bUnlit=True
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=5
	LightSaturation=16
	LightRadius=9
	B227_bReplicateExplosion=True
	ExplosionDecal=Class'UnrealShare.BelchScorch'
}
