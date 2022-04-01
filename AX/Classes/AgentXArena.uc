//=============================================================================
// AgentXarena.
//=============================================================================

class AgentXarena expands UTC_Mutator
config(axcfg);

var() config int healthon;
var() config int rocketlauncher;
var() config int grenadelauncher;
var() config int minelauncher;


var string agweap;


function PreBeginPlay()
{
     defaultweapon=class'AX.ppk';

}

function bool AlwaysKeep(Actor Other)
{
	if ( Other.IsA('StationaryPawn') )
		return true;

       if (healthon == 1)
          {
            if ( Other.IsA('tournamenthealth') )
		return true;
          }

	if (NextMutator != none)
		return class'UTC_Mutator'.static.UTSF_AlwaysKeep(NextMutator, Other);
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local Inventory Inv;


	bSuperRelevant = 1;


	if ( Other.IsA('StationaryPawn') )
		return true;

	Inv = Inventory(Other);
 	if ( Inv == None )
	{
		bSuperRelevant = 0;
		return true;
	}


	if ( Other.IsA('Weapon') )
	{
		if ( Other.IsA('pulsegun') )
		{
			ReplaceWith(Other, "AX.SWAT551");
			return false;
		}
            if ( Other.IsA('chainsaw') )
		{
			ReplaceWith(Other, "AX.shottie");
			return false;
		}

		if ( Other.IsA('ripper') )
		{
			ReplaceWith( Other, "AX.famasg2" );
			return false;
		}
		if ( Other.IsA('shockrifle') )
		{
			ReplaceWith( Other, "AX.ak47" );
			return false;
		}
		if ( Other.IsA('Minigun2') )
		{
			ReplaceWith( Other, "AX.asm4" );
			return false;
		}
		if ( Other.IsA('Enforcer') )
		{
			ReplaceWith( Other, "AX.ppk" );
			return false;
		}

		if ( grenadelauncher == 1 && Other.IsA('UT_Eightball') )
		{
			ReplaceWith( Other, "AX.glaun" );
			return false;
            }


		if ( grenadelauncher != 1 && Other.IsA('UT_Eightball') )
		{
			ReplaceWith( Other, "AX.asm4" );
			return false;
            }


		if ( Other.IsA('UT_FlakCannon') )
		{
			ReplaceWith( Other, "AX.shottie" );
			return false;
		}

		if ( minelauncher == 1 && Other.IsA('ut_biorifle') )
		{
			ReplaceWith( Other, "AX.Rocketl" );
			return false;
		}


		if ( minelauncher != 1 && Other.IsA('ut_biorifle') )
		{
			ReplaceWith( Other, "AX.Famasg2" );
			return false;
		}


		if ( rocketlauncher == 1 && Other.IsA('Warheadlauncher') )
		{
			ReplaceWith( Other, "AX.rocketl" );
			return false;
		}


		if ( rocketlauncher != 1 && Other.IsA('Warheadlauncher') )
		{
			ReplaceWith( Other, "AX.ppk" );
			return false;
		}


		if ( Other.IsA('impacthammer') )
		{
			ReplaceWith( Other, "AX.ppk");
			return false;
            }
            if ( Other.IsA('sniperrifle') )
		{
			ReplaceWith( Other, "AX.sniper");
			return false;

		}
		bSuperRelevant = 0;
		return true;
	}
	if ( Other.IsA('Ammo') )
	{

		if ( Other.IsA('shockcore') )
		{
			ReplaceWith( Other, "AX.Akammo" );
			return false;
		}
		if ( Other.IsA('miniammo') )
		{
			ReplaceWith( Other, "AX.asm4ammo" );
			return false;
		}
		if ( Other.IsA('pammo') )
		{
			ReplaceWith(Other, "AX.SWATammo");
			return false;
		}
		if ( Other.IsA('Bladehopper') )
		{
			ReplaceWith( Other, "AX.FAMASammo" );
			return false;
		}

		if ( minelauncher == 1 && Other.IsA('bioammo') )
		{
			ReplaceWith( Other, "AX.grammo" );
			return False;
            }

		if ( minelauncher != 1 && Other.IsA('bioammo') )
		{
			ReplaceWith( Other, "AX.FAMASammo" );
			return False;
		}


		if ( Other.IsA('RifleAmmo') )
		{
			ReplaceWith( Other, "AX.Sniperammo" );
			return false;
		}
		if ( Other.IsA('Bulletbox') )
		{
			ReplaceWith( Other, "AX.Sniperammo" );
			return false;
                }
                if ( Other.IsA('flakammo') )
		{
			ReplaceWith( Other, "AX.axsgunammo" );
			return false;
		}
		if (grenadelauncher == 1 && Other.IsA('rocketpack') )
		{
			ReplaceWith( Other, "AX.grammo" );
			return false;
		}
            if (grenadelauncher != 1 && Other.IsA('rocketpack') )
		{
			ReplaceWith( Other, "AX.asm4ammo" );
			return false;
		}
            		if ( Other.IsA('eClip') )
		{
			ReplaceWith( Other, "AX.famasammo" );
			return false;
		}
		bSuperRelevant = 0;
		return true;
	}
      if ( Other.IsA('tournamentpickup') )
	{

        if ( Other.IsA('Udamage') )
	  {
		ReplaceWith( Other, "AX.asm4" );
		return false;
	  }

	  if ( Other.IsA('thighpads') )
	  {
		ReplaceWith( Other, "AX.axkevlar");
		return false;
	  }

	  if ( Other.IsA('Armor2') )
	  {
		ReplaceWith( Other, "AX.axkevlar" );
		return false;
	  }

	  if ( Other.IsA('ut_ShieldBelt') )
	  {
		ReplaceWith( Other, "Ax.AXkevlar" );
		return false;
	  }
        if ( Other.IsA('ut_invisibility') )
	  {
		ReplaceWith( Other, "AX.famasammo" );
		return false;
	  }



	  bSuperRelevant = 0;
	  return true;
       }
   }

defaultproperties
{
     healthon=1
     RocketLauncher=1
     grenadelauncher=1
     agweap="class"
}
