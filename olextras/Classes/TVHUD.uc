// ============================================================
// olextras.TVHUD: An entirely new HUD. based on features from the unreal and UT HUDS
// Unique Features:
// handles friendly name drawing.
// Fade stuff
// Pickup displaying
// translator new line stuff
// Adds support for client-side inventory items (they are a little b0rked though when it comes to switching items :( )
// Used for coop and SP
// ============================================================

class TVHUD expands oldskoolHUD;

/////////////////////////////////
//// NEW HUD GRAPHICS ///////////
/////////////////////////////////

//Items (64x64 images):
#exec OBJ LOAD FILE="OlextrasResources.u" PACKAGE=olextras

//Weapon Pictures (HUD Base w/ all weapons shown)  //128x64

//Weapon Icons (just picked up)           (64x64)

//Ammo Icons (used in current ammotype and just picked up)  (128x128 as in larger area)

//follower icons:   (64x64)

//Misc: (varying size)

//CrossHair:

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
var globalconfig int TvCrosshair; //crosshair for ONP
var globalconfig bool bHideHUD;
//hack for UMS:
var HUD RealHUD;
//test:
var bool NoZBufHack;
//FPS saving variables (pre-multiplied on resolution change):
var float M3, M4, M5, M9, M11, M64, M113, M128, M245;

var bool B227_bHandledGameEnd; // prevents counting end stats multiple times
var float B227_YScale;

