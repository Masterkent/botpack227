//=============================================================================
// UT_Invisibility.
//=============================================================================
class UT_Invisibility extends TournamentPickUp;

#exec MESH IMPORT MESH=invis2M ANIVFILE=MODELS\invis_a.3D DATAFILE=MODELS\invis_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=invis2M STRENGTH=0.5
#exec MESH ORIGIN MESH=invis2M X=0 Y=0 Z=0  YAW=0
#exec MESH SEQUENCE MESH=invis2M SEQ=All    STARTFRAME=0  NUMFRAMES=1
//#exec OBJ LOAD FILE=..\Textures\belt_fx.utx  PACKAGE=botpack.belt_fx
#exec TEXTURE IMPORT NAME=jinvis FILE=MODELS\invis2.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=invis2M X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=invis2M NUM=1 TEXTURE=jinvis
#exec TEXTURE IMPORT NAME=B227_I_UT_Invisibility FILE=Textures\Hud\B227_i_UT_Invisibility.pcx GROUP="Icons" MIPS=OFF

state Activated
{
	function EndState()
	{
		bActive = false;
		if (Owner != none)
		{
			Owner.PlaySound(DeActivateSound, SLOT_None);

			if (Owner.Texture == FireTexture'Botpack227_Base.Belt_fx.Invis.Invis')
			{
				Owner.SetDefaultDisplayProperties();
				if (Pawn(Owner) != none)
					Pawn(Owner).Visibility = Pawn(Owner).default.Visibility;
			}
			B227_SetShieldBeltEffectsVisibility(true);
		}
	}

	// [U227] Excluded
	///function Activate()
	///{
	///	bActive = true;
	///	SetOwnerDisplay();
	///}

	function SetOwnerDisplay()
	{
		if ( !bActive )
			return;
		Owner.SetDisplayProperties(ERenderStyle.STY_Translucent, 
							 FireTexture'Botpack227_Base.Belt_fx.Invis.Invis',
							 false,
							 true);
		B227_SetShieldBeltEffectsVisibility(false);
		if( Inventory != None )
			Inventory.SetOwnerDisplay();
	}

	function ChangedWeapon()
	{
		if ( !bActive )
			return;
		if( Inventory != None )
			Inventory.ChangedWeapon();

		// Make new weapon invisible.
		if (Pawn(Owner) != none && Pawn(Owner).Weapon != none)
			Pawn(Owner).Weapon.SetDisplayProperties(ERenderStyle.STY_Translucent, 
									 FireTexture'Botpack227_Base.Belt_fx.Invis.Invis',
									 false,
									 true);
	}

	function Timer()
	{
		if (Pawn(Owner) == none)
		{
			UsedUp();
			return;
		}
		Charge -= 1;
		if (Charge <= 0)
			UsedUp();
		else
		{
			Pawn(Owner).Visibility = Min(10, Pawn(Owner).Visibility);
			if (Owner.Style != STY_Translucent)
				Owner.SetDisplayProperties(
					ERenderStyle.STY_Translucent, 
					FireTexture'Botpack227_Base.Belt_fx.Invis.Invis',
					false,
					true);
			else if (Pawn(Owner).Weapon != none && Pawn(Owner).Weapon.Style != STY_Translucent)
				Pawn(Owner).Weapon.SetDisplayProperties(ERenderStyle.STY_Translucent, 
									 FireTexture'Botpack227_Base.Belt_fx.Invis.Invis',
									 false,
									 true);
			B227_SetShieldBeltEffectsVisibility(false);
		}
	}

	function BeginState()
	{
		bActive = true;
		Owner.PlaySound(ActivateSound, SLOT_None, 4.0);

		Owner.SetDisplayProperties(ERenderStyle.STY_Translucent, 
								   FireTexture'Botpack227_Base.Belt_fx.Invis.Invis',
								   false,
								   true);
		SetTimer(0.5,True);
		B227_SetShieldBeltEffectsVisibility(false);
	}
}

state DeActivated
{
Begin:
}

// Auxiliary
function B227_SetShieldBeltEffectsVisibility(bool bVisible)
{
	local ShieldBeltEffect BeltEffect;
	local UT_ShieldBeltEffect UTBeltEffect;

	if (bVisible)
	{
		foreach Owner.ChildActors(class'ShieldBeltEffect', BeltEffect)
			if (BeltEffect.DrawType == DT_None)
				BeltEffect.DrawType = BeltEffect.default.DrawType;
	}
	else
	{
		foreach Owner.ChildActors(class'ShieldBeltEffect', BeltEffect)
			BeltEffect.DrawType = DT_None;
	}
	foreach Owner.ChildActors(class'UT_ShieldBeltEffect', UTBeltEffect)
		UTBeltEffect.bHidden = !bVisible;
}

defaultproperties
{
	ExpireMessage="Invisibility has worn off."
	bAutoActivate=True
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You have Invisibility."
	ItemName="Invisibility"
	RespawnTime=120.000000
	PickupViewMesh=LodMesh'Botpack.invis2M'
	Charge=100
	MaxDesireability=1.200000
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	ActivateSound=Sound'Botpack227_Base.Pickups.Invisible'
	RemoteRole=ROLE_DumbProxy
	Texture=FireTexture'Botpack227_Base.Belt_fx.Invis.Invis'
	Mesh=LodMesh'Botpack.invis2M'
	CollisionRadius=15.000000
	CollisionHeight=20.000000
	Icon=Texture'Botpack.Icons.B227_I_UT_Invisibility'
}
