// The player
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles
#exec OBJ LOAD FILE="EpicCustomModels.u"

class NaliMage extends naliplayer;

var bool bLastJumpAlt;
var bool bDisarmed;

var() travel NCMixingVial CurrentVial;
var() travel int SpellSkills[7];
var() travel float SpellExp[7];
var() travel float LevelNeeds[9];
var travel int OpenBooks[7];

// stuff relating to spell selection
var travel int currentbook;
var travel NCSpell HighlightedSpell;
var travel NCSpell SelectedSpell;
var travel NCSpell QuickSpells[4];
var travel int CurrQuickSpell;

var() travel float mana;
var() travel float maxmana;
var string ReadableEntry;
var NCLogbookEntry logbookevent;
var string ReadableTitle;
var float Readablestart;
var string ConvString;
var actor CurrentTalker;
var float TalkBegin;
var float TalkLast;
var() string bookmessage[6];
var float LastSpellTime;
var travel float manaLevel;
var float speedTime;

var Music SavedSong;

var NCManaZone ManaZones[10];

var int pickupGroup;

replication
{
	reliable if (Role < ROLE_Authority)
		B227_GetWeapon;
}

/*function ClientSetMusic( music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
	SavedSong = NewSong;
	Super.ClientSetMusic(NewSong,NewSection,NewCdTrack,NewTransition);
}*/

exec function PrintExp() {
	local int i;
	while (i < 6) {
		ClientMessage("Skill #" $ i $ ": " $ SpellExp[i]);
		i++;
	}
}

exec function ShowLoadMenu() // make sure to load the UWindow menu instead of the Unreal one when we're dead
{
	if (WindowConsole(player.console) != none) {
		if (WindowConsole(player.console).bLocked)
			return;
		WindowConsole(player.console).bQuickKeyEnable = False;
		WindowConsole(player.console).LaunchUWindow();
	}
	else {
		ShowMenu();
	}
}

event PlayerInput (float DeltaTime) {
	Super.PlayerInput(DeltaTime);
	speedTime += DeltaTime;
	if (speedTime >= 0.4) {
		speedTime = 0;
		if (GroundSpeed > default.GroundSpeed) GroundSpeed -= 1.6;
		if (GroundSpeed < default.GroundSpeed) GroundSpeed = default.GroundSpeed;
		if (WaterSpeed > default.WaterSpeed) WaterSpeed -= 1;
		if (WaterSpeed < default.WaterSpeed) WaterSpeed = default.WaterSpeed;
		if (AirSpeed > default.AirSpeed) AirSpeed -= 2;
		if (AirSpeed < default.AirSpeed) AirSpeed = default.AirSpeed;
	}
}

exec function skipKeyDwn() { // the player has pressed the skip key - either skip the cutscene or go to next conv. line
	local actor a;
	local NCTalkerNali tn;
	local NCCompanionRabbit cr;
	local NCPawnEnchantTalk pet;

	if (NCMovie(Level.Game) != none) { // a movie - skip it
		foreach allactors(Class'actor',a,'skipCS') {
			a.Trigger(self,self);
		}
	}
	else { // a conversation - skip to next line
		foreach allactors(Class'NCTalkerNali',tn) { // check for talking Nali
			if (tn.talkingto == self && tn.leftoffpoint < ArrayCount(tn.convspeaktime)) {
				tn.convspeaktime[tn.leftoffpoint - 1] = 0;
			}
		}
		foreach allactors(Class'NCCompanionRabbit',cr) { // check for talking rabbits
			if (cr.owner == self || (cr.potentialuser == self && VSize(cr.location - location) < 600)) {
				if (cr.conversenum < ArrayCount(cr.ConvSpeakTime)) {
					cr.ConvSpeakTime[cr.conversenum-1] = 0;
				}
				if (cr.owner == self && !cr.convdone) {
					cr.TimerRate = 0;
					cr.Timer();
				}
			}
		}
		foreach allactors(Class'NCPawnEnchantTalk',pet) { // check for comm spells
			if (pet.instigator == self && pet.commpoint != none) {
				pet.TimerRate = 0;
				pet.Timer();
			}
		}
	}
}

exec function OneSkill(int skill) {
	GainExp(skill,1000);
}

exec function TwoSkill(int skill) {
	GainExp(skill,2500);
}

exec function ThreeSkill(int skill) {
	GainExp(skill,5500);
}

exec function FourSkill(int skill) {
	GainExp(skill,11500);
}

exec function FiveSkill(int skill) {
	GainExp(skill,23500);
}

exec function EightSkill(int skill) {
	GainExp(skill,263500);
}

function bool CheckSkill(int inbook, int minskill) {
	if (SpellSkills[inbook] >= minskill)
		return true;
	else
		return false;
}

function GainExp(int inbook, float inExp) {
	local int levelindex;

	if (inbook < ArrayCount(SpellSkills) && SpellSkills[inbook] < 8) {
		SpellExp[inbook] += inExp;
		levelindex = SpellSkills[inbook];
		while (SpellExp[inbook] >= LevelNeeds[levelindex+1] && SpellSkills[inbook] < 8) {
			levelindex = SpellSkills[inbook];
			SpellSkills[inbook]++;
			SpellExp[inbook] -= LevelNeeds[levelindex+1];
		}
		manalevel = float(SpellSkills[0]+SpellSkills[1]+SpellSkills[2]+SpellSkills[3]+SpellSkills[4]+SpellSkills[5])/4;
		maxmana = 100+int(manalevel)*10;
		//ClientMessage(SpellExp[inbook]);
	}
}