/////////////////////////////////////////////////
// Icon grabbing functions:
/////////////////////////////////////////////////
static simulated function Texture FindItemIcon (class<inventory> inv){ //get actual icon for class.
//others:
  Switch (inv){
    case class'thighpads':
      return Texture'ThighPadsI';
    case class'Armor':
    case class'olweapons.olarmor':
      return Texture'I_Armor';
    case class'armor2':
    //-Case class'Armor':
      return Texture'ArmorI';
    Case class'AsbestosSuit':
      return Texture'AsbestosI';
    Case class'Flare':
      return Texture'FlareI';
    Case class'Flashlight':
      return Texture'FlashLightI';
    Case class'KevlarSuit':
      return Texture'KevlarI';
    Case class'Seeds':
      return Texture'SeedsI';
    Case class'SearchLight':
      return Texture'SearchLightI';
    Case class'ToxinSuit':
      return Texture'ToxinI';
    Case class'Translator':
      return Texture'TranslatorI';
  }
  if (ClassIsChildOf(inv,class'Shieldbelt')||ClassIsChildOf(inv,class'ut_Shieldbelt'))
    return Texture'ShieldBeltI';
  return inv.default.Icon;
}
static simulated function texture FindPkupicon(class<inventory> inv){  //get icon for just-pickup area.
  If (ClassIsChildOf(Inv,class'Ammo')){   //only here and on per-weapon basis
    switch inv{
      case class'rocketpack':
        return Texture'EightballA';
      case class'pammo':
        return Texture'PulseGunA';
      case class'bladehopper':
        return Texture'RipperA';
      case class'bioammo':
        return Texture'BioRifleA';
      case class'shockcore':
        return Texture'ASMDA';
      case class'SuperShockCore':
        return Texture'SuperShockA';
    }
    if (classischildof(inv,class'miniammo'))
      return Texture'EnfMiniA';
    if (classischildof(inv,class'flakammo'))
      return Texture'FlakCannonA';
    if (classischildof(inv,class'BulletBox'))
      return Texture'SniperA';
    return Texture'DPistolA';
  }
  if (!ClassIsChildOf(inv,class'Weapon'))
    return FindItemIcon(inv); //all else is the same
  if (ClassIsChildOf(inv,class'UT_biorifle'))
    return Texture'BioRifleP';
  if (ClassIsChildOf(inv,class'Translocator'))
    return Texture'TranslocatorP';
  if (ClassIsChildOf(inv,class'SniperRifle'))
    return Texture'SniperP';
  if (ClassIsChildOf(inv,class'Enforcer'))
    return Texture'EnforcerP';
  if (ClassIsChildOf(inv,class'Minigun2'))
    return Texture'MinigunP';
  if (ClassIsChildOf(inv,class'Pulsegun'))
    return Texture'PulseGunP';
  if (ClassIsChildOf(inv,class'Ripper'))
    return Texture'RipperP';
  if (ClassIsChildOf(inv,class'UT_Eightball'))
    return Texture'EightballP';
  if (ClassIsChildOf(inv,class'UT_FlakCannon'))
    return Texture'FlakCannonP';
  if (ClassIsChildOf(inv,class'SuperShockRifle'))
    return Texture'SuperShockP';
  if (ClassIsChildOf(inv,class'ShockRifle'))
    return Texture'ASMDP';
  return Texture'DPistolP'; //default
}
static simulated function Texture GetWeaponIcon (Class<Weapon> inv){ //get weapon icon for weapon area
  if (ClassIsChildOf(inv,class'UT_biorifle'))
    return Texture'BioRifleW';
  if (ClassIsChildOf(inv,class'Translocator'))
    return Texture'TranslocatorW';
  if (ClassIsChildOf(inv,class'SniperRifle'))
    return Texture'SniperW';
  if (ClassIsChildOf(inv,class'Enforcer'))
    return Texture'EnforcerW';
  if (ClassIsChildOf(inv,class'Minigun2'))
    return Texture'MinigunW';
  if (ClassIsChildOf(inv,class'Pulsegun'))
    return Texture'PulseGunW';
  if (ClassIsChildOf(inv,class'Ripper'))
    return Texture'RipperW';
  if (ClassIsChildOf(inv,class'UT_Eightball'))
    return Texture'EightballW';
  if (ClassIsChildOf(inv,class'UT_FlakCannon'))
    return Texture'FlakCannonW';
  if (ClassIsChildOf(inv,class'SuperShockRifle'))
    return Texture'SuperShockW';
  if (ClassIsChildOf(inv,class'ShockRifle'))
    return Texture'ASMDW';
  if (ClassIsChildOf(inv,class'OldPistol'))
    return Texture'DPistolW';
}
static simulated function Texture GetAmmoIcon (Class<Weapon> W){ //get ammo icon on a per-weapon basis
  if (ClassIsChildOf(W,class'UT_biorifle'))
    return Texture'BioRifleA';
  if (ClassIsChildOf(W,class'Translocator'))
    return Texture'TranslocatorA';
  if (ClassIsChildOf(W,class'SniperRifle'))
    return Texture'SniperA';
  if (ClassIsChildOf(W,class'Enforcer')||ClassIsChildOf(W,class'Minigun2'))
    return Texture'EnfMiniA';
  if (ClassIsChildOf(W,class'Pulsegun'))
    return Texture'PulseGunA';
  if (ClassIsChildOf(W,class'Ripper'))
    return Texture'RipperA';
  if (ClassIsChildOf(W,class'UT_Eightball'))
    return Texture'EightballA';
  if (ClassIsChildOf(W,class'UT_FlakCannon'))
    return Texture'FlakCannonA';
  if (ClassIsChildOf(W,class'SuperShockRifle'))
    return Texture'SuperShockA';
  if (ClassIsChildOf(W,class'ShockRifle'))
    return Texture'ASMDA';
  return Texture'DPistolA'; //default
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
  Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);
  Canvas.StrLen(Amount,Xl,Yl);
  Canvas.SetPos(fmax(Canvas.CurX-Xl+60*scale,Canvas.CurX),Canvas.Cury-M4-Yl+M64);
  Canvas.DrawText(Amount,False);
  Canvas.Font = Canvas.LargeFont;
  Canvas.CurX = TempX;
  Canvas.CurY = TempY;
}
//Draw Weapon function Modes:
// 0=normal
// 1=raised
// 2=selected (selected always lowest)
simulated function DrawWeaponIcon(Canvas Canvas, texture Icon, int Pos, byte Mode, float Ammo, optional bool Pending){
  local float Xl, Yl;
  local bool bCannotUse;
  if (Mode==1&&Pos>2)
    bSSLRaised=true;
  bCannotUse = (Ammo==0.0);
  Ammo=Fclamp(Ammo,0,1);
   Canvas.SetPos(Pos*M128,canvas.clipy-M64*(Mode%2+1));
  Xl=Canvas.CurX;
  Yl=Canvas.CurY;
   if (Mode==2){
     Canvas.Style=ERenderStyle.STY_Translucent;
     Canvas.DrawColor = GoldColor;
     Canvas.DrawRect(Texture'WeaponGlowTex',M128,M64); //selected glows.
   }
   Canvas.Style=NormalStyle;
   Canvas.SetPos(Xl,Yl);
   Canvas.DrawColor = WhiteColor;
   Canvas.DrawRect(Texture'WeaponPipe',M128,M64);
   Canvas.SetPos(Xl,Yl);
   if (Level.bHighDetailMode||Mode==2||Pending)
      Canvas.Style=ERenderStyle.STY_Translucent;
   Canvas.DrawRect(Texture'WeaponGlass',M128,M64);
   If (Level.bHighDetailMode&&Mode!=2&&!Pending)
     Canvas.Style=ERenderStyle.STY_Translucent;
   else
     Canvas.Style=NormalStyle;
   Canvas.SetPos(Xl,Yl);
   if (Icon!=none)
    Canvas.DrawRect(Icon,M128,M64);
   Pos=Pos%10;
   Canvas.Style=NormalStyle;
   Canvas.Font=MyFonts.GetMediumFont(Canvas.ClipX);
   Canvas.SetPos(Xl+M9,Yl+M5);
   if (bCannotUse)
    Canvas.DrawColor=FaceColor;
   Canvas.DrawText(Pos);
   if (Ammo==0){
     Canvas.DrawColor=WhiteColor;
     return;
   }
   Canvas.SetPos(Xl+M11,Yl+M3);
   Canvas.StrLen(Pos,Xl,Yl);
    Canvas.DrawColor.G=Ammo*GreenColor.G;
    Canvas.DrawColor.R=RedColor.R-Canvas.DrawColor.G;
   if (Canvas.DrawColor.G<48)  //prevents excessive green..
     Canvas.DrawColor.G=max(0,2*Canvas.DrawColor.G-48);
   Canvas.DrawColor.B=0;
   Canvas.DrawTile(Texture'TvHudLine',fmin(98*scale*Ammo,M113-Xl),M9-scale,0,0.5,32.0,2.0);
   Canvas.DrawColor = WhiteColor;
}
//for ammo,armor, inv, etc.
simulated function DrawONPIcon(canvas canvas, texture Icon, float X, float Y, optional bool bGlow){
  Canvas.SetPos(X,Y);
  if (icon==none)
    DrawPipeIcon(canvas,Icon,M64,M64,true,bGlow);
  else
    DrawPipeIcon(canvas,Icon,Icon.Usize*scale,Icon.Vsize*scale,true,bGlow);
  Canvas.SetPos(X,Y);
}
//universal:
simulated function DrawPipeIcon(canvas canvas, texture Icon, float Xl, float Yl,
 optional bool bTranslucent, optional bool bGlow){
  local float X,Y;
  local Color OldCol;
  OldCol=Canvas.DrawColor;
  Canvas.Style=ERenderStyle.STY_Masked;
  X=Canvas.CurX;
  Y=Canvas.CurY;
  if (bGlow){
    Canvas.Style=ERenderStyle.STY_Translucent;
    Canvas.DrawRect(Texture'IconGlowTex',XL,YL);
    Canvas.Style=NormalStyle;
  }
  Canvas.SetPos(X,Y);
  Canvas.DrawColor=WhiteColor;
  Canvas.DrawRect(Texture'IconPipe',XL,YL);
  if (bGlow||(bTranslucent&&Level.bHighDetailMode))
    Canvas.Style=ERenderStyle.STY_Translucent;
  Canvas.SetPos(X,Y);
  Canvas.DrawColor=OldCol;
  Canvas.DrawRect(Texture'IconGlass',XL,YL);
  Canvas.Style=NormalStyle;
  Canvas.SetPos(X,Y);
  if (icon!=none)
    Canvas.DrawRect(Icon,XL,YL);
}
//used for armor and inv:
simulated function DrawChargeIcon(Canvas Canvas, float X, float Y, Inventory Item, optional bool bActivated)
{
  local float Ammo;
  if (Item.StatusIcon==Item.default.StatusIcon&&!Item.IsA('TvPickup'))
    Item.StatusIcon=FindItemIcon(Item.Class);
  if (Item.StatusIcon == none)
    return;
  if (bActivated)
    Canvas.DrawColor=RedColor;
  Canvas.SetPos(X,Y);
  DrawPipeIcon(canvas,Item.StatusIcon,M64,M64,true,Item==PawnOwner.SelectedItem);
  Canvas.SetPos(X,Y);
  Canvas.DrawColor=WhiteColor;
  if (Item.IsA('Pickup')&&Pickup(Item).bCanHaveMultipleCopies)
     DrawONPIconValue(Canvas,Pickup(Item).NumCopies);
  else if (item.charge>0){
    Ammo=fmin(float(Item.Charge)/float(Item.Default.Charge),1);
    Canvas.CurX += M4;
    Canvas.CurY += 56*scale;
    Canvas.DrawColor.G=Ammo*GreenColor.G;
    Canvas.DrawColor.R=RedColor.R-Canvas.DrawColor.G;
    if (Canvas.DrawColor.G<48)  //prevents excessive green..
      Canvas.DrawColor.G=max(0,2*Canvas.DrawColor.G-48);
    Canvas.DrawColor.B=0;
    Canvas.DrawTile(Texture'TvHudLine',scale*54.0*Ammo,M4,0,0,32.0,2.0);
  }
  Canvas.DrawColor=WhiteColor;
}
simulated function DrawStatusBar (Canvas Canvas, float X, float Y, float BarLength){
  BarLength=Fclamp(BarLength,0,1);
  Canvas.SetPos(X,Y);
  Canvas.DrawRect(Texture'StatusBorder',M64,2*M128);
  Canvas.SetPos(X,Y+5.5*scale+M245*(1-BarLength));
  if (BarLength>0){
    Canvas.DrawColor.G=BarLength*GreenColor.G;
    Canvas.DrawColor.R=max(RedColor.R-Canvas.DrawColor.G,0);
    if (Canvas.DrawColor.G<48)  //prevents excessive green..
      Canvas.DrawColor.G=max(0,2*Canvas.DrawColor.G-48);
    Canvas.DrawColor.B=0;
    if (Level.bHighDetailMode)
      Canvas.Style=ERenderStyle.STY_Translucent;
    Canvas.DrawTile(Texture'Greybar',M64,
     BarLength*M245,0,
      5.5+(1-BarLength)*245,64,
       BarLength*245);    //variable size bar
  }
  Canvas.DrawColor=WhiteColor;
  Canvas.Style=NormalStyle;
}
simulated function HudSetup (Canvas Canvas){
  Super.HudSetup(Canvas);
  if (breschanged){  //cache multipliers here
    Scale=Canvas.ClipX/1536;  //lower icons are 1536 pixels long
    M3=3*scale;
    M4=4*scale;
    M5=5*scale;
    M9=9*scale;
    M11=11*scale;
    M64=64*scale;
    M113=113*scale;
    M128=128*scale;
    M245=245*scale;
  }
  HudMode=0; //no HUD modes in ONP=force

  B227_YScale = Canvas.ClipY / 1536 * 4 / 3;
  if (!class'UTC_HUD'.default.B227_bVerticalScaling)
    B227_YScale = Scale;
}
simulated function float GetAmmo(Weapon W){
  if (W.AmmoType==None)
    return -1;
  else
    return float(W.AmmoType.AmmoAmount)/float(W.AmmoType.MaxAmmo);
}
simulated function DrawArmor(Canvas Canvas, int X, int Y, bool bDrawOne){  //Now used for armor and weapon icons!
local byte bTrans, bSSL; //weapon bytes: 0=not found, 1=spot drawn, 2=found, 3=already drawn, 4=all done (top and bottom), 5=found: raised
local Weapon Trans,SSL; //to read later
local int ArmorAmount;
//local texture Icon;
local float xl, yl;
local inventory Inv;
local byte raise;
local int loops;
  if (PawnOwner.Weapon!=none){
    if (PawnOwner.Weapon.StatusIcon==PawnOwner.Weapon.default.StatusIcon)
      PawnOwner.Weapon.StatusIcon=GetWeaponIcon(PawnOwner.Weapon.class);
    DrawWeaponIcon(Canvas,PawnOwner.Weapon.StatusIcon,PawnOwner.Weapon.InventoryGroup,2,GetAmmo(PawnOwner.Weapon));
    if (PawnOwner.Weapon.IsA('Translocator'))
      bTrans=3;
    else if (PawnOwner.Weapon.IsA('SuperShockRifle'))
      bSSL=3;
    else if (PawnOwner.Weapon.IsA('OldPistol'))
      bTrans=1;
    else if (PawnOwner.Weapon.IsA('ShockRifle'))
      bSSL=1;
  }
  armoroffset=0;
  for( Inv=pawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory ){
    loops++;
    if (loops>1000) //infinite iterator!
      break;
    if ( TVTranslator(Inv) != None )   //grab it here.
      TVTranslator = TVTranslator(Inv);
    if (Inv.bIsAnArmor&&Inv.Charge>0){
      ArmorAmount+=Inv.Charge;
      DrawChargeIcon(Canvas,ArmorOffset,0,Inv);
      ArmorOffset+= M64;
    }
    else if (Inv.IsA('Weapon')){
      if (inv==PawnOwner.Weapon)
        Continue;
      if (Inv.StatusIcon==Inv.default.StatusIcon)
        Inv.StatusIcon=GetWeaponIcon(class<weapon>(Inv.class));
      if (Inv.StatusIcon==none)
        Continue;
      if (Inv.IsA('translocator')){
        if (btrans==2||btrans==3||btrans==5) //error?
          Continue;
        else if (btrans==0){
          btrans=2;
          trans=Weapon(inv);
        }
        else if (btrans==1){
          btrans=4;
          DrawWeaponIcon(Canvas,Inv.StatusIcon,1,1,0);
        }
      }
      else if (Inv.IsA('SuperShockRifle')){
        if (bSSL==2||bSSL==3||bSSL==5) //error?
          Continue;
        else if (bSSL==0){
          SSL=Weapon(inv);
          bSSL=2;
        }
        else if (bSSL==1){
          bSSL=4;
          DrawWeaponIcon(Canvas,Inv.StatusIcon,4,1,GetAmmo(Weapon(Inv)));
        }
      }
      else{
        if (Inv.IsA('OldPistol')){
          if (bTrans==4)
            Continue;
          Raise=byte(btrans==3);
          if (btrans==0)
            bTrans=1;
          else if (btrans==2)
            btrans=5;
        }
        else if (Inv.IsA('ShockRifle')){
          if (bSSL==4)
            Continue;
          Raise=byte(bSSL==3);
          if (bSSL==0)
            bSSL=1;
          else if (bSSL==2)
            bSSL=5;
        }
        else
          Raise=0;
        DrawWeaponIcon(Canvas,Inv.StatusIcon,Inv.InventoryGroup,Raise,GetAmmo(Weapon(Inv)),(level.netmode!=nm_client&&Inv==PawnOwner.PendingWeapon));
      }
    }
  }
  if (btrans==2||btrans==5)
    DrawWeaponIcon(Canvas,Trans.StatusIcon,1,byte(btrans==5),-1,(level.netmode!=nm_client&&Trans==PawnOwner.PendingWeapon));
  if (bSSL==2||bSSL==5)
    DrawWeaponIcon(Canvas,SSL.statusIcon,4,byte(bSSL==5),GetAmmo(SSL),(level.netmode!=nm_client&&SSL==PawnOwner.PendingWeapon));
  if (ArmorAmount>0){
    Canvas.SetPos(ArmorOffset,0);
    Canvas.Font=MyFonts.GetHugeFont(Canvas.ClipX);
    Canvas.StrLen(ArmorAmount,Xl,Yl);
    ArmorOffset+=Xl;
    Canvas.CurY+=(M64-Yl)/2;
    Canvas.DrawColor=TurqColor;
    Canvas.DrawText(ArmorAmount);
    Canvas.DrawColor=WhiteColor;
  }
}

