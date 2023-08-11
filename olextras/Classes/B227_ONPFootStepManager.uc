class B227_ONPFootStepManager expands FootStepManager;

#exec OBJ LOAD FILE="ONPFootSteps.uax"

var Sound FootStepSound_OnWood;

static function bool OverrideFootstep(Pawn Other, out Sound Step, out byte WetSteps)
{
	local Texture HitTexture;

	if (super.OverrideFootstep(Other, Step, WetSteps))
		return true;

	Other.TraceSurfHitInfo(Other.Location, Other.Location - vect(0,0,30),,, HitTexture);
	if (HitTexture != none)
		Step = GetFootStepSound(HitTexture);

	return Step != none;
}

static function Sound GetFootStepSound(Texture T)
{
	switch (Caps(T.Name))
	{
		case "TONNFLOOR":
		case "XIPTH":
		case "XPTH":
		case "EBFLOOR3":
		case "TONNFLOOR":
		case "SWINDO2M":
		case "MMCRATE3":
		case "MFLOORZ":
		case "FLOOR4":
		case "MFLOORX":
		case "MFLOORY":
		case "MMCRATE2":
		case "MCMETL":
		case "RUSTPL2":
		case "PIPE3":
		case "IRNWALL2":
		case "NONDETGR8":
		case "INXGRID":
		case "MTL-BMPS2":
		case "RUSTEEL1":
		case "FLRWKA":
		case "WARN":
		case "PBLOOD5":
		case "WALLWKD":
		case "BS_1":
			return Sound'ONPFootSteps.FS_METAL_1';
		case "SHFLOOR01":
		case "GROUND1":
		case "DMGROUND1":
		case "MORTER1":
		case "MORTER2":
		case "DIRTNEW":
		case "DIRT_SU2":
		case "DIRT1":
		case "DIRT2":
		case "MSROCK3":
		case "VOLCANICGRPATH1":
		case "VOLCANICGROUND1":
		case "TRANSITION2":
		case "BASIC1":
		case "BASIC2":
		case "ABASIC4":
		case "DMGRAS2":
			return Sound'ONPFootSteps.FS_GRAVEL_1';
		case "DMGRA":
		case "EZGRASS":
		case "DMGRAS":
		case "GRASS":
			return Sound'ONPFootSteps.FS_GRASS_1';
		case "QBS2":
		case "SCARPET3":
		case "GCLTH2":
		case "GCLTH3":
		case "GCLTH5":
		case "RUG-BLU2":
		case "RUG-BLU":
		case "RUG-REND":
		case "RUG-RUG":
			return Sound'ONPFootSteps.FS_STUFF_1';
		case "OQ_WL2":
		case "MUD2":
			return Sound'ONPFootSteps.FS_MUD_1';
		case "AA_BS":
		case "JEBWLG1":
		case "JEBWLG2":
		case "T-GRATE":
		case "DMESH3M":
		case "DMESH1M":
		case "METAL4":
		case "METWALL":
		case "GRATE3-M":
		case "RUST2":
		case "BASEIRM3":
		case "MIRONFX2":
		case "MIRONFX":
		case "MFLOOR":
		case "GIRDERM3":
		case "IRONWALX":
		case "GIRDR2M":
		case "MGR8MS3":
		case "I-BEAM":
		case "FENCE1":
		case "TRIM1NEW":
		case "BLOOD6":
		case "HULLRIB1":
		case "SLOTTED3":
			return Sound'ONPFootSteps.FS_METAL2_1';
		case "WOOD1":
		case "WOOD2A":
		case "T-WOOD":
		case "T-WOOD2":
		case "WOODF2":
		case "SKYWOODV":
		case "ROTWOOD2":
		case "U_BOX1":
		case "WOODMAI3":
		case "HASH-ICE-3":
		case "DECKRF1":
		case "DECKSM1":
		case "BOARDS1B":
			return default.FootStepSound_OnWood; // uses hyphen in the name
		case "OLDFLOR2":
		case "COBBLE2":
		case "CONCRETEBASE":
			return Sound'ONPFootSteps.FS_CONCRETE_1';
		case "PAVEBASE":
		case "SANDMRTR2":
			return Sound'ONPFootSteps.FS_SAND_1';
		case "AZ-FLOOR":
		case "FLOOR1":
		case "FLOOR2":
		case "FLOOR2B":
		case "FLOOR2B2":
		case "FLOOR2J2":
		case "CHESSB1":
		case "CHESSB2":
		case "COBBLE2":
		case "SFLOORA":
		case "SFLOORA2":
		case "SFLOORA3":
		case "SFLOORB":
		case "SFLOORB2":
		case "SFLOORB3":
		case "SFLOORC":
		case "SFLOORC2":
		case "SFLOORC3":
		case "SFLOORC4":
			return Sound'ONPFootSteps.fs_stein_1';
	}
	return none;
}

defaultproperties
{
	FootStepSound_OnWood=Sound'ONPFootSteps.FS_ON-WOOD_1'
}
