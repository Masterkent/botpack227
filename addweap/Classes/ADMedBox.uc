//=============================================================================
// MedBox.
//=============================================================================
class ADMedBox extends MedBox;

#exec OBJ LOAD FILE="addweapResources.u" PACKAGE=addweap

//////same as in addweapons

var() float AccuracyDownRatio;
var() float ReduceGroundSpeedRatio;


Function ResetADwounds(pawn P)

{

P.GroundSpeed = P.GroundSpeed+ReduceGroundSpeedRatio;
iF (P.GroundSpeed >= P.Default.Groundspeed) P.GroundSpeed = P.Default.Groundspeed;


If( P.isa('CombatFemale'))
  {
    CombatFemale(P).WeaponAccuracyIndex=CombatFemale(P).WeaponAccuracyIndex-AccuracyDownRatio;
    if ( CombatFemale(P).WeaponAccuracyIndex < 0 ) CombatFemale(P).WeaponAccuracyIndex=0;
  }

If( P.isa('Combatmale'))
	 {
         Combatmale(P).WeaponAccuracyIndex=Combatmale(P).WeaponAccuracyIndex-AccuracyDownRatio;
         if ( Combatmale(P).WeaponAccuracyIndex < 0 ) Combatmale(P).WeaponAccuracyIndex=0;
         }
If( P.isa('CombatFemaleBotPlus'))
	 {
	 CombatFemaleBotPlus(P).WeaponAccuracyIndex=CombatFemaleBotPlus(P).WeaponAccuracyIndex-AccuracyDownRatio;
         if ( CombatFemaleBotPlus(P).WeaponAccuracyIndex < 0 ) CombatFemaleBotPlus(P).WeaponAccuracyIndex=0;
         }

If( P.isa('CombatmaleBotPlus'))
	 {
	 CombatmaleBotPlus(P).WeaponAccuracyIndex=CombatmaleBotPlus(P).WeaponAccuracyIndex-AccuracyDownRatio;
         if ( CombatmaleBotPlus(P).WeaponAccuracyIndex < 0 ) CombatmaleBotPlus(P).WeaponAccuracyIndex=0;
         }

}

auto state Pickup
{
	function Touch( actor Other )
	{
		local int HealMax;
		local Pawn P;

		if ( ValidTouch(Other) )
		{
			P = Pawn(Other);
			HealMax = P.default.health;
			if (bSuperHeal) HealMax = Min(199, HealMax * 2.0);
			if (P.Health < HealMax)
			{
				if (Level.Game.LocalLog != None)
					Level.Game.LocalLog.LogPickup(Self, P);
				if (Level.Game.WorldLog != None)
					Level.Game.WorldLog.LogPickup(Self, P);

				P.Health += HealingAmount;
				if (P.Health > HealMax) P.Health = HealMax;
				PlayPickupMessage(P);
				ResetADwounds(P);
				//PlaySound (PickupSound,,2.5);
				if (P.bIsfemale) playSound (sound'femalemedikit',,2.5);
				else playSound (sound'malemedikit',,2.5);
				Other.MakeNoise(0.2);
				SetRespawn();
			}
		}
	}
}

defaultproperties
{
     AccuracyDownRatio=0.400000
     ReduceGroundSpeedRatio=30.000000
     PickupMessage="You picked up Medikit +"
     PickupViewMesh=LodMesh'addweap.ADMedBox'
     Mesh=LodMesh'addweap.ADMedBox'
}
