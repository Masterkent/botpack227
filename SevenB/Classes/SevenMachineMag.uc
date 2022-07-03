// ===============================================================
// SevenB.SevenMachineMag: Machine mag. speed changes, etc.     Enforcer style
// ===============================================================

class SevenMachineMag extends OLautomag;
//skinz
#exec OBJ LOAD FILE="SevenBResources.u" PACKAGE=SevenB

//for tick based anims/firing:
var float tickcount;
var bool bFireDelay;
var() texture MuzzleFlashVariations[5];
var travel bool HasTwoMag;

function float RateSelf( out int bUseAltMode )  //don't use in water
{
  // don't recommend self in water!
  if (owner.region.zone.bwaterzone)
    return -2;
  return Super.RateSelf(bUseAltMode);
}

function Fire(float Value)
{
  if (!owner.region.zone.bWaterZone)
  	Super.Fire(Value);
}

function AltFire( float Value )
{
  if (!owner.region.zone.bWaterZone)
  	Super.AltFire(Value);
}

/*-
simulated event RenderOverlays(canvas Canvas)         //muzzle stuff.....
{
  local PlayerPawn PlayerOwner;

  if ( (bMuzzleFlash > 0) && !Level.bDropDetail )
    MFTexture = MuzzleFlashVariations[Rand(5)];
  PlayerOwner = PlayerPawn(Owner);
  if ( PlayerOwner != None )
  {
    if ( PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV )
      return;
    if (  (Level.NetMode == NM_Client) && (PlayerOwner.Handedness == 2) )
    {
      bHideWeapon = true;
      return;
    }
    if ( !bHideWeapon )
    {
      if ( Mesh == mesh'AutoML' )
        PlayerOwner.Handedness = 1;
      else if (slavemag != none)
        PlayerOwner.Handedness = -1;
    }
  }
  if ( (PlayerOwner == None) || (PlayerOwner.Handedness == 0) )
  {
    if ( AnimSequence == 'Shot2' )
    {
      FlashO = -2 * Default.FlashO;
      FlashY = Default.FlashY * 2.5;
    }
    else
    {
      FlashO = 1.9 * Default.FlashO;
      FlashY = Default.FlashY;
    }
  }
  else if ( AnimSequence == 'Shot2' )
  {
    FlashO = Default.FlashO * 0.3;
    FlashY = Default.FlashY * 2.5;
  }
  else
  {
    FlashO = Default.FlashO;
    FlashY = Default.FlashY;
  }
  if ( !bHideWeapon  )
  {
    if ( PlayerOwner == None )
      bMuzzleFlash = 0;
  }
  multiskins[1]=texture'MAGtwo';  //swap skin so it is displayed only in 1st person
  Super.RenderOverlays(Canvas);
  multiskins[1]=default.MultiSkins[1];
}
*/

simulated event RenderOverlays(canvas Canvas)
{
	local PlayerPawn PlayerOwner;
	local int realhand;

	if ( (bMuzzleFlash > 0) && !Level.bDropDetail )
		MFTexture = MuzzleFlashVariations[Rand(5)];
	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner != None )
	{
		if ( PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV )
			return;
		realhand = PlayerOwner.Handedness;
		if (  (Level.NetMode == NM_Client) && (realHand == 2) )
		{
			bHideWeapon = true;
			return;
		}
		if ( !bHideWeapon )
		{
			if ( Mesh == mesh'AutoML' )
				PlayerOwner.Handedness = 1;
			else if ( slavemag != None )
				PlayerOwner.Handedness = -1;
		}
	}
	if ( (PlayerOwner == None) || (PlayerOwner.Handedness == 0) )
	{
		if ( AnimSequence == 'Shot2' )
		{
			FlashO = -2 * Default.FlashO;
			FlashY = Default.FlashY * 2.5;
		}
		else
		{
			FlashO = 1.9 * Default.FlashO;
			FlashY = Default.FlashY;
		}
	}
	else if ( AnimSequence == 'Shot2' )
	{
		FlashO = Default.FlashO * 0.3;
		FlashY = Default.FlashY * 2.5;
	}
	else
	{
		FlashO = Default.FlashO;
		FlashY = Default.FlashY;
	}
	if ( !bHideWeapon && slavemag != None )
	{
		slavemag.isslave = true;  // keep updating this stuff: no need to replicate
		slavemag.mastermag = self;
		if ( PlayerOwner == None )
			bMuzzleFlash = 0;

		multiskins[1] = texture'MAGtwo';  // swap skin so it is displayed only in 1st person
		super(TournamentWeapon).RenderOverlays(Canvas);
		multiskins[1]=default.MultiSkins[1];

		if ( slavemag != None )
		{
			if ( slavemag.bBringingUp )
			{
				slavemag.bBringingUp = false;
				slavemag.PlaySelect();
			}
			slavemag.RenderOverlays(Canvas);
		}
	}
	else
	{
		multiskins[1] = texture'MAGtwo';  // swap skin so it is displayed only in 1st person
		super(TournamentWeapon).RenderOverlays(Canvas);
		multiskins[1]=default.MultiSkins[1];
	}

	if ( PlayerOwner != None )
		PlayerOwner.Handedness = realhand;
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
  local ut_shellcase s;
  local vector realLoc;
  local int rndDam;
  local int dir;
  if ( PlayerViewOffset.Y >= 0 )
    dir = 1;
  else
    dir = -1;

  realLoc = Owner.Location + CalcDrawOffset();
