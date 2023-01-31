class B227_Config expands Info
	config(Botpack);

var(General) config bool bEnableExtensions;
var(General) config bool bEnableExtras;
var(DMMutator) config bool bAutoActivatePickups;
var(DMMutator) config bool bUseFlakShellAmmo;
var(DMMutator) config bool bLogNonUTInventory;
var(HUD) config bool bUseTahomaFonts;
var(HUD) config bool bYellowTeamSayMessages;
var(NPC) config float BotDodgeEndTime;
var(Player) config bool bFixLoaded;
var(Weapon) config bool bAdjustMinigunMuzzleFlashOffset;
var(Weapon) config bool bAdjustNPCFirePosition;
var(Weapon) config bool bModifyProjectilesLighting;
var(Weapon) config bool bModifyShockComboDamage;
var(Weapon) config bool bPulseGunAdjustNPCAccuracy; // Reduce accuracy for pawns with low Skill
var(Weapon) config bool bPulseGunGuideBeam;
var(Weapon) config bool bPulseGunHardcoreDamage; // 150% damage in non-deathmatch games
var(Weapon) config bool bPulseGunLimitWallEffect;
var(Weapon) config bool bTraceFireThroughWarpZones;
var(Weapon) config bool bTranslocatorModuleRecovery;
var(Weapon) config bool bUseEnergyAmplifier;
var(Weapon) config bool bUseEmitterSmokeTrails;
var(Weapon) config bool bUseSpriteSmokeTrails;

static function bool ShouldModifyProjectilesLighting()
{
	return default.bEnableExtensions && default.bModifyProjectilesLighting;
}

defaultproperties
{
	bEnableExtensions=True
	bEnableExtras=True
	bAutoActivatePickups=True
	bUseFlakShellAmmo=True
	bLogNonUTInventory=True
	bUseTahomaFonts=False
	bYellowTeamSayMessages=True
	BotDodgeEndTime=0.35
	bFixLoaded=True
	bAdjustMinigunMuzzleFlashOffset=True
	bAdjustNPCFirePosition=True
	bModifyProjectilesLighting=True
	bModifyShockComboDamage=True
	bPulseGunAdjustNPCAccuracy=True
	bPulseGunGuideBeam=True
	bPulseGunHardcoreDamage=False
	bPulseGunLimitWallEffect=True
	bTraceFireThroughWarpZones=True
	bTranslocatorModuleRecovery=False
	bUseEnergyAmplifier=True
	bUseEmitterSmokeTrails=True
	bUseSpriteSmokeTrails=True
}
