// Base of all NC weapons
// Code by Sergey 'Eater' Levin

class NCWeapon extends TournamentWeapon;

var() byte fred, fgreen, fblue; // colors of the muzzle flash
var() texture InfoTexture; // the info panel
var() bool bHasHand;

function setHand(float Hand) {
	//-if (Hand == 0 || Hand == 2) {
	//-	PlayerPawn(Owner).Handedness = -1;
	//-}
	Super.setHand(Hand);
}

function DoFire(float F) { // the actual fire function
	super(weapon).fire(f);
}

function Fire(float F) {
	if (NaliMage(Owner) == none || !NaliMage(Owner).bDisarmed)
		DoFire(F);
	else
		return;
}

function float RateSelf( out int bUseAltMode )
{
	if ( (AmmoType != None) && (AmmoType.AmmoAmount <=0) )
		return -2;
	bUseAltMode = 0;
	return (AIRating + FRand() * 0.05);
}

function Weapon WeaponChange( byte F )
{
	local Weapon newWeapon;

	if ( InventoryGroup == F )
	{
		return self;
	}
	else if ( Inventory == None )
		return None;
	else
		return Inventory.WeaponChange(F);
}

function BringUp()
{
	local Inventory Inv;

	Skin = Default.Skin;
	for ( Inv=Owner.Inventory; Inv!=None; Inv=Inv.Inventory ) {
		if ( NCProtectEffect(Inv) != none ) {
			NCProtectEffect(Inv).newWeaponDrawn();
		}
	}

	Super.BringUp();
}

simulated event RenderOverlays( canvas Canvas ) // altered to allow multi-colored muzzle flashes
{
	local rotator NewRot;
	local bool bPlayerOwner;
	local int Hand;
	local PlayerPawn PlayerOwner;

	//-if (PlayerPawn(Owner).Handedness == 0 || PlayerPawn(Owner).Handedness == 2) {
	//-	PlayerPawn(Owner).Handedness = -1;
	//-}
	if ( bHideWeapon || (Owner == None) )
		return;

	PlayerOwner = PlayerPawn(Owner);

	if ( PlayerOwner != None )
	{
		if ( PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV )
			return;
		bPlayerOwner = true;
		Hand = PlayerOwner.Handedness;

		if (  (Level.NetMode == NM_Client) && (Hand == 2) )
		{
			bHideWeapon = true;
			return;
		}
	}

	if ( !bPlayerOwner || (PlayerOwner.Player == None) )
		Pawn(Owner).WalkBob = vect(0,0,0);

	if ( (bMuzzleFlash > 0) && bDrawMuzzleFlash && (MFTexture != None) && (!Pawn(Owner).bBehindView))
	{
		MuzzleScale = Default.MuzzleScale * Canvas.ClipX/640.0;
		if ( !bSetFlashTime )
		{
			bSetFlashTime = true;
			FlashTime = Level.TimeSeconds + FlashLength;
		}
		else if ( FlashTime < Level.TimeSeconds )
			bMuzzleFlash = 0;
		if ( bMuzzleFlash > 0 )
		{
			if ( Hand == 0 )
				Canvas.SetPos(Canvas.ClipX/2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipX * (-0.2 * Default.FireOffset.Y * FlashO), Canvas.ClipY/2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipY * (FlashY + FlashC));
			else
				Canvas.SetPos(Canvas.ClipX/2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipX * (Hand * Default.FireOffset.Y * FlashO), Canvas.ClipY/2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipY * FlashY);

			Canvas.Style = 3;
			Canvas.DrawColor.r = fred;
			Canvas.DrawColor.g = fgreen;
			Canvas.DrawColor.b = fblue;
			Canvas.DrawIcon(MFTexture, MuzzleScale);
			Canvas.DrawColor.r = 255;
			Canvas.DrawColor.g = 255;
			Canvas.DrawColor.b = 255;
			Canvas.Style = 1;
		}
	}
	else
		bSetFlashTime = false;

	SetLocation( Owner.Location + CalcDrawOffset() );
	NewRot = Pawn(Owner).ViewRotation;

	if ( Hand == 0 )
		newRot.Roll = -2 * Default.Rotation.Roll;
	else
		newRot.Roll = Default.Rotation.Roll * Hand;

	setRotation(newRot);
	Canvas.DrawActor(self, false);
}

defaultproperties
{
     fred=255
     fgreen=255
     fblue=255
}