//if (frand()<0.31415926){     //we don't want too many shell cases....
	  s = Spawn(class'LongUT_ShellCase',Pawn(Owner), '', realLoc + 20 * X + FireOffset.Y * Y + Z);
	  if ( s != None )
  	  s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*dir*Y + (FRand()*0.3+1.0) * Z)*160);
//}
  if (Other == Level)
  {
    if ( IsSlave || (slavemag != None) )
      Spawn(class'osLightWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
    else
      Spawn(class'osWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
  }
  else if ((Other != self) && (Other != Owner) && (Other != None) )
  {
    rndDam = Rand(3) + 4; //avg=5
		if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
      && (instigator.IsA('PlayerPawn') || (instigator.IsA('Bot') && !Bot(Instigator).bNovice)||
        (Other.IsA('ScriptedPawn') && (ScriptedPawn(Other).bIsBoss || level.game.difficulty>=3))) ){
        MyDamageType='Decapitated';
        rndDam*=3; //up to 21. avg=18
    }
    else
      MyDamageType='shot';
    Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, rndDam * 350.0 * X, MyDamageType);
    if ( !Other.IsA('Pawn') && !Other.IsA('Carcass') )
      spawn(class'SpriteSmokePuff',,,HitLocation+HitNormal*9);
  }
}

function SetSwitchPriority(pawn Other)         //uses master priority
{
	super(UIweapons).SetSwitchPriority(Other);
}

