// ============================================================
// OldSkool.Mappack:
// The main info class for all OldSkool Map packs
// Subclass Me to built a map pack.
// ============================================================

class Mappack expands Object
abstract
config (OldSkool);
//the following is already here (in defaults), but can be changed (I used it for Legacy and Team Vortex...probably PC's can use it too)
var () string spgameinfo, coopgameinfo;
//aditional menu (appears after you load the game), load menu, and save menu are not used at this time, but can be
//Creditswindow:  For a mod, you'd probably want to include this.  List the full name of the window.. currently used in Team Vortex, Legacy, and Unreal
var () class<Uwindowwindow> savemenu, loadmenu, creditswindow, additionalmenu, weaponwindowclass;
var () class<UWindowDialogClientWindow>  playerwindow;
      /*
The following MUST be assigned in a childclass...
maps: list maps to be filtered out (43 is the amount in Unreal and presumably the maximum amount ever found in an SP episode....)  I added 1 as it needs to be done to not overload the array, but the maximum amount of maps allowed IS 43!! Use the .UNR extension!!! include all maps played and the flyby (if applicable)
*/ var () name maps[44];     /*
author:  The Author's Name (for a true mod, I'd recommend a team name i.e DeCyber for Legacy, Epic/Digital Extremes for Unreal, and Team Vortex for Operation: Na Pali or whatever the hell they call it (ironically enough I'm on that team).
Title:  The Packs Title
flyby:  If your map pack has a flyby included (right now only Legacy, Ballad of Ash, and Unreal) included this variable.  If not don't include it in the defaults
basedir: if map is one of those screwy ones we set the base dir here.....
     */
var () string Author, Title, FlyBy, basedir;
//The screenshot wanted for the pack.... obvious what this is for...... you need to say packscreenshot=Texture'whatever' for this to work.  I HIGHLY recommend you put in an #exec texture import in your map list and have the defualts go to it.  Or it CAN always default to yourlevelname.screenshot
var () texture Screenshot;
//is loading notification relevent to pack?      (right now for TV it is)
var () bool loadrelevent;
//bloaded: if the load is relevent, then this will change upon loading games.....   a gametype or something is responsible for switching it off......       not meant to be set by a pack....
var config bool bLoaded;

defaultproperties
{
     spgameinfo="oldskool.singleplayer2"
     coopgameinfo="oldskool.coopgame2"
     savemenu=Class'olroot.OldSkoolSaveGameWindow'
     loadmenu=Class'olroot.OldSkoolLoadGameWindow'
     weaponwindowclass=Class'olroot.OldskoolWeaponPriorityWindow'
     playerwindow=Class'olroot.oldskoolPlayerSetupClient'
}
