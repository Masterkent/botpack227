// ===============================================================
// XidiaMPack.XidiaAutomag: Simply allows akimbo in SP and more shell time...
// ===============================================================

class XidiaAutomag expands OLautomag;

var travel bool HasTwoMag;

function SetSwitchPriority(pawn Other)   //allows use of ENF properties
{
  local int i;
  local name temp, carried;

  if ( PlayerPawn(Other) != None )
  {
    for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == 'OLautomag' )
      {
        AutoSwitchPriority = i;
        return;
      }
    // else, register this weapon
    carried = 'OLautomag';
    for ( i=AutoSwitchPriority; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++ )
    {
      if ( PlayerPawn(Other).WeaponPriority[i] == '' )
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


function bool HandlePickupQuery( inventory Item )
{
  local int OldAmmo;
  local Pawn P;

  if (Item.class == class)
  {
    if ( Weapon(item).bWeaponStay && slavemag!=None && (!Weapon(item).bHeldItem || Weapon(item).bTossedOut) )
      return true;
    P = Pawn(Owner);

    if ( AmmoType != None )
    {
      OldAmmo = AmmoType.AmmoAmount;
      if ( AmmoType.AddAmmo(Weapon(Item).PickupAmmoCount) && (OldAmmo == 0)
        && (P.Weapon.class != item.class) && !P.bNeverSwitchOnPickup )
          WeaponSet(P);
    }
    if (Level.Game.LocalLog != None)
      Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
    if (Level.Game.WorldLog != None)
      Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
    //message
    if (slavemag!=None)
      P.ClientMessage("You scavenge some ammo",'Pickup');
    else
      P.ClientMessage("Automag Akimbo!",'Pickup');
    //P.ReceiveLocalizedMessage( class'PickupMessagePlus', 0, None, None, Self.Class );

    if (slavemag==None) {
      HasTwoMag=true;     //IMPORTANT: TWO automag TRAVEL VAR.
      slavemag=Spawn(class'Xidiaautomag',owner);
      slavemag.isslave=true;
      slavemag.mastermag=self; //new clip referencing..
      slavemag.setHand(255);
      slavemag.BecomeItem();
      slavemag.BringUp();
      SetTwoHands();
      AIRating = 0.4;
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

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
  local shellcase s;
  local vector realLoc;

  realLoc = Owner.Location + CalcDrawOffset();
//  if (slavemag!=None && ( (iFireAGun==1 && IsInState('AltFiring')) || iFireAGun==0 && IsInState('NormalFire')))
//    s = Spawn(class'ShellCase',Pawn(Owner), '', realLoc + 20 * X + slavemag.FireOffset.Y * Y + Z);
//    else
  s = Spawn(class'LongShellCase',, '', realLoc + 20 * X + FireOffset.Y * Y + Z);
  if ( s != None )
    s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);
  if (Other == Level)
  {
    Spawn(class'olweapons.osWallHitEffect',,, HitLocation+HitNormal*9, Rotator(HitNormal));
  }
  else if ((Other != self) && (Other != Owner) && (Other != None) )
  {
    if ( FRand() < 0.2 )
      X *= 5;
    if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
      && (instigator.IsA('PlayerPawn') || (instigator.IsA('Bot') && !Bot(Instigator).bNovice)||
        (Other.IsA('ScriptedPawn') && (ScriptedPawn(Other).bIsBoss || level.game.difficulty>=3))) ){
        Other.TakeDamage(2*HitDamage, Pawn(Owner), HitLocation, 3000.0*X, 'Decapitated');
    }
    else
      Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 3000.0*X, MyDamageType);
    if ( !Other.bIsPawn && !Other.IsA('Carcass') )
      spawn(class'SpriteSmokePuff',,,HitLocation+HitNormal*9);
    else
      Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);

  }
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
  slavemag=Spawn(class'Xidiaautomag',owner);
  slavemag.isslave=true;
  slavemag.mastermag=self; //new clip referencing..
  slavemag.setHand(255);
  slavemag.BecomeItem();
  slavemag.BringUp();
  SetTwoHands();
  AIRating = 0.4;
  Slavemag.SetDisplayProperties(Style, Texture, bUnlit, bMeshEnviromap);
  SetTwoHands();

}

//no firing code:

simulated function bool clientfire(float value){
  if (owner.region.zone.bwaterzone){
    PlayIdleAnim();
    GotoState('');
    return false;
  }
  else
    return super.clientfire(value);
}

simulated function bool clientaltfire(float value){
  if (owner.region.zone.bwaterzone){
    PlayIdleAnim();
    GotoState('');
    return false;
  }
  else
    return super.clientaltfire(value);
}