function float calcInManaMult(float manamult, float mmaxmana, float inbook, float minskill) {
	local float manadiff;
	local int skillExtra;
	local float skillMult;
	local float ourmult;

	skillExtra = SpellSkills[inbook] - minskill;

	skillMult = 1/(8-minskill);

	ourmult = manamult;
	manadiff = mmaxmana - manamult;
	manadiff *= skillMult*skillExtra;
	ourmult += manadiff;
	return ourmult;
}

function GiveMana(float inmana, float manamult, float mmaxmana, int inbook, int minskill) {
	local float ourmult;

	// multiply manamult and inmana by skill here
	//ClientMessage(inmana$" , "$manamult);

	if (!CheckSkill(inbook,minskill))
		return;

	ourmult = calcInManaMult(manamult,mmaxmana,inbook,minskill);

	if (mana > (maxmana*ourmult))
		return;
	if ((inmana + mana) > (maxmana*ourmult))
		mana = maxmana*ourmult;
	else
		mana += inmana;
}

function bool TakeMana(float ToTake) {
	//ClientMessage(ToTake);
	if (mana >= ToTake) {
		mana -= ToTake;
		return true;
	}
	else {
		mana = 0;
		return false;
	}
}

exec function SetQuickSpell() {
	local int i;

	while (i < 4) {
		if (QuickSpells[i] == HighlightedSpell)
			return;
		i++;
	}
	i = 0;
	while (i < 4) {
		if (QuickSpells[i] == none) {
			QuickSpells[i] = HighlightedSpell;
			i = 254;
		}
		i++;
	}
	if (i != 255)
		QuickSpells[CurrQuickSpell] = HighlightedSpell;

	ClientMessage(HighlightedSpell.ItemName$" spell added to quick spell slot");
}

exec function NextQuickSpell() {
	local int i;

	if (CurrQuickSpell >= 3)
		CurrQuickSpell = 0;
	else
		CurrQuickSpell++;

	while ((QuickSpells[CurrQuickSpell] == none) && (i < 3)) {
		if (CurrQuickSpell >= 3)
			CurrQuickSpell = 0;
		else
			CurrQuickSpell++;
		i++;
	}

	SelectedSpell = QuickSpells[CurrQuickSpell];
	ClientMessage(SelectedSpell.ItemName$" spell selected");
}

exec function PrevQuickSpell() {
	local int i;

	if (CurrQuickSpell <= 0)
		CurrQuickSpell = 3;
	else
		CurrQuickSpell--;

	while ((QuickSpells[CurrQuickSpell] == none) && (i < 3)) {
		if (CurrQuickSpell <= 0)
			CurrQuickSpell = 3;
		else
			CurrQuickSpell--;
		i++;
	}

	SelectedSpell = QuickSpells[CurrQuickSpell];
	ClientMessage(SelectedSpell.ItemName$" spell selected");
}

function float GetInitialStress(int inbook) {
	if ((LastSpellTime == 0) || ((Level.TimeSeconds-LastSpellTime) > 1.0))
		return 0;
	else {
		//ClientMessage("In Stress: "$(1-(Level.TimeSeconds-LastSpellTime)));
		return 1-(Level.TimeSeconds-LastSpellTime);
	}
}

function SpellFinished() {
	LastSpellTime = Level.TimeSeconds;
}

exec function SelectSpell() {
	NCHUD(myHUD).spellTime = Level.TimeSeconds;
	if (!SelectedSpell.bCasting) { // can't switch spell while it's being cast
		if (HighlightedSpell == none)
			NextSpell();
		SelectedSpell = HighlightedSpell;
		ClientMessage(SelectedSpell.ItemName$" spell selected");
	}
}

exec function NextSpell() {
	local Inventory Inv;
	local bool GetNext;
	local bool GotNext;

	if ( bShowMenu || Level.Pauser!="" )
		return;
	NCHUD(myHUD).spellTime = Level.TimeSeconds;
	if ((HighlightedSpell==None) || (HighlightedSpell.book != currentbook)) {
		for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory ) {
			if ((NCSpell(Inv) != none) && (NCSpell(Inv).book == currentbook)) {
				HighlightedSpell = NCSpell(Inv);
				//ClientMessage(HighlightedSpell.ItemName$HighlightedSpell.M_Selected);
				Break;
			}
		}
	}
	else {
		for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory ) {
			if ((NCSpell(Inv) != none) && (NCSpell(Inv).book == currentbook)) {
				if (NCSpell(Inv) == HighlightedSpell) {
					GetNext = true;
				}
				else {
					if (GetNext) {
						GotNext = true;
						HighlightedSpell = NCSpell(Inv);
						//ClientMessage(HighlightedSpell.ItemName$HighlightedSpell.M_Selected);
						Break;
					}
				}
			}
		}
		if (!GotNext) {
			for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory ) {
				if ((NCSpell(Inv) != none) && (NCSpell(Inv).book == currentbook)) {
					HighlightedSpell = NCSpell(Inv);
					Break;
				}
			}
		}
	}
	if (HighlightedSpell!=None) {
		ClientMessage(HighlightedSpell.ItemName$" spell highlighted");
		SelectSpell();
	}
}

