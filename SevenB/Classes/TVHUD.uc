// ============================================================
// SevenB.TVHUD: 7Bullets (Xidia) HUD.
// less stuff than old unreal hud.. oh well.
// ============================================================

class TVHUD expands oldskoolHUD;

/////////////////////////////////
//// NEW XIDIA HUD GRAPHICS ///////////
/////////////////////////////////

//Items (64x64 images):
#exec OBJ LOAD FILE="SevenBResources.u" PACKAGE=SevenB

//Weapon Pictures (HUD Base w/ all weapons shown)  //128x64  add ripper?  WHERE IS DPISTOL?
//full ammo:

//#exec TEXTURE IMPORT NAME=ChainsawF FILE=hud\Chainsaw.PCX GROUP="Icons" MIPS=OFF FLAGS=2

//#exec TEXTURE IMPORT NAME=bioF FILE=hud\bio.PCX GROUP="Icons" MIPS=OFF FLAGS=2

//#exec TEXTURE IMPORT NAME=stingF FILE=hud\stinger.PCX GROUP="Icons" MIPS=OFF FLAGS=2
//empty:

//#exec TEXTURE IMPORT NAME=stingE FILE=hud\empty_stinger.PCX GROUP="Icons" MIPS=OFF FLAGS=2
//#exec TEXTURE IMPORT NAME=bioE FILE=hud\empty_bio.PCX GROUP="Icons" MIPS=OFF FLAGS=2

//missing: (not in inv yet)

//#exec TEXTURE IMPORT NAME=ChainsawN FILE=hud\no_Chainsaw.PCX GROUP="Icons" MIPS=OFF FLAGS=2

//#exec TEXTURE IMPORT NAME=bioN FILE=hud\no_bio.PCX GROUP="Icons" MIPS=OFF FLAGS=2

//#exec TEXTURE IMPORT NAME=stingN FILE=hud\no_stinger.PCX GROUP="Icons" MIPS=OFF FLAGS=2
//Misc: (varying size)

//inv stuff:

//CrossHair: (gone now!)
//#exec OBJ LOAD FILE=..\Textures\ONPCrossHairs.utx PACKAGE=XidiaMPack.CrossHair

var bool blackout; //force black.
var TranslatorHistoryList TList;   //MOVED!!!! translator message history.
var float TransFlashTime;  //because the counter sux
var TVTranslator TVTranslator;
//used for pickup system
struct PickupInfo{
  var texture Icon; //icon of pickup
  var string text; //text of pickup
  var float ExpireTime; //time that message will expire
};
const WeapMult = 0.78769;
var PickupInfo Pickups[5]; //array of picked up items
var float Scale; //for multiple resolutions=stay constant HUD size.
var float PickupTime; //for stupid pickup thingy.
var actor Hit; //so only 1 trace a hit
var texture CrossHairTextures[21]; //loaded crosshairs
var bool bSSLRaised;  //if SSL is present, would interfere with pickup messages...
var float InvRightClip; //amount clip can be on right. (inv/pickups can block)
//var float MessageFadeTime; //controls speech area fading.
var byte OldPlayerMod; //controls HUD fade-in/out.
//HUD fade controls:
var float HUDFadeTime; //current fade-out time
var float HUDFadeMult; //multiply deltatime incrememnts by this.
var ERenderStyle NormalStyle; //translucent when fading.
//HUD config:
var globalconfig int TvCrosshair; //crosshair for ONP -> eh.. deprecated
var globalconfig bool bHideHUD;
var config bool bPixelHack; //for warped rendering.
//hack for UMS:
var HUD RealHUD;
//test:
var bool NoZBufHack;
var bool bShowHitZ;
//FPS saving variables (pre-multiplied on resolution change):
var float M3, M4, M5, M9, M11, M48, M64, M113, M128, M134, M156, M245, M256, M335, M15, M35;
var texture WeapIcons[30];  //weapon icon array. 0-9=full, 10-19=empty, 20-29=missing   no.. this isn't very extendable ;p

var globalconfig bool B227_bVerticalScaling;
var float B227_CrosshairScale;


