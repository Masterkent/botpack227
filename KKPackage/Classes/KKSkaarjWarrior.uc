//=============================================================================
// Skaarj.
//=============================================================================
class KKSkaarjWarrior extends SkaarjWarrior;

function eAttitude AttitudeToCreature(Pawn Other)
{
	if ( Other.IsA('Skaarj') )
	{
		if ( Other.IsA('SkaarjBerserker') )
			return ATTITUDE_Ignore;
		else
			return ATTITUDE_Friendly;
	}
	else if ( Other.IsA('Pupae') )
		return ATTITUDE_Friendly;
	else if ( Other.IsA('Nali') )
	{
		if( Other.IsA('NaliDefiler') )
			return ATTITUDE_Ignore;
		else
			return ATTITUDE_Hate;
	}
	else if ( Other.IsA('WarLord') || Other.IsA('Queen') )
		return ATTITUDE_Friendly;
	else
		return ATTITUDE_Ignore;
}

defaultproperties
{
}