function AltFire( float Value ) {

  if (owner.region.zone.bwaterzone){
    GotoState('Idle');
    return;
  }
  else
    super.AltFire(value);

}

function Fire( float Value ) {
  if (owner.region.zone.bwaterzone){
    GotoState('Idle');
    return;
  }
  else
    super.Fire(value);
}

state Idle
{
Begin:
  bPointing=False;
  if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
    Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
  //Disable('AnimEnd');
  if (slavemag!=None && !slavemag.isinstate('newclip'))
    slavemag.LoopAnim('Sway1',0.02, 0.1);
  LoopAnim('Sway1',0.02, 0.1);
  if ( Pawn(Owner).bFire!=0 && !owner.region.zone.bWaterZone) Global.Fire(0.0);
  if ( Pawn(Owner).bAltFire!=0 && !owner.region.zone.bWaterZone) Global.AltFire(0.0);
}

state AltFiring
{
ignores Fire, AltFire, AnimEnd;

Begin:

  FinishAnim();
  if (slavemag!=None)
  slavemag.Playaltstart();
  Playaltstart();
  FinishAnim();
Repeater:
  if (AmmoType.UseAmmo(1))
  {
      iFireAGun=1-iFireAGun;
    if (ifireagun==1&&slavemag!=none)
    slaveclipcount++;
    else if (clipcount<20)
    ClipCount++;

      Pawn(Owner).PlayRecoil(1.5 * FiringSpeed);
    TraceFire(AltAccuracy);
    if (iFireAGun==1 && slavemag!=None)
    slavemag.playrepeatfiring();
    else
    PlayRepeatFiring();
    if (slavemag!=None){
      Sleep(0.13);
    }
     else
    FinishAnim();
  }

  if ( AltAccuracy < 3 )
    AltAccuracy += 0.5;
  if (ifireagun==0&&ClipCount>15) Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
  else if (slaveclipcount>15) Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
  if ( bChangeWeapon )
    GotoState('DownWeapon');
  else if ( (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) || owner.region.zone.bWaterZone)
    GotoState('Idle');
  else if (ClipCount>=20&&(slavemag==none||slaveclipcount>=20)){
    if (slavemag!=none){
      slaverequestreload=true;
      repfire=true;
    }
    GoToState('NewClip');
  }
  else if ( (Pawn(Owner).bAltFire!=0)
    && AmmoType.AmmoAmount>0 )
  {
    if ( PlayerPawn(Owner) == None )
      Pawn(Owner).bAltFire = int( FRand() < AltReFireRate );
    if (clipcount>=20&&slaveclipcount<20&&slavemag!=none&&ifireagun==1){ //we need to sleep to let it catch up.....
  sleep(0.13);
  ifireagun=0;  }
    Goto('Repeater');
  }
  if (/*iFireAGun==1 && */slavemag!=None)
  slavemag.playaltend();
  Playaltend();
  FinishAnim();
  if(slavemag!=None)
  slavemag.PlayAnim('T2', 0.9, 0.05);
  PlayAnim('T2', 0.9, 0.05);
  FinishAnim();
  Finish();
}
simulated state ClientAltFiring
{
Begin:
  WantFinish=true;
  FinishAnim();
  if (slavemag!=None)
    slavemag.Playaltstart();
  Playaltstart();
  FinishAnim();
  wantfinish=false;
  if (iFireAGun==0 && slavemag!=None&&AmmoType.AmmoAmount>0)
    Animend(); //crappy hack :(
Repeater:
//  playerpawn(owner).clientmessage("Repeater BEG!  Anim="@animsequence@"Slavemag anim="@slavemag.animsequence@"iFireAGun="@ifireagun);
  if (AmmoType.AmmoAmount>0)
  {
    Wantfinish=true;
    iFireAGun=1-iFireAGun;
    if (iFireAGun==1 && slavemag!=None)
      slavemag.playrepeatfiring();
    else
      PlayRepeatFiring();
    if (slavemag!=None){
      if (iFireAGun==1&&animsequence=='shot2b'&&IsAnimating())
        Finishanim();
      else{
        WantFinish=false;
        Sleep(0.13);
      }
    }
    else
      FinishAnim();
  }
  //playerpawn(owner).clientmessage("Repeater END!  Anim="@animsequence@"Slavemag anim="@slavemag.animsequence@"iFireAGun="@ifireagun);
  if ( (Pawn(Owner) == None)
      || ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) || owner.region.zone.bWaterZone)
    {
      PlayIdleAnim();
      if (slavemag!=none)
        slavemag.playidleanim();
      GotoState('');
    }
  else if ( !bCanClientFire )
      GotoState('');
  if ((ifireagun==0&&ClipCount>15)||slaveclipcount>15)
   owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
  if (ClipCount>=20&&(slavemag==none||slaveclipcount>=20)){
    if (slavemag!=none)
      slaverequestreload=true;
    GoToState('ClientNewClip');
  }
  else if (Pawn(Owner).bAltFire!=0)
  {
    if (clipcount>=20&&slaveclipcount<20&&slavemag!=none&&ifireagun==1){ //if norm done and out of clip
      WantFinish=false;
      sleep(0.13);
      ifireagun=0;
    }
//    playerpawn(owner).clientmessage("Going back to repeat!  Anim="@animsequence@"Slavemag anim="@slavemag.animsequence@"iFireAGun="@ifireagun);
    Goto('Repeater');
  }
  if (slavemag!=None)
    slavemag.playaltend();
  Playaltend();
  WantFinish=true;
  FinishAnim();
  if(slavemag!=None)
    slavemag.PlayAnim('T2', 0.9, 0.05);
  PlayAnim('T2', 0.9, 0.05);
  FinishAnim();
  WantFinish=false;
  //playerpawn(owner).clientmessage("After finish!  Anim="@animsequence@"Slavemag anim="@slavemag.animsequence@"iFireAGun="@ifireagun);
  //finish:
  if ( (Pawn(Owner) == None)
      || ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) )
    {
      PlayIdleAnim();
      GotoState('');
    }
    else if ( !bCanClientFire )
      GotoState('');
    else if ( Pawn(Owner).bFire != 0 )
      Global.ClientFire(0);
    else if ( Pawn(Owner).bAltFire != 0 )
      Global.ClientAltFire(0);
    else
    {
      PlayIdleAnim();
      GotoState('');
    }
}