exec function PrevSpell() {
	local Inventory Inv, PrevItem;
	local bool getLastSpell;

	if ( bShowMenu || Level.Pauser!="" )
		return;
	NCHUD(myHUD).spellTime = Level.TimeSeconds;
	if ((HighlightedSpell==None) || (HighlightedSpell.book != currentbook)) {
		for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory ) {
			if ((NCSpell(Inv) != none) && (NCSpell(Inv).book == currentbook)) {
				HighlightedSpell = NCSpell(Inv);
				//ClientMessage(HighlightedSpell.ItemName$HighlightedSpell.M_Selected);
				Break;
			}
		}
	}
	else {
		for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory ) {
			if ((NCSpell(Inv) != none) && (NCSpell(Inv).book == currentbook)) {
				if (getLastSpell) {
					Highlightedspell = NCSpell(Inv);
				}
				else {
					if (NCSpell(Inv) == HighlightedSpell) {
						if (PrevItem != none) {
							HighlightedSpell = NCSpell(PrevItem);
							Break;
							//ClientMessage(HighlightedSpell.ItemName$HighlightedSpell.M_Selected);
						}
						else {
							getLastSpell = true;
						}
					}
					PrevItem = Inv;
				}
			}
		}
	}
	if (HighlightedSpell!=None) {
		ClientMessage(HighlightedSpell.ItemName$" spell highlighted");
		SelectSpell();
	}
}

exec function NextBook() {
	local int i, j;

	NCHUD(myHUD).spellTime = Level.TimeSeconds;
	while (i < 6) {
		if (OpenBooks[i] == 1)
			j++;
		i++;
	}

	if (j <= 0) return;

	if (currentbook < 5)
		currentbook++;
	else
		currentbook = 0;
	if (OpenBooks[currentbook] == 0) {
		NextBook();
	}
	else {
		ClientMessage(bookmessage[currentbook]);
		NextSpell();
	}
}

exec function PrevBook() {
	local int i, j;

	NCHUD(myHUD).spellTime = Level.TimeSeconds;
	while (i < 6) {
		if (OpenBooks[i] == 1)
			j++;
		i++;
	}

	if (j <= 0) return;

	if (currentbook > 0)
		currentbook--;
	else
		currentbook = 5;
	if (OpenBooks[currentbook] == 0) {
		PrevBook();
	}
	else {
		ClientMessage(bookmessage[currentbook]);
		NextSpell();
	}
}

simulated event RenderOverlays( canvas Canvas )
{
	if (NCMovie(Level.Game) == none) {
		if ( Weapon != None && !bHidden ) {
			Weapon.ScaleGlow = ScaleGlow;
			if (Style == STY_Translucent && Weapon.Style != STY_Translucent)
				Weapon.Style = STY_Translucent;
			if (Style == STY_Normal && Weapon.Style != Weapon.default.style)
				weapon.style = weapon.default.style;
			Weapon.RenderOverlays(Canvas);
		}
	}

	if ( myHUD != None )
		myHUD.RenderOverlays(Canvas);
}
function ChangedWeapon() {
	if (NCMovie(Level.Game) == none)
		Super.ChangedWeapon();
	else {
		Weapon = None;
		Inventory.ChangedWeapon();
	}
}
exec function ActivateItem()
{
	if (NCMovie(Level.Game) == none) {
		NCHUD(myHUD).inventoryTime = Level.TimeSeconds;
		Super.ActivateItem();
	}
}
function NormallyVisible()
{
	// do nothing
}
exec function Fire( optional float F )
{
	if (NCMovie(Level.Game) == none && !bDisarmed)
		Super.Fire(f);
	else
	{
		bFire = 0;
		if (NCMovie(Level.Game) != none)
			B227_SwitchToNextLevel();
	}
}

function MainAltFire( optional float F ) {
	bJustAltFired = true;
	if( bShowMenu || (Level.Pauser!="") || (Role < ROLE_Authority) )
	{
		if ( !bShowMenu && (Level.Pauser == PlayerReplicationInfo.PlayerName) )
			SetPause(False);
		return;
	}
	if( SelectedSpell!=None && (!bDisarmed || SelectedSpell.bHarmless))
	{
		SelectedSpell.Cast();
	}
}
state FeigningDeath
{
ignores SeePlayer, HearNoise, Bump, Fire, AltFire;
	event PlayerTick( float DeltaTime )
	{
		Super(UnrealIPlayer).PlayerTick(DeltaTime);
	}
}
exec function AltFire( optional float F )
{
	if (NCMovie(Level.Game) == none)
		MainAltFire(f);
	else
	{
		bAltFire = 0;
		B227_SwitchToNextLevel();
	}
}
exec function SwitchWeapon (byte F )
{
	if (NCMovie(Level.Game) == none) {
		NCHUD(myHUD).weaponTime = Level.TimeSeconds;
		Super.SwitchWeapon(F);
	}
}

