// Used to progress the story line - a communication spell
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellHolyTalk extends NCEnchantSpell;

function FinishCasting(float timeheld) {
	local vector X,Y,Z,startloc;
	local rotator newrot;
	local NCPawnEnchant Enchant;

	Super(NCSpell).FinishCasting(timeheld);
	if (ScanForAccidents(timeheld) && (timeheld >= mintime)) {
		newrot = owner.rotation;
		newrot.pitch = 0;
		GetAxes(newrot,X,Y,Z);
		newrot.yaw += 16384*2;
		startloc = owner.location + 70*X;
		Enchant = Spawn(Enchantment,,,startloc,newrot);
		Enchant.bTargetReceived = true;
	}
}

defaultproperties
{
     Range=1500.000000
     faildamage=0.000000
     Enchantment=Class'NaliChronicles.NCPawnEnchantTalk'
     mintime=1.900000
     bTargeted=False
     manapersecond=0.500000
     InfoTexture=Texture'NaliChronicles.Icons.HolyTalkInfo'
     Book=4
     recycletime=1.000000
     casttime=2.000000
     magicsparkskin(0)=Texture'UnrealShare.Effects.T_PBurst'
     magicsparkskin(1)=Texture'Botpack.RipperPulse.HEexpl1_a01'
     magicsparkskin(2)=Texture'Botpack.RipperPulse.HEexpl1_a03'
     magicsparkskin(3)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(4)=Texture'UnrealShare.DBEffect.de_A00'
     magicsparkskin(5)=Texture'UnrealShare.DEFBurst.dt_a00'
     magicsparkskin(6)=Texture'UnrealShare.Effects.T_PBurst'
     magicsparkskin(7)=Texture'UnrealShare.SKEffect.Skj_a00'
     magicspark=Class'NaliChronicles.NCHolySpark'
     magicsparkcolor=152.000000
     Difficulty=1.200000
     PickupMessage="You got the communication spell"
     ItemName="Communication"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.HolyTalk'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollh'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