simulated function DrawHealth(Canvas Canvas, int X, int Y)
{
  local float Xf, Yf;
  DrawONPIcon (Canvas,Texture'HealthCross',0
    ,canvas.clipy-M128,pawnowner.health>pawnowner.default.health);
  Canvas.Font=Myfonts.GetBigFont(Canvas.ClipX);
  Canvas.StrLen(PawnOwner.Health,Xf,Yf);
  Canvas.SetPos(M64-Xf/2,
    Canvas.clipy-M64-Yf/2);
  Canvas.DrawText(Max(0,PawnOwner.Health),False);
  DrawStatusBar (Canvas, 0,
   canvas.clipy-(384)*scale,
    float(PawnOwner.Health)/float(PawnOwner.Default.Health));
}

simulated function DrawAmmo(Canvas Canvas, int X, int Y)
{
  local texture foundicon;
  local float Xf, Yf;
  if (PawnOwner.Weapon==none)
    return;
  FoundIcon=GetAmmoIcon(PawnOwner.Weapon.Class);
  DrawONPIcon (Canvas,FoundIcon,canvas.clipx-M128
   ,canvas.clipy-M128);
  if (PawnOwner.Weapon.AmmoType==none)
    return;
  Canvas.Font=Myfonts.GetBigFont(Canvas.ClipX);
  Canvas.StrLen(PawnOwner.Weapon.AmmoType.AmmoAmount,Xf,Yf);
  Canvas.SetPos(Canvas.clipx-M64-Xf/2,
   Canvas.clipy-M64-Yf/2);
  Canvas.DrawText(PawnOwner.Weapon.AmmoType.AmmoAmount,False);
  DrawStatusBar (Canvas, canvas.clipx-M64,
   canvas.clipy-(FoundIcon.vsize+256)*scale,
    float(PawnOwner.Weapon.AmmoType.AmmoAmount)/float(PawnOwner.Weapon.AmmoType.MaxAmmo));
}