function bool determineUsability(Inventory Inv) {
	if ( Inv.bActivatable && ((pickupGroup == 0 && NCPickup(Inv) == None) || (NCPickup(Inv) != none && (NCPickup(Inv).pickupGroup == pickupGroup || NCPickup(Inv).interGroup) ) ) ) {
		return true;
	}
	else {
		//ClientMessage(NCPickup(Inv).pickupgroup $ " my group: " $ pickupgroup);
		return false;
	}
}

exec function PrevItem()
{
	local Inventory Inv, LastInv;

	if (NCMovie(Level.Game) == none) {
		if (NCDiary(SelectedItem) != none && NCDiary(SelectedItem).isInState('Activated')) {
			NCDiary(SelectedItem).CycleEntry(-1);
			return;
		}
		if (NCLogbook(SelectedItem) != none && NCLogbook(SelectedItem).bCurrentlyActivated) {
			NCLogbook(SelectedItem).CycleEntry(-1);
			return;
		}
		if (NCHUD(myHUD) != none)
			NCHUD(myHUD).inventoryTime = Level.TimeSeconds;
		//-Super.PrevItem();
		//-while (!determineUsability(SelectedItem) && SelectedItem != none)
		//-	Super.PrevItem();
		for (Inv = Inventory; Inv != SelectedItem && Inv != none; Inv = Inv.Inventory)
			if (Inv.bActivatable && determineUsability(Inv))
				LastInv = Inv;
		if (LastInv == none && SelectedItem != none) {
			for (Inv = SelectedItem; Inv != none; Inv = Inv.Inventory)
				if (Inv.bActivatable && determineUsability(Inv))
					LastInv = Inv;
		}
		if (LastInv != none) {
			SelectedItem = LastInv;
			ClientMessage(SelectedItem.ItemName $ SelectedItem.M_Selected);
		}
	}
}

exec function NextItem()
{
	local Inventory Inv;

	if (NCMovie(Level.Game) == none) {
		if (NCDiary(SelectedItem) != none && NCDiary(SelectedItem).isInState('Activated')) {
			NCDiary(SelectedItem).CycleEntry(1);
			return;
		}
		if (NCLogbook(SelectedItem) != none && NCLogbook(SelectedItem).bCurrentlyActivated) {
			NCLogbook(SelectedItem).CycleEntry(1);
			return;
		}
		if (NCHUD(myHUD) != none)
			NCHUD(myHUD).inventoryTime = Level.TimeSeconds;
		//-Super.NextItem();
		//-while (SelectedItem != none && !determineUsability(SelectedItem))
		//-	Super.NextItem();
		if (SelectedItem != none) {
			for (Inv = SelectedItem.Inventory; Inv != none; Inv = Inv.Inventory)
				if (Inv.bActivatable && determineUsability(Inv))
					break;
		}
		if (Inv == none) {
			for (Inv = Inventory; Inv != SelectedItem && Inv != none; Inv = Inv.Inventory)
				if (Inv.bActivatable && determineUsability(Inv))
					break;
		}
		if (Inv != none) {
			SelectedItem = Inv;
			ClientMessage(SelectedItem.ItemName $ SelectedItem.M_Selected);
		}
	}
}

state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		local bool bOldHidden;
		local float oldScale;

		oldScale = ScaleGlow;
		bOldHidden = bHidden;
		Super.ProcessMove(DeltaTime, NewAccel, DodgeMove, DeltaRot);
		bHidden = bOldHidden;
		ScaleGlow = oldScale;
	}
}

exec function GetWeapon(class<Weapon> NewWeaponClass ) // changed to allow selection of weapons w/o ammo
{
	local Inventory Inv;

	if (Level.NetMode == NM_Client)
		B227_GetWeapon(NewWeaponClass);
	else if (NCMovie(Level.Game) == none) {
		if ( (Inventory == None) || (NewWeaponClass == None)
			|| ((Weapon != None) && (Weapon.Class == NewWeaponClass)) )
			return;

		for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory ) {
			if ( Inv.Class == NewWeaponClass )
			{
				PendingWeapon = Weapon(Inv);
				Weapon.PutDown();
				return;
			}
		}
	}
}

/* PrevWeapon()
- switch to previous inventory group weapon
*/
exec function PrevWeapon()
{
	local int prevGroup;
	local Inventory inv;
	local Weapon realWeapon, w, Prev;
	local bool bFoundWeapon;

	if (NCMovie(Level.Game) != none)
		return;
	NCHUD(myHUD).weaponTime = Level.TimeSeconds;
	if( bShowMenu || Level.Pauser!="" )
		return;
	if ( Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}
	prevGroup = 0;
	realWeapon = Weapon;
	if ( PendingWeapon != None )
		Weapon = PendingWeapon;
	PendingWeapon = None;

	for (inv=Inventory; inv!=None; inv=inv.Inventory)
	{
		w = Weapon(inv);
		if ( w != None )
		{
			if ( w.InventoryGroup == Weapon.InventoryGroup )
			{
				if ( w == Weapon )
				{
					bFoundWeapon = true;
					if ( Prev != None )
					{
						PendingWeapon = Prev;
						break;
					}
				}
				else if ( !bFoundWeapon )
					Prev = W;
			}
			else if ( (w.InventoryGroup < Weapon.InventoryGroup)
					&& (w.InventoryGroup >= prevGroup) )
			{
				prevGroup = w.InventoryGroup;
				PendingWeapon = w;
			}
		}
	}
	bFoundWeapon = false;
	prevGroup = Weapon.InventoryGroup;
	if ( PendingWeapon == None )
		for (inv=Inventory; inv!=None; inv=inv.Inventory)
		{
			w = Weapon(inv);
			if ( w != None )
			{
				if ( w.InventoryGroup == Weapon.InventoryGroup )
				{
					if ( w == Weapon )
						bFoundWeapon = true;
					else if ( bFoundWeapon && (PendingWeapon == None) )
						PendingWeapon = W;
				}
				else if ( (w.InventoryGroup > PrevGroup) )
				{
					prevGroup = w.InventoryGroup;
					PendingWeapon = w;
				}
			}
		}

	Weapon = realWeapon;
	if ( PendingWeapon == None )
		return;

	Weapon.PutDown();
}