simulated function PostRender( canvas Canvas )
{
  local PlayerPawn P;
  local float multiplier;
  P = PlayerPawn(Owner);
  if  (P != None)
  {
	  if (isinstate('clientnewclip')||isinstate('newclip'))
  		bOwnsCrossHair=true;
  	else
    	bOwnsCrossHair = false;
    if(P.Handedness != 1|| p.myhud.isa('challengehud'))
			multiplier=0.8;
		else
			multiplier=0.9;
        Canvas.DrawColor.B = 0;
    If (slavemag !=none){
  //reverse if left side...)
  if(P.Handedness != 1){
        if (clipcount > 29){       //set colour according to shots left.....
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 0;}
    else{
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;}
    Canvas.SetPos(0.85 * Canvas.ClipX , multiplier* Canvas.ClipY);
            Canvas.Style = ERenderStyle.STY_Translucent;
            class'FontInfo'.static.B227_SetStaticScaledSmallFont(Canvas, true);
            Canvas.DrawText("Clip: "$35-clipcount);
            if (slaveclipcount > 29){       //set colour according to shots left.....
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 0;}
    else{
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;}
    Canvas.SetPos(0.05 * Canvas.ClipX ,multiplier * Canvas.ClipY);
            Canvas.Style = ERenderStyle.STY_Translucent;
            class'FontInfo'.static.B227_SetStaticScaledSmallFont(Canvas, true);
         Canvas.DrawText("Clip: "$35-slaveclipcount);}
    else{
                if (slaveclipcount > 29){       //set colour according to shots left.....
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 0;}
    else{
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;}
        Canvas.SetPos(0.85 * Canvas.ClipX , multiplier * Canvas.ClipY);
            Canvas.Style = ERenderStyle.STY_Translucent;
            class'FontInfo'.static.B227_SetStaticScaledSmallFont(Canvas, true);
            Canvas.DrawText("Clip: "$35-slaveclipcount);
            if (clipcount > 29){       //set colour according to shots left.....
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 0;}
    else{
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;}
    Canvas.SetPos(0.05 * Canvas.ClipX , multiplier * Canvas.ClipY);
            Canvas.Style = ERenderStyle.STY_Translucent;
            class'FontInfo'.static.B227_SetStaticScaledSmallFont(Canvas, true);
            Canvas.DrawText("Clip: "$35-clipcount); }}
    else { //doesn't have 2
            if (clipcount > 29){       //set colour according to shots left.....
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 0;}
    else{
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;}
    if(P.Handedness != 1){
    Canvas.SetPos(0.05 * Canvas.ClipX , multiplier * Canvas.ClipY);
            Canvas.Style = ERenderStyle.STY_Translucent;
            class'FontInfo'.static.B227_SetStaticScaledSmallFont(Canvas, true);  }
            else {
            Canvas.SetPos(0.85 * Canvas.ClipX ,multiplier * Canvas.ClipY);
            Canvas.Style = ERenderStyle.STY_Translucent;
            class'FontInfo'.static.B227_SetStaticScaledSmallFont(Canvas, true); }
            Canvas.DrawText("Clip: "$35-clipcount);}

    Canvas.Reset();
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 255;
    Canvas.DrawColor.B = 255;
  }
}

function Finish()
{
  if ( bChangeWeapon )
    GotoState('DownWeapon');
	else if ( PlayerPawn(Owner) == None ){
	  if (owner.region.zone.bWaterZone)
  		GotoState('Idle');
	  else
		  Super(uiweapons).Finish();
	}
  else if ( (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) )
    GotoState('Idle');
  else if (ClipCount>=35&&(slavemag==none||slaveclipcount>=35)){
    if (slavemag!=none){
      repfire=true;
      slaverequestreload=true;
    }
    GoToState('NewClip');
  }
  else if (owner.region.zone.bWaterZone)
  	GotoState('Idle');
  else if (Pawn(Owner).bFire!=0 )
    Global.Fire(0);
  else if (Pawn(Owner).bAltFire!=0 )
    Global.AltFire(0);
  else
    GotoState('Idle');
}

function bool HandlePickupQuery( inventory Item )
{
  local int OldAmmo;
  local Pawn P;

  if (Item.class == class)
  {
    if (Weapon(item).bWeaponStay && (slavemag!=None) && (!Weapon(item).bHeldItem || Weapon(item).bTossedOut) )
      return true;
    P = Pawn(Owner);

    if ( AmmoType != None )
    {
      OldAmmo = AmmoType.AmmoAmount;
      if ( AmmoType.AddAmmo(PickupAmmoCount) && (OldAmmo == 0)
        && (P.Weapon.class != item.class) && !P.bNeverSwitchOnPickup )
          WeaponSet(P);
    }
    if (Level.Game.LocalLog != None)
      Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
    if (Level.Game.WorldLog != None)
      Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
		if (slavemag!=None){
      if (PlayerPawn(Owner) != none && ChallengeHud(PlayerPawn(Owner).myHud) != none)
      P.ClientMessage("You scavenge some ammo",'PickupMessagePlus');
      else
      P.ClientMessage("You scavenge some ammo",'Pickup');}
    else{
      if (PlayerPawn(Owner) != none && ChallengeHud(PlayerPawn(Owner).myHud) != none)
      P.clientmessage("Machine Mag Akimbo!",'PickupMessagePlus');
      else
      P.ClientMessage("Machine Mag Akimbo!",'Pickup');}
    //P.ReceiveLocalizedMessage( class'PickupMessagePlus', 0, None, None, Self.Class );

    if (slavemag==None) {
      HasTwoMag=true;     //IMPORTANT: TWO automag TRAVEL VAR.
      slavemag=Spawn(class,owner);
      slavemag.isslave=true;
      slavemag.mastermag=self; //new clip referencing..
      slavemag.setHand(255);
      slavemag.BecomeItem();
      slavemag.BringUp();
      slaveclipcount = 0; //force (assumes getting all ammo)
      SetTwoHands();
      AIRating = 0.6;
      Slavemag.SetDisplayProperties(Style, Texture, bUnlit, bMeshEnviromap);
    SetTwoHands();
     }
    item.PlaySound(PickupSound);
    item.SetRespawn();
    return true;
  }
  if ( Inventory == None )
    return false;

  return Inventory.HandlePickupQuery(Item);
}