/////////////////////////////////////////////////
// Icon grabbing functions:
/////////////////////////////////////////////////
static simulated function Texture FindItemIcon (class<inventory> inv){ //get actual icon for class.
//others:
  Switch (inv){
    Case class'Flare':
      return Texture'FlaresI';
    Case class'Flashlight':
      return Texture'FlashLightI';
    Case class'Seeds':
    case class'Rations':
      return Texture'SeedsI';
    case class'jumpboots':
    case class'ut_jumpboots':
    case class'Xidiajumpboots':
      return Texture'JumpBootsI';
    case class'ScubaGear':
      return Texture'ScubaI';
    Case class'SearchLight':
      return Texture'FlashLightI';
    Case class'Translator':
      return Texture'TransI';
  }
  return inv.default.Icon;
}
/////////////////////////////////////////////
// Drawing Functions:
/////////////////////////////////////////////
simulated function DrawONPIconValue(Canvas Canvas, int Amount)
{
  local float TempX,TempY;
  local float Xl, Yl;
  TempX = Canvas.CurX;
  TempY = Canvas.CurY;
  Amount++;
  Canvas.Font = MyFonts.GetSmallFont(B227_ScaledFontScreenWidth(Canvas));
  Canvas.StrLen(Amount,Xl,Yl);
  Canvas.SetPos(fmax(Canvas.CurX-Xl+M48,Canvas.CurX),Canvas.Cury-Yl+M48);
  Canvas.DrawText(Amount,False);
  Canvas.Font = Canvas.LargeFont;
  Canvas.CurX = TempX;
  Canvas.CurY = TempY;
}
//Draw Weapon function Modes:
// 0=normal
// 1=raised
// 2=selected (selected always lowest)
simulated function DrawWeaponIcon(Canvas Canvas, int Pos, byte Mode, float Ammo, optional bool Pending){
  local float Xl, Yl;
  local byte AddedArray;
  if (Ammo==0.0)
    AddedArray=10;
  else if (Ammo<-1.5)
    AddedArray=20;
  Ammo=Fclamp(Ammo,0,1);
  Canvas.SetPos(M335+(Pos-1)*M156,canvas.clipy-M134);
  Xl=Canvas.CurX;
  Yl=Canvas.CurY;
   Canvas.Style=NormalStyle;
   Canvas.SetPos(Xl,Yl);
   Canvas.DrawColor = WhiteColor;
   Canvas.DrawRect(Texture'wSlot',M156,M134);
  Xl+=M15;
  YL+=M35;
   Canvas.Style=ERenderStyle.STY_Translucent;
   Canvas.SetPos(Xl,Yl);
   if (Mode==2){
     Canvas.DrawRect(Texture'wSelect',M128*weapmult,M64*weapmult); //selected icon.
     Canvas.SetPos(Xl,Yl);
   }
   else if (Pending){ //if pending
     Canvas.DrawRect(Texture'weaponglowtex',M128*weapmult,M64*weapmult); //pending glows.
     Canvas.SetPos(Xl,Yl);
   }
   Canvas.DrawRect(WeapIcons[pos%10+AddedArray],M128*weapmult,M64*weapmult);
   if (Ammo==0){
     return;
   }
   Canvas.Style=NormalStyle;
   Canvas.SetPos(Xl,Yl);
    Canvas.DrawColor.G=Ammo*GreenColor.G;
    Canvas.DrawColor.R=RedColor.R-Canvas.DrawColor.G;
   if (Canvas.DrawColor.G<48)  //prevents excessive green..
     Canvas.DrawColor.G=max(0,2*Canvas.DrawColor.G-48);
   Canvas.DrawColor.B=0;
   Canvas.DrawTile(Texture'TvHudLine',M128*ammo*weapmult,weapmult*(M9-scale),0,0.5,32.0,2.0);
   Canvas.DrawColor = WhiteColor;
}
//used for armor and inv:
simulated function DrawChargeIcon(Canvas Canvas, float X, float Y, Inventory Item, optional bool bActivated)
{
  //-local float Ammo;
  if (Item.StatusIcon==Item.default.StatusIcon&&!Item.IsA('TvPickup'))
    Item.StatusIcon=FindItemIcon(Item.Class);
  if (Item.StatusIcon == none)
    return;
  Canvas.SetPos(X,Y);
  Canvas.Style=ERenderStyle.STY_Translucent;
  if (Item==PawnOwner.SelectedItem){
    Canvas.DrawRect(Texture'iSelect',M48,M48);
    Canvas.SetPos(X,Y);
  }
  if (bActivated)
    Canvas.DrawColor=TurqColor;
  Canvas.DrawRect(Item.StatusIcon,M48,M48);
  Canvas.Style=NormalStyle;
  Canvas.DrawColor=WhiteColor;
  Canvas.SetPos(X,Y);
  if (Item.IsA('Pickup')&&Pickup(Item).bCanHaveMultipleCopies)
     DrawONPIconValue(Canvas,Pickup(Item).NumCopies);
/*  else if (item.charge>0){
    Ammo=fmin(float(Item.Charge)/float(Item.Default.Charge),1);
//    Canvas.CurX += 1.51*M4;
    Canvas.CurY += 68*scale;
    Canvas.DrawColor.G=Ammo*GreenColor.G;
    Canvas.DrawColor.R=RedColor.R-Canvas.DrawColor.G;
    if (Canvas.DrawColor.G<48)  //prevents excessive green..
      Canvas.DrawColor.G=max(0,2*Canvas.DrawColor.G-48);
    Canvas.DrawColor.B=0;
    Canvas.DrawTile(Texture'TvHudLine',M48*Ammo,M4*1.51,0,0,32.0,2.0);
  }*/
  Canvas.DrawColor=WhiteColor;
}
simulated function HudSetup (Canvas Canvas){
  local float CurrentScale;

  Canvas.Reset();
  Super.HudSetup(Canvas);

  CurrentScale = B227_ScaledScreenWidth(Canvas) / 1536;
  if (Scale != CurrentScale){  //cache multipliers here
//    Scale=Canvas.ClipX/1950;  //lower icons are 1950 pixels long
    Scale = CurrentScale;
    M3=3*scale;
    M4=4*scale;
    M5=5*scale;
    M9=9*scale;
    M11=11*scale;
    M15=15*scale*weapmult;
    M35=35*scale*weapmult;
    M48=72*scale; //obfuscation?
    M64=64*scale;
    M113=113*scale;
    M128=128*scale;
    M134=weapmult*134*scale;
    M156=weapmult*156*scale;
    M245=245*scale;
    M256=256*Scale;
    M335=WeapMult*335*scale;
  }
  HudMode=0; //no HUD modes in ONP=force

  B227_CrosshairScale = class'UTC_HUD'.static.B227_CrosshairSize(Canvas, 1536);
}
simulated function float GetAmmo(Weapon W){
  if (W.AmmoType==None)
    return -1;
  else
    return float(W.AmmoType.AmmoAmount)/float(W.AmmoType.MaxAmmo);
}
simulated function DrawArmor(Canvas Canvas, int X, int Y, bool bDrawOne){  //Now used for armor and weapon icons!
local int ArmorAmount;
//local texture Icon;
local inventory Inv;
local int loops;
local byte taken[10];
local int i;
//hacks for 2 weapons in slot 5:
local weapon Sl5;
local float PaddingRight;

  if (PawnOwner.Weapon!=none){
    DrawWeaponIcon(Canvas,PawnOwner.Weapon.InventoryGroup,2,GetAmmo(PawnOwner.Weapon));
    taken[PawnOwner.Weapon.InventoryGroup-1]=1;
  }
  for( Inv=pawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory ){
    loops++;
    if (loops>1000) //infinite iterator!
      break;
    if ( TVTranslator(Inv) != None )   //grab it here.
      TVTranslator = TVTranslator(Inv);
    if (Inv.bIsAnArmor&&Inv.Charge>0){
      ArmorAmount+=Inv.Charge;
    }
    else if (Inv.IsA('Weapon')){
      if (level.netmode==nm_client)
       SetInvGroup(Inv);
      if (inv==PawnOwner.Weapon||taken[Inv.InventoryGroup-1]==1)
        Continue;
      if (Inv.InventoryGroup==5&&taken[4]==0){ //prioritize by ammo and pending weapon
					if ((level.netmode!=nm_client&&Inv==PawnOwner.PendingWeapon)){
			      DrawWeaponIcon(Canvas,Inv.InventoryGroup,0,GetAmmo(Weapon(Inv)),(level.netmode!=nm_client&&Inv==PawnOwner.PendingWeapon));
     				taken[4]=1;
     				continue;
					}
					if (Sl5==none||GetAmmo(Weapon(Inv))>GetAmmo(Sl5))
							Sl5=Weapon(Inv);
					continue;
			}
      DrawWeaponIcon(Canvas,Inv.InventoryGroup,0,GetAmmo(Weapon(Inv)),(level.netmode!=nm_client&&Inv==PawnOwner.PendingWeapon));
      taken[Inv.InventoryGroup-1]=1;
    }
  }
  //weapon 5 stuff:
  if (taken[4]==0&&Sl5!=none){
  	taken[4]=1;
		DrawWeaponIcon(Canvas,Sl5.InventoryGroup,0,GetAmmo(Sl5));
  }
	for (i=0;i<10;i++) //fill in empty weapons
    if (taken[i]==0)
      DrawWeaponIcon(Canvas,i+1,0,-2.0);
  PaddingRight = Canvas.SizeX - B227_ScaledScreenWidth(Canvas);
  Canvas.SetPos(Canvas.SizeX - M64 * weapmult - PaddingRight, Canvas.SizeY - M134);
  Canvas.Style=1;
  Canvas.DrawRect(Texture'bgpad', M64 + PaddingRight, M134);
  if (ArmorAmount>0){
    Canvas.SetPos(Canvas.clipx-235*scale,67*scale);
    Canvas.Font=MyFonts.GetBigFont(B227_ScaledFontScreenWidth(Canvas));
    Canvas.DrawColor=GreenColor;
    Canvas.DrawText(ArmorAmount);
    Canvas.DrawColor=WhiteColor;
  }
}
 /*
simulated function SetINvGroup (Inventory W){
  if (W.IsA('XidiaMinigun2')||W.IsA('olautomag'))
    return;
  if (W.InventoryGroup!=W.default.InventoryGroup)
    return;
  if (W.IsA('ChainSaw'))
    W.InventoryGroup=1;
  else if (W.IsA('OldPistol'))
    W.InventoryGroup=2;
  else if (W.IsA('olEightball'))
    W.InventoryGroup=9;
  else if (W.IsA('ut_biorifle'))
    W.InventoryGroup=1;
  else if (W.IsA('Ripper'))
    W.InventoryGroup=7;
  else if (W.IsA('olStinger'))
    W.InventoryGroup=5;
  else if (W.IsA('ut_flakcannon'))
    W.InventoryGroup=8;
}     */

function SetInvGroup(Inventory W)
{
	if (W.IsA('SevenChainGun'))
		W.InventoryGroup = 3;
	else if (W.IsA('SevenSniperRifle'))
		W.InventoryGroup = 6;
	else if (W.IsA('SBBloodRipper'))
		W.InventoryGroup = 7;
	else if (W.IsA('SevenCarRifle'))
		W.InventoryGroup = 10;
}

simulated function DrawHealth(Canvas Canvas, int X, int Y)      //render health icon + text
{
  local float per;
  Canvas.SetPos(Canvas.clipx-102*scale,67*scale);
  per=fclamp(float(pawnowner.health)/pawnowner.default.health,0.0,1.0);
  Canvas.DrawColor.G=per*GreenColor.G;
  Canvas.DrawColor.R=RedColor.R-Canvas.DrawColor.G;
  if (Canvas.DrawColor.G<48)  //prevents excessive green..
    Canvas.DrawColor.G=max(0,2*Canvas.DrawColor.G-48);
  Canvas.DrawColor.B=0;
  Canvas.Font=MyFonts.GetBigFont(B227_ScaledFontScreenWidth(Canvas));
  Canvas.DrawText(Max(0,PawnOwner.Health),False);
  Canvas.DrawColor=WhiteColor;
}