/* NextWeapon()
- switch to next inventory group weapon
*/
exec function NextWeapon()
{
	local int nextGroup;
	local Inventory inv;
	local Weapon realWeapon, w, Prev;
	local bool bFoundWeapon;

	if (NCMovie(Level.Game) != none)
		return;
	NCHUD(myHUD).weaponTime = Level.TimeSeconds;
	if( bShowMenu || Level.Pauser!="" )
		return;
	if ( Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}
	nextGroup = 100;
	realWeapon = Weapon;
	if ( PendingWeapon != None )
		Weapon = PendingWeapon;
	PendingWeapon = None;

	for (inv=Inventory; inv!=None; inv=inv.Inventory)
	{
		w = Weapon(inv);
		if ( w != None )
		{
			if ( w.InventoryGroup == Weapon.InventoryGroup )
			{
				if ( w == Weapon )
					bFoundWeapon = true;
				else if ( bFoundWeapon )
				{
					PendingWeapon = W;
					break;
				}
			}
			else if ( (w.InventoryGroup > Weapon.InventoryGroup) && (w.InventoryGroup < nextGroup) )
			{
				nextGroup = w.InventoryGroup;
				PendingWeapon = w;
			}
		}
	}

	bFoundWeapon = false;
	nextGroup = Weapon.InventoryGroup;
	if ( PendingWeapon == None )
		for (inv=Inventory; inv!=None; inv=inv.Inventory)
		{
			w = Weapon(Inv);
			if ( w != None )
			{
				if ( w.InventoryGroup == Weapon.InventoryGroup )
				{
					if ( w == Weapon )
					{
						bFoundWeapon = true;
						if ( Prev != None )
							PendingWeapon = Prev;
					}
					else if ( !bFoundWeapon && (PendingWeapon == None) )
						Prev = W;
				}
				else if ( (w.InventoryGroup < nextGroup) )
				{
					nextGroup = w.InventoryGroup;
					PendingWeapon = w;
				}
			}
		}

	Weapon = realWeapon;
	if ( PendingWeapon == None )
		return;

	Weapon.PutDown();
}

function PlayDodge(eDodgeDir DodgeMove)
{
	Velocity.Z = 210;
	if ( DodgeMove == DODGE_Left )
		TweenAnim('DodgeL', 0.25);
	else if ( DodgeMove == DODGE_Right )
		TweenAnim('DodgeR', 0.25);
	else if ( DodgeMove == DODGE_Back )
		TweenAnim('DodgeB', 0.25);
	else
		PlayAnim('Flip', 1.35 * FMax(0.35, Region.Zone.ZoneGravity.Z/Region.Zone.Default.ZoneGravity.Z), 0.06);
}

function PlayChatting()
{
	if ( mesh != None )
		LoopAnim('Chat1', 0.7, 0.25);
}

function PlayWaiting()
{
	local name newAnim;

	if ( Mesh == None )
		return;

	if ( bIsTyping )
	{
		PlayChatting();
		return;
	}

	if ( (IsInState('PlayerSwimming')) || (Physics == PHYS_Swimming) )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			LoopAnim('TreadSM');
		else
			LoopAnim('TreadLG');
	}
	else
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		ViewRotation.Pitch = ViewRotation.Pitch & 65535;
		If ( (ViewRotation.Pitch > RotationRate.Pitch)
			&& (ViewRotation.Pitch < 65536 - RotationRate.Pitch) )
		{
			If (ViewRotation.Pitch < 32768)
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
					TweenAnim('AimUpSm', 0.3);
				else
					TweenAnim('AimUpLg', 0.3);
			}
			else
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
					TweenAnim('AimDnSm', 0.3);
				else
					TweenAnim('AimDnLg', 0.3);
			}
		}
		else if ( (Weapon != None) && Weapon.bPointing )
		{
			if ( Weapon.bRapidFire && ((bFire != 0) || (bAltFire != 0)) )
				LoopAnim('StillFRRP');
			else if ( Weapon.Mass < 20 )
				TweenAnim('StillSMFR', 0.3);
			else
				TweenAnim('StillFRRP', 0.3);
		}
		else
		{
			if ( FRand() < 0.1 )
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
					PlayAnim('CockGun', 0.5 + 0.5 * FRand(), 0.3);
				else
					PlayAnim('CockGunL', 0.5 + 0.5 * FRand(), 0.3);
			}
			else
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
				{
					if ( (FRand() < 0.75) && ((AnimSequence == 'Breath1') || (AnimSequence == 'Breath2')) )
						newAnim = AnimSequence;
					else if ( FRand() < 0.5 )
						newAnim = 'Breath1';
					else
						newAnim = 'Breath2';
				}
				else
				{
					if ( (FRand() < 0.75) && ((AnimSequence == 'Breath1L') || (AnimSequence == 'Breath2L')) )
						newAnim = AnimSequence;
					else if ( FRand() < 0.5 )
						newAnim = 'Breath1L';
					else
						newAnim = 'Breath2L';
				}

				if ( AnimSequence == newAnim )
					LoopAnim(newAnim, 0.4 + 0.4 * FRand());
				else
					PlayAnim(newAnim, 0.4 + 0.4 * FRand(), 0.25);
			}
		}
	}
}

