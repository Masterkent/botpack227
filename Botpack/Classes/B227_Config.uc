class B227_Config expands B227_BaseConfig
	config(Botpack);

var(General) globalconfig bool bEnableExtensions;
var(General) globalconfig bool bEnableExtras;
var(DMMutator) globalconfig bool bAutoActivatePickups;
var(DMMutator) globalconfig bool bUseFlakShellAmmo;
var(DMMutator) globalconfig bool bLogNonUTInventory;
var(HUD) globalconfig bool bUseTahomaFonts;
var(HUD) globalconfig bool bYellowTeamSayMessages;
var(Misc) globalconfig bool bFixLoaded;
var(Misc) globalconfig bool bUDamageModifyDeactivation;
var(Misc) globalconfig float BotDodgeEndTime;
var(Weapon) globalconfig bool bAdjustNPCFirePosition;
var(Weapon) globalconfig bool bDroppableSlaveEnforcer;
var(Weapon) globalconfig bool bMinigunAdjustMuzzleFlashOffset;
var(Weapon) globalconfig bool bModifyProjectilesLighting;
var(Weapon) globalconfig bool bModifyShockComboDamage;
var(Weapon) globalconfig bool bPulseGunAdjustNPCAccuracy; // Reduce accuracy for pawns with low Skill
var(Weapon) globalconfig bool bPulseGunAllowCenterView;
var(Weapon) globalconfig bool bPulseGunGuideBeam;
var(Weapon) globalconfig bool bPulseGunHardcoreDamage; // 150% damage in non-deathmatch games
var(Weapon) globalconfig bool bPulseGunLimitWallEffect;
var(Weapon) globalconfig bool bTraceFireThroughWarpZones;
var(Weapon) globalconfig bool bTranslocatorModuleRecovery;
var(Weapon) globalconfig bool bUseEmitterSmokeTrails;
var(Weapon) globalconfig bool bUseEnergyAmplifier;
var(Weapon) globalconfig bool bUseSpriteSmokeTrails;
var(Weapon) globalconfig float MinigunMuzzleFlashScale;

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
	bFixLoaded=True
	bUDamageModifyDeactivation=True
	BotDodgeEndTime=0.35
	bAdjustNPCFirePosition=True
	bDroppableSlaveEnforcer=True
	bMinigunAdjustMuzzleFlashOffset=True
	bModifyProjectilesLighting=True
	bModifyShockComboDamage=True
	bPulseGunAdjustNPCAccuracy=True
	bPulseGunAllowCenterView=True
	bPulseGunGuideBeam=True
	bPulseGunHardcoreDamage=False
	bPulseGunLimitWallEffect=True
	bTraceFireThroughWarpZones=True
	bTranslocatorModuleRecovery=False
	bUseEnergyAmplifier=True
	bUseEmitterSmokeTrails=True
	bUseSpriteSmokeTrails=True
	MinigunMuzzleFlashScale=1.0
}
