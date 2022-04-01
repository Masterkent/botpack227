// Drains health from target and transfers it to player
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellMystDragon extends NCSpell;

var() class<NCDragonHead> head;
var() int newmode;

function FinishCasting(float timeheld) {
	local NCProphetStaff staff;

	Super.FinishCasting(timeheld);
	staff = NCProphetStaff(Pawn(Owner).FindInventoryType(Class'NCProphetStaff'));
	if (staff != none && pawn(owner).weapon == staff) {
		if (staff.head == none) {
			staff.createHead(newmode,head,timeheld*10);
		}
		else {
			if (staff.mode == newmode) {
				staff.head.headLastTime += timeheld*10;
			}
			else {
				staff.createHead(newmode,head,timeheld*10);
			}
		}
	}
}

defaultproperties
{
     Head=Class'NaliChronicles.NCDragonHead'
     newmode=-1
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant02'
     manapersecond=1.000000
     InfoTexture=Texture'NaliChronicles.Icons.MystDragonInfo'
     Book=5
     recycletime=2.500000
     casttime=6.000000
     magicsparkskin(0)=Texture'Botpack.utsmoke.s3r_a00'
     magicsparkskin(1)=Texture'Botpack.utsmoke.us10_a00'
     magicsparkskin(2)=Texture'Botpack.utsmoke.US3_A00'
     magicsparkskin(3)=Texture'Botpack.utsmoke.us4_a00'
     magicsparkskin(4)=Texture'Botpack.utsmoke.us5_a00'
     magicsparkskin(5)=Texture'Botpack.Effects.jenergy2'
     magicsparkskin(6)=Texture'Botpack.Effects.jenergy3'
     magicsparkskin(7)=FireTexture'UnrealShare.Effect16.fireeffect16'
     magicspark=Class'NaliChronicles.NCDarkSpark'
     magicsparkcolor=0.000000
     PickupMessage="You got the dragon head spell for the Prophet's staff"
     ItemName="Dragon Head"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.MystDragon'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolld'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
