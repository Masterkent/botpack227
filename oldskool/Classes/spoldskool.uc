// ============================================================
// oldskool.spoldskool: base mutator for singleplayer2
// Psychic_313: mostly unchanged
// ============================================================

class spoldskool expands UTC_Mutator
config(Oldskool);
//da pulse icon......
#exec OBJ LOAD FILE="OldSkoolResources.u" PACKAGE=oldskool

var bool PropSetup; //no replacement
var config bool               //yawn....
    bmed,
    bBioRifle,
    bASMD,
    bStingy,
    bRazor,
    bFlak,
    bmini,
    bEball,
    bRifle,
    bjump,
    bdamage,
    bpad,
    bmegahealth,
    barmor,
    bmag,
    bshield,
    bUseDecals, //more specifically blood decals :P
    PermaDecals, //permanent decals.
    B227_bCheckReplacement,
    B227_bModifyAmmoPickupSound,
    B227_bPermaCarcasses;
//non-config options (for save game hack):
var bool   oBioRifle,
    oASMD,
    oStingy,
    oRazor,
    oFlak,
    omini,
    oEball,
    oRifle,
    odamage,
    opad,
    oarmor,
    omag,
    oshield;
var config bool UnAir; //U1 aircontrol
var bool NewVersion; //a hack. :D
var localized string spymessage[2];

var transient int B227_DifficultiesNum;