//follower info displaying:
function DrawFollowers (Canvas Canvas)
{
  local texture icon;
  local float Y, Xl, Yl;
  local int i, j;
  local string FollowName;
  Canvas.Style=1;
  if (ArmorOffset>0)
    Y=M64;
  Canvas.Font=Myfonts.GetSmallFont(Canvas.ClipX); //change?
  //draw info:
  for (i=0;i<8;i++){
    if (tvplayer(playerowner).FollowerInfo[i]=="")
      return;
    canvas.SetPos(0,y);
    icon=none;
    switch (left(tvplayer(playerowner).FollowerInfo[i],1)){
      case "0":
        icon=texture'FnMerc';
        break;
      case "1":
        icon=texture'FeMerc';
        break;
      case "2":
        icon=texture'Fnali';
        break;
      case "3":
        icon=texture'FSkaarjW';
        break;
      case "4":
        icon=texture'FSkaarjT';
        break;
      case "5":  //human: must DLO icon (I hate this system)
        break;
      case "6":
        icon=texture'FnKrall';
        break;
      default:    //7
        icon=texture'FeKrall';
        break;
    }
    if (icon!=none)
      FollowName=mid(tvplayer(playerowner).FollowerInfo[i],1);
    else{
      j=instr(tvplayer(playerowner).FollowerInfo[i],chr(16));
      FollowName=mid(tvplayer(playerowner).FollowerInfo[i],1,j-1);
      icon=Texture(DynamicLoadObject(mid(tvplayer(playerowner).FollowerInfo[i],j+1),class'Texture',true));
    }
    Canvas.DrawRect(icon,M64,M64);
    FollowName=FollowName$"->"$tvplayer(playerowner).FollowerHealth[i]@"H";
    Canvas.StrLen(followname,XL,YL);
    Canvas.CurY+=(M64-Yl)/2;
    Canvas.DrawText(followname);
    if (XL+M64>armoroffset)   //fixme: update for chat area size.
      Armoroffset=XL+M64;
    Y+=M64;
  }
}
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
}
//entry point for U1 health
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
  local string text;
  local int Health;
  super.Message(PRI,Msg,MsgType);
