//=============================================================================
// INFUT_ADD_TurretActivateMessage.
//
// OptionalObject is an INFIL_UTTurret
//
// written by N.Bogenrieder (aka Beppo)
//=============================================================================
class INFUT_ADD_TurretActivateMessage expands INFUT_ADD_LocalMessagePlus;

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return ClipY - YL - (64.0/768)*ClipY;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (OptionalObject != None)
		return Class<INFUT_ADD_Turret>(OptionalObject).default.ActivateMessage;
}

defaultproperties
{
}
