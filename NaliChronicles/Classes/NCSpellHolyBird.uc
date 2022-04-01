// Creates a bird at the end of the staff
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellHolyBird extends NCSpellMystDragon;

defaultproperties
{
     Head=Class'NaliChronicles.NCBirdHead'
     newmode=1
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant03'
     InfoTexture=Texture'NaliChronicles.Icons.HolyBirdInfo'
     Book=4
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
     PickupMessage="You got the Bird of Light spell for the Prophet's staff"
     ItemName="Bird of Light"
     Icon=Texture'NaliChronicles.Icons.HolyBird'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrollh'
}
