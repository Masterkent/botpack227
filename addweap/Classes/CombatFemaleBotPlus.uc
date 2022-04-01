//=============================================================================
// FemaleBotPlus.
//=============================================================================
class CombatFemaleBotPlus extends FemaleBotPlus;



var() Float WeaponAccuracyIndex;

replication
{
reliable if( Role==ROLE_Authority )
		WeaponAccuracyIndex;

}
Function ProceedWeaponAccuracy(float AccuracyDownRatio)

{

                WeaponAccuracyIndex=WeaponAccuracyIndex + AccuracyDownRatio;
		If ( WeaponAccuracyIndex > 3) WeaponAccuracyIndex=3;


		return;
}

defaultproperties
{
}