function PlayTurning()
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if ( (Weapon == None) || (Weapon.Mass < 20) )
		PlayAnim('TurnSM', 0.3, 0.3);
	else
		PlayAnim('TurnLG', 0.3, 0.3);
}

function TweenToWalking(float tweentime)
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if (Weapon == None)
		TweenAnim('Walk', tweentime);
	else if ( Weapon.bPointing || (CarriedDecoration != None) )
	{
		if (Weapon.Mass < 20)
			TweenAnim('WalkSMFR', tweentime);
		else
			TweenAnim('WalkLGFR', tweentime);
	}
	else
	{
		if (Weapon.Mass < 20)
			TweenAnim('WalkSM', tweentime);
		else
			TweenAnim('WalkLG', tweentime);
	}
}

function PlayWalking()
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if (Weapon == None)
		LoopAnim('Walk');
	else if ( Weapon.bPointing || (CarriedDecoration != None) )
	{
		if (Weapon.Mass < 20)
			LoopAnim('WalkSMFR');
		else
			LoopAnim('WalkLGFR');
	}
	else
	{
		if (Weapon.Mass < 20)
			LoopAnim('WalkSM');
		else
			LoopAnim('WalkLG');
	}
}

function TweenToRunning(float tweentime)
{
	local vector X,Y,Z, Dir;

	BaseEyeHeight = Default.BaseEyeHeight;
	if (bIsWalking)
	{
		TweenToWalking(0.1);
		return;
	}

	GetAxes(Rotation, X,Y,Z);
	Dir = Normal(Acceleration);
	if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
	{
		// strafing or backing up
		if ( Dir Dot X < -0.75 )
			PlayAnim('BackRun', 0.9, tweentime);
		else if ( Dir Dot Y > 0 )
			PlayAnim('StrafeR', 0.9, tweentime);
		else
			PlayAnim('StrafeL', 0.9, tweentime);
	}
	else if (Weapon == None)
		PlayAnim('RunSM', 0.9, tweentime);
	else if ( Weapon.bPointing )
	{
		if (Weapon.Mass < 20)
			PlayAnim('RunSMFR', 0.9, tweentime);
		else
			PlayAnim('RunLGFR', 0.9, tweentime);
	}
	else
	{
		if (Weapon.Mass < 20)
			PlayAnim('RunSM', 0.9, tweentime);
		else
			PlayAnim('RunLG', 0.9, tweentime);
	}
}

function PlayRunning()
{
	local vector X,Y,Z, Dir;

	BaseEyeHeight = Default.BaseEyeHeight;

	// determine facing direction
	GetAxes(Rotation, X,Y,Z);
	Dir = Normal(Acceleration);
	if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
	{
		// strafing or backing up
		if ( Dir Dot X < -0.75 )
			LoopAnim('BackRun');
		else if ( Dir Dot Y > 0 )
			LoopAnim('StrafeR');
		else
			LoopAnim('StrafeL');
	}
	else if (Weapon == None)
		LoopAnim('RunSM');
	else if ( Weapon.bPointing )
	{
		if (Weapon.Mass < 20)
			LoopAnim('RunSMFR');
		else
			LoopAnim('RunLGFR');
	}
	else
	{
		if (Weapon.Mass < 20)
			LoopAnim('RunSM');
		else
			LoopAnim('RunLG');
	}
}

function PlayRising()
{
	BaseEyeHeight = 0.4 * Default.BaseEyeHeight;
	TweenAnim('DuckWlkS', 0.7);
}

function PlayFeignDeath()
{
	local float decision;

	BaseEyeHeight = 0;
	decision = frand();
	if ( decision < 0.33 )
		TweenAnim('DeathEnd', 0.5);
	else if ( decision < 0.67 )
		TweenAnim('DeathEnd2', 0.5);
	else
		TweenAnim('DeathEnd3', 0.5);
}

function PlayGutHit(float tweentime)
{
	if ( (AnimSequence == 'GutHit') || (AnimSequence == 'Dead2') )
	{
		if (FRand() < 0.5)
			TweenAnim('LeftHit', tweentime);
		else
			TweenAnim('RightHit', tweentime);
	}
	else if ( FRand() < 0.6 )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('Dead2', tweentime);

}