function DropFrom(vector StartLocation)
{
  super.dropfrom(startlocation);
  HasTwoMag=false; //set back var.
}

event TravelPostAccept() //this allows the slave auto to be spawned  (check if more ammo given?)
{
local Pawn P;
  super.TravelPostAccept();
  P = Pawn(Owner);
  if (!hastwoMag||P==none)
    return;
//spawn a slave
  slavemag=Spawn(class'SevenMachineMag',owner);
  slavemag.isslave=true;
  slavemag.mastermag=self; //new clip referencing..
  slavemag.setHand(255);
  slavemag.BecomeItem();
  slavemag.BringUp();
  SetTwoHands();
  AIRating = 0.6;
  Slavemag.SetDisplayProperties(Style, Texture, bUnlit, bMeshEnviromap);
  SetTwoHands();

}
function SetTwoHands()
{
  if ( Slavemag == None )
    return;

  if ( (PlayerPawn(Owner) != None) && (PlayerPawn(Owner).Handedness == 2) )
  {
    SetHand(2);
    return;
  }

  if ( Mesh == mesh'AutoML' )
    SetHand(1);
  else
    SetHand(-1);
}

function setHand(float Hand)
{
  if ( Hand == 2 )
  {
    bHideWeapon = true;
    Super(uiweapons).SetHand(Hand);
    return;
  }

  if ( Slavemag != None )
  {
    if ( Hand == 0 )
      Hand = -1;
    Slavemag.SetHand(-1 * Hand);
  }
  Super(uiweapons).SetHand(Hand);
  if ( Hand == 1 )
    Mesh = mesh'AutoML';
  else
    Mesh = mesh'AutoMR';
}

function PlayFiring() /*buggy?*/        //4x as fast!
{
  Owner.PlaySound(FireSound, SLOT_None,2.0*Pawn(Owner).SoundDampening);
  //PlayAnim('Shoot',0.5 + 0.31 * FireAdjust, 0.02);
  if (iFireAGun==1 && slavemag!=None) {
    	slavemag.LoopAnim('Shoot',2, 0.01);
		}
     else{
    LoopAnim('Shoot',2, 0.01);
	}
}

function PlayRepeatFiring()    //4x as fast!
{
  if ( Affector != None )
    Affector.FireEffect();
  if ( PlayerPawn(Owner) != None &&playerpawn(owner).player.IsA('viewport'))
  {
    PlayerPawn(Owner).ClientInstantFlash( -0.2, vect(325, 225, 95));
    PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
  }
	Owner.PlaySound(FireSound, SLOT_None,2.0*Pawn(Owner).SoundDampening);
  LoopAnim('Shot2', 2.3, 0.02);
}

function PlayIdleSide()    //sideways idle anim
{
  PlayAnim('Shot2', 0.01, 1);
}
function GiveAmmo( Pawn Other ) //set clip count
{
	super(uiweapons).GiveAmmo(Other);
  If (35<Ammotype.ammoamount)  //assumes single machine mag!
  	ClipCount = 0;
  else
  	ClipCount = 35-Ammotype.ammoamount;
}

