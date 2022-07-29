// ============================================================
// olextras.tvmutator: Handles various tricks...
// ============================================================

class tvmutator expands spoldskool;

//the following takes in damage. Passes to coop game or sp
function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation,
            out Vector Momentum, name DamageType)
{
  if (level.game.IsA('tvsp'))
    TVSP(level.game).ScoreDamage(ActualDamage,Victim,InstigatedBy);
  else if (level.game.IsA('tvcoop'))
    tvcoop(level.game).ScoreDamage(ActualDamage,Victim,InstigatedBy);
}
function prebeginplay(){ //disable all swaps (cannot use always keep do to icons
bBioRifle=false;
oBioRifle=false;
basmd=false; //all to UI weapons (sktrooper swapping)
bstingy=false;
brazor=false;
bflak=false;
bmini=false;
beball=false;
brifle=false;
bmag=false;
bdamage=false;
bmed=false;
bjump=false;
bdamage=false;
bpad=false;
bmegahealth=false;
barmor=false;
bshield=false;
Super.PreBeginPlay();
class'olKraalBolt'.default.maxspeed=10000;
class'ol1337krallBolt'.default.maxspeed=10000;
//hacks to access projectiles:
class'olslithprojectile'.default.bGameRelevant=false;
class'ExplosionChain'.default.bGameRelevant=false;

	if (Level.NetMode == NM_Standalone)
		B227_AddONPSPFix();
}
   /*
function bool PreventDeath(Pawn Killed, Pawn Killer, name damageType, vector HitLocation)
{

  if (damageType == 'Gibbed' && Killer != NONE )
  {
   //reset health.....
    if (Killed.Health < -999)           //telefrag sets health to -1000
    Killed.Health = Killed.Default.Health;
    log ("Player tried to telefrag a baddie");
    return true;
   }
   //next mutator
   if ( NextMutator != None )
    return NextMutator.PreventDeath(Killed,Killer, damageType,HitLocation);
  return false;
 }   */