function PlayHeadHit(float tweentime)
{
	if ( (AnimSequence == 'HeadHit') || (AnimSequence == 'Dead4') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('HeadHit', tweentime);
	else
		TweenAnim('Dead4', tweentime);
}

function PlayLeftHit(float tweentime)
{
	if ( (AnimSequence == 'LeftHit') || (AnimSequence == 'Dead3') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('LeftHit', tweentime);
	else
		TweenAnim('Dead3', tweentime);
}

function PlayRightHit(float tweentime)
{
	if ( (AnimSequence == 'RightHit') || (AnimSequence == 'Dead5') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('RightHit', tweentime);
	else
		TweenAnim('Dead5', tweentime);
}

function PlayLanded(float impactVel)
{
	impactVel = impactVel/JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	BaseEyeHeight = Default.BaseEyeHeight;

	if ( impactVel > 0.17 )
		PlaySound(LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
	if ( !FootRegion.Zone.bWaterZone && (impactVel > 0.01) )
		PlaySound(Land, SLOT_Interact, FClamp(4 * impactVel,0.5,5), false,1000, 1.0);
	if ( (impactVel > 0.06) || (GetAnimGroup(AnimSequence) == 'Jumping') || (GetAnimGroup(AnimSequence) == 'Ducking') )
	{
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('LandSMFR', 0.12);
		else
			TweenAnim('LandLGFR', 0.12);
	}
	else if ( !IsAnimating() )
	{
		if ( GetAnimGroup(AnimSequence) == 'TakeHit' )
		{
			SetPhysics(PHYS_Walking);
			AnimEnd();
		}
		else
		{
			if ( (Weapon == None) || (Weapon.Mass < 20) )
				TweenAnim('LandSMFR', 0.12);
			else
				TweenAnim('LandLGFR', 0.12);
		}
	}
}

function PlayInAir()
{
	local vector X,Y,Z, Dir;
	local float f, TweenTime;

	BaseEyeHeight =  0.7 * Default.BaseEyeHeight;

	if ( (GetAnimGroup(AnimSequence) == 'Landing') && !bLastJumpAlt )
	{
		GetAxes(Rotation, X,Y,Z);
		Dir = Normal(Acceleration);
		f = Dir dot Y;
		if ( f > 0.7 )
			TweenAnim('DodgeL', 0.35);
		else if ( f < -0.7 )
			TweenAnim('DodgeR', 0.35);
		else if ( Dir dot X > 0 )
			TweenAnim('DodgeF', 0.35);
		else
			TweenAnim('DodgeB', 0.35);
		bLastJumpAlt = true;
		return;
	}
	bLastJumpAlt = false;
	if ( GetAnimGroup(AnimSequence) == 'Jumping' )
	{
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('DuckWlkS', 2);
		else
			TweenAnim('DuckWlkL', 2);
		return;
	}
	else if ( GetAnimGroup(AnimSequence) == 'Ducking' )
		TweenTime = 2;
	else
		TweenTime = 0.7;

	if ( AnimSequence == 'StrafeL' )
		TweenAnim('DodgeR', TweenTime);
	else if ( AnimSequence == 'StrafeR' )
		TweenAnim('DodgeL', TweenTime);
	else if ( AnimSequence == 'BackRun' )
		TweenAnim('DodgeB', TweenTime);
	else if ( (Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('JumpSMFR', TweenTime);
	else
		TweenAnim('JumpLGFR', TweenTime);
}

function PlayDuck()
{
	BaseEyeHeight = 0;
	if ( (Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('DuckWlkS', 0.25);
	else
		TweenAnim('DuckWlkL', 0.25);
}

function PlayCrawling()
{
	//log("Play duck");
	BaseEyeHeight = 0;
	if ( (Weapon == None) || (Weapon.Mass < 20) )
		LoopAnim('DuckWlkS');
	else
		LoopAnim('DuckWlkL');
}

function TweenToWaiting(float tweentime)
{
	if ( (IsInState('PlayerSwimming')) || (Physics == PHYS_Swimming) )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('TreadSM', tweentime);
		else
			TweenAnim('TreadLG', tweentime);
	}
	else
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('StillSMFR', tweentime);
		else
			TweenAnim('StillFRRP', tweentime);
	}
}

function PlayRecoil(float Rate)
{
	if ( Weapon.bRapidFire )
	{
		if ( !IsAnimating() && (Physics == PHYS_Walking) )
			LoopAnim('StillFRRP', 0.02);
	}
	else if ( AnimSequence == 'StillSmFr' )
		PlayAnim('StillSmFr', Rate, 0.02);
	else if ( (AnimSequence == 'StillLgFr') || (AnimSequence == 'StillFrRp') )
		PlayAnim('StillLgFr', Rate, 0.02);
}

function PlayFiring()
{
	// switch animation sequence mid-stream if needed
	if (AnimSequence == 'RunLG')
		AnimSequence = 'RunLGFR';
	else if (AnimSequence == 'RunSM')
		AnimSequence = 'RunSMFR';
	else if (AnimSequence == 'WalkLG')
		AnimSequence = 'WalkLGFR';
	else if (AnimSequence == 'WalkSM')
		AnimSequence = 'WalkSMFR';
	else if ( AnimSequence == 'JumpSMFR' )
		TweenAnim('JumpSMFR', 0.03);
	else if ( AnimSequence == 'JumpLGFR' )
		TweenAnim('JumpLGFR', 0.03);
	else if ( (GetAnimGroup(AnimSequence) == 'Waiting') || (GetAnimGroup(AnimSequence) == 'Gesture')
		&& (AnimSequence != 'TreadLG') && (AnimSequence != 'TreadSM') )
	{
		if ( Weapon.Mass < 20 )
			TweenAnim('StillSMFR', 0.02);
		else
			TweenAnim('StillFRRP', 0.02);
	}
}

function PlayWeaponSwitch(Weapon NewWeapon)
{
	if ( (Weapon == None) || (Weapon.Mass < 20) )
	{
		if ( (NewWeapon != None) && (NewWeapon.Mass > 20) )
		{
			if ( (AnimSequence == 'RunSM') || (AnimSequence == 'RunSMFR') )
				AnimSequence = 'RunLG';
			else if ( (AnimSequence == 'WalkSM') || (AnimSequence == 'WalkSMFR') )
				AnimSequence = 'WalkLG';
		 	else if ( AnimSequence == 'JumpSMFR' )
		 		AnimSequence = 'JumpLGFR';
			else if ( AnimSequence == 'DuckWlkL' )
				AnimSequence = 'DuckWlkS';
		 	else if ( AnimSequence == 'StillSMFR' )
		 		AnimSequence = 'StillFRRP';
			else if ( AnimSequence == 'AimDnSm' )
				AnimSequence = 'AimDnLg';
			else if ( AnimSequence == 'AimUpSm' )
				AnimSequence = 'AimUpLg';
		 }
	}
	else if ( (NewWeapon == None) || (NewWeapon.Mass < 20) )
	{
		if ( (AnimSequence == 'RunLG') || (AnimSequence == 'RunLGFR') )
			AnimSequence = 'RunSM';
		else if ( (AnimSequence == 'WalkLG') || (AnimSequence == 'WalkLGFR') )
			AnimSequence = 'WalkSM';
	 	else if ( AnimSequence == 'JumpLGFR' )
	 		AnimSequence = 'JumpSMFR';
		else if ( AnimSequence == 'DuckWlkS' )
			AnimSequence = 'DuckWlkL';
	 	else if (AnimSequence == 'StillFRRP')
	 		AnimSequence = 'StillSMFR';
		else if ( AnimSequence == 'AimDnLg' )
			AnimSequence = 'AimDnSm';
		else if ( AnimSequence == 'AimUpLg' )
			AnimSequence = 'AimUpSm';
	}
}

function PlaySwimming()
{
	BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
	if ((Weapon == None) || (Weapon.Mass < 20) )
		LoopAnim('SwimSM');
	else
		LoopAnim('SwimLG');
}

function TweenToSwimming(float tweentime)
{
	BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
	if ((Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('SwimSM',tweentime);
	else
		TweenAnim('SwimLG',tweentime);
}

function B227_GetWeapon(class<Weapon> NewWeaponClass)
{
	if (Level.NetMode != NM_Client)
		GetWeapon(NewWeaponClass);
}

function B227_SwitchToNextLevel()
{
	local Teleporter Telep;

	if (Level.NetMode != NM_Standalone)
		return;

	foreach Level.AllActors(class'Teleporter', Telep)
		if (InStr(Telep.URL, "/") > 0 || InStr(Telep.URL, "#") > 0)
		{
			Level.GetLocalPlayerPawn().ClientTravel(Telep.URL, TRAVEL_Relative, true);
			return;
		}
}

final static function SwitchToNextLevel(LevelInfo Level, string URL, bool bItems)
{
	local Teleporter Telep;

	if (Len(URL) == 0)
	{
		foreach Level.AllActors(class'Teleporter', Telep)
			if (InStr(Telep.URL, "/") > 0 || InStr(Telep.URL, "#") > 0)
			{
				URL = Telep.URL;
				break;
			}
	}
	else if (InStr(URL, "/") <= 0 && InStr(URL, "#") <= 0)
		return;

	if (Len(URL) == 0)
		return;

	if (Level.NetMode == NM_Standalone)
		Level.GetLocalPlayerPawn().ClientTravel(URL, TRAVEL_Relative, bItems);
	else
		Level.ServerTravel(URL, bItems);
}

defaultproperties
{
     SpellSkills(0)=1
     LevelNeeds(1)=1000.000000
     LevelNeeds(2)=1500.000000
     LevelNeeds(3)=3000.000000
     LevelNeeds(4)=6000.000000
     LevelNeeds(5)=12000.000000
     LevelNeeds(6)=30000.000000
     LevelNeeds(7)=60000.000000
     LevelNeeds(8)=150000.000000
     mana=100.000000
     maxmana=100.000000
     bookmessage(0)="Earth magic book selected"
     bookmessage(1)="Water magic book selected"
     bookmessage(2)="Wind magic book selected"
     bookmessage(3)="Fire magic book selected"
     bookmessage(4)="Divine magic book selected"
     bookmessage(5)="Dark magic book selected"
     breathagain=Sound'NaliChronicles.NaliMage.DeepBreath1'
     GaspSound=Sound'NaliChronicles.NaliMage.DeepBreath2'
     bCheatsEnabled=True
     Health=100
     MenuName="NaGaruuk"
     Skin=Texture'UnrealShare.Skins.JNali2'
     Mesh=LodMesh'epiccustommodels.tnalimesh'
     DrawScale=1.300000
}
