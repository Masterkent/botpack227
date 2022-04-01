// A simple magic armor spell that gives the player a cloud shield that provides good defense but blocks view
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellAirCloudShield extends NCProtectSpell;

defaultproperties
{
     armorpersecond=25.000000
     faildamage=3.000000
     Enchantment=Class'NaliChronicles.NCCloudShield'
     mintime=0.100000
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant06'
     manapersecond=2.000000
     InfoTexture=Texture'NaliChronicles.Icons.AirCloudshieldInfo'
     Book=2
     recycletime=2.500000
     casttime=4.000000
     magicsparkskin(0)=Texture'Botpack.RipperPulse.HEexpl1_a00'
     magicsparkskin(1)=Texture'Botpack.ShockExplo.asmdex_a00'
     magicsparkskin(2)=Texture'Botpack.UT_Explosions.Exp5_a00'
     magicsparkskin(3)=Texture'Botpack.utsmoke.US3_A00'
     magicsparkskin(4)=Texture'UnrealShare.DBEffect.de_A00'
     magicsparkskin(5)=FireTexture'UnrealShare.Effect17.fireeffect17'
     magicsparkskin(6)=FireTexture'UnrealShare.Effect2.FireEffect2'
     magicsparkskin(7)=Texture'UnrealShare.Effects.SmokeE3'
     magicsparkcolor=152.000000
     PickupMessage="You got the cloud-shield spell"
     ItemName="Cloud-shield"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.AirCloudshield'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolla'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
