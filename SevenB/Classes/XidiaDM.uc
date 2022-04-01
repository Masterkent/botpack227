// ===============================================================
// SevenB.XidiaDM: Xidia Survivor Mode. A 7Bullets multiplay option
// ===============================================================

class XidiaDM extends Arena;

var int CarConvert; //0,1=grenade ammo. 2=bullets

function PostBeginPlay(){
	local spawnnotify sn;
	CarConvert=rand(2)+1;
  class'PlayerShadow'.default.bGameRelevant=false; //to mutate shadows
  sn=spawn(class'Sevenbloodnotify');
  sn.ActorClass=class'UT_BloodBurst'; //perhaps this should only be blood hit?
}

function ScoreKill(Pawn Killer, Pawn Other) //dead players drop machine mag clip
{
  local Inventory a;
  local vector x,y,z;
  GetAxes(Other.Rotation,X,Y,Z);
  a = other.spawn(class'MachineMagClip',,,Other.Location);
    if ( a != None )
    {
      a.RespawnTime = 0.0; //don't respawn
      a.BecomePickup();
      a.RemoteRole = ROLE_DumbProxy;
      a.SetPhysics(PHYS_Falling);
      a.bCollideWorld = true;
      a.Velocity = Other.Velocity + VRand() * 280;
      a.GotoState('PickUp', 'Dropped');
    }

	//Call next mutator
  if ( NextMutator != None )
    class'UTC_Mutator'.static.UTSF_ScoreKill(NextMutator, Killer, Other);
}
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
  bSuperRelevant = 0;
  if (level.game.isa('lastmanstanding')&&Other.Isa('ammo')&& (Ammo(Other).MyMarker != None)){    //emulate non-arena mode...
    Ammo(Other).MyMarker.markedItem = None;
		return false;
	}
 	if (Other.Isa('Uiweapons')){
    if ((Other.IsA('quadshot')) || (Other.IsA('olquadshot') &&!Other.IsA('SbQuadshot'))){
      Replaceweapon(Other, class'sbquadshot', pawn(Other.owner));
      return false;
    }
    if (Other.IsA('Oldpistol')){ //set to powerlevel 4
    	OldPistol(Other).powerlevel=4;
    	OldPistol(Other).PickupAmmoCount=90;
    	OldPistol(Other).AltProjectileClass=class'SBAltDispersionAmmo';
    	OldPistol(Other).AIRating/=2;
    	return true;
    }
		return true;
  }
  if (other.isa('tournamentweapon'))  {
    if (Other.IsA('PulseGun')&&!other.isa('SevenPulseGun'))
    {
      Replaceweapon(Other, class'SevenPulseGun', pawn(Other.owner));
      return false;
    }
    if ( Other.IsA('SniperRifle') )
    {
      Replaceweapon( Other, class'SevenSniperRifle', pawn(Other.owner) );
      return false;
    }
    if ( Other.IsA('Ripper')&&!Other.IsA('SBBloodRipper') )
    {
      Replaceweapon( Other, class'SBBloodRipper', pawn(Other.owner) );
      return false;
    }
    if ( Other.IsA('Minigun2')&&!Other.IsA('SevenChainGun') )
    {
      Replaceweapon( Other, class'SevenCarRifle', pawn(Other.owner) );
      return false;
    }
    if ( Other.IsA('Enforcer'))
    {
      Replaceweapon( Other, class'SevenMachineMag',pawn(Other.owner) );
      return false;
    }
    if ( Other.IsA('UT_Eightball'))
    {
       Replaceweapon( Other, class'tvEightball', pawn(Other.owner) );
      return false;
    }
    if ( Other.IsA('UT_FlakCannon')&&!Other.IsA('SBFlechetteCannon') )
    {
       Replaceweapon( Other, class'SBFlechetteCannon', pawn(Other.owner) );
      return false;
    }
    if ( Other.IsA('SuperShockRifle')){
      ReplaceWeapon( Other, class'SBQuadshot', pawn(Other.owner));
      return false;
    }
    if ( Other.IsA('ShockRifle')&&!other.isa('Sevenshockrifle'))
    {
      Replaceweapon( Other, class'Sevenshockrifle', pawn(Other.owner) );
      return false;
	  }

    if ( Other.IsA('UT_BioRifle') )
    {
      Replaceweapon( Other, class'SBQuadshot', pawn(Other.owner) );
      return false;
    }
    if ( Other.IsA('impacthammer'))
    {
      Replaceweapon( Other, class'SevenChainGun', pawn(Other.owner));
      return false;
    }
    if ( Other.IsA('chainsaw'))
    {
      Replaceweapon( Other, class'SevenMachineMag', pawn(Other.owner));
      return false;
    }
		if ( Other.IsA('WarheadLauncher'))
    {
      Replaceweapon( Other, class'SevenChainGun', pawn(Other.owner));
    	return false;
    }
    return true;
		}
  if (other.Isa('defaultammo')){ //for powerlevel 4
  	ammo(other).maxammo=90;
  	return true;
  }
	if (other.isa('tournamentammo'))       //handle necessary ammo changes
   {
    if ( Other.IsA('RocketPack'))
    {
      ReplaceWith( Other, "SevenB.SBGrenadeAmmo" );
      return false;
    }
    if ( Other.IsA('PAmmo') && !Other.IsA('SBPAmmo'))
    {
      ReplaceWith(Other, "SevenB.SBPAmmo");
      return false;
    }
    if ((Other.IsA('EClip')||Other.IsA('MiniAmmo'))&&!Other.Isa('MachineMagClip')&&!Other.Isa('SevenMiniammo'))
    {   //convert randomly to car ammo
			if (CarConvert%3==2)
				ReplaceWith( Other, "SevenB.CarGrenadeAmmo" );
			else
        ReplaceWith( Other, "SevenB.CARifleClip" );
      if (CarConvert<3) //initially force a different ammo on 2nd run
				CarConvert+=4;
			else
				CarConvert+=rand(3);
			return false;
    }
    if ( Other.IsA('Bioammo'))  //shells
    {
			 ReplaceWith(Other,"SevenB.sbshells");
			 return false;
		}
   	return true;
	}

  if ( Other.IsA('UT_JumpBoots')&&!Other.IsA('USMGravBoots'))
  {
    ReplaceWith( Other, "SevenB.USMGravBoots");
		return false;
  }
  if ( Other.IsA('UDamage'))
  {
    ReplaceWith( Other, "SevenB.SkaarjBomb" );
    return false;
  }
  if ( Other.IsA('ThighPads')&&!Other.IsA('USMThighPads'))
  {
    ReplaceWith( Other, "SevenB.USMThighPads");
    return false;
  }
  if ( Other.IsA('Armor2')&&!Other.Isa('USMBodyArmor'))
  {
    ReplaceWith( Other, "SevenB.USMBodyArmor" );
    return false;
  }
  if (Other.class==class'PlayerShadow'){
 	 ReplaceWith(other,"SevenB.TvShadow");
 	 return false;
	}
	return true;
}