//  if (Msg!=""&&MsgType!='CriticalEvent'&&MsgType!='Pickup')
//    MessageFadeTime=1.0;
  if (MsgType=='CriticalEvent'&&tvtranslator!=none)
    tvtranslator.ForceDeactivate();
  if (pawnowner.isinstate('PlayerShip'))
    return;
  if (PRI==playerowner.playerreplicationinfo&&MsgType=='pickup'){ //check if matches health (in this case it MUST be a U1 health)
    if (Msg==class'OSDispersionPowerUp'.default.pickupmessage){  //one exception
      AddPickup(Texture'DPistolA',"Power");
      return;
    }
    if (Msg==class'SuperHealth'.default.pickupmessage)
      Text="+100";
    else{
      Health=FindHealthAmount(Msg);
      if (Health==-1) //not a real health message.
        return;
      Text="+"$Health;
    }
    AddPickup(Texture'HealthCross',text);
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
local int messages, i;
local float TempX, Tempy;
local string tmp;

 // List Translator messages if activated
  if (TvTranslator!=None )
  {
    if(TvTranslator.bActive )
    {
      Canvas.bCenter = false;
      Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);
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
DrawFollowers(canvas); //draw teh followers.
Canvas.Style=2;
for (i=0;i<5;i++){
  if (Pickups[i].expireTime!=0&&Pickups[i].ExpireTime<=level.timeseconds)
    ClearPickup(Pickups[i]);
  else if (Pickups[i].Text!="")
    messages++;
  else
    break;
}
messages--;
TempX=Canvas.ClipX;
Yf=M64;
//playerpawn(owner).clientmessage("message count is"@messages);
for (i=messages;i>=0;i--){
  TempX-=M64;
  DrawPickIcon(Canvas, TempX, Yf, pickups[i].icon, pickups[i].text);
}
if (tempx<InvRightClip)
  InvRightClip=tempx;
}
//special function when player takes damage, fires, etc.
function DeActivateTranslator(){
  if (TvTranslator!=none)
    TvTranslator.ForceDeactivate();
}

simulated function DrawPickIcon(Canvas Canvas, float X, float Y, texture Icon, string text)
{
  Local int Width;
  local float Xl, Yl, test, lim;
  local string str;
  Canvas.SetPos(X,y);
  DrawPipeIcon(Canvas,Icon,M64,M64);
  if (text=="")
    return;
  Canvas.Font=Myfonts.GetSmallestFont(Canvas.ClipX);
  Canvas.StrLen(text,Xl,Yl);
  lim=60*scale;
  if (Xl>lim){   //scale txt down
    while (test<=lim){
      str=mid(text,Width,1);
      Width++;
      Canvas.StrLen(str,Xl,Yl);
      test+=Xl;
    }
    text=left(text,width-1);
    Xl=test-Xl;
  }
  Canvas.SetPos(X+fmax(0,lim-Xl),Y+fmax(0,56*scale-Yl));
  Canvas.DrawText(text,False);
}

//other HUD stuff:
simulated function PostBeginPlay()      //set to 5...
{
  FaceAreaOffset = -64;
  if(tvplayer(owner)!=none&&(tvplayer(owner).linfo.bcutscene||tvplayer(owner).linfo.bjet))  //verify the gametypes and set accordingly..
    nohud=true;
  MyFonts = spawn(Class'Botpack.FontInfo');    //load fonts...
  if (tvsp(level.game)==none||level.game.class==class'MonsterSmash'){ //coop
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
local byte btemp;
  if (RealHUD!=none){
    RealHUD.PostRender(Canvas);
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
     else
       HUDFadeTime=-1.0; //fade in
  }
  nohud=(bHideHUD||tvplayer(owner).linfo.ForceNoHUD||(tvplayer(owner).PlayerMod==1&&HUDFadeTime==0)
    ||(MOTDFadeOutTime>0&&tvsp(level.game)!=none&&level.game.class!=class'MonsterSmash'));
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

  if (tvsp(level.game)==none||level.game.class==class'MonsterSmash'){
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
  if (Level.NetMode != NM_Standalone || B227_bHandledGameEnd)
    return;
  HUDFadeTime=1.0;
  HUDFadeMult=1/TimeToTele;
//  tvplayer(owner).playermod=1;
//  OldPlayerMod=1;
  tvsp(level.game).bGODModeAllowed=true;
  PlayerOwner.ReducedDamageType='All';
  B227_bHandledGameEnd = true;
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

  if (tvsp(level.game)==none||level.game.class==class'MonsterSmash'){
    super.DrawMOTD(canvas);
    return;
  }
  Canvas.Font = MyFonts.GetHugeFont( Canvas.ClipX );          //use botpack fontinfo's

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
      Canvas.SetPos(0.0, Canvas.ClipY/2 - 4*(YL/2));
      Canvas.DrawText(Level.Title, true);
      Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
      Canvas.StrLen("testy", XL, YL);
      Canvas.SetPos(0.0, Canvas.Clipy/2 - (YL/2));
      Canvas.DrawText("By: "$Level.Author, true);
      Canvas.SetPos(0.0, 32 + 4*YL);
    Canvas.SetPos(0.0, Canvas.ClipY/2 + 5*(YL/2));
      Canvas.DrawText(Level.LevelEnterText, true);                  //in case David wants it.....

    Canvas.bCenter = false;
    Canvas.Style=NormalStyle;
}

//Check the last trace.
simulated function bool TraceIdentify(canvas Canvas)
{
  if ( Pawn(Hit)!=none && ((Pawn(Hit).bIsPlayer) ||(Hit.isa('follower')&&Follower(Hit).IsFriend())))
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
//FOLLOWER INFO:
simulated function DrawIdentifyInfo(canvas Canvas, float PosX, float PosY)
{
  local float XL, YL, XOffset;
  local string Following;

  if (!TraceIdentify(Canvas)||(bSSLRaised&&currentpickup.lifetime>level.timeseconds))
    return;

  Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);
  Canvas.Style = 3;
  if (Follower(identifytarget)!=none)
     IdentifyTarget.MenuName=Follower(IdentifyTarget).MyName;
  XOffset = 0.0;
  if (identifytarget.playerreplicationinfo!=none)
    Canvas.StrLen(IdentifyName$": "$IdentifyTarget.PlayerReplicationInfo.PlayerName, XL, YL);
  else
    Canvas.StrLen(IdentifyName$": "$IdentifyTarget.MenuName, XL, YL);
  XOffset = Canvas.ClipX/2 - XL/2;
  Canvas.SetPos(XOffset, Canvas.ClipY - 188*scale);

  if((identifytarget.playerreplicationinfo!=none&&IdentifyTarget.PlayerReplicationInfo.PlayerName != "")||IdentifyTarget.menuname!="")
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

  if (identifytarget.playerreplicationinfo==none){ //orders :)

    if (!IdentifyTarget.IsA('Follower')||Follower(IdentifyTarget).bcoward)
       return;
    IF (Follower(IdentifyTarget).PaPRI==none)
      Following="Nobody";
    else
      Following=Follower(IdentifyTarget).PaPRI.playername;

    XOffset = 0.0;
    Canvas.StrLen("Controller: "$Following, XL, YL);
    XOffset = Canvas.ClipX/2 - XL/2;
    Canvas.SetPos(XOffset, Canvas.ClipY - 148*scale);
    SetDrawColor(Canvas,255,2,IdentifyFadeTime);
    Canvas.StrLen("Controller: ", XL, YL);
    XOffset += XL;
    Canvas.DrawText("Controller: ");
    Canvas.SetPos(XOffset, Canvas.ClipY - 148*scale);
    SetDrawColor(Canvas,255,1,IdentifyFadeTime);
    Canvas.StrLen(Following, XL, YL);
    Canvas.DrawText(Following);

  }
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
simulated function DrawMainInventory(Canvas Canvas)
{
  local inventory inv,
    items[5]; //0,1=next ; 2=selected ; 3,4=previous
  local int cnt, loops;
  local float XPos;
  if ( pawnOwner.Inventory==None||PawnOwner.SelectedItem==none) Return;
  items[2]=PawnOwner.SelectedItem;
  inv=items[2].Inventory;
  cnt=2;
  if (inv==none)
    inv=PawnOwner.Inventory;
  While (inv!=items[2]){
    if (loops>1000) //infinite iterator!
      break;
    loops++;
    if (Inv.bActivatable){
       if (cnt>0){
         cnt--;
         Items[cnt]=inv;
       }
       else{
         items[4]=items[3];
         items[3]=inv;
       }
    }
    inv=inv.inventory;
    if (inv==none)
      inv=pawnowner.inventory;
  }
  if (items[1]==none){
    items[0]=items[2];
    items[2]=none;
  }
  else if (items[0]==none){
    items[0]=items[1];
    items[1]=items[2];
    items[2]=none;
  }
  else if (items[3]==none){
    inv=items[2];
    items[2]=items[0];
    items[0]=items[1];
    items[1]=inv;
  }
  XPos=Canvas.ClipX;
  for (cnt=0;cnt<5;cnt++){
    if (items[cnt]==none)
      break;
    XPos-=M64;
    DrawChargeIcon(Canvas,XPos,0,Items[cnt],(Items[cnt].bActive
     ||(Items[cnt]==TvTranslator&&bFlashTranslator&&TransFlashTime>=Level.TimeSeconds)));
  }
  InvRightClip=Xpos;
}
simulated function GetHit(){   //called always to ensure trace
  local vector Start, End;
  Start=PawnOwner.Location;
  Start.Z += PawnOwner.BaseEyeHeight;
  End=Start+2048*vector(PawnOwner.viewrotation); //seemed like not too long of a trace
  Hit=PlayerOwner.TraceShot(Start,End,End,Start);
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
  TvCrosshair = TvCrosshair + d;
  if ( TvCrosshair > class'ChallengeHUD'.default.CrossHairCount)
    TvCrosshair = 0;
  else if ( Crosshair < 0 )
    TvCrosshair = class'ChallengeHUD'.default.CrossHairCount;
}

simulated function Texture LoadCrosshair(int c)
{
  if (c==0)
    CrossHairTextures[c] = Texture(DynamicLoadObject("olextras.Main_00", class'Texture')); //onp crosshair.
  else
    CrossHairTextures[c] = Texture(DynamicLoadObject(class'ChallengeHUD'.default.CrossHairs[c-1], class'Texture'));
  return CrossHairTextures[c];
}

//UT crosshair :) (code mostly challenge hud -> to have pickup effect)
simulated function DrawCrossHair( canvas Canvas, int StartX, int StartY )
{
  local float PickDiff;
  local float XLength;
  local texture Cross;
  if (nohud||(motdfadeouttime>0&&tvsp(level.game)!=none&&level.game.class!=class'MonsterSmash')){
    Canvas.Style=2;
    return;
  }
  if (tvCrosshair>class'challengeHUD'.default.CrosshairCount)
     tvCrosshair=0;

  PickDiff = Level.TimeSeconds - PickupTime;
  XLength = B227_YScale * 77;
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
      if (Hit.IsA('MercCarcass')||Hit.IsA('HumanCarcass')) //considered combatent ally
        Canvas.DrawColor = CyanColor;
      else if (Hit.IsA('NaliCarcass')||Hit.IsA('CowCarcass')) //considered neutral
        Canvas.DrawColor = GreenColor;
      else  //considered enemy carcass
        Canvas.DrawColor = RedColor;
    }
  }
  else if (Hit.IsA('UTHumanCarcass'))
    Canvas.DrawColor = CyanColor;
  else if ((Hit.IsA('projectile')&&!Hit.Isa('TranslocatorTarget'))||Hit.IsA('SludgeBarrel')||Hit.IsA('TarydiumBarrel')) //non-combatent explosives.
    Canvas.DrawColor = GoldColor;
  else if (!Hit.bIsPawn)
    Canvas.DrawColor = WhiteColor;
  else if (Hit.Isa('playerpawn')||(Hit.IsA('Follower')&&Follower(Hit).IsFriend()))  //combatent allies
    Canvas.DrawColor = CyanColor;
  else if (Hit.IsA('Nali')||Hit.IsA('Cow')||Hit.IsA('Bird1')||Hit.IsA('NaliRabbit'))  //neutrals
    Canvas.DrawColor = GreenColor;
  else  //enemies
    Canvas.DrawColor = RedColor;
  Cross = CrossHairTextures[tvCrosshair];
  if( Cross == None )
    Cross = LoadCrosshair(tvCrosshair);
  if (cross == none)
    tvCrossHair=0;
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
  Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);

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
      if (bSSLRaised||playerowner.bShowScores)
        Canvas.SetPos(4, Canvas.ClipY - M128 - Yl);
      else
        Canvas.SetPos(4, Canvas.ClipY - M64 - Yl);
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
          Canvas.DrawColor = RedColor;
        else
            Canvas.DrawColor= GrayColor;
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
    Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);
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
  Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);
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

defaultproperties
{
     NormalStyle=STY_Normal
     HUDConfigWindowType="olextras.tvhudconfig"
     Texture=None
}