state Active
{

Begin:
 /*
  if (ammotype!=none&&!isslave){
  If (slavemag==none){   //simple check......
  if (34<ammotype.ammoamount)
  clipcount=0;
  else
  clipcount=35-ammotype.ammoamount;
  }
  else{
  If (69<ammotype.ammoamount){                   //complex: gotta make sure we have enough ammo to fill the clips....
  ClipCount = 0;
  Slaveclipcount = 0;}
  else{
  if (ifireagun==1){ //base by primary
  clipcount=(70-ammotype.ammoamount)/2;
  slaveclipcount=(70-ammotype.ammoamount)-clipcount;} //give it the remaining amount....
  else{ //based on slave
  slaveclipcount=(70-ammotype.ammoamount)/2;
  clipcount=(70-ammotype.ammoamount)-slaveclipcount;}
  }}
       }
  */
  if (isslave)   //get the slave outa here!
  gotostate('');
  else{
  FinishAnim();
  if ( bChangeWeapon )
    GotoState('DownWeapon');
  bWeaponUp = True;
  bCanClientFire = true;
  /*-if ( (Level.Netmode != NM_Standalone) && (Owner != None)
    && Owner.IsA('TournamentPlayer')
    && (PlayerPawn(Owner).Player != None)
    && !PlayerPawn(Owner).Player.IsA('ViewPort') )
  {
    if (  bForceFire ||Pawn(Owner).bFire != 0 )
      TournamentPlayer(Owner).SendFire(self);
    else if ( bForceAltFire ||Pawn(Owner).bAltFire != 0 )
      TournamentPlayer(Owner).SendAltFire(self);
    else if ( !bChangeWeapon )
      TournamentPlayer(Owner).UpdateRealWeapon(self);
  }*/
  Finish();
}      }

//newclip animations.....
function playeject(){
PlayAnim('Eject',1.5,0.05);
Owner.PlaySound(Misc2Sound, SLOT_None,1.0*Pawn(Owner).SoundDampening);
}

function playselectclip(){
Owner.PlaySound(SelectSound, SLOT_None,1.0*Pawn(Owner).SoundDampening);
PlayAnim('Select',1.6,0.07);
}

////////////////////////////////////////////////////////
state NewClip     //THE SLAVE CAN BE IN THIS STATE!
{
ignores Fire, AltFire, animend;
 function tick(float delta){
   if (trytick&&!isslave&&!slaveprevent){
    trytick=false;
    if ( bChangeWeapon )
      GotoState('DownWeapon');
    if (!owner.region.zone.bWaterZone){
			if (Pawn(Owner).bFire!=0)
  	    Global.Fire(0);
    	else if ( Pawn(Owner).bAltFire!=0 )
      	Global.AltFire(0);
    	else
      	GotoState('Idle');
      }
    }
 }
 begin:
  //bcanclientfire=false;
  //hack sorta to play cockgun (only works if the mesh is in wating state).  I like Hasanim!!!!
  if (isslave&&mastermag==none)
  log ("mastermag equaled none!");
  if ((pawn(owner)!=None)&&owner.animsequence!=''&&(pawn(owner).GetAnimGroup(pawn(owner).AnimSequence) == 'waiting')&&(pawn(owner).hasanim('cockgun')))
  Pawn(owner).PlayAnim('CockGun',, 0.3);
  Playeject();
  FinishAnim();
  If (!isslave&&slavemag==none){   //simple check......
  if (34<ammotype.ammoamount)
  clipcount=0;
  else
  clipcount=35-ammotype.ammoamount;
  }
  else{
  If (!isslave&&69<ammotype.ammoamount)                   //complex: gotta make sure we have enough ammo to fill the clips....
  ClipCount = 0;
  else if (isslave&&69<mastermag.ammotype.ammoamount)
  mastermag.slaveclipcount=0;
  else{
  if (!isslave)
  clipcount=(70-ammotype.ammoamount)/2;
  else
  mastermag.slaveclipcount=(70-mastermag.ammotype.ammoamount)-mastermag.clipcount; //give it the remaining amount....
  }}
  if (!isslave&&slaverequestreload&&slavemag!=none){
    slaverequestreload=false;
    slavemag.gotostate('newclip');
    slaveprevent=true;
  }
  Playselectclip();
  FinishAnim();
  //bcanclientfire=true;
 // reloadnow=false;
 if (isslave) {
  mastermag.slaveprevent=false;
  playidleanim();
  Gotostate('');
 }
 else
  trytick=true; //launch ticker....
}

