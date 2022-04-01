// A projectile that inspires fear into all it hits
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

//#exec TEXTURE IMPORT NAME=skull_a00 FILE=TEXTURES\skull_a00.pcx GROUP=Skins PALETTE=skull_a00


//#exec TEXTURE IMPORT NAME=skull_a01 FILE=TEXTURES\skull_a01.pcx GROUP=Skins PALETTE=skull_a01


//#exec TEXTURE IMPORT NAME=skull_a02 FILE=TEXTURES\skull_a02.pcx GROUP=Skins PALETTE=skull_a02


//#exec TEXTURE IMPORT NAME=skull_a03 FILE=TEXTURES\skull_a03.pcx GROUP=Skins PALETTE=skull_a03


//#exec TEXTURE IMPORT NAME=skull_a04 FILE=TEXTURES\skull_a04.pcx GROUP=Skins PALETTE=skull_a04

class NCFearBolt extends NCMagicProj;

var float Count;
var() texture dbTex[5];
var() texture fbTex[9];

state Flying
{
	function Tick(float DeltaTime) {
		local NCFirePuff b;

		Count += DeltaTime;
		if ( (Count>0.025) && (Level.NetMode!=NM_DedicatedServer) ) {
			b = Spawn(class'NaliChronicles.NCFirePuff');
			b.RemoteRole = ROLE_None;
			Texture = dbTex[Rand(5)];
			b.Texture = fbTex[Rand(9)];
			b.MainScale = DrawScale/2;
			b.LightSaturation=255;
			Count=0.0;
		}
		Super.Tick(DeltaTime);
	}

	function vector randomizeLoc() {
		local vector newloc;

		newloc = location;
		newloc.x += -5+(10*Frand());
		newloc.y += -5+(10*Frand());
		newloc.z += -5+(10*Frand());
	}

	simulated function ProcessTouch( Actor H, Vector HitLocation )
	{
		local ScriptedPawn SP;

		if (h != instigator && NCFearBolt(h) == none)
		{
			DealOutExp(H);
			if (ScriptedPawn(H) != none) { // only scare scripted pawns
				SP = ScriptedPawn(H);
				if ((SP.health < 1000) && ((Damage/52) > ((0.3*float(SP.Intelligence))*(float(SP.health)/float(SP.default.health))))) {
					SP.AttitudeToPlayer = ATTITUDE_Fear;
					SP.GotoState('Retreating');
					if (Nali(SP) == none && NaliWarrior(SP) == none)
						NaliOwner.GainExp(5,75);
					SP.Aggressiveness *= 0.75; // make us more peaceful
				}
			}
			H.TakeDamage(damage,instigator,HitLocation,(30000.0 * Normal(Velocity)), 'burned');
			Explode(HitLocation,vector(rotation));
		}
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Explode(Location, HitNormal);
	}

	function Explode(vector HitLocation, vector HitNormal) {
		local int i;
		local NCFirePuff b;

		if ( (Role == ROLE_Authority) && (FRand() < 0.5) )
			MakeNoise(1.0); //FIXME - set appropriate loudness
		while (i < 5) {
			b = Spawn(class'NaliChronicles.NCFirePuff',,,randomizeLoc());
			b.RemoteRole = ROLE_None;
			b.Texture = dbTex[Rand(5)];
			b.MainScale = DrawScale*(1+(Frand()/2));
			b.LightSaturation=LightSaturation;
			b.LightHue=LightHue;
			b.LightBrightness=LightBrightness;
			i++;
		}
		PlaySound(ImpactSound, SLOT_Misc, 2.0,,2000, 0.5+FRand());
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
     dbTex(0)=Texture'NaliChronicles.Skins.skull_a00'
     dbTex(1)=Texture'NaliChronicles.Skins.skull_a01'
     dbTex(2)=Texture'NaliChronicles.Skins.skull_a02'
     dbTex(3)=Texture'NaliChronicles.Skins.skull_a03'
     dbTex(4)=Texture'NaliChronicles.Skins.skull_a04'
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
     ImpactSound=Sound'UnrealShare.Female.death1dfem'
     RemoteRole=ROLE_SimulatedProxy
     AmbientSound=Sound'UnrealShare.General.Brufly1'
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
     LightBrightness=32
     LightRadius=6
     LightPeriod=50
}