simulated function DrawAmmo(Canvas Canvas, int X, int Y)
{
  Canvas.Style=1;
  Canvas.SetPos(0,Canvas.clipy-240*scale*weapMult);
  //hack for b0rked OGL renderer
  Canvas.DrawTile( Texture'AmmoCount', M335, 240*scale*weapMult, 0, 0, Texture'AmmoCount'.USize, Texture'AmmoCount'.VSize+byte(bPixelHack));
  if (PawnOwner.Weapon==none)
    return;
  Canvas.Font=Myfonts.GetHugeFont(B227_ScaledFontScreenWidth(Canvas));
  Canvas.SetPos(75*scale,canvas.clipy-79*scale);
  if (PawnOwner.Weapon.AmmoType!=none)
    Canvas.DrawText(PawnOwner.Weapon.AmmoType.AmmoAmount,False);
  else
    Canvas.DrawText("INF",False);
  if (PawnOwner.Weapon.IsA('sevencarrifle')&&sevenCarRifle(PawnOwner.Weapon).bUseAlt){
    Canvas.SetPos(32*scale,canvas.clipy-99*scale);
    Canvas.Style=ERenderStyle.Sty_Translucent;
    Canvas.DrawRect(Texture'gAmmo',40*scale,40*scale);
    Canvas.Style=NormalStyle;
  }
}
/*
//used for pickup icon system:
simulated function LocalizedMessage( class<LocalMessage> lMessage, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString )
{
  local texture icon;
  local string text;
  super.LocalizedMessage(lmessage,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject,CriticalString);
  if (!classischildof(lmessage,class'PickupMessagePlus')||class<inventory>(optionalobject)==none)
    return; //who cares!
  if (lmessage==class'PickupMessageHealthPlus'){
    icon=Texture'HealthCross';
    text="+"$Class<TournamentHealth>(OptionalObject).Default.HealingAmount;
  }
  else
    text=class<inventory>(OptionalObject).default.itemname;
  if (class<OSDispersionPowerUp>(OptionalObject)!=none)
    return;
  if (text=="")
    text=GetItemName(string(OptionalObject));
  if (class<tvPickup>(OptionalObject)!=none)
    icon=class<tvPickup>(OptionalObject).default.StatusIcon;
  if (icon==none)
    icon=FindPkupIcon(class<inventory>(OptionalObject));
//  if (icon!=none)
  AddPickup(icon,text);
} */
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
  local int I;
if ((MsgType=='say' || msgtype=='teamsay')&& (pri.talktexture!=none||facetime<level.timeseconds)) //if no face, render, unless one is present.
  {
if (pri.team<4)
FaceTeam = TeamColor[PRI.Team];
FaceTexture = PRI.TalkTexture;
      FaceTime = Level.TimeSeconds + 3;
}
if (msg=="") return;
if (msgtype=='pickupmessageplus') //make pickupplus pickup.
msgtype='pickup';
  if (msgtype=='pickup'){
  currentpickup.lifetime=6+level.timeseconds;
  currentpickup.contents=msg;}
  else if (msgtype=='criticalevent'){
  if (tvtranslator!=none)
    tvtranslator.ForceDeactivate();
  criticalmessage.lifetime=6+level.timeseconds;
  criticalmessage.contents=msg;
  if (translator!=none&&translator.bcurrentlyactivated)
  translator.activatetranslator(false); } //shut off translator so message shows.
  else{   //main speech area (say, events, and deaths)
  for (i=2;i>-1;i--){    //move events down.
  if (shortmessages[i].contents!="")
  copyolmessage(shortmessages[i+1],shortmessages[i]);
  }
  shortmessages[0].type=msgtype;        //setup new message.
  shortmessages[0].contents=msg;
  shortmessages[0].PRI=PRI;
  if (tvplayer(playerowner)!=none&&tvplayer(playerowner).playermod==1)
    shortmessages[0].lifetime=19+level.timeseconds;
  else
    shortmessages[0].lifetime=6+level.timeseconds;
  }

}
simulated function SayMessage(coerce string Msg, float Time, PlayerReplicationInfo PRI){
  local int I;
  if (pri.talktexture!=none||facetime<level.timeseconds) //if no face, render, unless one is present.
  {
    if (pri.team<4)
      FaceTeam = TeamColor[PRI.Team];
    FaceTexture = PRI.TalkTexture;
    FaceTime = Level.TimeSeconds + 3;
  }
  if (msg=="")
    return;
  for (i=2;i>-1;i--){    //move events down.
    if (shortmessages[i].contents!="")
      copyolmessage(shortmessages[i+1],shortmessages[i]);
  }
  shortmessages[0].type='Say';        //setup new message.
  shortmessages[0].contents=msg;
  shortmessages[0].PRI=PRI;
  shortmessages[0].lifetime=fmax(Time,3)+level.timeseconds;
}
simulated function int FindHealthAmount(string Msg){ //parses health pickup string to return health amount
local int GoodNumber;
local int test;
local int i;
GoodNumber=-1;
for (i=1;i<len(msg);i++){
 // if (int(right(msg,i))!=0||mid(msg,len(msg)-i+1,1)=="0")
 test=asc(mid(msg,len(msg)-i,1));
 if (test>=0x30&&test<=0x39) //numeric
    GoodNumber=int(right(msg,i));
  else
    return GoodNumber;
}
return GoodNumber;
}
simulated function AddPickup (texture icon, string text){
local int i;
  PickupTime=Level.TimeSeconds; //crosshair
  for (i=3;i>-1;i--)
    CopyPickup(Pickups[i+1],Pickups[i]);
  Pickups[0].icon=icon;
  Pickups[0].Text=Text;
  Pickups[0].ExpireTime=level.timeseconds+4.3;
}

simulated function CopyPickup(out PickupInfo P1, PickupInfo P2)  //copying.
{
  P1.Icon = P2.Icon;
  P1.Text = P2.Text;
  P1.ExpireTime = P2.ExpireTime;
}
simulated function ClearPickup(out PickupInfo Pick)  //clearing.
{
  Pick.Icon = none;
  Pick.Text = "";
  Pick.ExpireTime=0;
}