state NormalFire
{
ignores Fire, AltFire, AnimEnd;

  function BeginState()
  {
    tickcount=0;
    bFireDelay=true;
    Enable('tick');
  }

  function Tick( float DeltaTime )  //better timing
  {
    tickCount+=deltatime*1000;
    if (tickCount>=66.87){        //increments of 1/2 fire time
      TickCount-=66.87;
      bFireDelay=false;
    }
    if( Owner == None )
    {
      AmbientSound = None;
    }
  }
  function EndState()
  {
    Super(uiweapons).EndState();
    OldFlashCount = FlashCount;
  }

Begin:
 FlashCount++;
 if (ifireagun==1&&slavemag!=none&&slaveclipcount<35){
  slavemag.bMuzzleFlash++;
 	slaveclipcount++;
 }
 else if (clipcount<35){
 	ClipCount++;
  bMuzzleFlash++; //do steady flash?
 }
 if (iFireAGun==1 && slavemag!=None) {
  while (bFireDelay) //hold..
    Sleep(0.0);
  bFireDelay=true;
  }
  else {
	  while (bFireDelay) //hold..
   	 Sleep(0.0);
  	bFireDelay=true;
    if (slavemag==None){ //another hold
	  	while (bFireDelay)
  	 	 Sleep(0.0);
  		bFireDelay=true;
  	}
  }
  if (ifireagun==0&&ClipCount>29) Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
  else if (slaveclipcount>29) Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
 iFireAGun=1-iFireAGun;
  if ( bChangeWeapon ){
		GotoState('DownWeapon');
  }
//  else if ( PlayerPawn(Owner) == None )    UsAaR33: pawns obey same rulez as players.....
  //  Super.Finish();
  else if ( (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) )
    GotoState('Idle');
  else if (ClipCount>=35&&(slavemag==none||slaveclipcount>=35)){
    if (slavemag!=none){
      slavemag.PlayIdleAnim();
			slaverequestreload=true;
      repfire=true;
     }
  	GoToState('NewClip');
  }
  else if (clipcount>=35&&slaveclipcount<35&&slavemag!=none&&ifireagun==0){ //we need to sleep to let it catch up.....
    PlayIdleAnim();
	  while (bFireDelay) //hold..
  	  Sleep(0.0);
  	bFireDelay=true;
  	ifireagun=1;
  	if ( Pawn(Owner).bFire!=0 && !owner.region.zone.bWaterZone) Global.Fire(0);
  	else if ( Pawn(Owner).bAltFire!=0 && !owner.region.zone.bWaterZone)Global.AltFire(0);
	}
  else if (clipcount<35&&slaveclipcount>=35&&slavemag!=none&&ifireagun==1){ //we need to sleep to let it catch up.....
    slavemag.PlayIdleAnim();
	  while (bFireDelay) //hold..
  	  Sleep(0.0);
  	bFireDelay=true;
  	ifireagun=0;
  	if ( Pawn(Owner).bFire!=0 && !owner.region.zone.bWaterZone) Global.Fire(0);
  	else if ( Pawn(Owner).bAltFire!=0 && !owner.region.zone.bWaterZone)Global.AltFire(0);
	}
  else if ( Pawn(Owner).bFire!=0 && !owner.region.zone.bWaterZone) Global.Fire(0);
  else if ( Pawn(Owner).bAltFire!=0 && !owner.region.zone.bWaterZone)Global.AltFire(0);
  GoToState('Idle');
}