function ModifyPlayer(Pawn Other)
{
	local float f;
  local inventory inv;
  Super.ModifyPlayer( Other );
	GiveWeapon(Other, class'SevenMachineMag');
	if (level.game.isa('LastManStanding')){ //LMS support.....     code taken and edited from the LMS add default inventory...
		GiveWeapon(Other, class'SevenShockRifle');
	  GiveWeapon(Other, class'SevenCarRifle');
	  GiveWeapon(Other, class'SBBloodRipper');
	  GiveWeapon(Other, class'SBQuadshot');
	  GiveWeapon(Other, class'SBFlechetteCannon');
	  GiveWeapon(Other, class'SevenMachineMag');
  	if ( Other.IsA('PlayerPawn') )
  	{
    	GiveWeapon(Other, class'SevenSniperRifle');
    	GiveWeapon(Other, class'SevenPulseGun');
    	GiveWeapon(Other, class'SevenChaingun');
    	GiveWeapon(Other, class'TVEightball');
    	Other.SwitchToBestWeapon();
  	}
  	else
  	{
    	// randomize order for bots so they don't always use the same weapon; unfortunately this isn't perfect as different random vars are called in LMS...   (this function called before LMS')
    	F = FRand();
    	if ( F < 0.7 )
    	{
      	GiveWeapon(Other, class'SevenSniperRifle');
      	GiveWeapon(Other, class'SevenPulseGun');
      	if ( F < 0.4 )
      	{
        	GiveWeapon(Other, class'SevenChaingun');
        	GiveWeapon(Other, class'TVEightball');
      	}
      	else
      	{
       		GiveWeapon(Other, class'TVEightball');
        	GiveWeapon(Other, class'SevenChaingun');
      	}
    	}
    	else
    	{
      	GiveWeapon(Other, class'SevenChaingun');
   	  	GiveWeapon(Other, class'TVEightball');
      	if ( F < 0.88 )
      	{
        	GiveWeapon(Other, class'SevenSniperRifle');
        	GiveWeapon(Other, class'SevenPulseGun');
      	}
      	else
      	{
        	GiveWeapon(Other, class'SevenPulseGun');
        	GiveWeapon(Other, class'SevenSniperRifle');
      	}
    	}
  	}

  	for ( inv=Other.inventory; inv!=None; inv=inv.inventory )
  	{
    	if ( (Weapon(inv) != None) && (Weapon(inv).AmmoType != None) )
     		Weapon(inv).AmmoType.AmmoAmount = Weapon(inv).AmmoType.MaxAmmo;
  	}
  	inv = Spawn(class'USMBodyArmor');
  	if( inv != None )
  	{
    	inv.bHeldItem = true;
    	inv.RespawnTime = 0.0;
    	inv.GiveTo(Other);
  	}
	}
}


