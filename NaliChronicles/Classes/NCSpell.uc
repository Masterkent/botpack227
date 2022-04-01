// The base of all spells
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpell extends Inventory
	abstract;

var() bool bHarmless;
var float lasttime;
var bool spelldone;
var() sound StartSound, EndSound, CastingSound, FailSound;
var() float manapersecond;
var() texture InfoTexture;
var() int book;
var() bool bReadyToCast, bCasting;
var() float recycletime, casttime;
var float percentcompleted;
var float currtime;
var float stress;
var float lasthealth;
var() texture magicsparkskin[8];
var() class<NCSpellEffect> magicspark;
var() class<NCSpellEffect> starteffect;
var() class<NCSpellEffect> endeffect;
var float SpellEffectTime;
var float magicsparkcolor;
var() float difficulty;

function float GetMySkill() {
	local float f, skillFloat;

	skillFloat = NaliMage(Owner).SpellSkills[book];
	skillFloat = skillFloat/10;
	f = skillFloat+difficulty;
	if (f > 2.0)
		f = 2.0;

	return f;
}

function bool HandlePickupQuery( inventory Item )
{
	if (item.class == class) {
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
		Pawn(Owner).ClientMessage(item.PickupMessage, 'Pickup');
		Item.PlaySound (Item.PickupSound,,2.0);
		Item.SetRespawn();
		Item.Destroy();
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

auto state Pickup
{
	function Touch( actor Other )
	{
		local Inventory Copy;
		if ( ValidTouch(Other) )
		{
			Copy = SpawnCopy(Pawn(Other));
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
			Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
			PlaySound (PickupSound,,2.0);
			//-Pickup(Copy).PickupFunction(Pawn(Other)); // this not a Pickup
			if ((NaliMage(Other) != none) && (NaliMage(Other).OpenBooks[book] == 0))
				NaliMage(Other).OpenBooks[book] = 1;
		}
	}
}

function Cast() {
	if (NaliMage(Owner).Mana >= manapersecond*0.1) {
		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		bReadyToCast = false;
		bCasting = true;
		BeginCastEffect();
		GotoState('Casting');
	}
}

function BeginCastEffect() {
	local vector effectlocation, X, Y, Z;
	local actor a;

	SpellEffectTime = 0.0;
	AmbientSound = CastingSound;
	PlaySound(StartSound, SLOT_Misc,Pawn(Owner).SoundDampening*4.0);
	if (starteffect != none) {
		effectlocation = owner.location;
		GetAxes(pawn(owner).viewrotation,X,Y,Z);
		effectlocation += CalcDrawOffset();
		effectlocation += -17 * Z + 40 * X;
		a = Spawn(starteffect,,,effectlocation,pawn(owner).viewrotation);
		if (a.bParticles) {
			a.Texture = magicsparkskin[Rand(8)];
			a.Skin = a.Texture;
		}
	}
}

function FinishCastEffect() {
	local vector effectlocation, X, Y, Z;
	local actor a;

	AmbientSound = None;
	PlaySound(EndSound, SLOT_Misc,Pawn(Owner).SoundDampening*4.0);
	if (endeffect != none) {
		effectlocation = owner.location;
		GetAxes(pawn(owner).viewrotation,X,Y,Z);
		effectlocation += CalcDrawOffset();
		effectlocation += -17 * Z + 40 * X;
		a = Spawn(endeffect,,,effectlocation,pawn(owner).viewrotation);
		if (a.bParticles) {
			a.Texture = magicsparkskin[Rand(8)];
			a.Skin = a.Texture;
		}
	}
}

function FinishCasting(float timeheld) {
	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	stress += (float(Rand(100))/1000)*(1-(GetMySkill()/2));
	NaliMage(Owner).SpellFinished();
	//Pawn(Owner).ClientMessage("stress: "$stress$" charge: "$timeheld$" mana: "$NaliMage(Owner).mana);
}

function float ManaMult() {
	local float f;

	f = Frand();
	if (f > stress/GetMySkill())
		f = stress/GetMySkill();

	if (f < 0)
		f = 0;

	//Pawn(Owner).ClientMessage(1+f);

	return 1+f;
}

function float GetInitialStress() {
	return NaliMage(Owner).GetInitialStress(book);
}

state Casting {
	function BeginState() {
		currtime = Level.TimeSeconds;
		stress = GetInitialStress();
		lasthealth = Pawn(Owner).health;
		lasttime = Level.TimeSeconds;
		SetTimer(0.1,true);
	}

	function Timer() {
		local float timediff;

		// test for things that can disrupt spells
		if ((Pawn(Owner).bFire != 0) && (pawn(owner).weapon != none)) // shooting
			stress += 0.02;
		if (Owner.velocity != vect(0,0,0)) { // moving
			stress += 0.005;
			if ((Owner.Physics == PHYS_Walking) && (Pawn(Owner).Acceleration != vect(0,0,0)))
				stress += 0.005;
			else if (Owner.Physics == PHYS_Falling)
				stress += 0.01;
		}
		if (Pawn(Owner).health < lasthealth) // taking damage
			stress += (lasthealth - Pawn(Owner).health)/20;
		lasthealth = Pawn(Owner).health;
		timediff = Level.TimeSeconds - lasttime;
		while ((timediff - 0.1) >= 0) {
			timediff -= 0.1;
			if (Pawn(Owner).bAltFire != 0) {
				if (!NaliMage(Owner).TakeMana( manapersecond*0.1*ManaMult() )) {
					FinishCastEffect();
					FinishCasting(Level.TimeSeconds-currtime);
					percentcompleted = (Level.TimeSeconds-currtime)/casttime;
					spelldone=false;
					timediff = 0;
					GotoState('Recycling');
				}
				else {
					if (spelldone) {
						FinishCastEffect();
						FinishCasting(casttime);
						stress = 0.0;
						percentcompleted = 1.0;
						spelldone=false;
						timediff = 0;
						GotoState('Recycling');
					}
				}
			}
		}
		lasttime = Level.TimeSeconds - timediff;
	}

	function Cast() { }

	function float BigRand() {
		local float f;

		f = Frand()*5;
		if (Frand() >= 0.5)
			f = -f;
		return f;
	}

	function Tick(float DeltaTime) {
		local vector effectlocation, X, Y, Z;
		local actor a;

		SetLocation(Owner.location);
		SpellEffectTime += DeltaTime;
		if (SpellEffectTime >= 0.15) {
			SpellEffectTime -= 0.15;
			if (magicspark != none) {
				effectlocation = owner.location;
				GetAxes(pawn(owner).viewrotation,X,Y,Z);
				effectlocation += CalcDrawOffset();
				effectlocation += (-17+BigRand())*Z + BigRand()*Y + (40+BigRand())*X;
				a = Spawn(magicspark,,,effectlocation,pawn(owner).viewrotation);
				a.LightHue = magicsparkcolor;
				a.Texture = magicsparkskin[Rand(8)];
			}
		}
		if (Pawn(Owner).bAltFire == 0) {
			FinishCastEffect();
			FinishCasting(Level.TimeSeconds-currtime);
			stress = 0.0;
			percentcompleted = (Level.TimeSeconds-currtime)/casttime;
			spelldone=false;
			GotoState('Recycling');
		}
	}

	Begin:
	sleep(casttime);
	spelldone=true;
}

state Recycling {
	function BeginState() {
		currtime = Level.TimeSeconds;
	}

	function Cast() { }

	Begin:
	bCasting = false;
	sleep(recycletime*percentcompleted);
	bReadyToCast = true;
	GotoState('Idle2');
}

defaultproperties
{
     StartSound=Sound'UnrealI.Queen.stab1Q'
     EndSound=Sound'UnrealShare.Generic.RespawnSound'
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant03'
     FailSound=Sound'UnrealI.Krall.hit2k'
     manapersecond=5.000000
     bReadyToCast=True
     recycletime=2.000000
     casttime=1.000000
     magicsparkskin(0)=Texture'UnrealShare.Effects.T_PawnT'
     magicsparkskin(1)=Texture'Botpack.FlareFX.utflare8'
     magicsparkskin(2)=Texture'Botpack.FlareFX.utflare5'
     magicsparkskin(3)=Texture'UnrealShare.SKEffect.Skj_a09'
     magicsparkskin(4)=Texture'Botpack.ASMDAlt.ASMDAlt_a02'
     magicsparkskin(5)=Texture'Botpack.BoltCap.pEnd_a02'
     magicsparkskin(6)=Texture'Botpack.PlasmaExplo.pblst_a03'
     magicsparkskin(7)=Texture'Botpack.RipperPulse.HEexpl1_a03'
     magicspark=Class'NaliChronicles.NCMagicSpark'
     starteffect=Class'NaliChronicles.NCStartEffect'
     endeffect=Class'NaliChronicles.NCEndEffect'
     magicsparkcolor=10.000000
     Difficulty=1.000000
     bAmbientGlow=False
     bRotatingPickup=False
     PickupMessage="You found a spell"
     PickupViewMesh=LodMesh'NaliChronicles.smallscroll'
     PickupViewScale=0.600000
     PickupSound=Sound'UnrealShare.Pickups.HEALTH1'
     Icon=Texture'UnrealShare.Icons.I_Health'
     Skin=Texture'NaliChronicles.Skins.Jsmallscroll'
     Mesh=LodMesh'NaliChronicles.smallscroll'
     DrawScale=0.600000
     AmbientGlow=0
     SoundVolume=240
     CollisionRadius=16.000000
     CollisionHeight=4.000000
}
