// ===============================================================
// XidiaMPack.XidiaPack: ol info desc.
// for entire gold thing
// ===============================================================

class XidiaPack expands mappack;

#exec OBJ LOAD FILE="XidiaMPackResources.u" PACKAGE=XidiaMPack

var () string MapTitles[16];  //titles of map. file name is arraynum
var () int ExpStart; //where expansion pack starts (#)

defaultproperties
{
     MapTitles(0)="Orbit"
     MapTitles(1)="Landing"
     MapTitles(2)="Outpost Pheonix"
     MapTitles(3)="Mine"
     MapTitles(4)="Derelict Underground"
     MapTitles(5)="Derelict Surface"
     MapTitles(6)="Darklord"
     MapTitles(7)="Exodus"
     MapTitles(8)="Awakening"
     MapTitles(9)="Self Destruct"
     MapTitles(10)="Underground Railrod"
     MapTitles(11)="Return To Outpost Pheonix"
     MapTitles(12)="Dead Mines"
     MapTitles(13)="Genome Warriors"
     MapTitles(14)="Black Widow"
     MapTitles(15)="Beacon"
     ExpStart=9
     spgameinfo="xidiampack.tvsp"
     coopgameinfo="xidiampack.tvcoop"
     creditswindow=Class'XidiaMPack.tvCreditsWindow'
     additionalmenu=Class'XidiaMPack.TutMSGWin'
     Maps(0)=XidiaGold-Map1-Orbit
     Maps(1)=XidiaGold-Map2-Landing
     Maps(2)=XidiaGold-Map3-OutpostPheonix
     Maps(3)=XidiaGold-Map4-Mine
     Maps(4)=XidiaGold-Map5-Derelict-A
     Maps(5)=XidiaGold-Map6-Derelict-B
     Maps(6)=XidiaGold-Map7-Darklord
     Maps(7)=XidiaGold-Map8-Exodus
     Maps(8)=XidiaES-Map0-Awakening
     Maps(9)=XidiaES-Map1-SelfDestruct
     Maps(10)=XidiaES-Map2-Rail
     Maps(11)=XidiaES-Map3-ReOP
     Maps(12)=XidiaES-Map4-DeadMines
     Maps(13)=XidiaES-Map5-GenomeWarriors
     Maps(14)=XidiaES-Map6-BlackWidow
     Maps(15)=XidiaES-Map7-Beacon
     Maps(16)=XidiaES-Map8-Extro
     Author="Team Phalanx"
     Title="Xidia Gold"
     Screenshot=Texture'XidiaMPack.XiShot'
}
