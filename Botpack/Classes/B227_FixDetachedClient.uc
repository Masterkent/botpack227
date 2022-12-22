// Prevents "Detached Client" from being displayed on ScriptedTextures FlakAmmoled and MiniAmmoled.
// This class may be removed in future versions.
class B227_FixDetachedClient expands Info;

simulated event BeginPlay()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;

	if (Texture'FlakAmmoled'.NotifyActor == none)
		Texture'FlakAmmoled'.NotifyActor = self;

	if (Texture'MiniAmmoled'.NotifyActor == none)
		Texture'MiniAmmoled'.NotifyActor = self;
}

defaultproperties
{
	bAlwaysRelevant=True
	bNetTemporary=True
	RemoteRole=ROLE_SimulatedProxy
}
