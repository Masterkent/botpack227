//=============================================================================
//
//
//
//=============================================================================
class addweapons expands TournamentWeapon
config(CombatZone);



Var() float ShotAccuracy,ShotAccuracyBase,AccuracyDownRatio,MinGroundSpeed,ReduceGroundSpeedRatio;
var int ClipCount;
var int AClipCount;
var int shotc;
var() int LegDamage,HeadDamage,ArmorDamage;
var() bool bHighDetailSmoke;
var () sound ZoomSound;
var () int ADMAXFOV;
var () float ClipCountOffset;

REPLICATION
{

reliable if( Role == ROLE_Authority )

		  AClipCount;


}


Function ProcessHitLocation(actor owner, actor Other, vector HitLocation, vector X, int HeadDamage, int ArmorDamage, int LegDamage)
{

 local int HitHeight, HitAngle;
 local float ReducedGroundSpeed;


 //if (Other.IsA('Pawn'))
 // {

    HitHeight = HitLocation.Z - Other.Location.Z;


    if (HitHeight > 0.62 * Other.CollisionHeight)
	    {
               Other.TakeDamage(HeadDamage, Pawn(Owner), HitLocation, 35000 * X, AltDamageType);
	       return;
	    }
    else if (HitHeight < 0.75 * Other.CollisionHeight - Other.CollisionHeight )
            {
		Other.TakeDamage(LegDamage, Pawn(Owner), HitLocation, 25000 * X, MyDamageType);
		ReducedGroundspeed = Pawn(other).GroundSpeed - ReduceGroundSpeedRatio;
		If ( ReducedGroundSpeed <= MinGroundSpeed ) ReducedGroundSpeed=MinGroundSpeed;
		Pawn(other).GroundSpeed = ReducedGroundspeed;
		return;


	    }
    else
	    {
                HitAngle = (Other.Rotation.Yaw - rotator(HitLocation - Other.Location).Yaw) & 65535;
            if ( (HitAngle < 10000 && HitAngle > 0) || (HitAngle > 55535 && HitAngle < 65535) || (HitAngle < 42768 && HitAngle > 22768))
              	{
		Other.TakeDamage(ArmorDamage, Pawn(Owner), HitLocation,30000 * X, MyDamageType);
		return;
		}

            else
		{

		Other.TakeDamage(LegDamage, Pawn(Owner), HitLocation,25000 * X, MyDamageType);

		If (Pawn(Other).Isa('CombatFemaleBotPlus') )
		{
		  CombatFemaleBotPlus(other).ProceedWeaponAccuracy(AccuracyDownRatio);

		}
                else If (Pawn(Other).Isa('CombatMaleBotPlus') )
		{
		  CombatMaleBotPlus(other).ProceedWeaponAccuracy(AccuracyDownRatio);

		}
 		else If (Pawn(Other).Isa('CombatMale') )
		{
		   CombatMale(other).ProceedWeaponAccuracy(AccuracyDownRatio);

	        }
		else If (Pawn(Other).Isa('CombatFeMale') )
		{
		   CombatFemale(other).ProceedWeaponAccuracy(AccuracyDownRatio);

	        }

		}
             }

   //}
}

function AdjustAccuracy (actor owner,float ShotAccuracyBase, out float ShotAccuracy )

{


		If (Pawn(owner).Isa('CombatFemaleBotPlus') )
		{
		 ShotAccuracy = ShotAccuracyBase + CombatFemaleBotPlus(Owner).WeaponAccuracyIndex;

		}
                else If (Pawn(owner).Isa('CombatMaleBotPlus') )
		{
		 ShotAccuracy = ShotAccuracyBase + CombatMaleBotPlus(Owner).WeaponAccuracyIndex;

		}
 		else If (Pawn(owner).Isa('CombatMale') )
		{
		  ShotAccuracy = ShotAccuracyBase + CombatMale(Owner).WeaponAccuracyIndex;

	        }
		else If (Pawn(owner).Isa('CombatFeMale') )
		{
		   ShotAccuracy = ShotAccuracyBase + CombatFemale(Owner).WeaponAccuracyIndex;

	        }




}

defaultproperties
{
     ShotAccuracyBase=0.300000
     AccuracyDownRatio=0.400000
     MinGroundSpeed=120.000000
     ReduceGroundSpeedRatio=30.000000
     ClipCountOffset=0.280000
     MyDamageType=shot
     AltDamageType=Decapitated
}
