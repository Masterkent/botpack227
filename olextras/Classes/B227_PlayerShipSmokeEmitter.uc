class B227_PlayerShipSmokeEmitter expands XEmitter
	transient;

event FellOutOfWorld();

function StopEmitting()
{
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
