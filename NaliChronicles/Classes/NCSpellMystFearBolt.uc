// A "devine" projectile that's uh... devine
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpellMystFearBolt extends NCProjSpell;

defaultproperties
{
     Proj=Class'NaliChronicles.NCFearBolt'
     damagepersecond=18.000000
     sizepersecond=0.200000
     mintime=0.000001
     CastingSound=Sound'NaliChronicles.SpellFX.CastingChant05'
     manapersecond=2.500000
     InfoTexture=Texture'NaliChronicles.Icons.MystFearBoltInfo'
     Book=5
     recycletime=1.250000
     casttime=2.000000
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
     PickupMessage="You got the fear bolt spell"
     ItemName="Fear bolt"
     PickupViewMesh=LodMesh'NaliChronicles.bigscroll'
     Icon=Texture'NaliChronicles.Icons.MystFearBolt'
     Skin=Texture'NaliChronicles.Skins.Jsmallscrolld'
     Mesh=LodMesh'NaliChronicles.bigscroll'
}
