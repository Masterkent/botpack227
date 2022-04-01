//==============================================================
//the original mutator (made in Unreal ED :)...
//gets the honor of being called OldSkool... (Original didn't have options though)
// Psychic_313: moved to OlWeapons as it seemed to fit in there.
// Hmm... the irony... OldSkool.uc removed from Oldskool.u :-)
// Also imported another PulseIcon for OlWeapons, and added a couple of fixes requested by UsAaR33.
//==============================================================
class oldskool expands Arena
config (oldskool); //h4ck....

#exec OBJ LOAD FILE="OLweaponsResources.u" PACKAGE=OLweapons

var config bool bmed,
    bPistol,
    bMag,
    bBioRifle,
    bASMD,
    bStingy,
    bRazor,
    bFlak,
    bmini,
    bEball,
    bRifle,
    bSuperASMD,
    bPower,
    bRedeem,
    bjump,
    bdamage,
    bpad,
    bmegahealth,
    barmor,
    bbandaid,
    binvis,
    bdefauto,
    bpowerups,
    bscorebored;

var config int shieldmode, redeemmode, quadmode, arenamode, maxpowerups;
var config int poweruptime;
var int NumPoints;
var bool Initialized;
var  osDispersionpowerup SpawnedRelic;

function PostBeginPlay()             //following 3 functions ripped and heavily edited from relic.relic
{
  local NavigationPoint NP;
  local int i;
  if (Initialized || !bpowerups || !bpistol || quadmode==1)     //only call once or option not enabled......
    return;
  Initialized = True;            //certain UT versions call mutator postbegin play's twice....

  // Calculate number of navigation points.
  for (NP = Level.NavigationPointList; NP != None; NP = NP.NextNavigationPoint)
  {
    if (NP.IsA('PathNode'))
      NumPoints++;
  }
  for (i=0; i<Min(maxpowerups, Int(numpoints/1.5)); i++)  //spawn amount here.....
  Spawnpowerup(0);

}

function Spawnpowerup(int RecurseCount)
{
  local int PointCount, navpoint;
  local NavigationPoint NP;
  local osDispersionpowerup Touching;

  NavPoint = Rand(NumPoints);
  for (NP = Level.NavigationPointList; NP != None; NP = NP.NextNavigationPoint)
  {
    if ( NP.IsA('PathNode') )
    {
      if (PointCount == NavPoint)
      {
        // check that there are no other power ups here
        if ( RecurseCount < 3 )
          ForEach VisibleCollidingActors(class'osDispersionpowerup', Touching, 40, NP.Location)
          {
            Spawnpowerup(RecurseCount + 1);
            return;
          }

        // Spawn it here.
        SpawnedRelic = Spawn(class'olWeapons.osDispersionpowerup', , , NP.Location);
        if ( SpawnedRelic != None)
        spawnedrelic.doswap=true;
        SpawnedRElic.mastermutator=self;        //set var........
        SpawnedRElic.respawntime=0.0;  //prevent respawning :D
        return;
      }
      PointCount++;
    }
  }
}