//For setting heads to green.  Assumes only 1 unique texture has been set!
function MinipulateSkin (actor Other, actor In){
  local int i, j;
  for (i=0;i<8;i++)
    if (in.multiskins[i]!=none){
      for (j=0;j<8;j++)
        Other.multiskins[j]=in.multiskins[i];
      Other.Skin=in.multiskins[i];
      return;
    }
  if (in.skin==none)
    return;
  other.skin=in.skin;
  for (j=0;j<8;j++)
    Other.multiskins[j]=in.skin;
}
//convert explosion chains to the UT style one
function actor ReplaceNonInv(Actor other,class<actor> NewC){
  local actor A;
  if
  (  (level.game.Difficulty==0 && !Other.bDifficulty0 ) //filters
  ||  (level.game.Difficulty==1 && !Other.bDifficulty1 )
  ||  (level.game.Difficulty==2 && !Other.bDifficulty2 )
  ||  (level.game.Difficulty>=3 && !Other.bDifficulty3 )
  ||  (!Other.bSinglePlayer && (Level.NetMode==NM_Standalone) )
  ||  (!Other.bNet && (Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer )) )
    return none;
  if( FRand() > Other.OddsOfAppearing )
    return none;
  A = Spawn(NewC,other.owner,Other.tag,Other.Location, Other.Rotation);
  if ( A != None )
  {
    A.event = Other.event;
    A.tag = Other.tag;
    A.SetCollision(Other.bCollideActors,Other.bBlockActors,Other.bBlockPlayers);
    A.bCollideWorld=Other.bCollideWorld;
    A.bProjTarget=Other.bProjTarget;
    A.SetCollisionSize(Other.CollisionRadius,Other.CollisionHeight);
  }
  return A;
}
function ReplaceExploChain(ExplosionChain other){
  local TVExplosionChain A;
  A=TVExplosionChain(ReplaceNonInv(Other,class'TvExplosionChain'));
  if (A==none)
    return;
  A.MomentumTransfer = Other.MomentumTransfer;
  A.Damage = Other.Damage;
  A.Size = Other.Size;
  A.Delaytime = Other.Delaytime;
  A.bOnlyTriggerable = Other.bOnlyTriggerable;
}
function ReplaceTransEvent(TranslatorEvent other){
  local TvTranslatorEvent A;
  A=TvTranslatorEvent(ReplaceNonInv(Other,class'TvTranslatorEvent'));
  if (A==none)
    return;
  A.Message=Other.Message;
  A.AltMessage=Other.AltMessage;
  A.NewMessageSound=Other.NewMessageSound;
  A.bTriggerAltMessage=Other.bTriggerAltMessage;
  A.ReTriggerDelay=Other.ReTriggerDelay;
}
//ENFORCER REPLACEMENT!
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
local bool bRetVal;
local float Dif;
if (other.class==class'ONPLevelInfo'){ //found level info!
  if (level.game.IsA('tvsp'))
    tvsp(level.game).RegisterONPLevelInfo(other);
  else if (level.game.Isa('tvcoop'))
    tvcoop(level.game).RegisterONPLevelInfo(other);
  return true;
}
if (other.class==class'enforcer'){ //replace ENF
  bmini=true;    //so ammo works right...
  ReplaceWith(Other, "olextras.SPEnf");
  bmini=false;
  return false;    //always remove ENF
}
if (other.class==class'dispersionpistol'||other.class==class'oldpistol'){ //replace pistol
  ReplaceWith(Other, "olextras.NoammoDpistol");
  return false;    //always remove ENF
}
if (other.class==class'ExplosionChain'){
  ReplaceExploChain(ExplosionChain(other));
  return false;
}
if (other.class==class'TranslatorEvent'){  //for co-op translator
  ReplaceTransEvent(TranslatorEvent(other));
  return false;
}
if (Other.class==class'PulseGun'||Other.class==class'ospulsegun'){ //hack to swap projectiles here
  ReplaceWith(Other, "olextras.TVPulsegun");
  return false;
}
if (Other.class==class'ut_eightball'){
  ReplaceWith(Other, "olextras.TVEightball");
  return false;
}
//for co-op supportive inv items:
if (Other.class==class'translator'){
  ReplaceWith(Other, "olextras.TVtranslator");
  return false;
}
if (Other.class==class'flashlight'){
  ReplaceWith(Other, "olextras.TvFlashlight");
  return false;
}
if (Other.class==class'searchlight'){
  ReplaceWith(Other, "olextras.TVSearchLight");
  return false;
}
if (Other.IsA('WarHeadLauncher')||Other.IsA('uDamage')){
  ReplaceWith(Other,"olextras.SuperAmmoShockRifle");
  return false;
}
if (Other.IsA('ImpactHammer')||Other.IsA('ChainSaw')||Other.IsA('UT_Invisibility')||Other.IsA('UT_JumpBoots')){
  ReplaceWith(Other,"olWeapons.osDispersionpowerup");
  return false;
}
if (Other.class==class'UT_ShieldBelt'){
  ReplaceWith(Other,"olWeapons.ospowershield");
  return false;
}
if (Level.Game.class==class'MonsterSmash'){
 if (Other.IsA('Trigger')&&Trigger(Other).TriggerType==0) //let pawns use triggers and movers
   Trigger(Other).TriggerType=TT_PawnProximity;
 if (Other.IsA('Mover')&&Mover(Other).BumpType==0)
   Mover(Other).BumpType=BT_PawnBump;
 if (Other.IsA('ControlPoint')||Other.Isa('FlagBase'))
   MonsterSmash(level.game).bTranslocator=true;
 if (Other.IsA('FortStandard')){
   FortStandard(Other).FallBackFort='';
   FortStandard(Other).DestroyFort(none);
 }
 if (Other.Isa('TeamCannon')&&TeamCannon(Other).Deactivatesound!=Sound'UnrealI.CannonExplode')
   return false;
}
if (Level.NetMode!=nm_standalone&&(Other.Isa('PlayerMotionFreeze')||Other.IsA('ViewSpot')||Other.IsA('ViewSpotStop')))
  return false; //no cutscenes in co-op!
