// ===============================================================
// SevenB.SevenPack: ol info desc.
// for Seven Bullets
// ===============================================================

class SevenBPack expands mappack;

#exec OBJ LOAD FILE="SevenBResources.u" PACKAGE=SevenB

var () string MapTitles[14];  //titles of map. file name is arraynum

defaultproperties
{
     MapTitles(0)="Seven Bullets"
     MapTitles(1)="Infiltration of the Kran"
     MapTitles(2)="The Rogue"
     MapTitles(3)="Slight Complication"
     MapTitles(4)="Familiar Odds"
     MapTitles(5)="The Lost Passage of Vandora"
     MapTitles(6)="The Guardian of Vandora's Pass"
     MapTitles(7)="Tension at Vandora's Temple"
     MapTitles(8)="The Situation at Noork's Elbow"
     MapTitles(9)="Beneath the Terraniux"
     MapTitles(10)="The Dead Scorpions"
     MapTitles(11)="Unfinished Business"
     MapTitles(12)="The Ghost of Oraghar"
     MapTitles(13)="Departure"
     spgameinfo="SevenB.tvsp"
     coopgameinfo="SevenB.tvcoop"
     creditswindow=Class'SevenB.tvCreditsWindow'
     additionalmenu=Class'SevenB.TutMSGWin'
     Maps(0)=Jones-01-Deployment
     Maps(1)=Jones-02-Darkness
     Maps(2)=Jones-03-Power
     Maps(3)=Jones-04-Trench
     Maps(4)=Jones-05-Trench2
     Maps(5)=Jones-05-TemplePart2
     Maps(6)=Jones-05-TemplePart3
     Maps(7)=Jones-06-Vandora
     Maps(8)=Jones-07-Noork
     Maps(9)=Jones-08-Pirate
     Maps(10)=Jones-08-Pirate2
     Maps(11)=Jones-08-Pirate3
     Maps(12)=Jones-09-Scar
     Maps(13)=Jones-10-End
     Author="Team Phalanx"
     Title="Seven Bullets"
     Screenshot=Texture'SevenB.SevenBShot'
}