state AltFiring      //might be real risky using firedelay to control anims!
{
ignores Fire, AltFire, AnimEnd;

  function BeginState()
  {
    tickcount=0;
    bFireDelay=true;
    Enable('tick');
  }
  function EndState()
  {
    Super(uiweapons).EndState();
    OldFlashCount = FlashCount;
  }
  function Tick( float DeltaTime )  //better timing
  {
    tickCount+=deltatime*1000;
    if (tickCount>=43.33){        //increments of 1/2 fire time
      TickCount-=43.33;
      bFireDelay=false;
    }
    if( Owner == None )
    {
      AmbientSound = None;
    }
  }

Begin:
  FinishAnim();
	if (iFireAGun==0 && slavemag!=none && slaveclipcount>=35)
		iFireAGun=1;
	else if (iFireAGun==1 && clipcount>=35)
		iFireAGun=0;
	Repeater:
  if (AmmoType.UseAmmo(1))
  {
    FlashCount++;
    iFireAGun=1-iFireAGun;
    if (ifireagun==1&&slavemag!=none)
    slaveclipcount++;
    else if (clipcount<35)
    ClipCount++;

      Pawn(Owner).PlayRecoil(1.5 * FiringSpeed);
    TraceFire(AltAccuracy);
    if (iFireAGun==1 && slavemag!=None){
   		slavemag.bMuzzleFlash++;
			slavemag.playrepeatfiring();
   	}
    else{
			bMuzzleFlash++;
    	PlayRepeatFiring();
    }
  	while (bFireDelay)
  	 	 Sleep(0.0);
 		bFireDelay=true;
    if (slavemag==None){ //another if no slave
  		while (bFireDelay)
  	 		 Sleep(0.0);
 			bFireDelay=true;
 		}
  }

  if ( AltAccuracy < 3 )
    AltAccuracy += 0.5;
  if (ifireagun==0&&ClipCount>29)
		Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
  else if (slaveclipcount>29)
		Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
  if ( bChangeWeapon )
    GotoState('DownWeapon');
  else if ( (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) )
    GotoState('Idle');
  else if (ClipCount>=35&&(slavemag==none||slaveclipcount>=35)){
    if (slavemag!=none){
      slaverequestreload=true;
      repfire=true;
    }
	  if(slavemag!=None)
  		slavemag.PlayAnim('T2', 0.9, 0.05);
  	PlayAnim('T2', 0.9, 0.05);
  	FinishAnim();
    GoToState('NewClip');
  }
  else if ( (Pawn(Owner).bAltFire!=0 && !owner.region.zone.bWaterZone)
    && AmmoType.AmmoAmount>0 )
  {
    if ( PlayerPawn(Owner) == None )
      Pawn(Owner).bAltFire = int( FRand() < AltReFireRate );
    if (clipcount>=35&&slaveclipcount<35&&slavemag!=none&&ifireagun==1){ //we need to sleep to let it catch up.....
 			PlayIdleSide();
  		while (bFireDelay)
  	 		 Sleep(0.0);
 			bFireDelay=true;
  		ifireagun=0;
		}
		else if (clipcount<35&&slaveclipcount>=35&&slavemag!=none&&ifireagun==0){ //we need to sleep to let it catch up.....
 			SevenMachineMag(slavemag).PlayIdleSide();
  		while (bFireDelay)
  	 		 Sleep(0.0);
 			bFireDelay=true;
  		ifireagun=1;
		}
    Goto('Repeater');
  }
  if(slavemag!=None)
  	slavemag.PlayAnim('T2', 0.9, 0.05);
  PlayAnim('T2', 0.9, 0.05);
  FinishAnim();
  Finish();
}

function PlayIdleAnim()
{
  if ( Mesh == PickupViewMesh )
    return;
  if ( (FRand()>0.96) && (AnimSequence != 'Twiddle') )
    PlayAnim('Twiddle',0.6,0.3);
  else
    LoopAnim('Sway',0.2, 0.3);
}

