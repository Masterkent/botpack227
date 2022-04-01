// The visuals for a magical armor or shield belt
// Code by Sergey 'Eater' Levin, 2001

class NCShieldEffect extends Effects;

var NCShieldEffect weaponChild;
var int FatnessOffset;

simulated function Tick(float DeltaTime)
{
	local int IdealFatness;
	local rotator NewRot;

	if ( bHidden || Owner == None )
		return;

	IdealFatness = Owner.Fatness; // UT shieldbelt code for calculating fatness
	IdealFatness += FatnessOffset;

	if ( Fatness > IdealFatness )
		Fatness = Max(IdealFatness, Fatness - 130 * DeltaTime);
	else
		Fatness = Min(IdealFatness, 255);

	if (weapon(Owner) != none) {
		SetLocation( Owner.Owner.Location + weapon(owner).CalcDrawOffset() );
		NewRot = Pawn(Owner.Owner).ViewRotation;

		if ( PlayerPawn(Owner.Owner).Handedness == 0 )
			newRot.Roll = -2 * owner.Default.Rotation.Roll;
		else
			newRot.Roll = owner.Default.Rotation.Roll * PlayerPawn(Owner.Owner).Handedness;
		SetRotation(NewRot);
	}

	if ((Pawn(Owner) != none) && (weaponChild == none) && (Pawn(Owner).weapon != none)) {
		weaponChild = Spawn(Class'NCShieldEffect',,,Pawn(Owner).weapon.location,Pawn(Owner).weapon.rotation);
		weaponChild.texture = texture;
		weaponChild.setOwner(Pawn(Owner).weapon);
		weaponChild.mesh = Pawn(Owner).weapon.playerviewmesh;
		weaponChild.drawScale = Pawn(Owner).weapon.playerviewscale;
		weaponChild.bOwnerNoSee = False;
		weaponChild.setPhysics(PHYS_None);
		weaponChild.FatnessOffset = 3;
		//Pawn(Owner).clientmessage(weaponChild$" loc: "$weaponChild.location$" wep loc: "$weaponChild.owner.location);
	}
	if ((weaponChild != none) && (weaponChild.owner != Pawn(Owner).weapon)) {
		weaponChild.setOwner(Pawn(Owner).weapon);
		weaponChild.mesh = Pawn(Owner).weapon.playerviewmesh;
		weaponChild.drawScale = Pawn(Owner).weapon.playerviewscale;
	}
}

function Destroyed() {
	if (weaponChild != none) {
		weaponChild.destroy();
	}
}

defaultproperties
{
     FatnessOffset=29
     bAnimByOwner=True
     bOwnerNoSee=True
     bNetTemporary=False
     bTrailerSameRotation=True
     Physics=PHYS_Trailer
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=FireTexture'UnrealShare.Belt_fx.ShieldBelt.N_Shield'
     ScaleGlow=0.500000
     AmbientGlow=64
     Fatness=157
     bUnlit=True
     bMeshEnviroMap=True
}
