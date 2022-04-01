// ============================================================
// OLweapons.UIweapons: really a dummy class... defines 1 var (decals) but mainly helps the mutator
// Psychic_313: unchanged
// This is the main config class - note for menu making
// ============================================================

class UIweapons expands TournamentWeapon
config (oldskool)
abstract;

var config bool bUseDecals;  //decals option
var config bool akimbomag; //akimbo mag option (here to look neater in INI's..
var config bool newarmorrules; //new armor rules (i.e. limit at 150 armor)
//the following vars do nothing, but removing them may break binary compatibility.
var bool bwantreload;
var bool wepcanreload;

replication
{
  reliable if (Role < Role_Authority) //client send to server....
    reload, stopreload;
}

function SetSwitchPriority(pawn Other)         //allow weapon to register in first 20....
{
  local int i;
  local name temp, carried;

  if ( PlayerPawn(Other) != None )
  {
    for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == class.name )
      {
        AutoSwitchPriority = i;
        return;
      }
    // else, register this weapon
    carried = class.name;
    for ( i=AutoSwitchPriority; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++ )
    {
      if (( PlayerPawn(Other).WeaponPriority[i] == '' ) || ( PlayerPawn(Other).WeaponPriority[i] == 'None' )) //little bug pops up sometimes....
      {
        PlayerPawn(Other).WeaponPriority[i] = carried;
        return;
      }
      else if ( i<ArrayCount(PlayerPawn(Other).WeaponPriority)-1 )
      {
        temp = PlayerPawn(Other).WeaponPriority[i];
        PlayerPawn(Other).WeaponPriority[i] = carried;
        carried = temp;
      }
    }
  }
}
/*
//client to server reloading functions...
exec function reload()
{ //call the exec function (var failed to replicate to server continuously.......
  if (pawn(owner)!=none&&pawn(owner).weapon==self)
  bwantreload=true;
}

exec function stopreload()
{
  if (pawn(owner)!=none&&pawn(owner).weapon==self)
  bwantreload=false;
}        */

//new replicated versions for OSA 2.25
//now set pawn(owner).bextra3
function tick(float delta){    //server bextra 3 updater:    (bshadowcast is unused anyway.)
  if (role<role_authority&&playerpawn(owner)!=none&&bool(pawn(owner).bextra3)!=owner.bShadowCast){
    owner.bshadowcast=!owner.bshadowcast;
    if (owner.bshadowcast) //now reload
      reload();
    else
      stopreload();
  }
}


function reload(){
  pawn(owner).bextra3=1;
  pawn(owner).weapon.tick(0.0); //force tick to reload if needed...
}
function stopreload(){
  pawn(owner).bextra3=0;
}

defaultproperties
{
     bUseDecals=True
     akimbomag=True
     bSpecialIcon=True
}