//shows clip count (an enhancement)         (idea from AgentX...thankx guys!!! great mod!!!!!!)
simulated function PostRender( canvas Canvas )
{
  local PlayerPawn P;
  local float multiplier;
  P = PlayerPawn(Owner);
  if  (P != None)
  {
      multiplier=0.8; //eh.. ya
        Canvas.DrawColor.B = 0;
    If (slavemag !=none){
  //reverse if left side...)
  if(P.Handedness != 1){
        if (clipcount > 15){       //set colour according to shots left.....
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 0;}
    else{
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;}
    Canvas.SetPos(0.85 * Canvas.ClipX , multiplier* Canvas.ClipY);
            Canvas.Style = ERenderStyle.STY_Translucent;
            Canvas.Font = Canvas.SmallFont;
            Canvas.DrawText("Clip: "$20-clipcount);
            if (slaveclipcount > 15){       //set colour according to shots left.....
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 0;}
    else{
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;}
    Canvas.SetPos(0.05 * Canvas.ClipX ,multiplier * Canvas.ClipY);
            Canvas.Style = ERenderStyle.STY_Translucent;
            Canvas.Font = Canvas.SmallFont;
         Canvas.DrawText("Clip: "$20-slaveclipcount);}
    else{
                if (slaveclipcount > 15){       //set colour according to shots left.....
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 0;}
    else{
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;}
        Canvas.SetPos(0.85 * Canvas.ClipX , multiplier * Canvas.ClipY);
            Canvas.Style = ERenderStyle.STY_Translucent;
            Canvas.Font = Canvas.SmallFont;
            Canvas.DrawText("Clip: "$20-slaveclipcount);
            if (clipcount > 15){       //set colour according to shots left.....
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 0;}
    else{
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;}
    Canvas.SetPos(0.05 * Canvas.ClipX , multiplier * Canvas.ClipY);
            Canvas.Style = ERenderStyle.STY_Translucent;
            Canvas.Font = Canvas.SmallFont;
            Canvas.DrawText("Clip: "$20-clipcount); }}
    else { //doesn't have 2
            if (clipcount > 15){       //set colour according to shots left.....
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 0;}
    else{
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;}
    if(P.Handedness != 1){
      Canvas.SetPos(0.05 * Canvas.ClipX , multiplier * Canvas.ClipY);
      Canvas.Style = ERenderStyle.STY_Translucent;
      Canvas.Font = Canvas.SmallFont;
    }
    else {
      Canvas.SetPos(0.85 * Canvas.ClipX ,multiplier * Canvas.ClipY);
      Canvas.Style = ERenderStyle.STY_Translucent;
      Canvas.Font = Canvas.SmallFont; }
      Canvas.DrawText("Clip: "$20-clipcount);
    }
  }
  Canvas.Reset();
}

defaultproperties
{
     InventoryGroup=2
}
