//=============================================================================
//
//=============================================================================

class addweap expands UTC_Mutator;


function PreBeginPlay()
{
     defaultweapon=class'addweap.imphammer';

}

function bool AlwaysKeep(Actor Other)
{
	if ( Other.IsA('StationaryPawn') )
		return true;

        //if ( Other.IsA('tournamenthealth') )
		//return true;



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
		if ( Other.IsA('Warheadlauncher') )
		{
			ReplaceWith( Other, "addweap.m79" );
			return false;
		}
		if ( Other.IsA('ut_biorifle') )
		{
			ReplaceWith( Other, "addweap.h21e" );
			return false;
		}
          	if ( Other.IsA('pulsegun') )
		{
			ReplaceWith(Other, "addweap.msg");
			return false;
		}
		if ( Other.IsA('impacthammer') )
		{
		        ReplaceWith( Other, "addweap.imphammer" );
			return false;
                }
		if ( Other.IsA('UT_Eightball') )
		{
			ReplaceWith( Other, "addweap.m79" );
			return false;
		}

		if ( Other.IsA('ripper') )
		{
			ReplaceWith( Other, "addweap.smokegun" );
			return false;
		}

		if ( Other.IsA('shockrifle') )
		{
			ReplaceWith( Other, "addweap.mpk5" );
			return false;
		}
		if ( Other.IsA('Minigun2') )
		{
			ReplaceWith( Other, "addweap.mac10" );
			return false;
		}
		if ( Other.IsA('Enforcer') )
		{
			ReplaceWith( Other, "addweap.mac10" );
			return false;
		}

		if ( Other.IsA('UT_FlakCannon') )
		{
			ReplaceWith( Other, "addweap.xm" );
			return false;
		}


                if ( Other.IsA('sniperrifle') )
		{
			ReplaceWith( Other, "addweap.hkg11");
			return false;

		}
		bSuperRelevant = 0;
		return true;
	}

	if ( Other.IsA('Ammo') )
	{

               if (  Other.IsA('bioammo') )
		{
			ReplaceWith( Other, "addweap.h21ammo" );
			return False;
		}
		 if ( Other.IsA('pammo') )
		{
			ReplaceWith( Other, "addweap.msgammo" );
			return false;
		}
                if ( Other.IsA('Bladehopper') )
		{
			ReplaceWith( Other, "addweap.smokeammo" );
			return false;
		}
		if ( Other.IsA('shockcore') )
		{
			ReplaceWith( Other, "addweap.mpkammo" );
			return false;
		}
		if ( Other.IsA('miniammo') )
		{
			ReplaceWith( Other, "addweap.mac10ammo" );
			return false;
		}
		if ( Other.IsA('Bulletbox') )
		{
			ReplaceWith( Other, "addweap.hkg11ammo" );
			return false;
		}
		if ( Other.IsA('flakammo') )
		{
			ReplaceWith( Other, "addweap.xmammo" );
			return false;
		}
		if ( Other.IsA('rocketpack') )
		{
			ReplaceWith( Other, "addweap.m79ammo" );
			return false;
		}
		bSuperRelevant = 0;
		return true;
            }

    if ( Other.IsA('tournamentpickup') )
	{

	  if ( Other.IsA('Armor2') )
	  {
		ReplaceWith( Other, "addweap.bulletvest" );
		return false;
	  }

	  if ( Other.IsA('ut_ShieldBelt') )
	  {
		ReplaceWith( Other, "addweap.bulletvest" );
		return false;
	  }


	  bSuperRelevant = 0;
	  return true;
       }

    if ( Other.IsA('tournamenthealth') )
	{

	 if ( Other.IsA('MedBox') && !Other.IsA('ADMedbox') )
	  {
		ReplaceWith( Other, "addweap.ADMedbox" );
		return false;
	  }
         if ( Other.IsA('HealthVial')  )
	  {
		ReplaceWith( Other, "unrealshare.bandages" );
		return false;
	  }

	  bSuperRelevant = 0;
	  return true;
       }



}

defaultproperties
{
}