function ModifyPlayer(Pawn Other)
{ local float f;
  local inventory inv;
  Super.ModifyPlayer( Other );
if (arenamode!=0)
return;
if (level.game.isa('LastManStanding')){ //LMS support.....     code taken and edited from the LMS add default inventory...
if (basmd)
GiveWeapon(Other, class'olweapons.olasmd');
if (bbiorifle)
  GiveWeapon(Other, class'olweapons.olgesbiorifle');
  if (brazor)
  GiveWeapon(Other, class'olweapons.olrazorjack');
  if (bflak)
  GiveWeapon(Other, class'olweapons.olFlakCannon');
  if (bmag)
  GiveWeapon(Other, class'olweapons.olautomag');
  if (quadmode>1)
  GiveWeapon(Other, class'olweapons.olquadshot');
  if ( Other.IsA('PlayerPawn') )
  {
    if (brifle)
    GiveWeapon(Other, class'olweapons.olRifle');
    if (bstingy)
    GiveWeapon(Other, class'olweapons.olstinger');
    if (bmag)
    GiveWeapon(Other, class'olweapons.olminigun');
    if (beball)
    GiveWeapon(Other, class'olweapons.olEightball');
    Other.SwitchToBestWeapon();
  }
  else
  {
    // randomize order for bots so they don't always use the same weapon; unfortunately this isn't perfect as different random vars are called in LMS...   (this function called before LMS')
    F = FRand();
    if ( F < 0.7 )
    {
      if (brifle)
      GiveWeapon(Other, class'olweapons.olRifle');
      if (bstingy)
      GiveWeapon(Other, class'olweapons.olstinger');
      if ( F < 0.4 )
      {
        if (bmag)
        GiveWeapon(Other, class'olweapons.olMinigun');
        if (beball)
        GiveWeapon(Other, class'olweapons.olEightball');
      }
      else
      {
        if (beball)
        GiveWeapon(Other, class'olweapons.olEightball');
        if (bmag)
        GiveWeapon(Other, class'olweapons.olMinigun');
      }
    }
    else
    {
      if (bmag)
      GiveWeapon(Other, class'olweapons.olMinigun');
     if (beball)
     GiveWeapon(Other, class'olweapons.olEightball');
      if ( F < 0.88 )
      {
        if (brifle)
        GiveWeapon(Other, class'olweapons.olRifle');
        if (bstingy)
        GiveWeapon(Other, class'olweapons.olstinger');
      }
      else
      {
        if (bstingy)
        GiveWeapon(Other, class'olweapons.olstinger');
        if (brifle)
        GiveWeapon(Other, class'olweapons.olRifle');
      }
    }
  }

  for ( inv=Other.inventory; inv!=None; inv=inv.inventory )
  {
    //weap = Weapon(inv);
    if ( (Weapon(inv) != None) && (Weapon(inv).AmmoType != None) )
      Weapon(inv).AmmoType.AmmoAmount = Weapon(inv).AmmoType.MaxAmmo;
  }
  if (barmor) {
  inv = Spawn(class'olarmor');
  if( inv != None )
  {
    inv.bHeldItem = true;
    inv.RespawnTime = 0.0;
    inv.GiveTo(Other);
  }                        }  }

else if ((bdefauto)&&(bmag))
GiveWeapon(Other, class'olweapons.olautomag');
}
function bool AlwaysKeep( Actor Other )
{
  local bool bRetVal;
  local name quadammoname;
 //  if (other.IsA('inventory')&&bhud) //so pickup messages work (yes, you can call it safely here :P)......
//Inventory(other).PickupMessageClass = None;
    if (Inventory(Other) != none && class'UTC_Inventory'.static.B227_GetPickupMessageClass(Inventory(Other)) == none)
        class'UTC_Inventory'.static.B227_SetPickupMessageClass(Inventory(Other), Class'BotPack.PickupMessagePlus');
    bRetVal = false;
      if (arenamode>0){ //launch arena handler :D
    switch (arenamode){ //gotta love 'em switches.....
    case 1:
    weaponname='oldpistol';
    ammoname='defaultammo';
     break;
     case 2:
    weaponname='olautomag';
    ammoname='shellbox';
       break;
     case 3:
     weaponname='olstinger';
    ammoname='StingerAmmo';
        break;
     case 4:
    weaponname='olasmd';
    ammoname='ASMDammo';
        break;
     case 5:
    weaponname='oleightball';
    ammoname='RocketCan';
    break;
     case 6:
    weaponname='olflakcannon';
    ammoname='Flakbox';
        break;
     case 7:
    weaponname='olrazorjack';
    ammoname='Razorammo';
        break;
     case 8:
    weaponname='olgesbiorifle';
    ammoname='sludge';
        break;
     case 9:
    weaponname='olrifle';
    ammoname='RifleAmmo';
     break;
     case 10:
    weaponname='olminigun';
    ammoname='shellbox';
    break;
     case 11:
    weaponname='olquadshot';
    ammoname='olshells';

    break;
         case 12:
    if (bmag){                //only option that means ANYTHING in arena mode....
    weaponname='olsmmag';
    ammoname='osmagammo';
    }
    else{
    weaponname='olsmenf';
    ammoname='osmagammo2';
    }
    break;
     }
  if ( Other.IsA(WeaponName) )
  {
    Weapon(Other).PickupAmmoCount = Weapon(Other).AmmoName.Default.MaxAmmo;
    return true;
  }
  if ( Other.IsA(AmmoName))
  {
    Ammo(Other).AmmoAmount = Ammo(Other).MaxAmmo;
    return true;
  }      }
  else if (level.game.isa('lastmanstading')&&Other.Isa('ammo')&&Other.Location!=Vect(0,0,0))
  return false;
     if (quadmode>1){
    switch (quadmode){
    case 2:
    quadammoname='eclip';
    break;
    case 3:
    quadammoname='pammo';
    break;
    case 4:
    quadammoname='shockcore';
    break;
    case 5:
    quadammoname='rocketpack';
    break;
    case 6:
    quadammoname='flakammo';
    break;
    case 7:
    quadammoname='bladehopper';
    break;
    case 8:
    quadammoname='bioammo';
    break;
    case 9:
    quadammoname='bulletbox';
    break;
    case 10:
    quadammoname='miniammo';
    break;
    case 11:
    quadammoname='warhadammo';
    break;
    }
    if (Other.Isa(quadammoname))
     return false;
    }
  if (other.Isa('uiweapons')&&ArenaMode==0)             //in case something screws up and changes these....
  bretval = true;
  else if (other.Isa('ammo')&&Arenamode==0){
  if (other.Isa('asmdammo')&&basmd)
  bretval=true;
  else if (other.isa('defaultammo')) //always as this isn't NORMALLY found in levels....
  bretval=true;
  else if (Other.isa('osmagammo'))        //always preserve this :D
  bretval=true;
  else if (other.isa('flakbox')&&bflak)
  bretval=true;
  else if (other.isa('razorammo')&&brazor)
  bretval=true;
  else if (other.isa('rifleammo')&&brifle)
  bretval=true;
  else if (other.isa('rocketcan')&&beball)
  bretval=true;
  else if (other.isa('clip')&&bmag)
  bretval=true;
  else if (other.isa('shellbox')&&(bmini||Other.Location== vect(0,0,0)))
  bretval=true;
  else if (other.isa('sludge')&&bbiorifle)
  bretval=true;
  else if (other.isa('stingerammo')&&bstingy)
  bretval=true;
  }
  //if it's destroyed it kills our reference to it......
  else if ( Other.IsA('WeaponPowerUp') && bpistol&&!Other.Isa('osDispersionpowerup'))
  {
    Replacewith(Other, "olWeapons.osDispersionpowerup");      //so it doesn't die....
  }
  else if ( Other.IsA('osDispersionPowerUp') && bpistol)
  {
    bRetVal = true;
  }
  else if ( Other.IsA('Bandages') &&bbandaid)              //the following must stay.......
  {
    bRetVal = true;
  }

  else if ( Other.IsA('SuperHealth')&&bmegahealth )
  {
    bRetVal = true;
  }

else if ( Other.IsA('Amplifier')&&bdamage )
{
  bRetVal = true;
  }
  else if ( Other.IsA('osKevlarSuit')&&bpad )
  {
    bRetVal = true;
  }
  else if ( Other.IsA('nalifruit')&&bmed )
  {
    bRetVal = true;
  }

  else if ( Other.IsA('Health')&&bmed )
  {
    bRetVal = true;
  }

/*else if ( Other.IsA('invisibility')&&binvis )
  {
    bRetVal = true;
  } */

  else if ( NextMutator != None )           //yawn....
  {
    bRetVal = class'UTC_Mutator'.static.UTSF_AlwaysKeep(NextMutator, Other);
  }
  return bRetVal;
}
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{ local name WeaponName, AmmoName, quadname, quadammoname;
local string WeaponString, AmmoString;
    bSuperRelevant = 0;
    if (arenamode>0){ //launch arena handler :D
    switch (arenamode){ //gotta love 'em switches.....
    case 1:
    weaponname='oldpistol';
    ammoname='defaultammo';
    weaponstring="olweapons.oldpistol";
    ammostring="olWeapons.osDispersionpowerup";
    break;
     case 2:
    weaponname='olautomag';
    ammoname='shellbox';
    weaponstring="olweapons.olautomag";
    ammostring="UnrealShare.Shellbox";
    break;
     case 3:
     weaponname='olstinger';
    ammoname='StingerAmmo';
    weaponstring="olweapons.olstinger";
    ammostring="UnrealShare.StingerAmmo";
    break;
     case 4:
    weaponname='olasmd';
    ammoname='ASMDammo';
    weaponstring="olweapons.olasmd";
    ammostring="UnrealShare.ASMDAmmo";
    break;
     case 5:
    weaponname='oleightball';
    ammoname='RocketCan';
    weaponstring="olweapons.oleightball";
    ammostring="UnrealShare.RocketCan";
    break;
     case 6:
    weaponname='olflakcannon';
    ammoname='Flakbox';
    weaponstring="olweapons.olflakcannon";
    ammostring="UnrealI.FlakBox";
    break;
     case 7:
    weaponname='olrazorjack';
    ammoname='Razorammo';
    weaponstring="olweapons.olrazorjack";
    ammostring="UnrealI.RazorAmmo";
    break;
     case 8:
    weaponname='olgesbiorifle';
    ammoname='sludge';
    weaponstring="olweapons.olgesbiorifle";
    ammostring="UnrealI.Sludge";
    break;
     case 9:
    weaponname='olrifle';
    ammoname='RifleAmmo';
    weaponstring="olweapons.olrifle";
    ammostring="UnrealI.RifleAmmo";
    break;
     case 10:
    weaponname='olminigun';
    ammoname='shellbox';
    weaponstring="olweapons.olminigun";
    ammostring="UnrealShare.Shellbox";
    break;
     case 11:
    weaponname='olquadshot';
    ammoname='olshells';
    weaponstring="olweapons.olquadshot";
    ammostring="olweapons.olshells";
    break;
         case 12:
    if (bmag){                //only option that means ANYTHING in arena mode....
    weaponname='olsmmag';
    ammoname='osmagammo';
    weaponstring="olweapons.olsmmag";
    ammostring="olweapons.osmagammo"; }
    else{
    weaponname='olsmenf';
    ammoname='osmagammo2';
    weaponstring="olweapons.olsmenf";
    ammostring="olweapons.osmagammo2"; }
    break;
     }
    if ( Other.IsA('Weapon') )
  {
    if ( !Other.IsA(WeaponName))
    {
      Level.Game.bCoopWeaponMode = false;
      ReplaceWith(Other, WeaponString);
      return false;
    }
  }

  if ( Other.IsA('Ammo') )
  {
    if (!Other.IsA(AmmoName))
    {
      ReplaceWith(Other, AmmoString);
      return false;
    }
  }}
  else if (level.game.isa('lastmanstanding')&&Other.Isa('ammo')&&Other.location!=Vect(0,0,0))    //emulate non-arena mode...
    return false;
    if (quadmode>1){
    switch (quadmode){
    case 2:
    quadname='enforcer';
    quadammoname='eclip';
    break;
    case 3:
    quadname='pulsegun';
    quadammoname='pammo';
    break;
    case 4:
    quadname='shockrifle';
    quadammoname='shockcore';
    break;
    case 5:
    quadname='ut_eightball';
    quadammoname='rocketpack';
    break;
    case 6:
    quadname='ut_flakcannon';
    quadammoname='flakammo';
    break;
    case 7:
    quadname='ripper';
    quadammoname='bladehopper';
    break;
    case 8:
    quadname='ut_biorifle';
    quadammoname='bioammo';
    break;
    case 9:
    quadname='sniperrifle';
    quadammoname='bulletbox';
    break;
    case 10:
    quadname='minigun2';
    quadammoname='miniammo';
    break;
    case 11:
    quadname='warheadlauncher';
    quadammoname='warhadammo';
    break;
    }
    if (Other.Isa(quadname)) {    //first verifications......
    Replaceweapon( Other, class'olweapons.olquadshot', pawn(Other.owner) );
      return false;           }
    if (Other.Isa(quadammoname)&&Other.Location != vect(0,0,0)&&Other.owner==None) {
    Replacewith( Other, "olweapons.olshells" );
      return false;           }
    }
    if (Other.Isa('Uiweapons'))
    return true;
    if (other.isa('tournamentweapon'))  {
    if (Other.IsA('PulseGun')&&!other.isa('ospulsegun'))

    {
      if (bstingy) {
      Replaceweapon(Other, class'olweapons.olstinger', pawn(Other.owner));
      return false; }
      else if (bdamage){
      Replaceweapon(Other, class'olweapons.ospulsegun', pawn(Other.owner));
      return false;     }
      else
      return true;
    }
    if ( Other.IsA('SniperRifle')&&bRifle )
    {
      Replaceweapon( Other, class'olweapons.olrifle', pawn(Other.owner) );
      return false;
    }
    if ( Other.IsA('Ripper')&&bRazor )
    {
      Replaceweapon( Other, class'olweapons.olrazorjack', pawn(Other.owner) );
      return false;
    }
    if ( Other.IsA('Minigun2')&&bMini )
    {
      Replaceweapon( Other, class'olweapons.olMinigun', pawn(Other.owner) );
      return false;
    }
    if ( Other.IsA('Enforcer')&&bMag )
    {
      Replaceweapon( Other, class'olweapons.olautomag',pawn(Other.owner) );
      return false;
    }
    if ( Other.IsA('UT_Eightball')&&bEball )
    {
       Replaceweapon( Other, class'olweapons.olEightball', pawn(Other.owner) );
      return false;
    }
    if ( Other.IsA('UT_FlakCannon')&&bFlak )
    {
       Replaceweapon( Other, class'olweapons.olFlakCannon', pawn(Other.owner) );
      return false;
    }
    if ( Other.IsA('ShockRifle')&&!Other.IsA('superShockRifle')&&!other.isa('osshockrifle'))
    {
      if (basmd){
      Replaceweapon( Other, class'olweapons.olasmd', pawn(Other.owner) );
      return false;}
      else if (bdamage){
      Replaceweapon( Other, class'olweapons.osshockrifle', pawn(Other.owner) );
      return false;}
      else
      return true;
    }
      if ( Other.IsA('SuperShockRifle')&&bASMD )     //if owner had shock rifle at start it would be fawked anyway....
    {
      ReplaceWith( Other, "olweapons.olasmd");
      ReplaceWith( Other, "olweapons.osamplifier");
      return false;
    }

    if ( Other.IsA('UT_BioRifle')&&bBioRifle )
    {
      Replaceweapon( Other, class'olweapons.olGESBioRifle', pawn(Other.owner) );
      return false;
    }
    if ( Other.IsA('impacthammer')&&bPistol )       //default weapon wouldn;t be called :D
    {
      ReplaceWith( Other, "olWeapons.osDispersionPowerUp");
      return false;
    }
    if ( Other.IsA('chainsaw') &&bPower)
    {
      ReplaceWith( Other, "olWeapons.osDispersionPowerUp");
      return false;
    }

if ( Other.IsA('WarheadLauncher'))
    {
      If (redeemmode==1){
      ReplaceWith( Other, "olweapons.olasmd" );
      ReplaceWith( Other, "unrealshare.amplifier" );
      return false; }
      else if (redeemmode==2){
      if (!bmag)
      Replaceweapon( Other, class'olweapons.olSMmag', pawn(Other.owner));
      else
      Replaceweapon( Other, class'olweapons.olSMenf', pawn(Other.owner) );
      return false; }
    return true;
    }
    return true;}
   if (other.isa('tournamentammo'))       //second part ensures that ammo in guns is not replaced....
   {
    if ( Other.IsA('ShockCore'))
    {
      if (basmd){
      ReplaceWith( Other, "unrealshare.asmdammo" );
      return false;}
      else{
      shockcore(other).icon=Texture'UnrealShare.Icons.I_ASMD';
      return true;}
    }
    if ( Other.IsA('RocketPack'))
    {
      If (beball){
      ReplaceWith( Other, "unrealshare.RocketCan" );
      return false;}
      else {
      RocketPack(Other).UsedInWeaponSlot[5]=0;
      RocketPack(Other).UsedInWeaponSlot[9]=1;
      RocketPack(Other).Icon=Texture'UnrealShare.Icons.I_RocketAmmo';
      return true;}
    }
    if ( Other.IsA('PAmmo') )
    {
      if (bstingy){
      ReplaceWith(Other, "unrealshare.stingerAmmo");
      return false; }
      else{
      Pammo(Other).UsedInWeaponSlot[3]=0;
      Pammo(Other).UsedInWeaponSlot[5]=1;
      Pammo(Other).Icon=Texture'pulseicon';       //ph34r |\/|y 1c0|\| |\/|4k1|\|9 5k1llz!!!!!!!
      return true;}
    }
    if ( Other.IsA('BladeHopper'))
    {
      if (brazor){
      ReplaceWith( Other, "unreali.razorammo" );
      return false;}
      else{bladehopper(other).UsedInWeaponSlot[7]=0;
bladehopper(other).UsedInWeaponSlot[6]=1;
bladehopper(other).Icon=Texture'UnrealI.Icons.I_RazorAmmo';
      return true;
    }
    }
    if ( Other.IsA('RifleShell'))
    {
      if (brifle){
      ReplaceWith( Other, "unreali.Rifleround" );
      return false; }
      else{
      bulletbox(other).UsedInWeaponSlot[9]=0;             //already has icon..... good epic :D
        bulletbox(other).UsedInWeaponSlot[0]=1;
      return true;}
    }
    if ( Other.IsA('BulletBox')&&!Other.Isa('Rifleshell'))
    {
      if (brifle){
      ReplaceWith( Other, "unreali.rifleAmmo" );
      return false;}
      else{bulletbox(other).UsedInWeaponSlot[9]=0;
        bulletbox(other).UsedInWeaponSlot[0]=1;
      return true;}
    }
    if ( Other.IsA('FlakAmmo'))
    {
      if (bflak){
      ReplaceWith( Other, "unreali.FlakBox" );
      return false;}
      else{
      flakammo(other).UsedInWeaponSlot[6]=0;
    flakammo(other).UsedInWeaponSlot[8]=1;
    flakammo(other).Icon=Texture'UnrealI.Icons.I_FlakAmmo';
      return true;}
    }
    if ( Other.IsA('EClip'))
    {
      if (bmag&&Other.Location!= vect(0,0,0)&&Other.owner==None){
      ReplaceWith( Other, "unrealshare.Clip" );
      return false; }
      else{
       miniammo(other).UsedInWeaponSlot[0]=0;
 miniammo(other).UsedInWeaponSlot[7]=1;
 miniammo(other).Icon=Texture'UnrealShare.Icons.I_ShellAmmo';
      return true;}
    }
    if ( Other.IsA('MiniAmmo')&&!Other.Isa('eclip')&&!Other.Isa('osmagammo2'))
    {
      if (bmini&&Other.Location!= vect(0,0,0)&&Other.owner==None){
      ReplaceWith( Other, "unrealshare.ShellBox" );
      return false;   }
      else{
       miniammo(other).UsedInWeaponSlot[0]=0;
 miniammo(other).UsedInWeaponSlot[7]=1;
 miniammo(other).Icon=Texture'UnrealShare.Icons.I_ShellAmmo';
      return true;}
    }
    if ( Other.IsA('Bioammo'))
    {
      if (bBioRifle){
      ReplaceWith( Other, "unreali.Sludge" );
      return false;  }
      else {bioammo(other).UsedInWeaponSlot[8]=0;
bioammo(other).UsedInWeaponSlot[3]=1;
bioammo(other).Icon=Texture'UnrealI.Icons.I_SludgeAmmo';
    return true;}

 }
 if (Other.IsA('Ammo') && !Other.IsA('TournamentAmmo'))
 {     //fix up this stuff.....
    if (Ammo(Other).PickupSound == Sound'UnrealShare.Pickups.AmmoSnd')
        Ammo(Other).PickupSound = Sound'BotPack.Pickups.AmmoPick';
    if (UTC_Ammo(Other) != none)
        UTC_Ammo(Other).PickupMessageClass = Class'BotPack.PickupMessagePlus';
 }
 return true;}

  if ( Other.IsA('UT_JumpBoots')&&!Other.IsA('osjumpBoots')&&bJump )
  {

    ReplaceWith( Other, "olweapons.osJumpBoots" );
    return false;
  }
  if ( Other.IsA('UDamage')&&bdamage )
  {
    ReplaceWith( Other, "olweapons.osAmplifier" );
    return false;
  }

  if ( Other.IsA('ThighPads'))
  {
    if (bpad){
    ReplaceWith( Other, "olweapons.osKevlarSuit");
    return false; }
    else{
    thighpads(other).Icon=Texture'UnrealShare.Icons.I_kevlar'; //to stop confusion :D
return true;}
  }
  if ( Other.IsA('HealthPack')&&bmegahealth )
  {
    ReplaceWith( Other, "unrealshare.SuperHealth" );
    return false;
  }
  if ( Other.IsA('Armor2')&&!Other.Isa('olarmor'))
  {
    if (barmor){
    ReplaceWith( Other, "olweapons.olArmor" );
    return false;}
    else{
    armor2(other).Icon=Texture'UnrealShare.Icons.I_Armor';
    return true;}
  }
  if ( Other.IsA('HealthVial')&&bbandaid )
  {
    ReplaceWith( Other, "Unrealshare.Bandages" );
    return false;
  }
  if ( Other.IsA('Medbox')&&bmed )
  {
    ReplaceWith( Other, "unrealshare.health" );
    return false;
  }
  if ( Other.IsA('UT_ShieldBelt')&&!Other.IsA('osShieldBelt'))
  {
    If (shieldmode==2){
    ReplaceWith( Other, "olweapons.osPowerShield" );
    return false; }
    else If (shieldmode==1){
    ReplaceWith( Other, "olweapons.osShieldbelt" );
    return false; }
    else
    return true;
  }
  if ( Other.IsA('UT_invisibility')&&binvis )
  {
    ReplaceWith( Other, "olweapons.oldskoolinvisibility" );
    return false;
  }

     return true;
  }