//translator history moving (good thing execs are checked here first :)
exec function NextWeapon(){
  if (Tvtranslator!=none&&TVTranslator.bActive)
    TvTranslator.PrevHistory();
  else
    playerowner.NextWeapon();
}
exec function PrevWeapon(){
  if (TVTranslator!=none&&TVTranslator.bActive)
    TVTranslator.NextHistory();
  else
    playerowner.PrevWeapon();
}
//Client-side item stuff:
exec function ActivateItem()
{
  if( Level.Pauser!=""||tvPlayer(Owner).PlayerMod==1)
    return;
  if (TvPickup(PlayerOwner.SelectedItem)==None||!TvPickup(PlayerOwner.SelectedItem).ClientActivate())
    PlayerOwner.ActivateItem();
}
exec function ActivateTranslator()
{
  if (tvPlayer(Owner).PlayerMod!=1&&TvTranslator!=none)
    TvTranslator.ClientActivate();
}
//actual pickup drawing: (positions ripped from Legacy)
simulated function DrawInventory(Canvas Canvas, int X, int Y, bool bDrawOne)
{
local float Xf, Yf;
//-local int messages;
local int i;
local float TempX, Tempy;
local string tmp;

  Canvas.Reset();
  Canvas.bNoSmooth = true;

 // List Translator messages if activated
  if (TvTranslator!=None )
  {
    if(TvTranslator.bActive )
    {
      Canvas.bCenter = false;
      Canvas.Font = MyFonts.GetSmallFont(B227_ScaledFontScreenWidth(Canvas));
      TempX = Canvas.ClipX;
      TempY = Canvas.ClipY;
      CurrentMessage = TvTranslator.GetMessage();
      Canvas.Style = 2;
      Canvas.SetPos(Canvas.ClipX/2-256*scale, Canvas.ClipY/2-256*scale);
      Canvas.DrawIcon(texture'Newtrans', 2.0*scale);
      Canvas.DrawColor=GreenColor;
      Canvas.SetOrigin(Canvas.ClipX/2-220*scale,Canvas.ClipY/2-224*scale);
      Canvas.SetClip(450*scale,440*scale);
      Canvas.SetPos(0,0);
      Canvas.Style = 1;
      Canvas.StrLen("a",Xf,Yf); //get vertical offset.
      tmp=CurrentMessage;
      while (tmp!=""){
        i=instr(tmp,chr(13));
        if (i!=-1)
          CurrentMessage=left(tmp,i);
        else
          CurrentMessage=tmp;
        Canvas.DrawText(CurrentMessage, False);
        if (i==-1)
          break;
        tmp=mid(tmp,i+1);
        Canvas.CurX=0; //reset cursor. preserve curY.
      }
      Canvas.ClipX = TempX;
      Canvas.ClipY = TempY;
      HUDSetup(canvas);
//      CurrentMessage = Translator.NewMessage;
    }
    else
      bFlashTranslator = (TvTranslator.bNewMessage || TvTranslator.bNotNewMessage );
  }
if (TransFlashTime<=Level.TimeSeconds-0.75) //translator timer
  TransFlashTime=Level.TimeSeconds+0.25;
Canvas.Style=2;
DrawMainInventory(canvas); //main ONP inv stuff.
Canvas.Style=2;
TempX=Canvas.ClipX;
Yf=M64;
//playerpawn(owner).clientmessage("message count is"@messages);
if (tempx<InvRightClip)
  InvRightClip=tempx;
}
//special function when player takes damage, fires, etc.
function DeActivateTranslator(){
  if (TvTranslator!=none)
    TvTranslator.ForceDeactivate();
}

//other HUD stuff:
simulated function PostBeginPlay()      //set to 5...
{
  FaceAreaOffset = -64;
  if(tvplayer(owner)!=none && tvplayer(owner).linfo != none && (tvplayer(owner).linfo.bcutscene||tvplayer(owner).linfo.bjet))  //verify the gametypes and set accordingly..
    nohud=true;
  MyFonts = spawn(Class'Botpack.FontInfo');    //load fonts...
  if (tvsp(level.game)==none){ //coop
    MOTDFadeouttime = 255;
    return;
  }
  OldPlayerMod=tvplayer(owner).PlayerMod;
  if (tvsp(level.game).bloadingsave) //this vaid?
    MOTDFadeOutTime = 0.1;                 //has to be a number to call it.... but no biggie..
  else if (nohud)
    MOTDFadeOutTime=0.55;
  else
 /* if ( nohud)    //this designates the map as a intermission (i.e flyby)
  MOTDFadeOutTime = 1.1;
  else*/
//  MOTDFadeOutTime = 5.5;  }
    MOTDFadeOutTime=1;
}
function PreRender( Canvas Canvas )
{
 // if (playerpawn(owner).player==none||playerpawn(owner).player.console==none||!playerpawn(owner).player.console.bnodrawworld)
 // return; //useless
 // if (windowconsole(playerpawn(owner).player.console).bUWindowActive||MOTDFadeOutTime==0)  //no switch off.
  if (blackout){
    canvas.setpos(0,0);
    Canvas.DrawTile( texture'BlackTexture', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256 );
  }
  if (motdfadeouttime>0&&tvsp(level.game)!=none&&tvtranslator!=none) //force trans off.
    tvTranslator.ForceDeactivate();
//  else // switch off!
//   playerpawn(owner).player.console.bnodrawworld=false;
  Super(HUD).PreRender(Canvas);
}

simulated function postrender(canvas canvas){  //Ship speed.
local byte btemp, i;
  if (RealHUD!=none){
    RealHUD.PostRender(Canvas);
    DrawUnrealMessages(Canvas);     //hack
    return;
  }
  HudSetup(canvas);
  InvRightClip=Canvas.ClipX;  //reset stuff
  bSSLRaised=false;
  //detect playermod changes:
  if (tvplayer(owner).playermod%2!=oldplayermod){
     oldplayermod=tvplayer(owner).playermod%2;
     HUDFadeMult=3;
     if (oldplayermod==1)
       HUDFadeTime=1; //fade out
     else{
      for (i=0;i<4;i++) //clear messages
        if (shortmessages[i].lifetime>level.timeseconds+1)
          shortmessages[i].lifetime=level.timeseconds+1;
      HUDFadeTime=-1.0; //fade in
    }
  }
  nohud = (bHideHUD ||
    tvplayer(owner) != none && tvplayer(owner).linfo != none && (tvplayer(owner).linfo.ForceNoHUD||(tvplayer(owner).PlayerMod==1&&HUDFadeTime==0)
    ||(MOTDFadeOutTime>0&&tvsp(level.game)!=none)));
  if (!nohud){
    if (!NoZBufHack)
      Canvas.DrawActor( self, false, true); //clears z buffer, so no weapons overlap HUD
    GetHit();
  }
  else{
    ArmorOffset=0;
    if ( PlayerPawn(Owner).ProgressTimeOut > Level.TimeSeconds ) //oldskool glitch
      DisplayProgressMessage(Canvas);
    if (pawnowner.isinstate('PlayerShip'))
       DrawHealth(canvas,0,0);
  }
  if (blackout){
    canvas.setpos(0,0);
    Canvas.DrawTile( texture'BlackTexture', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256 );
    Tlist=none;
    nohud=true;
  }
  if (pawnowner.isinstate('PlayerShip'))   //render it here
    message(pawnowner.playerreplicationinfo,int(pawnowner.airspeed)@"KM/H",'pickup'); //show message w/out console.
  if ( nohud&&PlayerPawn(Owner).bShowScores )
    {
    if ( PlayerPawn(Owner).bShowMenu )       //will end up going to uwindow (only called in sp mode)..
    {
      DisplayMenu(Canvas);
      return;
    }
        if ( (PlayerPawn(Owner).Scoring == None) && (PlayerPawn(Owner).ScoringType != None) )
        PlayerPawn(Owner).Scoring = Spawn(PlayerPawn(Owner).ScoringType, PlayerPawn(Owner));
      if ( PlayerPawn(Owner).Scoring != None )
      {
        armoroffset=0;
        hudsetup(canvas);
        PlayerOwner.Scoring.OwnerHUD = self;
        PlayerPawn(Owner).Scoring.ShowScores(Canvas);
        DrawTypingPrompt(Canvas, playerpawn(owner).player.Console); //allow typing to show.
        Canvas.Style=ERenderStyle.STY_Masked;
        return;
      }
    }
/*  if (nohud){        //hack
    if ( showtalkface && !PlayerOwner.bShowScores)
      bDrawFaceArea = (FaceTexture != None) && (FaceTime > Level.TimeSeconds);
    if ( bDrawFaceArea ){
      DrawTalkFace( Canvas, 0 );
    }
    else {
      facemsgset=0; //ensure it is 0.......
      faceareaoffset=-64;
    }
  }
  */
  super.postrender(canvas);
  //set keys to old values
  if (tvplayer(playerowner).playermod==2){
    btemp=playerowner.bfire;
    playerowner.bfire=playerowner.baltfire;
    playerowner.baltfire=btemp;
  }
  hudmode=default.hudmode; //configuration stuff...
  Canvas.Style=ERenderStyle.STY_Masked;
}
 //swaps as motd tick is changed......