function SetUpCurrent(){
  if (level.netmode!=NM_standalone||bUseDecals)   //in co-op, always spawn the notify to allow effect swapping client-side.
  spawn(class'bloodnotify');
  if (level.netmode!=NM_standalone||PermaDecals)
  spawn(class'decalnotify');
  if (level.netmode!=NM_standalone){
    //-spawn(class'EveryThingNotify');
    return;
  }
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
function postbeginplay(){
  SetupCurrent();
  class'UTC_GameInfo'.static.UTSF_RegisterDamageMutator(self);     //OSA 3: damage mutator for skaarj voice thing
  if (Level.Game.DefaultWeapon != none)
    Level.Game.DefaultWeapon = class<Weapon>(B227_ReplaceInventoryClass(Level.Game.DefaultWeapon));
//decals spawnnotify:
//log ("OldSkool Amp'd: SPOldSkool Postbeginplay called");
}
function FixContents(out class<Actor> conts)
{  //mag, minigun, armor and kev not swapped do ro replacewith stuff
	if (conts == none)
		return;
	if (conts == class'ShieldBelt' || conts == class'osShieldBelt')
	{
		if (bshield)
			conts = class'osUT_ShieldBelt';
		else
			conts = class'osShieldBelt';
	}
	else if (conts == class'PowerShield' || conts == class'olweapons.ospowershield')
	{
		if (bshield)
			conts = class'olweapons.shieldBeltpower';
		else
			conts = class'olweapons.ospowershield';
	}
	else if (conts == class'SuperHealth' && bmegahealth)
		conts = class'healthpack';
	else if (conts == class'health' && bmed)
		conts = class'medbox';
	else if (conts == class'Amplifier' && !bdamage) //do to modifications in replacewith, cannot swap damage
		conts = class'osamplifier';
	else if (conts == class'JumpBoots' && bjump)
		conts = class'UT_jumpboots';
	else if (conts == class'WeaponPowerup')
		conts = class'osDispersionpowerup';
	else if (ClassIsChildOf(conts, class'Clip') && bmag)
		conts = class'botpack.EClip';
	else if (ClassIsChildOf(conts, class'ShellBox') && bmag)
		conts = class'Botpack.MiniAmmo';
	else if (ClassIsChildOf(conts, class'StingerAmmo') && bstingy)
		conts = class'Botpack.PAmmo';
	else if (ClassIsChildOf(conts, class'ASMDAmmo') && basmd)
		conts = class'ShockCore';
	else if (ClassIsChildOf(conts, class'RocketCan') && beball)
		conts = class'Botpack.RocketPack';
	else if (ClassIsChildOf(conts, class'FlakShellAmmo') && bflak)
		conts = class'olweapons.OSFlakshellAmmo';
	else if (ClassIsChildOf(conts, class'FlakBox') && bflak)
		conts = class'Botpack.FlakAmmo';
	else if (ClassIsChildOf(conts, class'RazorAmmo') && brazor)
		conts = class'Botpack.BladeHopper';
	else if (ClassIsChildOf(conts, class'Sludge') && bBioRifle)
		conts = class'BioAmmo';
	else if (ClassIsChildOf(conts, class'RifleRound') && brifle)
		conts = class'Botpack.RifleShell';
	else if (ClassIsChildOf(conts, class'RifleAmmo') && brifle)
		conts = class'Botpack.bulletbox';
	else if (conts == class'Botpack.EClip' && !bmag && bmini)
		conts = class'Clip';
	else if (conts == class'Botpack.MiniAmmo' && !bmag && bmini)
		conts = class'ShellBox';
	else if (conts == class'dispersionpistol')
		conts = class'olweapons.oldpistol';
	else if (conts == class'AutoMag' || conts == class'olweapons.olautomag')
	{
		if (bmag)
			conts = class'Botpack.Enforcer';
		else
			conts = class'olweapons.olautomag';
	}
	else if (conts == class'Stinger' || conts == class'olweapons.olstinger')                             //set up decal/network weapons.....
	{
		if (bstingy)
			conts = class'olweapons.OSPulseGun';
		else
			conts=class'olweapons.olstinger';
	}
	else if (conts == class'ASMD' || conts == class'olweapons.olasmd')
	{
		if (basmd)
			conts = class'olweapons.osShockRifle';
		else
			conts = class'olweapons.olasmd';
	}
	else if (conts == class'Eightball' || conts == class'olweapons.olEightball')
	{
		if (beball)
			conts = class'botpack.UT_Eightball';
		else
			conts = class'olweapons.olEightball';
	}
	else if (conts == class'FlakCannon' || conts == class'olweapons.olFlakCannon')
	{
		if (bflak)
			conts = class'botpack.UT_flakcannon';
		else
			conts = class'olweapons.olFlakCannon';
	}
	else if (conts == class'Razorjack' || conts == class'olweapons.olrazorjack')
	{
		if (brazor)
			conts = class'botpack.ripper';
		else
			conts = class'olweapons.olrazorjack';
	}
	else if (conts == class'GesBioRifle' || conts == class'olweapons.olgesBioRifle')
	{
		if (bbiorifle)
			conts = class'botpack.UT_BioRifle' ;
		else
			conts = class'olweapons.olgesBioRifle';
	}
	else if (conts == class'Rifle' || conts == class'olweapons.olRifle')
	{
		if (brifle)
			conts = class'Botpack.SniperRifle';
		else
			conts = class'olweapons.olRifle';
	}
	else if (conts == class'Minigun' || conts == class'olweapons.olMinigun')
	{
		if (bmini)
			conts = class'Botpack.Minigun2';
		else
			conts = class'olweapons.olMinigun';
	}
	else if (conts == class'quadshot') //some maps had this?
		conts = class'olweapons.olquadshot';
	else if (conts == class'PulseGun')                            //set up UT: SP stuff for old new maps.....
		conts = class'olweapons.OSPulseGun';
	else if (conts == class'shockrifle')
		conts = class'olweapons.osShockRifle';
}


//main mutator logic:
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	//-local transhack hack;  //OSA 2.2 Illumination hack fix
	// replace Unreal I inventory actors by their Unreal Tournament equivalents
	// set bSuperRelevant to false if want the gameinfo's super.IsRelevant() function called
	// to check on relevancy of this actor.
	local class<Actor> ActorClass;

	if (!B227_bCheckReplacement)
		return true;

	// Not needed in Unreal 227
	//-if (other.isa('transporter'))
	//-{   //OSA 2.2 transport fix.
	//-	hack=spawn(class'transhack',,other.tag,other.location);
	//-	hack.Offset=transporter(other).Offset;
	//-	other.disable('trigger'); //my version is better :P
	//-	return true; //keep its navigation properties.  With trigger disabled it can't do anything and the hack manages it.
	//-}
	if (Decoration(Other) != none)
	{    //fix content (falling stuff)
		//-if (other.isa('tree')||left(getitemname(string(other.class)),5)~="plant")
		//-  other.style=STY_MASKED; //fix up mask bug in D3D?
		FixContents(Decoration(Other).Contents);
		FixContents(Decoration(Other).Content2);
		FixContents(Decoration(Other).Content3);
	}
	if (MusicEvent(Other) != none && MusicEvent(Other).Song == none && level.song == none)
	{
		MusicEvent(Other).song = music'olroot.null';
		return true;
	}
	//-if (other.style==STY_NORMAL&&other.isa('pawn')&&(other.isa('skaarjwarrior')||other.isa('krall')||other.isa('warlord')||other.isa('bird1')||other.isa('Slith')||other.isa('manta')))
	//-  other.style=STY_MASKED; //fix up masking bug on pawns
	if (Other.bIsPawn && Pawn(Other).DropWhenKilled != none)
		B227_AdjustInventoryClass(Pawn(Other).DropWhenKilled);
	if (Weapon(Other) != none && Weapon(Other).AmmoName != none)
		Weapon(Other).AmmoName = class<Ammo>(B227_ReplaceInventoryClass(Weapon(Other).AmmoName));
	if (Inventory(other) != none) //so pickup messages work......
		class'UTC_Inventory'.static.B227_SetPickupMessageClass(Inventory(other), none);
	//here we swap baddie projectiles around.... (neither a spawn notify nor mutator would affect the projectiles so I had to do it the hard way :(
	else if (ScriptedPawn(other) != none)
	{
		if (class'olweapons.uiweapons'.default.busedecals)
		{
			//if (other.isa('skaarjtrooper'))
			//scriptedpawn(other).Shadow = Spawn(class'PlayerShadow',other,,other.location);
			//else //what is the difference?  update(actor l) only works if a pawn has a weapon. thus I use olpawnshadow.  playershadow works for troopers though, so might was well be used.
			//-if (!other.isa('tentacle'))     //no decal for them.
			//-  scriptedpawn(other).Shadow = Spawn(class'olpawnShadow',other,,other.location);
			if (scriptedpawn(other).RangedProjectile == Class'UnrealShare.BruteProjectile')
				scriptedpawn(other).RangedProjectile = Class'oldskool.olBruteProjectile';
			if (scriptedpawn(other).RangedProjectile == Class'Unreali.mercrocket')
				scriptedpawn(other).RangedProjectile = Class'oldskool.olmercrocket';
			else if (scriptedpawn(other).RangedProjectile == Class'UnrealI.GasBagBelch')
				scriptedpawn(other).RangedProjectile=Class'oldskool.olGasBagBelch';
			else if (scriptedpawn(other).RangedProjectile == Class'UnrealI.KraalBolt')
				scriptedpawn(other).RangedProjectile=Class'oldskool.olkraalbolt';
			else if (scriptedpawn(other).RangedProjectile == Class'UnrealI.EliteKrallBolt')
				scriptedpawn(other).RangedProjectile=Class'oldskool.ol1337krallbolt';
			else if (scriptedpawn(other).RangedProjectile == Class'Unrealshare.skaarjprojectile')           //no slith thankz to the hitwall not being simulated (and me too lazy to redo it ;)
				scriptedpawn(other).RangedProjectile=Class'oldskool.olskaarjprojectile';
			else if (scriptedpawn(other).RangedProjectile == Class'Unreali.queenprojectile')
				scriptedpawn(other).RangedProjectile=Class'oldskool.olqueenprojectile';
			else if (scriptedpawn(other).RangedProjectile == Class'Unrealshare.tentacleprojectile')
				scriptedpawn(other).RangedProjectile=Class'oldskool.oltentacleprojectile';
			else if (scriptedpawn(other).RangedProjectile == Class'SlithProjectile')
				scriptedpawn(other).RangedProjectile=Class'olSlithProjectile';
			else if (scriptedpawn(other).RangedProjectile == Class'Unreali.warlordrocket')
				scriptedpawn(other).RangedProjectile = Class'oldskool.olwarlordrocket';
		}
		//if (busedecals||level.netmode!=nm_standalone)
		if (B227_bPermaCarcasses &&
			class<CreatureCarcass>(ScriptedPawn(Other).CarcassType) != none &&
			ScriptedPawn(Other).CarcassType == ScriptedPawn(Other).default.CarcassType)
		{
			ScriptedPawn(Other).CarcassType = class'olCreatureCarcass';
		}

		//get those skaarjy right.....                   i.e sets weapons so won't screw up player.  Warning: this makes the skaarj even deadlier ;)
		if (SkaarjTrooper(Other) != none)
			SkaarjTrooper(Other).WeaponType = class<Weapon>(B227_ReplaceInventoryClass(SkaarjTrooper(Other).WeaponType));
		return true;
	}
	else //anything else forget about it.....
		return true;

	if (Ammo(Other) != none)                           //ammo sets for correct item place.......
	{
		if (string(Ammo(Other).PickupSound) ~= "UnrealShare.Pickups.AmmoSnd" &&
			B227_bModifyAmmoPickupSound)
		{
			//fix up this stuff.....
			Ammo(Other).PickupSound = Sound'BotPack.Pickups.AmmoPick';
			//- Ammo(Other).bClientAnim=True;
		}
		if (TournamentAmmo(Other) != none)           //for UT: SP.......
		{
			//-if ( Other.IsA('shockcore')){    //check not default ammo...
			//-  shockcore(other).icon=Texture'UnrealShare.Icons.I_ASMD';
			//-  return true;
			//-}
			if (RocketPack(Other) != none)
			{
				RocketPack(Other).UsedInWeaponSlot[5]=0;
				RocketPack(Other).UsedInWeaponSlot[9]=1;
				//-RocketPack(Other).Icon=Texture'UnrealShare.Icons.I_RocketAmmo';
				return true;
			}
			if (PAmmo(Other) != none)
			{
				Pammo(Other).UsedInWeaponSlot[3]=0;
				Pammo(Other).UsedInWeaponSlot[5]=1;
				Pammo(Other).Icon=Texture'pulseicon';       //ph34r |\/|y 1c0|\| |\/|4k1|\|9 5k1llz!!!!!!!
				return true;
			}
			if (BladeHopper(Other) != none)
			{
				bladehopper(other).UsedInWeaponSlot[7]=0;
				bladehopper(other).UsedInWeaponSlot[6]=1;
				//-bladehopper(other).Icon=Texture'UnrealI.Icons.I_RazorAmmo';
				return true;
			}
			if (BulletBox(Other) != none)
			{
				bulletbox(other).UsedInWeaponSlot[9]=0;
				bulletbox(other).UsedInWeaponSlot[0]=1;
				return true;
			}
			if (FlakAmmo(Other) != none)
			{
				flakammo(other).UsedInWeaponSlot[6]=0;
				flakammo(other).UsedInWeaponSlot[8]=1;
				//-flakammo(other).Icon=Texture'UnrealI.Icons.I_FlakAmmo';
				return true;
			}
			if (MiniAmmo(Other) != none)
			{
				miniammo(other).UsedInWeaponSlot[0]=int(bmag && !bmini);
				miniammo(other).UsedInWeaponSlot[7]=1;
				//-miniammo(other).Icon=Texture'UnrealShare.Icons.I_ShellAmmo';
				return true;
			}
			if (BioAmmo(Other) != none)
			{
				bioammo(other).UsedInWeaponSlot[8]=0;
				bioammo(other).UsedInWeaponSlot[3]=1;
				//-bioammo(other).Icon=Texture'UnrealI.Icons.I_SludgeAmmo';
				return true;
			}
			return true;
		}

		if (Other.Class == class'ShellBox' && !bmag && bmini)
		{
			ShellBox(Other).UsedInWeaponSlot[0] = 0;
			ShellBox(Other).UsedInWeaponSlot[7] = 1;
		}
	}

	ActorClass = B227_ReplaceInventoryClass(Inventory(Other).Class);
	if (Other.Class == ActorClass)
		return true;
	B227_ReplacingActor = none;
	B227_ReplaceActor(Other, ActorClass);
	if (B227_ReplacingActor != none)
		B227_AdjustReplacingInventory(Inventory(B227_ReplacingActor), Inventory(Other));
	return false;
}

