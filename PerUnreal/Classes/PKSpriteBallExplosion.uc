//=============================================================================
// PKSpriteBallExplosion.
//=============================================================================
class PKSpriteBallExplosion extends AnimSpriteEffect;

var int ExpCount, MissCount;
var(Sounds) sound 	ExploSound[3];
var(Sounds) sound 	DebrisSound[3];

simulated function PostBeginPlay()
{
	if ( Role == ROLE_Authority )
		MakeSound();
	if ( !Level.bDropDetail )
		Texture = SpriteAnim[Rand(3)];
	if ( (Level.NetMode!=NM_DedicatedServer) && Level.bHighDetailMode && !Level.bDropDetail )
		SetTimer(0.05+FRand()*0.04,False);
	else
		LightRadius = 6;

	Spawn(class'PKExploSpark',Self, '', Location + (20 + 20 * FRand()) * (VRand() + Vect(0,0,0.5)) );
	Spawn(class'PKExploSpark',Self, '', Location + (20 + 20 * FRand()) * (VRand() + Vect(0,0,0.5)) );
	Spawn(class'PKExploSpark',Self, '', Location + (20 + 20 * FRand()) * (VRand() + Vect(0,0,0.5)) );

	Super.PostBeginPlay();
}

simulated Function Timer()
{
	if ( FRand() < 0.4 + (MissCount - 1.5 * ExpCount) * 0.25 )
	{
		ExpCount++;
		Spawn(class'PKExploSpark',Self, '', Location + (20 + 20 * FRand()) * (VRand() + Vect(0,0,0.5)) );
	}
	else
		MissCount++;
	if ( (ExpCount < 3) && (LifeSpan > 0.45) )
		SetTimer(0.05+FRand()*0.05,False);
}

function MakeSound()
{
local int rnd;

	rnd = Rand(3);
	PlaySound(ExploSound[rnd],SLOT_None,,, 8192, 0.5+1.0*FRand());
	PlaySound(DebrisSound[rnd],,,, 8192, 0.5+1.0*FRand());
}

defaultproperties
{
     ExploSound(0)=Sound'PerUnreal.Eightball.PKexplo1'
     ExploSound(1)=Sound'PerUnreal.Eightball.PKexplo2'
     ExploSound(2)=Sound'PerUnreal.Eightball.PKexplo3'
     DebrisSound(0)=Sound'PerUnreal.Eightball.PKdebris1'
     DebrisSound(1)=Sound'PerUnreal.Eightball.PKdebris2'
     DebrisSound(2)=Sound'PerUnreal.Eightball.PKdebris3'
     SpriteAnim(0)=Texture'Botpack.UT_Explosions.exp1_a00'
     SpriteAnim(1)=Texture'Botpack.UT_Explosions.Exp6_a00'
     SpriteAnim(2)=Texture'Botpack.UT_Explosions.Exp7_a00'
     NumFrames=8
     Pause=0.050000
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.700000
     DrawType=DT_SpriteAnimOnce
     Style=STY_Translucent
     Texture=Texture'Botpack.UT_Explosions.exp1_a00'
     Skin=Texture'UnrealShare.Effects.ExplosionPal'
     DrawScale=1.400000
     LightType=LT_TexturePaletteOnce
     LightEffect=LE_NonIncidence
     LightBrightness=192
     LightHue=27
     LightSaturation=71
     LightRadius=9
}