//if (other.isa('pickup')&&!other.isa('ammo')&&!other.isa('amplifier')) //no pickup options
//return true;
//-if (other.Isa('MoviePawn')) //UMS movie hack
//-  pawn(other).Shadow = Spawn(class'TVpawnShadow',other,,other.location);
if (other.isa('scriptedpawn')){
  //-if (other.style==STY_NORMAL&&(other.isa('skaarjwarrior')||other.isa('krall')||other.isa('warlord')||other.isa('Slith')||other.isa('manta')))
  //-  other.style=STY_MASKED; //fix up masking bug on pawns
  if (class'olweapons.uiweapons'.default.busedecals){
    //-if (!other.isa('tentacle'))     //no decal for them.
    //-    scriptedpawn(other).Shadow = Spawn(class'TVpawnShadow',other,,other.location);
    if (scriptedpawn(other).RangedProjectile==Class'UnrealShare.BruteProjectile')
      scriptedpawn(other).RangedProjectile=Class'TvBruteProjectile';
    if (scriptedpawn(other).RangedProjectile==Class'Unreali.mercrocket')
      scriptedpawn(other).RangedProjectile=Class'Tvmercrocket';
    else if (scriptedpawn(other).RangedProjectile==Class'UnrealI.GasBagBelch')
      scriptedpawn(other).RangedProjectile=Class'TvGasBagBelch';
    else if (scriptedpawn(other).RangedProjectile==Class'UnrealI.KraalBolt')
      scriptedpawn(other).RangedProjectile=Class'oldskool.olkraalbolt';
    else if (scriptedpawn(other).RangedProjectile==Class'UnrealI.EliteKrallBolt')
      scriptedpawn(other).RangedProjectile=Class'oldskool.ol1337krallbolt';
    else if (scriptedpawn(other).RangedProjectile==Class'Unrealshare.skaarjprojectile')           //no slith thankz to the hitwall not being simulated (and me too lazy to redo it ;)
      scriptedpawn(other).RangedProjectile=Class'olextras.TVSkaarjProjectile';
    else if (scriptedpawn(other).RangedProjectile==Class'Unreali.queenprojectile')
      scriptedpawn(other).RangedProjectile=Class'oldskool.olqueenprojectile';
    else if (scriptedpawn(other).RangedProjectile==Class'Unrealshare.tentacleprojectile')
      scriptedpawn(other).RangedProjectile=Class'oldskool.oltentacleprojectile';
    else if (scriptedpawn(other).RangedProjectile==Class'SlithProjectile')
      scriptedpawn(other).RangedProjectile=Class'olSlithProjectile';
    else if (scriptedpawn(other).RangedProjectile==Class'Unreali.warlordrocket')
      scriptedpawn(other).RangedProjectile=Class'Tvwarlordrocket';
  }
  if (ClassIsChildOf(ScriptedPawn(other).CarcassType, class'CreatureCarcass') &&
      ScriptedPawn(other).CarcassType == ScriptedPawn(other).default.CarcassType)
  {
    if (other.style!=STY_Translucent)
      scriptedpawn(other).carcasstype=class'olCreatureCarcass';
    else{
      scriptedpawn(other).carcasstype=class'TranslucentCreatureCarcass';
      scriptedpawn(other).bGreenBlood=true; //for MClane's green skaarj.  Will affect all translucent creatures however!
    }
  }
  if (!Other.Isa('follower')){ //projectile speed thing
    Dif=FClamp(pawn(other).Skill+level.game.Difficulty, 0, 3);
    if (Dif>1.0)
     scriptedpawn(other).projectilespeed*=0.9+0.1*Dif;
  }
  if (Other.Isa('Nali')&&Other.bShadowCast==true){
    if (TVSP(level.game)!=none)
      TVSP(level.game).GivePickup(class'Tvflashlight',pawn(other));
    if (TvCoop(level.game)!=none)
      TvCoop(level.game).GivePickup(class'Tvflashlight',pawn(other));
  }
  //Skaarj weapontype swaps. Use case statements???
  if ( Other.IsA('skaarjtrooper')){
    if (skaarjtrooper(Other).weapontype==Class'unreali.Stinger')
      skaarjtrooper(Other).weapontype=Class'olweapons.TVPulsegun';
    else if ( skaarjtrooper(Other).weapontype==Class'unreali.Rifle')
      skaarjtrooper(Other).weapontype=Class'botpack.SniperRifle';
    else if (skaarjtrooper(Other).weapontype==Class'unreali.Razorjack')
      skaarjtrooper(Other).weapontype=Class'botpack.ripper';
    else if ( skaarjtrooper(Other).weapontype==Class'unreali.Minigun')
      skaarjtrooper(Other).weapontype=Class'botpack.Minigun2';
    else if ( skaarjtrooper(Other).weapontype==Class'unreali.automag'||skaarjtrooper(Other).weapontype==Class'enforcer')                         //no special mags allowed in SP......
      skaarjtrooper(Other).weapontype=Class'spEnf';
    else if ( skaarjtrooper(Other).weapontype==Class'Eightball' || skaarjtrooper(Other).weapontype==Class'UT_Eightball')
      skaarjtrooper(Other).weapontype=Class'TVEightball';
    else if (skaarjtrooper(Other).weapontype==Class'FlakCannon')
      skaarjtrooper(Other).weapontype=Class'botpack.UT_flakcannon';
    else if ( skaarjtrooper(Other).weapontype==Class'unreali.ASMD')
      skaarjtrooper(Other).weapontype=Class'olweapons.osShockRifle';
    else if ( skaarjtrooper(Other).weapontype==Class'GesBioRifle')
      skaarjtrooper(Other).weapontype=Class'botpack.UT_BioRifle';
    else if ( skaarjtrooper(Other).weapontype==Class'dispersionpistol'||SkaarjTrooper(Other).WeaponType==class'oldpistol')           //always change......
      skaarjtrooper(Other).weapontype=Class'NoammoDpistol';
    else if ( skaarjtrooper(Other).weapontype==Class'shockrifle')
      skaarjtrooper(Other).weapontype=Class'olweapons.osshockrifle';
    else if ( skaarjtrooper(Other).weapontype==Class'pulsegun'||skaarjtrooper(Other).weapontype==Class'OsPulsegun')
      skaarjtrooper(Other).weapontype=Class'olweapons.TVPulsegun';
  }
  return true;
}
else if (other.class==class'tree5'||other.class==class'tree6'){ //replace palm trees w/ new mesh
  other.mesh=class'leetpalm'.default.mesh;
  other.prepivot.z-=16*other.drawscale;
  other.MultiSkins[0]=Texture'Jdmisgay12';
//  other.MultiSkins[0].DrawScale=0.96;
  if (other.class==class'tree5')
    other.drawscale*=3.3;
  else
    other.drawscale*=3.85;
  other.SetCollisionSize(0.8*other.collisionradius,other.collisionheight);
}
else if ((other.Isa('SlithProjectile')||Other.Isa('bruteprojectile'))&&scriptedpawn(other.instigator)!=none){   //projectile speed isn't used?
  Dif=FClamp(other.instigator.Skill+level.game.Difficulty, 0, 3);
  if (Dif>1.0)
    Projectile(other).speed*=0.9+0.1*Dif;
  Projectile(other).maxspeed=10000;
}
//various hacks:
else if (Other.IsA('CreatureChunks')&&other.Instigator!=none&&Other.Instigator.Style==STY_Translucent){
  Other.Style=STY_Translucent;
  CreatureChunks(Other).bGreenBlood=true;
  MinipulateSkin(Other,Other.Instigator);   //go greeb
}
else if (Other.IsA('olCreatureCarcass')&&Other.Instigator!=none){
  if (Other.Instigator.IsA('Follower'))
    Carcass(Other).Rats=byte(Follower(Other.Instigator).IsFriend());
  else if (Other.Instigator.IsA('Nali')||Other.Instigator.IsA('cow'))
    Carcass(Other).Rats=2;
}
bretval=super.checkreplacement(other,bsuperrelevant);        //very important :D
if (Other.Isa('inventory')) //set all messages!
  class'UTC_Inventory'.static.B227_SetPickupMessageClass(Inventory(Other), class'PickupMessagePlus');