function PreBeginPlay() {
  local class<UIweapons> weaponclass;
  local string oldservername;
  if ( (Level != None) && (Level.Game != None)&& (Level.Game.GameReplicationInfo != None)&& (Level.NetMode != NM_Client))       //modify server name, so it says -oldskool-
  {
    oldservername = Level.Game.GameReplicationInfo.Default.ServerName;
    if (InStr(oldservername,"-oldskool- ")==-1) //not already changed
    Level.Game.GameReplicationInfo.Default.ServerName="-oldskool- "$oldservername;   ///now change name...
  }
 /* if (bhud&&!level.game.isa('rocketarenagame'))                                  //notifications destroy hud when it's spawned and put new one in.. faster then actually destroying it in postbegin play, as saves calling hundreds of hud functions
  spawn (class'oldskool.oldhudnotify');
  if (bscorebored&&!level.game.isa('rocketarenagame'))
  spawn (class'oldskool.oldboardnotify');   */ // Psychic_313: wasn't me, UsAaR did this I think
  if (arenamode>0){
  switch (arenamode){ //gotta love 'em switches.....
    case 1:
    weaponclass=class'olweapons.oldpistol';
     break;
     case 2:
    weaponclass=class'olweapons.olautomag';
    break;
     case 3:
    weaponclass=class'olweapons.olstinger';
    break;
     case 4:
    weaponclass=class'olweapons.olasmd';
    break;
     case 5:
    weaponclass=class'olweapons.oleightball';
    break;
     case 6:
    weaponclass=class'olweapons.olflakcannon';
    break;
     case 7:
     weaponclass=class'olweapons.olrazorjack';
     break;
     case 8:
     weaponclass=class'olweapons.olgesbiorifle';
       break;
     case 9:
     weaponclass=class'olweapons.olrifle';
        break;
     case 10:
     weaponclass=class'olweapons.olminigun';
     break;
     case 11:
    weaponclass=class'olweapons.olquadshot';
     break;
         case 12:
    if (bmag)                //only option that means ANYTHING in arena mode....
    weaponclass=class'olweapons.olsmmag';
    else
    weaponclass=class'olweapons.olsmenf';
    break;
     }  }
     //DefaultWeapon=class'olweapons.olDPistol';}
  else if (quadmode==1&&!level.game.isa('rocketarenagame'))
  weaponclass=class'olweapons.olquadshot';
  else if(bPistol&&!level.game.isa('rocketarenagame'))
    weaponclass=class'olweapons.olDPistol';
    defaultweapon=weaponclass; //set the var.....
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
   //if (a.isa('olautomag')&&bmini) //set ammo types right....


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
    A = Spawn(aClass,,Other.tag,Other.Location, Other.Rotation);
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
     bmed=True
     bPistol=True
     bMag=True
     bBioRifle=True
     bASMD=True
     bStingy=True
     bRazor=True
     bFlak=True
     bEball=True
     BRifle=True
     bSuperASMD=True
     bPower=True
     bdamage=True
     bmegahealth=True
     binvis=True
     bdefauto=True
     bpowerups=True
     bscorebored=True
     shieldmode=2
     redeemmode=1
     quadmode=8
     maxpowerups=6
     poweruptime=17
}