//keeps even more inportant stuff......
function bool ReplaceWith(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;
	if (PropSetup)
		return false;
	if ((level.game.Difficulty==0 && !Other.bDifficulty0 )          //as gameinfo's isn't called...we'll just make up for it here.....
		||  (level.game.Difficulty==1 && !Other.bDifficulty1 )
		||  (level.game.Difficulty==2 && !Other.bDifficulty2 )
		||  (level.game.Difficulty>=3 && !Other.bDifficulty3 )
		||  (!Other.bSinglePlayer && (Level.NetMode==NM_Standalone) )
		||  (!Other.bNet && ((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer)) )
		||  (!Other.bNetSpecial  && (Level.NetMode==NM_Client)) )
	{
		return False;
	}
	if (FRand() > Other.OddsOfAppearing)
		return False;
	if (Inventory(Other) != none && (Other.Location == vect(0,0,0)))
		return false;
	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	if ( aClass != None )
		A = Other.Spawn(aClass,,Other.tag,Other.Location, Other.Rotation);
	if ( Inventory(Other) != none )
	{
		if ( Inventory(Other).MyMarker != None )
		{
			Inventory(Other).MyMarker.markedItem = Inventory(A);
			if ( Inventory(A) != None )
			{
				Inventory(A).MyMarker = Inventory(Other).MyMarker;
				A.SetLocation(A.Location + (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
			}
			Inventory(Other).MyMarker = None;
		}
		else if (Inventory(A) != none && Inventory(Other).bhelditem)
		{
			Inventory(A).bHeldItem = true;
			Inventory(A).Respawntime = 0.0;
		}
	}
	if (A != None)
	{
		B227_AdjustReplacingInventory(Inventory(A), Inventory(Other));
		return true;
	}
	return false;
}

//quick save and quickload...... (a cheat code too!!!!)
function Mutate(string MutateString, PlayerPawn Sender)
{ local class<Mappack> Packclass;
  if (MutateString ~= "quicksave")
  {
   if ( (sender.Health > 0)
    && (Level.NetMode == NM_Standalone))
  {
    class'olroot.OldSkoolSlotClientWindow'.default.quicksavetype=class'oldskool.oldskoolnewgameclientwindow'.default.SelectedPackType;       //obvious why this is needed :D
    class'olroot.OldSkoolSlotClientWindow'.static.staticsaveconfig();
    sender.ClientMessage("Saved game");
    sender.ConsoleCommand("SaveGame 1000");
  }
  }
  if ((MutateString ~= "quickload")&&(Level.NetMode == NM_Standalone)&&class'olroot.OldSkoolSlotClientWindow'.default.quicksavetype!=""){
  if (!(class'olroot.OldSkoolSlotClientWindow'.default.quicksavetype ~= "Custom"))
  PackClass = Class<Mappack>(DynamicLoadObject(class'olroot.OldSkoolSlotClientWindow'.default.quicksavetype, class'Class'));
  if ((packclass != None)&&(packclass.default.loadrelevent)) {          //a gameinfo should turn this off.....
    packclass.default.bLoaded = true;
    packclass.static.StaticSaveConfig(); }
  //sender.ConsoleCommand( "open ..\\save\\save1000.usa");}
  sender.ClientTravel( "?load=1000", TRAVEL_Absolute, false);}
  if (MutateString ~= "spyd00d" && Level.Game.Isa('singleplayer2')){
  sender.ClientMessage(spymessage[byte(Singleplayer2(level.game).spectateallowed)]);
  Singleplayer2(level.game).spectateallowed=!Singleplayer2(level.game).spectateallowed;
  }
  if ( NextMutator != None )
    class'UTC_Mutator'.static.UTSF_Mutate(NextMutator, MutateString, Sender);
}

//check skaarj feign for autotaunt.
function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation,
            out Vector Momentum, name DamageType)
{
  local int NextTaunt, i;
  if (Victim.isa('skaarj')&&TournamentPlayer(InstigatedBy)!=none&&TournamentPlayer(InstigatedBy).bAutoTaunt&&instigatedby.health>0&&
  (Level.TimeSeconds - SinglePlayer2(level.game).LastTauntTime > 3)
  &&DamageType != 'gibbed'&&(addvelocity(momentum,victim.velocity).z>120)
  &&victim.health-actualdamage< 0.4 * victim.Default.Health){
   //at this point try the random test.
   animsequence=victim.animsequence; //backups
   velocity=victim.velocity;
   victim.animsequence='Lunge';
   victim.velocity.z=121;
   victim.health-=actualdamage;
   skaarj(victim).PlayTakeHit(0,hitlocation,actualdamage);
   //set back:
   victim.velocity=velocity;
   velocity=vect(0,0,0);
   victim.health+=actualdamage; //then will be subtracted again :P
   if (victim.animsequence=='death2'){       //fake taunt!
      SinglePlayer2(level.game).LastTauntTime = Level.TimeSeconds;
    NextTaunt = Rand(class<ChallengeVoicePack>(InstigatedBy.PlayerReplicationInfo.VoiceType).Default.NumTaunts);
    for ( i=0; i<4; i++ )                                   //keeps taunts unique.....
    {
      if ( NextTaunt == SinglePlayer2(level.game).LastTaunt[i] )
        NextTaunt = Rand(class<ChallengeVoicePack>(InstigatedBy.PlayerReplicationInfo.VoiceType).Default.NumTaunts);
      if ( i > 0 )
        SinglePlayer2(level.game).LastTaunt[i-1] = SinglePlayer2(level.game).LastTaunt[i];
    }
     SinglePlayer2(level.game).LastTaunt[3] = NextTaunt;
     class'UTC_Pawn'.static.UTSF_SendGlobalMessage(InstigatedBy, None, 'AUTOTAUNT', NextTaunt, 5);
   }
   else
   victim.animsequence=animsequence; //set back to old. (only this case as need to force skaarj to feign)
   animsequence=''; //don't want something getting messed up :P
   }
   if ( NextDamageMutator != None )       //might as well.
    NextDamageMutator.MutatorTakeDamage( ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType );
}
function vector AddVelocity( vector NewVelocity, vector current)
{
  if ( (current.Z > 380) && (NewVelocity.Z > 0) )
    NewVelocity.Z *= 0.5;
  return current += NewVelocity;
}
function bool IsRelevant(Actor Other, out byte bSuperRelevant)
{
  local bool bResult;

  // allow mutators to remove actors
  bResult = CheckReplacement(Other, bSuperRelevant);
  if ( !propSetup&&bResult && (NextMutator != None) )
    bResult = NextMutator.IsRelevant(Other, bSuperRelevant);

  return bResult;
}

static function string B227_DifficultyString(byte Difficulty)
{
	if (default.B227_DifficultiesNum == 0)
	{
		default.B227_DifficultiesNum = int(GetDefaultObject(class'UMenuNewGameClientWindow').GetPropertyText("Skills[]"));
		if (default.B227_DifficultiesNum == 0)
			default.B227_DifficultiesNum = -1;
	}
	if (Difficulty < default.B227_DifficultiesNum)
		return class'UMenuNewGameClientWindow'.default.Skills[Difficulty];
	return string(Difficulty);
}

function B227_AdjustInventoryClass(out class<Inventory> InventoryClass)
{
	InventoryClass = B227_ReplaceInventoryClass(InventoryClass);
}

function class<Inventory> B227_ReplaceInventoryClass(class<Inventory> InventoryClass)
{
	local class<Actor> ActorClass;

	ActorClass = InventoryClass;
	FixContents(ActorClass);
	if (ClassIsChildOf(ActorClass, class'Inventory'))
		return class<Inventory>(ActorClass);
	return InventoryClass;
}

function B227_AdjustReplacingInventory(Inventory NewInventory, Inventory OldInventory)
{
	if (NewInventory == none || OldInventory == none)
		return;

	if (ThighPads(NewInventory) != none)
	{
		//kev suit pads.....
		NewInventory.Charge = 100;
		NewInventory.ArmorAbsorption = 80;
		NewInventory.AbsorptionPriority = 6;
	}
	else if (Armor2(NewInventory) != none)
		NewInventory.ArmorAbsorption = 90;
	else if (UDamage(NewInventory) != none)
	{
		//9 sec Udamage......
		NewInventory.Charge = 90;
		UDamage(NewInventory).FinalCount = 2;
	}
	else if (olautomag(NewInventory) != none && AutoMag(OldInventory) != none && AutoMag(OldInventory).HitDamage==70)
	{
		//h4x for Ballad of Ash
		olautomag(NewInventory).HitDamage = AutoMag(OldInventory).HitDamage;
		olautomag(NewInventory).AltFireSound = AutoMag(OldInventory).AltFireSound;
		olautomag(NewInventory).firesound = AutoMag(OldInventory).FireSound;
		olautomag(NewInventory).misc1sound = AutoMag(OldInventory).Misc1Sound;
		olautomag(NewInventory).misc2sound = AutoMag(OldInventory).Misc2Sound;
		olautomag(NewInventory).selectsound = AutoMag(OldInventory).SelectSound;
	}

	NewInventory.RotationRate = OldInventory.RotationRate;
}

function class<Actor> B227_VersionClass()
{
	return class'B227_oldskool_Version'; // makes class B227_oldskool_Version loaded
}

defaultproperties
{
     bmini=True
     bdamage=True
     bUseDecals=True
     PermaDecals=True
     UnAir=True
     spymessage(0)="Monster viewing cheat enabled."
     spymessage(1)="Monster viewing cheat disabled."
     B227_bCheckReplacement=True
     B227_bModifyAmmoPickupSound=True
     B227_bPermaCarcasses=True
}