simulated function Tick(float DeltaTime)
{
  if (playerowner!=none&&playerowner.myhud!=self&&playerowner.myhud!=none){
    if (playerowner.myhud.IsA('tvhud')&&!playerowner.myhud.bdeleteme){
      destroy();
      return;
    }
    RealHUD=playerowner.myhud;
    playerowner.myhud=self;
  }

  if (tvsp(level.game)==none){
    super.tick(deltatime);
    return;
  }
  IdentifyFadeTime -= DeltaTime;
  if (IdentifyFadeTime < 0.0)
    IdentifyFadeTime = 0.0;
  if (MOTDFadeOutTime > 0.0){
    MOTDFadeOutTime -= DeltaTime/tvplayer(owner).linfo.Fadeintime;
    if (MOTDFadeOutTime <=0.0){
      HUDFadeTime=-1.1;      //start HUD fade-in
      HUDFadeMult=1.1/tvplayer(owner).linfo.Fadeintime;
      MOTDFadeOutTime = 0.0;
    }
  }
  if (HUDFadeTime > 0.0){ //teleporting out
    HUDFadeTime -= DeltaTime*HUDFadeMult;
    SetHUDColors(HUDFadeTime);
    if (HUDFadeTime < 0.0)
      HUDFadeTime = 0.0;
  }
  else if (HUDFadeTime < 0.0){   //HUD fade-in
    HUDFadeTime += DeltaTime*HUDFadeMult;
    SetHUDColors(1.0 + HUDFadeTime);
    if (HUDFadeTime > 0.0)
      HUDFadeTime = 0.0;
  }
  if ( bDrawFaceArea )               //face stuff.....
  {
    if ( FaceAreaOffset < 0 )
      FaceAreaOffset += DeltaTime * 600;
    if ( FaceAreaOffset > 0 )
      FaceAreaOffset = 0.0;
  }
  else if ( FaceAreaOffset > MinFaceAreaOffset )
    FaceAreaOffset = FMax(FaceAreaOffset - DeltaTime * 600, MinFaceAreaOffset );
//  if (MessageFadeTime>0)
//    MessageFadeTime-=0.7*deltatime;
}

function TelePorting(float TimeToTele){ //when fade-out tele activated. Sp only:
  local string Temp;
  local float Goal, UberGoal, Time, pts;
  if (level.netmode!=nm_standalone)
    return;
  HUDFadeTime=1.0;
  HUDFadeMult=1/TimeToTele;
//  tvplayer(owner).playermod=1;
//  OldPlayerMod=1;
  tvsp(level.game).bGODModeAllowed=true;
  PlayerOwner.ReducedDamageType='All';
  if (tvplayer(owner).Linfo.bCutScene)
    return;
  //score dumping:
  tvplayer(owner).ScoreHolder.TotalLevelSecrets+=Level.Game.SecretGoals;
  tvplayer(owner).ScoreHolder.TotalSecretsFound+=playerowner.SecretCount;
  //handle goal time information:
  Goal=tvplayer(owner).Linfo.GoalTime;
  UberGoal=tvplayer(owner).Linfo.UberGoalTime;
  Time=tvplayer(owner).MyTime;
  if (Goal<=0.0||Time>Goal+20)
    return; //don't even handle.
  if (Time<=UberGoal){
    Temp="You=Über-l33t! Your time ("$class'tvscoreboard'.static.parseTime(Time)$" s) BEAT Über-Goal Time ("$class'tvscoreboard'.static.parseTime(UberGoal)$" s) by "$class'tvscoreboard'.static.parseTime(UberGoal-Time)$" s!";
    pts=tvplayer(owner).Linfo.UberGoalPoints+tvplayer(owner).Linfo.UberGoalMult*(UberGoal-Time);
  }
  else if (Time<=Goal){
    Temp="CONGRATULATIONS! Your time ("$class'tvscoreboard'.static.parseTime(Time)$" s) BEAT Goal Time ("$class'tvscoreboard'.static.parseTime(Goal)$" s) by "$class'tvscoreboard'.static.parseTime(Goal-Time)$" s!";
    pts=tvplayer(owner).Linfo.GoalPoints+tvplayer(owner).Linfo.GoalMult*(Goal-Time);
    if (time<=UberGoal+20)
      Temp=Temp$"  Time was only "$class'tvscoreboard'.static.parseTime(Time-UberGoal)$" s away from Über-Goal!";
  }
  else{
    playerowner.clientMessage("Nice Job! Your time was only "$class'tvscoreboard'.static.parseTime(Time-Goal)$"s away from the Goal Time.",'criticalevent',true);
    return;
  }
  Temp=Temp$"  "$string(int(pts))$" Points Awarded!";
  //handle high-score saving:
  tvplayer(owner).ScoreHolder.AddPoints(pts);
  playerowner.clientMessage(temp,'criticalevent',true);
  CriticalMessage.lifetime+=100; //stay on even as level loads.
}
simulated function SetHUDColors(float ColorMult){ //sets color properties to emulate fading
  ColorMult=fclamp(ColorMult,0.05,1.0);
  if (ColorMult<0.83&&level.bHighDetailMode)  //translucency control
    NormalStyle=ERenderStyle.STY_Translucent;
  else
    NormalStyle=ERenderStyle.STY_Normal;
  WhiteColor = class'UTC_HUD'.static.B227_MultiplyColor(default.WhiteColor, ColorMult);
  RedColor = class'UTC_HUD'.static.B227_MultiplyColor(default.RedColor, ColorMult);
  GreenColor = class'UTC_HUD'.static.B227_MultiplyColor(default.GreenColor, ColorMult);
  CyanColor = class'UTC_HUD'.static.B227_MultiplyColor(default.CyanColor, ColorMult);
  BlueColor = class'UTC_HUD'.static.B227_MultiplyColor(default.BlueColor, ColorMult);
  GoldColor = class'UTC_HUD'.static.B227_MultiplyColor(default.GoldColor, ColorMult);
  PurpleColor = class'UTC_HUD'.static.B227_MultiplyColor(default.PurpleColor, ColorMult);
  TurqColor = class'UTC_HUD'.static.B227_MultiplyColor(default.TurqColor, ColorMult);
  GrayColor = class'UTC_HUD'.static.B227_MultiplyColor(default.GrayColor, ColorMult);
  FaceColor = class'UTC_HUD'.static.B227_MultiplyColor(default.FaceColor, ColorMult);
}
simulated function DrawMOTD(Canvas Canvas)
{
  local GameReplicationInfo GRI;
  local float XL, YL;

  if(Owner == None) return;

  if (tvsp(level.game)==none){
    super.DrawMOTD(canvas);
    return;
  }
  Canvas.Font = MyFonts.GetHugeFont(B227_ScaledFontScreenWidth(Canvas));          //use botpack fontinfo's

//  if ((MOTDFadeOutTime<=5.25)&&(MOTDFadeOutTime>0)){ //color stuff.....
  if ((MOTDFadeOutTime<0.95)&&(MOTDFadeOutTime>0)){
//    if (MOTDFadeOutTime>=5.0) //fade in
 //     Canvas.DrawColor.R = -1020*MoTDFadeOutTime+5355;          //another of UsAaR33's stupid formula's :D
    if (MOTDFadeOutTime>=0.91)
      Canvas.DrawColor.R = -6375*MoTDFadeOutTime+6056;
 // else if (MOTDFadeOutTime<=3)                      //fade out....
//    Canvas.DrawColor.R = 85*MoTDFadeOutTime;          //another of UsAaR33's stupid formula's :D
    else if (MOTDFadeOutTime<0.55)
      Canvas.DrawColor.R = 465*MoTDFadeOutTime;
    else    //force it to show....
      Canvas.DrawColor.R = 255;
  }
  else
    Canvas.DrawColor.R = 0;
  Canvas.DrawColor.G = Canvas.DrawColor.R; //white always.
  Canvas.DrawColor.B = Canvas.DrawColor.R;
  if (Canvas.DrawColor.R<200&&(tvplayer(Owner).Linfo.bCutScene||tvplayer(Owner).Linfo.bJet))
    Canvas.Style=ERenderStyle.STY_Translucent;
  else
    Canvas.Style = 1;

  Canvas.bCenter = true;

  GRI = PlayerPawn(Owner).GameReplicationInfo;
  if ( (GRI == None) || (GRI.GameName == "Game") || (MOTDFadeOutTime <= 0) )
    return;
      Canvas.StrLen("testy", XL, YL);
      Canvas.SetPos(0.0, Canvas.ClipY/2 - 2*(YL/2));
      Canvas.DrawText(Level.Title, true);
      Canvas.Font = MyFonts.GetBigFont(B227_ScaledFontScreenWidth(Canvas));
      Canvas.StrLen("testy", XL, YL);
    Canvas.SetPos(0.0, Canvas.ClipY/2 + 3*(YL/2));
      Canvas.DrawText(Level.LevelEnterText, true);                  //in case David wants it.....

    Canvas.bCenter = false;
    Canvas.Style=NormalStyle;
}

