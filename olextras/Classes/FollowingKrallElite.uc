// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// FollowingKrallElite : balh
// ===============================================================

class FollowingKrallElite expands FollowingKrall;

function PreBeginPlay()
{
  Super.PreBeginPlay();
  bCanDuck = true;
}
function PlayMeleeAttack()
{
  local float decision;

  decision = FRand();
  if (!bSpearToss)
    decision *= 0.65;
  if (decision < 0.22)
    PlayAnim('Strike1');
   else if (decision < 0.44)
       PlayAnim('Strike2');
   else if (decision < 0.65)
     PlayAnim('Strike3');
   else
     PlayAnim('Throw');
}

defaultproperties
{
     StrikeDamage=28
     ThrowDamage=38
     PoundDamage=28
     MinDuckTime=5.000000
     bLeadTarget=True
     RangedProjectile=Class'oldskool.ol1337krallBolt'
     ProjectileSpeed=880.000000
     bCanStrafe=True
     Health=200
     UnderWaterTime=-1.000000
     Skill=1.000000
     MenuName="1337 Krall"
     Skin=Texture'UnrealI.Skins.ekrall'
}