//set all to pickupmessage plus
function bool AlwaysKeep( Actor Other )
{
  if (other.IsA('inventory') && class'UTC_Inventory'.static.B227_GetPickupMessageClass(Inventory(other)) == none)
     class'UTC_Inventory'.static.B227_SetPickupMessageClass(Inventory(Other), Class'BotPack.PickupMessagePlus');
  if (other.IsA('DefaultAmmo'))
  	return true;
	if ( NextMutator != None )
  {
    return class'UTC_Mutator'.static.UTSF_AlwaysKeep(NextMutator, Other);
  }
  return false;
}
//based on DMP's giveweapon.....
function GiveWeapon (Pawn P, Class<Weapon> WepClass)
{
  local Weapon newweapon;

  newWeapon = Spawn(WepClass);
  if( P.FindInventoryType(WepClass) != None )
    return;
  if( newWeapon != None )
  {
    If (level.game.isa('rocketarenagame')) //gotta make sure of RA compatibility....
    	newWeapon.bCanThrow = false;
    newWeapon.RespawnTime = 0.0;
    newWeapon.GiveTo(P);
    newWeapon.bHeldItem = true;
    newWeapon.GiveAmmo(P);
    newWeapon.SetSwitchPriority(P);
    newWeapon.WeaponSet(P);
    newWeapon.AmbientGlow = 0;
    if ( P.IsA('PlayerPawn') )
      newWeapon.SetHand(Playerpawn(P).Handedness);
    else
      newWeapon.GotoState('Idle');
    P.Weapon.GotoState('DownWeapon');
    P.PendingWeapon = None;
    P.Weapon = newWeapon;
  }
}
function bool ReplaceWeapon(actor Other, class<weapon> aclass, pawn owner)    //function used to replace the weapons........
{
  local Actor A;

  if (owner!=None){ //verify if it is owned......
  giveweapon(owner, aclass);
  return false;
  }

  if ( Other.Location == vect(0,0,0))
    return false;
  if ( aClass != None )
    A = Spawn(aClass,,Other.tag,Other.Location, Other.Rotation);
  if ( Inventory(Other).MyMarker != None )
    {
      Inventory(Other).MyMarker.markedItem = Inventory(A);
      if ( Inventory(A) != None )
      {
        Inventory(A).MyMarker = Inventory(Other).MyMarker;
        A.SetLocation(A.Location
          + (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
      }
      Inventory(Other).MyMarker = None;
    }
    else
    {
      Inventory(A).bHeldItem = true;
      Inventory(A).Respawntime = 0.0;
    }

  if ( A != None )
  {
    A.event = Other.event;
    A.tag = Other.tag;
    A.RotationRate= Other.RotationRate;


    return true;
  }
  return false;
}

function bool ReplaceWith(actor Other, string aClassName)    //simply to preserve rotationrate var....
{
  local Actor A;
  local class<Actor> aClass;

  if ( Other.IsA('Inventory') && (Other.Location == vect(0,0,0)) )
    return false;
  aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
  if ( aClass != None )
    A = Spawn(aClass,Other.Owner,Other.tag,Other.Location, Other.Rotation);
  if ( Other.IsA('Inventory') )
  {
    if ( Inventory(Other).MyMarker != None )
    {
      Inventory(Other).MyMarker.markedItem = Inventory(A);
      if ( Inventory(A) != None )
      {
        Inventory(A).MyMarker = Inventory(Other).MyMarker;
        A.SetLocation(A.Location
          + (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
      }
      Inventory(Other).MyMarker = None;
    }
    else if ( A.IsA('Inventory') )
    {
      Inventory(A).bHeldItem = true;
      Inventory(A).Respawntime = 0.0;
    }
  }
  if ( A != None )
  {
    A.event = Other.event;
    A.tag = Other.tag;
    A.RotationRate= Other.RotationRate;

    return true;
  }
  return false;
}

defaultproperties
{
     DefaultWeapon=Class'olweapons.OLDpistol'
}