//Check the last trace.
simulated function bool TraceIdentify(canvas Canvas)
{
  if ( Pawn(Hit)!=none && ((Pawn(Hit).bIsPlayer)))
  {
    IdentifyTarget = Pawn(Hit);
    IdentifyFadeTime = 3.0;
  }

  if ( IdentifyFadeTime == 0.0 )
    return false;

  if ( (IdentifyTarget == None) /*|| (!IdentifyTarget.bIsPlayer) */||
     (IdentifyTarget.bHidden) /*|| (IdentifyTarget.PlayerReplicationInfo == None )*/)
    return false;

  return true;
}

simulated function DrawIdentifyInfo(canvas Canvas, float PosX, float PosY)
{
  local float XL, YL, XOffset;

  if (!TraceIdentify(Canvas)||(bSSLRaised&&currentpickup.lifetime>level.timeseconds))
    return;

  Canvas.Font = MyFonts.GetSmallFont(B227_ScaledFontScreenWidth(Canvas));
  Canvas.Style = 3;
  XOffset = 0.0;
  if (identifytarget.playerreplicationinfo!=none)
    Canvas.StrLen(IdentifyName$": "$IdentifyTarget.PlayerReplicationInfo.PlayerName, XL, YL);
  else
    Canvas.StrLen(IdentifyName$": "$IdentifyTarget.MenuName, XL, YL);
  XOffset = Canvas.ClipX/2 - XL/2;
  Canvas.SetPos(XOffset, Canvas.ClipY - 188*scale);

  if((identifytarget.playerreplicationinfo!=none&&IdentifyTarget.PlayerReplicationInfo.PlayerName != ""))
  {
    if (identifytarget.playerreplicationinfo!=none)
      SetDrawColor(Canvas,IdentifyTarget.PlayerReplicationInfo.Team,2,IdentifyFadeTime);
    else
      SetDrawColor(Canvas,255,2,IdentifyFadeTime);
    Canvas.StrLen(IdentifyName$": ", XL, YL);
    XOffset += XL;
    Canvas.DrawText(IdentifyName$": ");
    Canvas.SetPos(XOffset, Canvas.ClipY - 188*scale);
    if (identifytarget.playerreplicationinfo!=none){
      SetDrawColor(Canvas,IdentifyTarget.PlayerReplicationInfo.Team,1,IdentifyFadeTime);
      Canvas.StrLen(IdentifyTarget.PlayerReplicationInfo.PlayerName, XL, YL);
      Canvas.DrawText(IdentifyTarget.PlayerReplicationInfo.PlayerName);
    }
    else{
      SetDrawColor(Canvas,255,1,IdentifyFadeTime);
      Canvas.StrLen(IdentifyTarget.menuname, XL, YL);
      Canvas.DrawText(IdentifyTarget.menuname);
    }
  }

  XOffset = 0.0;
  Canvas.StrLen(IdentifyHealth$": "$IdentifyTarget.Health, XL, YL);
  XOffset = Canvas.ClipX/2 - XL/2;
  Canvas.SetPos(XOffset, Canvas.ClipY - 168*scale);

    if (identifytarget.playerreplicationinfo!=none)
      SetDrawColor(Canvas,IdentifyTarget.PlayerReplicationInfo.Team,2,IdentifyFadeTime);
    else
      SetDrawColor(Canvas,255,2,IdentifyFadeTime);
    Canvas.StrLen(IdentifyHealth$": ", XL, YL);
    XOffset += XL;
    Canvas.DrawText(IdentifyHealth$": ");
    Canvas.SetPos(XOffset, Canvas.ClipY - 168*scale);
    if (identifytarget.playerreplicationinfo!=none)
      SetDrawColor(Canvas,IdentifyTarget.PlayerReplicationInfo.Team,1,IdentifyFadeTime);
    else
      SetDrawColor(Canvas,255,1,IdentifyFadeTime);
    Canvas.StrLen(IdentifyTarget.Health, XL, YL);
    Canvas.DrawText(IdentifyTarget.Health);

  Canvas.Style = 2;
  Canvas.DrawColor = WhiteColor;
}
//coop support:
simulated function DrawFragCount(Canvas Canvas, int X, int Y)     //to make better use of scoring #'s...
{
/*    //no frag counter currently.
  local color oldcol;
  if (tvsp(level.game)!=none){
  super.drawfragcount(canvas,x,y);
  return;}
  Canvas.SetPos(X,Y);
  if (realicons) {
  Canvas.DrawIcon(Texture'Realskull', 1.0);
  oldcol=canvas.drawcolor;
  canvas.drawcolor=redcolor;  }
  else
  Canvas.DrawIcon(Texture'IconSkull', 1.0);
  Canvas.CurX -= 31;
  Canvas.CurY += 23;
  if ( PawnOwner.PlayerReplicationInfo == None )
    return;
  Canvas.Font = Font'TinyWhiteFont';
  if (PawnOwner.PlayerReplicationInfo.score<10000)
    Canvas.CurX+=6;
  if (PawnOwner.PlayerReplicationInfo.score<1000)
    Canvas.CurX+=6;
  if (PawnOwner.PlayerReplicationInfo.score<100)
    Canvas.CurX+=6;
  if (PawnOwner.PlayerReplicationInfo.score<10)
    Canvas.CurX+=6;
  if (PawnOwner.PlayerReplicationInfo.score<0)
    Canvas.CurX-=6;
  if (PawnOwner.PlayerReplicationInfo.score<-9)
    Canvas.CurX-=6;
  if (PawnOwner.PlayerReplicationInfo.score<-90)
    Canvas.CurX-=6;
    if (PawnOwner.PlayerReplicationInfo.score<-900)
    Canvas.CurX-=6;
  if (PawnOwner.PlayerReplicationInfo.score<-9000)
    Canvas.CurX-=6;
  Canvas.DrawText(int(PawnOwner.PlayerReplicationInfo.score),False);
     if (realicons)
  canvas.drawcolor=oldcol;
  */
}
simulated function DrawMainInventory(Canvas Canvas) //draw the overlays and then the inv!
{
  local int xl, yl, cnt;
  local inventory inv;
  //overlays:
  CAnvas.SetPos(Canvas.ClipX-882*scale,0);
  invrightclip=Canvas.CurX;
  yl=1.51*M128;
  Canvas.DrawRect(Texture'DLeft',1.51*M64,yl);
//  CAnvas.SetPos(Canvas.ClipX-584*scale,0);
  Canvas.DrawRect(Texture'DCenter',1.51*M256,yl);
//  CAnvas.SetPos(Canvas.ClipX-M256,0);
  xl=canvas.curx;
  Canvas.Style=ERenderStyle.STY_Translucent;
  Canvas.DrawRect(Texture'HOverLay',canvas.clipx-xl,yl); //overlay thingy
  Canvas.Style=NormalStyle;
  CAnvas.SetPos(xl,0);
  Canvas.DrawRect(Texture'DRight',canvas.clipx-xl,yl);

  //inventory drawing:
  xl=Canvas.ClipX-816*scale;
  yl=36*scale;
  for (inv=pawnowner.inventory;inv!=none&&cnt<1000;inv=inv.inventory){
    cnt++;
    if (Inv.bActivatable){
      DrawChargeIcon(Canvas,xl,yl,inv,(inv.bActive
      ||(inv==TvTranslator&&bFlashTranslator&&TransFlashTime>=Level.TimeSeconds)));
      xl+=M48;
    }
  }
}
simulated function GetHit(){   //called always to ensure trace
  local vector Start, End;
  Start=PawnOwner.Location;
  Start.Z += PawnOwner.BaseEyeHeight;
  End=Start+2048*vector(PawnOwner.viewrotation); //seemed like not too long of a trace
  Hit=PlayerOwner.TraceShot(End,Start,End,Start);
  if (bShowHitZ&&Hit.IsA('pawn'))
  	Message(PlayerOwner.PlayerReplicationInfo,"Hit Player at"@(End.z-Hit.location.z)/(Hit.collisionheight)@"* collision height",'criticalevent');
}
//Special HUD config stuff:
exec function GrowHUD()
{
  bHideHUD=false;
  saveconfig();
}

