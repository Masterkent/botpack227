// ============================================================
// olextras.teamvortex: Operation: Na Pali Info for OSA
// ============================================================

class teamvortex expands mappack;
//#exec TEXTURE IMPORT NAME=TVShot FILE=..\olextras\textures\napali][.pcx MIPS=OFF
#exec OBJ LOAD FILE="OlextrasResources.u" PACKAGE=olextras

var () string MapTitles[36];  //titles of map. file name is arraynum +1

defaultproperties
{
     MapTitles(0)="Prisoned"
     MapTitles(1)="Escape from the Skaarj Base"
     MapTitles(2)="The Betrayers Path"
     MapTitles(3)="Gore Mine Crossing - Entrance"
     MapTitles(4)="Gore Mine Crossing"
     MapTitles(5)="Skaarj Outpost Pt 1"
     MapTitles(6)="Skaarj Outpost Pt 2"
     MapTitles(7)="Lil' Spire"
     MapTitles(8)="Entering the Mercenary Base"
     MapTitles(9)="Mercenary Base"
     MapTitles(10)="Ride With Me"
     MapTitles(11)="Sharuk Crossing"
     MapTitles(12)="Thra Fortress"
     MapTitles(13)="The Lost Sanctuary of Kalishra Pt 1"
     MapTitles(14)="The Lost Sanctuary of Kalishra Pt 2"
     MapTitles(15)="Nali Mountain Fighters Pt 1"
     MapTitles(16)="Nali Mountain Fighters Pt 2"
     MapTitles(17)="The Vulcano"
     MapTitles(18)="Inside the Outpost"
     MapTitles(19)="Wipeout"
     MapTitles(20)="Entry to the Fire God Temple"
     MapTitles(21)="Fire God Temple"
     MapTitles(22)="The Lands Of Rostivelt"
     MapTitles(23)="Forgotten Gods"
     MapTitles(24)="The Old Nali Ruins"
     MapTitles(25)="Transport Failed"
     MapTitles(26)="Rostivelt Lake"
     MapTitles(27)="The Research Lab"
     MapTitles(28)="Entry to Rrajigar"
     MapTitles(29)="Skaarjmines of Rrajigar"
     MapTitles(30)="Nyleve Falls"
     MapTitles(31)="Vortex Rikers"
     MapTitles(32)="Prisoned Again"
     MapTitles(33)="Na Pali Heaven Pt 1"
     MapTitles(34)="Na Pali Heaven Pt 2"
     MapTitles(35)="The Escape"
     spgameinfo="olextras.tvsp"
     coopgameinfo="olextras.tvcoop"
     creditswindow=Class'olextras.tvCreditsWindow'
     additionalmenu=Class'olextras.TutMSGWin'
     Maps(0)=NP02DavidM
     Maps(1)=NP03Atje
     Maps(2)=NP04Hyperion
     Maps(3)=NP05Heiko
     Maps(4)=NP06Heiko
     Maps(5)=NP07Hourences
     Maps(6)=NP08Hourences
     Maps(7)=NP09Silver
     Maps(8)=NP10Tonnberry
     Maps(9)=NP11Tonnberry
     Maps(10)=NP12Tonnberry
     Maps(11)=NP13DrPest
     Maps(12)=NP14MClaneDrPest
     Maps(13)=NP15Chico
     Maps(14)=NP16Chico
     Maps(15)=NP17Chico
     Maps(16)=NP18Chico
     Maps(17)=NP19part1Chico
     Maps(18)=NP19part2Chico
     Maps(19)=NP19part3ChicoHour
     Maps(20)=NP20DavidM
     Maps(21)=NP21Atje
     Maps(22)=NP22DavidM
     Maps(23)=NP23Kew
     Maps(24)=NP24MClane
     Maps(25)=NP25DavidM
     Maps(26)=NP26DavidM
     Maps(27)=NP27DavidM
     Maps(28)=NP28DavidM
     Maps(29)=NP29DavidM
     Maps(30)=NP30DavidM
     Maps(31)=NP31DavidM
     Maps(32)=NP32Strogg
     Maps(33)=NP33Atje
     Maps(34)=NP34Atje
     Maps(35)=NP35mclane
     Maps(36)=NP36evolve
     Maps(37)=NPCredits2
     Maps(38)=NP01eVOLVE
     Maps(39)=NPTut
     Maps(40)=NP10inter
     Maps(41)=NP26inter
     Maps(42)=NPEntry
     Author="Team Vortex"
     Title="Operation: Na Pali"
     FlyBy="NpEntry.Unr"
     Screenshot=Texture'olextras.TVShot'
}