state Idle
{
  //tick tock tick tock....the timer is too slow (1.5 sec) and used for waiting anyway, so we got tick used to detect reload calls...
  event Tick(float DeltaTime) {
  /*global.tick(deltatime);
        If ((Pawn(Owner)!=None)&&(Playerpawn(owner)==None)) {
        If ((20-clipcount<AmmoType.AmmoAmount)&&(Pawn(Owner).enemy==None)&&(clipcount!=0))            //we don't want to reload if all the ammo is actually IN the clip...
      //had problems reloading both....  h4x....  we can't let it reload if that's all the ammo (i.e. all ammo is in clips)
      Gotostate ('Newclip');  }           just reload the damn thing......       */
      local bool mastertostate;
      if (ammotype==none){log("ammotype fawked up!"); return; }
      if (pawn(owner)==none) return;
if (isslave)  //do not tick the slave.....
  return;
if (slavemag==none){ //simple reload
If (((Playerpawn(owner)!=None&&(playerpawn(owner).bextra3!=0))||(Playerpawn(owner)==none&&Pawn(Owner).enemy==None))&&(35-clipcount<AmmoType.AmmoAmount)&&(clipcount!=0))   //play the anim and goto the state
Gotostate('newclip');}
else{ //complex reload...
If (((Playerpawn(owner)!=None&&(playerpawn(owner).bextra3!=0))||(Playerpawn(owner)==none&&Pawn(Owner).enemy==None))&&(70-(clipcount+slaveclipcount)<ammotype.ammoamount)&&(clipcount!=0)){
  RepFire=true;
  Gotostate('newclip');
  mastertostate=true;
}
if (((Playerpawn(owner)!=None&&(playerpawn(owner).bextra3!=0))||(Playerpawn(owner)==none&&Pawn(Owner).enemy==None))&&(70-(clipcount+slaveclipcount)<ammotype.ammoamount)&&(slaveclipcount!=0)){
  if (!mastertostate){
		if (!slavemag.IsInState('NewClip'))
			slavemag.gotostate('newclip');
	}
  else
    slaverequestreload=true;
  }
}

  }
Begin:
  bPointing=False;
  if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
    Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
  //Disable('AnimEnd');
  if (slavemag!=None && !slavemag.isinstate('newclip'))
    slavemag.PlayIdleAnim();
  PlayIdleAnim();
  if ( Pawn(Owner).bFire!=0 && !owner.region.zone.bWaterZone) Global.Fire(0.0);
  if ( Pawn(Owner).bAltFire!=0 && !owner.region.zone.bWaterZone) Global.AltFire(0.0);
}

function AnimEnd()
{
  if ( (Level.NetMode == NM_Client) && bBringingUp  && (Mesh != PickupViewMesh) )
  {
    bBringingUp = false;
    PlaySelect();
  }
  else if (isslave&&mastermag!=none&&(mastermag.isinstate('')||mastermag.IsInState('idle')||animsequence=='select'))
     PlayIdleAnim();
  else if (!isslave)
    Super(TournamentWeapon).AnimEnd();
}

function ReloadCheck(){ //for state ticks
  if (role<role_authority&&playerpawn(owner)!=none&&bool(pawn(owner).bextra3)!=owner.bShadowCast){
    owner.bshadowcast=!owner.bshadowcast;
    if (owner.bshadowcast) //now reload
      reload();
    else
      stopreload();
  }
}

defaultproperties
{
     MuzzleFlashVariations(0)=Texture'Botpack.Skins.Muz1'
     MuzzleFlashVariations(1)=Texture'Botpack.Skins.Muz2'
     MuzzleFlashVariations(2)=Texture'Botpack.Skins.Muz3'
     MuzzleFlashVariations(3)=Texture'Botpack.Skins.Muz4'
     MuzzleFlashVariations(4)=Texture'Botpack.Skins.Muz5'
     AmmoName=Class'SevenB.MachineMagClip'
     PickupAmmoCount=35
     AIRating=0.300000
     RefireRate=0.910000
     AltRefireRate=0.980000
     FireSound=Sound'Botpack.enforcer.E_Shot'
     CockingSound=Sound'Botpack.enforcer.Cocking'
     SelectSound=Sound'Botpack.enforcer.Cocking'
     bDrawMuzzleFlash=True
     MuzzleScale=1.000000
     FlashY=0.100000
     FlashO=0.020000
     FlashC=0.035000
     FlashLength=0.010000
     FlashS=128
     MFTexture=Texture'Botpack.Skins.Muz1'
     bAmbientGlow=False
     PickupMessage="You got the Machine Mag."
     ItemName="Machine Mag"
     PlayerViewOffset=(X=3.300000,Y=-2.000000,Z=-3.000000)
     PlayerViewMesh=LodMesh'Botpack.AutoML'
     PickupViewMesh=LodMesh'Botpack.MagPick'
     ThirdPersonMesh=LodMesh'Botpack.AutoHand'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzEF3'
     MuzzleFlashScale=0.080000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy2'
     bHidden=True
     Mesh=LodMesh'Botpack.MagPick'
     MultiSkins(0)=Texture'SevenB.MAGone'
     MultiSkins(1)=Texture'SevenB.MAGthridskin'
     MultiSkins(2)=Texture'SevenB.MAGthree'
     MultiSkins(3)=Texture'SevenB.MAGfour'
     CollisionRadius=24.000000
     CollisionHeight=12.000000
     RotationRate=(Yaw=0)
}