exec function ShrinkHUD()
{
  bHideHUD=true;
  saveconfig();
}
simulated function ChangeCrosshair(int d)
{
  class'HUD'.default.Crosshair = class'HUD'.default.Crosshair + d;
  if ( class'HUD'.default.Crosshair >= class'ChallengeHUD'.default.CrossHairCount)
    class'HUD'.default.Crosshair = 0;
  else if ( class'HUD'.default.Crosshair < 0 )
    class'HUD'.default.Crosshair = class'ChallengeHUD'.default.CrossHairCount;
}

simulated function Texture LoadCrosshair(int c)
{
//  if (c==0)
//   CrossHairTextures[c] = Texture(DynamicLoadObject("XidiaMPack.Main_00", class'Texture')); //onp crosshair.
//  else
    CrossHairTextures[c] = Texture(DynamicLoadObject(class'ChallengeHUD'.default.CrossHairs[c], class'Texture'));
  return CrossHairTextures[c];
}

//UT crosshair :) (code mostly challenge hud -> to have pickup effect)
simulated function DrawCrossHair( canvas Canvas, int StartX, int StartY )
{
  local float PickDiff;
  local float XLength;
  local texture Cross;
  if (nohud||(motdfadeouttime>0&&tvsp(level.game)!=none)){
    Canvas.Style=2;
    return;
  }
  if (class'HUD'.default.Crosshair>class'challengeHUD'.default.CrosshairCount)
     class'HUD'.default.Crosshair=0;

  PickDiff = Level.TimeSeconds - PickupTime;
  XLength = B227_CrosshairScale * 77;
  if ( PickDiff < 0.4 )
  {
    if ( PickDiff < 0.2 )
      XLength *= (1 + 5 * PickDiff);
    else
      XLength *= (3 - 5 * PickDiff);
  }

  Canvas.bNoSmooth = False;
  Canvas.SetPos(0.5 * (Canvas.ClipX - XLength), 0.5 * (Canvas.ClipY - XLength)); //only center hand use.
  Canvas.Style = ERenderStyle.STY_Translucent;
  if (Hit==none||Hit==Level) //nothing
    Canvas.DrawColor = WhiteColor;
  else if (Hit.IsA('CreatureCarcass')){   //still draw for corpses
    if (Hit.IsA('olCreatureCarcass')){  //mutator sets this to correct thing.
      if (level.netmode==nm_client){ //use mesh.. some glitches occur
        Canvas.DrawColor = RedColor;
        switch GetItemName(string(Hit.mesh)){
          Case "Merc":
          Case "nalit":
            Canvas.DrawColor = CyanColor;
            break;
          Case "NaliCow":
          Case "CrossNali":
          Case "Nali1":
            Canvas.DrawColor = GreenColor;
            break;
        }
      }
      else{
        if (Carcass(Hit).rats==2)
          Canvas.DrawColor = GreenColor;
        else if (Carcass(Hit).rats==1)
          Canvas.DrawColor = CyanColor;
        else
          Canvas.DrawColor = RedColor;
      }
    }
    else{   //placed by map author
  //    if (Hit.IsA('MercCarcass')||Hit.IsA('HumanCarcass')) //considered combatant ally
   //     Canvas.DrawColor = CyanColor;
     /* else */if (Hit.IsA('NaliCarcass')||Hit.IsA('CowCarcass')) //considered neutral
        Canvas.DrawColor = GreenColor;
      else  //considered enemy carcass
        Canvas.DrawColor = RedColor;
    }
  }
  else if (Hit.IsA('UTHumanCarcass'))
    Canvas.DrawColor = RedColor;
  else if ((Hit.IsA('projectile')&&!Hit.Isa('TranslocatorTarget'))||Hit.IsA('SludgeBarrel')||Hit.IsA('TarydiumBarrel')) //non-combatant explosives.
    Canvas.DrawColor = GoldColor;
  else if (!Hit.bIsPawn)
    Canvas.DrawColor = WhiteColor;
  else if (Hit.Isa('playerpawn'))  //combatant allies
    Canvas.DrawColor = CyanColor;
  else if (Hit.IsA('Nali')||Hit.IsA('Cow')||Hit.IsA('Bird1')||Hit.IsA('NaliRabbit'))  //neutrals
    Canvas.DrawColor = GreenColor;
  else  //enemies
    Canvas.DrawColor = RedColor;
  Cross = CrossHairTextures[class'HUD'.default.Crosshair];
  if( Cross == None )
    Cross = LoadCrosshair(class'HUD'.default.Crosshair);
  if (cross == none)
    class'HUD'.default.CrossHair=0;
  Canvas.DrawTile(Cross, XLength, XLength, 0, 0, 64, 64);
  Canvas.bNoSmooth = True;
  Canvas.Style = 2;
  Canvas.DrawColor = WhiteColor;
}
//render the speech texture and set all clips
simulated function DrawSpeechArea(Canvas Canvas, float YL){
  local float XStretch;
//  local float XScale, YScale;
//  Canvas.Style = ERenderStyle.STY_Translucent;
//  Canvas.DrawColor = default.WhiteColor * MessageFadeTime;
  Canvas.SetPos(ArmorOffset+facemsgset+M4,0);
  Xstretch=InvRightClip-Canvas.CurX-M4;
//  XScale=XStretch/256;
//  YScale=Yl/200;
//  Canvas.DrawRect(Texture'ChatArea',XStretch,256*YScale);
//  Canvas.SetOrigin(ArmorOffset+facemsgset+8*XScale,29*YScale);
//  Canvas.SetClip(XScale*239,Yl);
  Canvas.SetOrigin(ArmorOffset+facemsgset+M4,0);
  Canvas.SetClip(XStretch,256*Yl);
//  Canvas.Style = NormalStyle;
}
//for unreal style criticalevents, pickups, events, speech, and deathmessages (TvHUD changes position/font)
simulated function drawunrealmessages(canvas canvas){
  local float XL, YL, YPos, BaseY;
  local float OldClipY;
  local int I;
  local float PickupColor;
  local console Console;
  local string str;
  local bool bDrewSpeech;
  Console = PlayerOwner.Player.Console;
  if (Console==none)
    return;
  Canvas.Font = MyFonts.GetSmallFont(B227_ScaledFontScreenWidth(Canvas));

  if ( !Console.Viewport.Actor.bShowMenu )
    DrawTypingPrompt(Canvas, Console);

  if ( currentpickup.lifetime>level.timeseconds)   //pickup message
    {
      Canvas.bCenter = true;
      if ( Level.bHighDetailMode )
        Canvas.Style = ERenderStyle.STY_Translucent;
      else
        Canvas.Style = ERenderStyle.STY_Normal;
      PickupColor = 42.0 * (currentpickup.lifetime-level.timeseconds);
      Canvas.DrawColor.r = PickupColor;
      Canvas.DrawColor.g = PickupColor;
      Canvas.DrawColor.b = PickupColor;
      Canvas.StrLen(currentpickup.contents,Xl,Yl);
      Canvas.SetPos(4, Canvas.ClipY - M128 - Yl);
      Canvas.DrawText( currentpickup.contents, true );
      Canvas.bCenter = false;
      Canvas.Style = NormalStyle;
    }
// Display critical message:
    if (criticalmessage.lifetime>=level.timeseconds&&(tvtranslator==none||!tvtranslator.bActive)){
      Canvas.bCenter = true;
      Canvas.Style = ERenderStyle.STY_Translucent;
      Canvas.DrawColor = default.TurqColor;
      Canvas.SetPos(0, Canvas.SizeY/2 - 32 * FMax(1, Canvas.SizeY/480));
      canvas.DrawText( criticalmessage.contents, true );
      Canvas.bCenter = false;
      Canvas.Style = NormalStyle;
    }
/*if (MessageFadeTime>0){
    OldClipY=Canvas.ClipY;
    Canvas.StrLen("T", XL, BaseY );
    DrawSpeechArea(Canvas, 4.2*BaseY);
  }*/
  for (i=3;i>-1;i--) //go in backwards.
  {
    if (shortmessages[i].contents!=""&&shortmessages[i].lifetime>=level.timeseconds) //thx to setup order this always works :P
    {
      if (!bdrewSpeech){
        OldClipY=Canvas.ClipY;
        Canvas.StrLen("T", XL, BaseY );
        DrawSpeechArea(Canvas, 4.2*BaseY);
        bDrewSpeech=true;
      }
//      MessageFadeTime=1.0;
      str=Draw1337erMessageHeader(Canvas, ShortMessages[I], int(YPos));
      if (str==""){
        if (ShortMessages[I].Type == 'DeathMessage')
          Canvas.DrawColor = default.RedColor;
        else
            Canvas.DrawColor= default.GrayColor;
        Canvas.SetPos(0, YPos);
      }
      Canvas.DrawText(shortmessages[I].contents, false );
      Canvas.StrLen(str$shortmessages[i].contents, XL, YL );
      YPos += 0.05 * BaseY + YL;
      if (YPos>3.17*BaseY) //message out of area!
        break;
    }
  }
  if (/*MessageFadeTime>0*/bDrewSpeech){
    Canvas.SetClip(OldClipX,OldClipY);
    HudSetup(Canvas);
  }
}
simulated function float DrawNextMessagePart( Canvas Canvas, coerce string MString, float XOffset, int YPos )
{
  local float XL, YL;

  Canvas.SetPos(XOffset, YPos);
  Canvas.StrLen( MString, XL, YL );
  XOffset += XL;
  Canvas.DrawText( MString, false );
  return XOffset;
}
simulated function string Draw1337erMessageHeader(Canvas Canvas, somemessage ShortMessage, int YPos)
{
  local float XOffset;
  local string strPlayerName;
  local byte Team;

  if ((ShortMessage.Type != 'Say') && (ShortMessage.Type != 'TeamSay'))
    return "";


  if (ShortMessage.PRI != none) {
    Team = ShortMessage.PRI.Team;
    strPlayerName = ShortMessage.PRI.PlayerName;
  } else {
    Team = 255;
    strPlayerName = "h4xx0r";
  }

  SetDrawColor(Canvas,Team,1);
  XOffset = DrawNextMessagePart(Canvas, strPlayerName$": ", XOffset, YPos);
  Canvas.SetPos(XOffset, YPos);

  if (ShortMessage.Type == 'TeamSay') {
    // Message text is team color for TeamSay
    SetDrawColor(Canvas,Team,2);
  } else {
    // ...otherwise green
    SetDrawColor(Canvas,255,2);
  }

  return strPlayerName$": ";
}

