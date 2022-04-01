// A fire ball with a flaming trail
// Code by Sergey 'Eater' Levin, 2001

class NCFireball extends NCMagicProj;

var float Count;
var() texture fbTex[9];

state Flying
{
	function Tick(float DeltaTime) {
		local NCFirePuff b;

		Count += DeltaTime;
		if ( (Count>0.025) && (Level.NetMode!=NM_DedicatedServer) ) {
			b = Spawn(class'NaliChronicles.NCFirePuff');
			b.RemoteRole = ROLE_None;
			Texture = fbTex[Rand(9)];
			b.Texture = fbTex[Rand(9)];
			b.MainScale = DrawScale;
			Count=0.0;
		}
		Super.Tick(DeltaTime);
	}

	simulated function ProcessTouch( Actor H, Vector HitLocation )
	{
		local int hitdamage;
		local vector hitDir;

		if (h != instigator && NCFireball(h) == none)
		{
			//DealOutExp(Other);
			Explode(HitLocation,vector(rotation));
		}
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Explode(Location, HitNormal);
	}

	function Explode(vector HitLocation, vector HitNormal) {
		local SpriteBallExplosion s;

		if ( (Role == ROLE_Authority) && (FRand() < 0.5) )
			MakeNoise(1.0); //FIXME - set appropriate loudness
		s = Spawn(class'SpriteBallExplosion',,,HitLocation+HitNormal*9);
		s.RemoteRole = ROLE_None;
		s.DrawScale *= DrawScale/0.6;
		PlaySound(ImpactSound, SLOT_Misc, 0.5,,, 0.5+FRand());
		ExpHurtRadius(Damage,Damage*1.2, 'exploded', MomentumTransfer, HitLocation );
		destroy();
	}

	function BeginState()
	{
		local rotator RandRot;

		Super.BeginState();
		Velocity = Vector(Rotation) * speed;
	}

	Begin:
	sleep(10.0);
	Explode(location,vector(rotation));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
}

defaultproperties
{
     fbTex(0)=Texture'UnrealShare.s_Exp004'
     fbTex(1)=Texture'UnrealShare.s_Exp005'
     fbTex(2)=Texture'UnrealShare.s_Exp006'
     fbTex(3)=Texture'UnrealShare.s_Exp007'
     fbTex(4)=Texture'UnrealShare.s_Exp008'
     fbTex(5)=Texture'UnrealShare.s_Exp009'
     fbTex(6)=Texture'UnrealShare.s_Exp010'
     fbTex(7)=Texture'UnrealShare.s_Exp011'
     fbTex(8)=Texture'UnrealShare.s_Exp012'
     speed=1000.000000
     Damage=2.000000
     MomentumTransfer=4000
     MyDamageType=Burned
     ImpactSound=Sound'UnrealShare.General.Expl03'
     ExplosionDecal=Class'Botpack.BlastMark'
     RemoteRole=ROLE_SimulatedProxy
     AmbientSound=Sound'Botpack.RocketLauncher.RocketFly1'
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'UnrealShare.s_Exp004'
     DrawScale=0.010000
     AmbientGlow=215
     Fatness=0
     bUnlit=True
     SoundRadius=14
     SoundVolume=255
     SoundPitch=100
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=128
     LightHue=32
     LightSaturation=8
     LightRadius=16
     LightPeriod=50
}
