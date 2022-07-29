// ============================================================
// XidiaMPack.tvmutator: Handles various tricks...
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
	local effects e;
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
class'ExplodingWall'.default.bGameRelevant=false;
class'BreakingGlass'.default.bGameRelevant=false;
//hacks for just loaded actors:
foreach allactors (class'effects',e){
	if (e.IsA('explosionChain')||e.IsA('explodingwall'))
		e.bGameRelevant=false; //should be destroyed now

	if (Level.NetMode == NM_Standalone)
		B227_AddSBSPFix();
}
/*
class'Fragment'.default.bGameRelevant=false;
class'GlassFragments'.default.bGameRelevant=false;
class'WallFragments'.default.bGameRelevant=false;
class'WoodFragments'.default.bGameRelevant=false;
*/
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
//convert various items
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

function ReplaceExplodingWall(ExplodingWall other){
  local SBExplodingWall A;
  local int i;
  A=SBExplodingWall(ReplaceNonInv(Other,class'SBExplodingWall'));
  if (A==none)
    return;
  A.ExplosionSize = Other.ExplosionSize;
  A.ExplosionDimensions = Other.ExplosionDimensions;
  A.WallParticleSize = Other.WallParticleSize;
  A.WoodParticleSize = Other.WoodParticleSize;
	if (Other.IsA('breakingglass')){
		A.Health=0; //destroyed instantly
		A.ActivatedBy[0]='All'; //flag to destroy instantly
	  A.GlassParticleSize = breakingglass(Other).ParticleSize;
		A.NumGlassChunks = breakingglass(Other).NumParticles;
	}
	else{
	  A.GlassParticleSize = Other.GlassParticleSize;
		A.NumGlassChunks = Other.NumGlassChunks;
		A.Health = Other.Health;
		for (i=0;i<5;i++)
			A.ActivatedBy[i]=Other.ActivatedBy[i];
	}
	A.NumWallChunks = Other.NumWallChunks;
	A.NumWoodChunks = Other.NumWoodChunks;
	A.WallTexture = Other.WallTexture;
	A.WoodTexture = Other.WoodTexture;
	A.GlassTexture = Other.GlassTexture;
	A.BreakingSound = Other.BreakingSound;
	A.bTranslucentGlass = Other.bTranslucentGlass;
	A.bUnlitGlass = Other.bUnlitGlass;
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
if (Other.IsA('Weapon')){
  Other.RotationRate=rot(0,0,0);
  Inventory(Other).bAmbientGlow=false;
}
if (other.class==class'SevenLevelInfo'){ //found level info!
  if (level.game.IsA('tvsp'))
    tvsp(level.game).RegisterSevenLevelInfo(other);
  else if (level.game.Isa('tvcoop'))
    tvcoop(level.game).RegisterSevenLevelInfo(other);
  return true;
}

if (other.class==class'SevenEndMark'){ //HACK FIX: FORCE IT TO BE ENABLED
    SevenEndMark(other).bEnabled=true;
    return true;
}
if (other.class==class'enforcer'){ //replace ENF
  bmini=true;    //so ammo works right...
  ReplaceWith(Other, "SevenB.SevenMachineMag");
  bmini=false;
  return false;    //always remove ENF
}
if (other.class==class'ExplosionChain'){
  ReplaceExploChain(ExplosionChain(other));
//	log ("found explosion chain");
  return false;
}
if (other.IsA('ExplodingWall')&&!other.IsA('sbExplodingWall')){
	ReplaceExplodingWall(ExplodingWall(Other));
//	log ("found exploding wall");
	return false;
}
if (other.class==class'TranslatorEvent'){  //for co-op translator
  ReplaceTransEvent(TranslatorEvent(other));
  return false;
}
if (Other.class==class'PulseGun'||Other.class==class'ospulsegun'){ //hack to swap projectiles here
  ReplaceWith(Other, "SevenB.SevenPulsegun");
  return false;
}
if (Other.class==class'pammo'){
  ReplaceWith(Other, "SevenB.SBpammo");
  return false;
}
if (Other.class==class'Shells'||Other.class==class'olShells'){
  ReplaceWith(Other, "SevenB.SBShells");
  return false;
}
if (Other.class==class'SniperRifle'){
  ReplaceWith(Other, "SevenB.SevenSniperRifle");
  return false;
}
if (Other.class==class'ripper'){
  ReplaceWith(Other, "SevenB.SBBloodripper");
  return false;
}
if (Other.class==class'minigun2'){
  ReplaceWith(Other, "SevenB.SevenChainGun");
  return false;
}
if (Other.class==class'UT_Flakcannon'){
  ReplaceWith(Other, "SevenB.SBFlechetteCannon");
  return false;
}
if (Other.class==class'ShockRifle'||Other.class==class'osShockRifle'){
  ReplaceWith(Other, "SevenB.SevenShockRifle");
  return false;
}
if (Other.class==class'ut_eightball'){
  ReplaceWith(Other, "SevenB.TVEightball");
  return false;
}
//for co-op supportive inv items:
if (Other.class==class'translator'){
  ReplaceWith(Other, "SevenB.TVtranslator");
  return false;
}
if (Other.class==class'flashlight'){
  ReplaceWith(Other, "SevenB.TvFlashlight");
  return false;
}
if ((Other.IsA('Ut_Jumpboots')&&!Other.Isa('xidiaJumpBoots'))||Other.Isa('JumpBoots')){
  ReplaceWith(Other, "SevenB.xidiaJumpBoots");
  return false;
}
if (Other.class==class'searchlight'){
  ReplaceWith(Other, "SevenB.TVSearchLight");
  return false;
}
if (Other.class==class'UT_ShieldBelt'){
  ReplaceWith(Other,"olWeapons.ospowershield");
  return false;
}
if (Level.NetMode!=nm_standalone&&(Other.Isa('PlayerMotionFreeze')||Other.IsA('ViewSpot')||Other.IsA('ViewSpotStop')||Other.IsA('NonBuggyViewSpot')))
  return false; //no cutscenes in co-op!
//-if (other.Isa('MoviePawn')) //UMS movie hack
//-  pawn(other).Shadow = Spawn(class'TVpawnShadow',other,,other.location);
if (other.isa('scriptedpawn')){
  //-if (other.style==STY_NORMAL&&(other.isa('skaarjwarrior')||other.isa('krall')||other.isa('warlord')||other.isa('Slith')||other.isa('manta')))
  //-  other.style=STY_MASKED; //fix up masking bug on pawns
  if (class'olweapons.uiweapons'.default.busedecals){
//-    if (!other.isa('tentacle'))     //no decal for them.
//-        scriptedpawn(other).Shadow = Spawn(class'TVpawnShadow',other,,other.location);
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
      scriptedpawn(other).RangedProjectile=Class'TVSkaarjProjectile';
    else if (scriptedpawn(other).RangedProjectile==Class'Unreali.queenprojectile')
      scriptedpawn(other).RangedProjectile=Class'oldskool.olqueenprojectile';
    else if (scriptedpawn(other).RangedProjectile==Class'Unrealshare.tentacleprojectile')
      scriptedpawn(other).RangedProjectile=Class'oldskool.oltentacleprojectile';
    else if (scriptedpawn(other).RangedProjectile==Class'SlithProjectile')
      scriptedpawn(other).RangedProjectile=Class'olSlithProjectile';
    else if (scriptedpawn(other).RangedProjectile==Class'Unreali.warlordrocket')
      scriptedpawn(other).RangedProjectile=Class'Tvwarlordrocket';
  }
	if (ClassIsChildOf(scriptedpawn(other).carcasstype,class'HumanCarcass')||ClassIsChildOf(scriptedpawn(other).carcasstype,class'UTHumanCarcass')){
     scriptedpawn(other).carcasstype=class'PermUTHumanCarcass';
	}
  else if (ClassIsChildOf(ScriptedPawn(other).CarcassType, class'CreatureCarcass') &&
      ScriptedPawn(other).CarcassType == ScriptedPawn(other).default.CarcassType)
  {
    if (other.style!=STY_Translucent)
      scriptedpawn(other).carcasstype=class'olCreatureCarcass';
    else{
      scriptedpawn(other).carcasstype=class'TranslucentCreatureCarcass';
      scriptedpawn(other).bGreenBlood=true; //for MClane's green skaarj.  Will affect all translucent creatures however!
    }
  }
 //projectile speed thing
 Dif=FClamp(pawn(other).Skill+level.game.Difficulty, 0, 3);
 if (Dif>1.0)
    scriptedpawn(other).projectilespeed*=0.9+0.1*Dif;
  if (Other.Isa('Nali')&&Other.bShadowCast==true){
    if (TVSP(level.game)!=none)
      TVSP(level.game).GivePickup(class'Tvflashlight',pawn(other));
    if (TvCoop(level.game)!=none)
      TvCoop(level.game).GivePickup(class'Tvflashlight',pawn(other));
  }
  //Skaarj weapontype swaps. Use case statements???
  if ( Other.IsA('skaarjtrooper')){
		if ( skaarjtrooper(Other).weapontype==Class'unreali.Rifle')
      skaarjtrooper(Other).weapontype=Class'olweapons.olRifle';
    else if (skaarjtrooper(Other).weapontype==Class'unreali.Razorjack')
      skaarjtrooper(Other).weapontype=Class'olweapons.olrazorjack';
    else if ( skaarjtrooper(Other).weapontype==Class'unreali.Minigun')
      skaarjtrooper(Other).weapontype=Class'olweapons.olMinigun';
    else if (SkaarjTrooper(Other).WeaponType==class'minigun2')
      SkaarjTrooper(Other).WeaponType=class'SevenChainGun';
    else if (SkaarjTrooper(Other).WeaponType==class'UT_FlakCannon')
      SkaarjTrooper(Other).WeaponType=class'SBFlechetteCannon';
    else if (SkaarjTrooper(Other).WeaponType==class'ripper')
      SkaarjTrooper(Other).WeaponType=class'SBbloodripper';
    else if ( skaarjtrooper(Other).weapontype==Class'unreali.automag'||skaarjtrooper(Other).weapontype==Class'enforcer')
      skaarjtrooper(Other).weapontype=Class'SevenMachineMag';
    else if (SkaarjTrooper(Other).WeaponType==class'PulseGun')
      SkaarjTrooper(Other).WeaponType=class'SevenPulseGun';
    else if (SkaarjTrooper(Other).WeaponType==class'SniperRifle')
      SkaarjTrooper(Other).WeaponType=class'SevenSniperRifle';
    else if ( skaarjtrooper(Other).weapontype==Class'Eightball')
      skaarjtrooper(Other).weapontype=Class'olEightball';
    else if (SkaarjTrooper(Other).weapontype==class'FlakCannon')
      skaarjtrooper(Other).weapontype=Class'olweapons.olFlakCannon';
    else if ( skaarjtrooper(Other).weapontype==Class'unreali.ASMD')
     skaarjtrooper(Other).weapontype=Class'olweapons.olasmd';
    else if ( skaarjtrooper(Other).weapontype==Class'GesBioRifle')
      skaarjtrooper(Other).weapontype=Class'olweapons.olgesBioRifle';
    if ( skaarjtrooper(Other).weapontype==Class'dispersionpistol')           //always change......
      skaarjtrooper(Other).weapontype=Class'olweapons.oldpistol';
    if ( skaarjtrooper(Other).weapontype==Class'shockrifle')
      skaarjtrooper(Other).weapontype=Class'Sevenshockrifle';

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
/*
else if (other.Isa('Fragment')&&level.netmode!=nm_dedicatedserver){ //permanent fragments
	Other.Lifespan=0;
	Other.Disable('Timer');
}
	*/
//various hacks:
else if (Other.IsA('CreatureChunks')&&other.Instigator!=none&&Other.Instigator.Style==STY_Translucent){
  Other.Style=STY_Translucent;
  CreatureChunks(Other).bGreenBlood=true;
  MinipulateSkin(Other,Other.Instigator);   //go greeb
}
else if (Other.IsA('olCreatureCarcass')&&Other.Instigator!=none){
 if (Other.Instigator.IsA('Nali')||Other.Instigator.IsA('cow'))
    Carcass(Other).Rats=2;
}
bretval=super.checkreplacement(other,bsuperrelevant);        //very important :D
//if (Other.Isa('inventory')) //set all messages!
//  Inventory(Other).PickupMessageClass=class'pickupmessageplus';
return bRetVal;
}
//overloaded simply for new notify
function SetUpCurrent(){
//  if (level.netmode!=NM_standalone||bUseDecals)   //in co-op, always spawn the notify to allow effect swapping client-side.
  spawn(class'Sevenbloodnotify');
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

function B227_AddSBSPFix()
{
	local class<Mutator> MutatorClass;
	local Mutator Mutator;

	MutatorClass = class<Mutator>(DynamicLoadObject("SevenBSPFix.SBSPFix", class'Class', true));
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