simulated function DrawTypingPrompt( canvas Canvas, console Console )
{
  local string TypingPrompt;
  local float XL, YL;

  if ( Console.bTyping )
  {
    Canvas.Font = MyFonts.GetSmallFont(B227_ScaledFontScreenWidth(Canvas));
    Canvas.DrawColor = default.GoldColor;
    TypingPrompt = "(> "$Console.TypedStr$"_";
    Canvas.StrLen( TypingPrompt, XL, YL );
    Canvas.SetPos( M4, Canvas.SizeY - Console.ConsoleLines - YL - 1 );
    Canvas.DrawText( TypingPrompt, false );
  }
}

function DrawTalkFace(Canvas Canvas, float YPos)
{
  local float Xl, Yl;
  Canvas.Font = MyFonts.GetSmallFont(B227_ScaledFontScreenWidth(Canvas));
  Canvas.StrLen("TEST", XL, YL);
  YPos = FMax(YL*4 + 8, 70);
  facemsgset=Ypos+7+faceareaoffset;
  Canvas.DrawColor = WhiteColor;
  Canvas.Style = NormalStyle;
  Canvas.SetPos(armoroffset, M4);
  Canvas.DrawTile(FaceTexture, Ypos-scale+faceareaoffset, YPos - Scale, -faceareaoffset, 0, FaceTexture.USize+faceareaoffset, FaceTexture.VSize);
  Canvas.Style = ERenderStyle.STY_Translucent;
  Canvas.DrawColor = FaceColor;
  Canvas.SetPos(armoroffset, 0);
  Canvas.DrawTile(texture'botpack.LadrStatic.Static_a00',Ypos + 7*scale+faceareaoffset, YPos + 7*scale, -faceareaoffset, 0, texture'botpack.LadrStatic.Static_a00'.USize+faceareaoffset, texture'botpack.LadrStatic.Static_a00'.VSize);
  Canvas.DrawColor = WhiteColor;
}

//debug (z buffer hack):
exec function ZBuffer(bool newb){
  NoZBufHack=!newb;
}

//more debug
exec function ShowHitZ(bool bshow){
	bShowHitZ = bshow;
}

//more perminent
exec function PixelFix(bool bHack){
	bPixelHack=bhack;
}

static function float B227_ScaledScreenWidth(Canvas Canvas)
{
	if (default.B227_bVerticalScaling)
		return FMin(Canvas.SizeX, Canvas.SizeY * 4 / 3);
	return Canvas.SizeX;
}

defaultproperties
{
     NormalStyle=STY_Normal
     WeapIcons(0)=Texture'SevenB.Icons.CARifleF'
     WeapIcons(1)=Texture'SevenB.Icons.DPistolF'
     WeapIcons(2)=Texture'SevenB.Icons.AutoMagF'
     WeapIcons(3)=Texture'SevenB.Icons.miniF'
     WeapIcons(4)=Texture'SevenB.Icons.asmdF'
     WeapIcons(5)=Texture'SevenB.Icons.pulseF'
     WeapIcons(6)=Texture'SevenB.Icons.sniperF'
     WeapIcons(7)=Texture'SevenB.Icons.RipperF'
     WeapIcons(8)=Texture'SevenB.Icons.FlakF'
     WeapIcons(9)=Texture'SevenB.Icons.EballF'
     WeapIcons(10)=Texture'SevenB.Icons.CARifleE'
     WeapIcons(11)=Texture'SevenB.Icons.DPistolE'
     WeapIcons(12)=Texture'SevenB.Icons.AutoMagE'
     WeapIcons(13)=Texture'SevenB.Icons.miniE'
     WeapIcons(14)=Texture'SevenB.Icons.asmdE'
     WeapIcons(15)=Texture'SevenB.Icons.pulseE'
     WeapIcons(16)=Texture'SevenB.Icons.sniperE'
     WeapIcons(17)=Texture'SevenB.Icons.ripperE'
     WeapIcons(18)=Texture'SevenB.Icons.FlakE'
     WeapIcons(19)=Texture'SevenB.Icons.EballE'
     WeapIcons(20)=Texture'SevenB.Icons.CARifleN'
     WeapIcons(21)=Texture'SevenB.Icons.DPistolN'
     WeapIcons(22)=Texture'SevenB.Icons.AutoMagN'
     WeapIcons(23)=Texture'SevenB.Icons.miniN'
     WeapIcons(24)=Texture'SevenB.Icons.asmdN'
     WeapIcons(25)=Texture'SevenB.Icons.pulseN'
     WeapIcons(26)=Texture'SevenB.Icons.sniperN'
     WeapIcons(27)=Texture'SevenB.Icons.RipperN'
     WeapIcons(28)=Texture'SevenB.Icons.FlakN'
     WeapIcons(29)=Texture'SevenB.Icons.EballN'
     HUDConfigWindowType="SevenB.tvhudconfig"
     Texture=None
     B227_bVerticalScaling=True
}
