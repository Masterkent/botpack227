class B227_UTSmokeTrailEmitter expands XEmitter
	transient
	config(Botpack);

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var config bool bAutoReduceSmokeOpacity;

var float StartTimestamp;
var float OffsetDistance;

var private float NextOpacityUpdateTimestamp;

event Tick(float DeltaTime)
{
	if (Owner == none)
		return;
	if (bDisabled && Level.TimeSeconds >= StartTimestamp)
		bDisabled = false;

	UpdatePosition();
	if (bAutoReduceSmokeOpacity)
		UpdateOpacity();
}

event FellOutOfWorld();

function UpdatePosition()
{
	SetLocation(Owner.Location - vector(Owner.Rotation) * OffsetDistance);
	SetRotation(Owner.Rotation);
}

function UpdateOpacity()
{
	const MaxGroupingDist = 128;
	const MaxGroupingActors = 16;
	local B227_UTSmokeTrailEmitter OtherSmokeEmitter;
	local float Grouping;
	local int i;

	if (Level.TimeSeconds < NextOpacityUpdateTimestamp)
		return;

	foreach RadiusActors(class'B227_UTSmokeTrailEmitter', OtherSmokeEmitter, MaxGroupingDist)
		if (OtherSmokeEmitter.Owner != none && OtherSmokeEmitter != self && i++ < MaxGroupingActors)
			Grouping +=
				FMax(0, vector(Rotation) Dot vector(OtherSmokeEmitter.Rotation)) *
				(1 - VSize(Location - OtherSmokeEmitter.Location) / MaxGroupingDist);
	FadeInMaxAmount = default.FadeInMaxAmount * (1 + Grouping / 2) / (1 + Grouping);

	NextOpacityUpdateTimestamp = Level.TimeSeconds + 0.1 * Level.TimeDilation;
}

function SetEmitterDelay(float Time)
{
	bDisabled = true;
	StartTimestamp = Level.TimeSeconds + Time;
}

function StopEmitting()
{
	SetOwner(none);
	Kill();
}

defaultproperties
{
	bStasis=False
	bForceStasis=False
	bStasisEmitter=False
	bNoUpdateOnInvis=False
	MaxParticles=80
	FadeInTime=0.0
	FadeOutTime=0.0
	FadeInMaxAmount=0.5
	StartingScale=(Min=2.0,Max=2.0)
	ParticleTextures(0)=Texture'Botpack.utsmoke.us8_a00'
	ParticleTextures(1)=Texture'Botpack.utsmoke.US3_A00'
	ParticleTextures(2)=Texture'Botpack.utsmoke.us2_a00'
	ParticleTextures(3)=Texture'Botpack.utsmoke.us1_a00'
	LifetimeRange=(Min=2.0,Max=2.0)
	BoxVelocity=(Z=(Min=50.0,Max=50.0))
	SpriteAnimationType=SAN_PlayOnce
	bUseRandomTex=True
	Physics=PHYS_None
	Style=STY_Translucent
}
