// A magical armor that cloaks the player
// Code by Sergey 'Eater' Levin, 2002

class NCShadowArmor extends NCProtectEffect;

var NCShieldEffect myEffect;

function Destroyed()
{
	if (myEffect != none) {
		myEffect.destroy();
	}
	Invisibility(false);
	Super.Destroyed();
}

function GiveTo(Pawn Other)
{
	myEffect = Spawn(Class'NaliChronicles.NCShieldEffect',,,other.location,other.rotation);
	myEffect.setOwner(Other);
	myEffect.Texture = Texture'UnrealShare.Belt_fx.invis';
	myEffect.Mesh = Other.mesh;
	myEffect.DrawScale = Other.DrawScale;
	Super.GiveTo(Other);
	Invisibility(true);
	GotoState('Active');
}

function UsedUp()
{
	if (myEffect != none) {
		myEffect.destroy();
	}
	Invisibility(false); // make absolutely sure we don't remain invisible
	Super.UsedUp();
}

state Active {
	Begin:
	sleep(0.15);
	Owner.ScaleGlow = float(Pawn(Owner).Visibility)/128.0;
	if (Owner.ScaleGlow-0.05 > 0)
		Owner.ScaleGlow -= 0.05;
	else
		Owner.ScaleGlow = 0;
	if (Owner.ScaleGlow <= 0 && hideCheck())
		Owner.bHidden = true;
	Pawn(Owner).Visibility = Owner.ScaleGlow*128.0;
	Goto('Begin');
}

function bool hideCheck() { // perform a check to see if any hostile pawns can see us, and if not, hide
	local Pawn p;

	foreach allactors(Class'Pawn',p) {
		if ((p.Enemy == owner || p.noise1other == owner || p.noise2other == owner)
		    && p.attitudeToPlayer <= ATTITUDE_Threaten && FastTrace(owner.location,p.location))
			return false;
	}
	return true;
}

function Invisibility (bool Vis) // copied from U1, with some changes
{
	if (Pawn(Owner)==None) Return;

	if( Vis )
	{
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).ClientAdjustGlow(-0.15, vect(-156.25,-156.25,-156.25));
		Pawn(Owner).Visibility = 128;
		//Pawn(Owner).bHidden=True;
		Pawn(Owner).ScaleGlow = 1.0;
		Owner.Style = STY_Translucent;
	}
	else
	{
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).ClientAdjustGlow(0.15, vect(156.25,156.25,156.25));
		Pawn(Owner).Visibility = Pawn(Owner).Default.Visibility;
		if ( Pawn(Owner).health > 0 )
			Pawn(Owner).bHidden=False;
		Owner.ScaleGlow = Owner.default.scaleglow;
		Owner.Style = STY_Normal;
	}
}

defaultproperties
{
     timeBeforeDecay=90.000000
     decayTimePerArmor=0.750000
     Charge=100
     ArmorAbsorption=75
     AbsorptionPriority=9
     Icon=Texture'NaliChronicles.Icons.MystShadowarmorBarIcon'
}