return bRetVal;
}

//overloaded simply for new notify
function SetUpCurrent(){
  if (level.netmode!=NM_standalone||bUseDecals)   //in co-op, always spawn the notify to allow effect swapping client-side.
  spawn(class'bloodnotify');
  if (level.netmode!=NM_standalone||PermaDecals)
  spawn(class'decalnotify');
  if (level.netmode!=NM_standalone){
    spawn(class'TvEveryThingNotify');
    return;
  }
  oBioRifle=bBiorifle;
  oASMD=basmd; //old options
  ostingy=bstingy;
  oRazor=brazor;
  oFlak=bflak;
  omini=bmini;
  oEball=beball;
  oRifle=brifle;
  odamage=bdamage;
  opad=bpad;
  oarmor=barmor;
  omag=bmag;
  oshield=bshield;
  NewVersion=true; //OSA 2.25+ save
}

function B227_AddONPSPFix()
{
	local class<Mutator> MutatorClass;
	local Mutator Mutator;

	MutatorClass = class<Mutator>(DynamicLoadObject("ONPSPFix.ONPSPFix", class'Class', true));
	if (MutatorClass == none)
		return;

	foreach AllActors(class'Mutator', Mutator)
		if (Mutator.Class == MutatorClass)
			return;
	Mutator = Spawn(MutatorClass);
	if (Mutator != none)
		AddMutator(Mutator);
}

defaultproperties
{
}
