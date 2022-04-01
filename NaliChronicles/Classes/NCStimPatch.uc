// A Skaarj health source
// Code by Sergey 'Eater' Levin

class NCStimPatch extends Health;

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

defaultproperties
{
     bAmbientGlow=False
     PickupMessage="You picked up a Skaarj stim patch +"
     RespawnTime=5.000000
     PickupViewMesh=LodMesh'NaliChronicles.stimpatch'
     PickupViewScale=2.000000
     Mesh=LodMesh'NaliChronicles.stimpatch'
     DrawScale=2.000000
     AmbientGlow=0
     CollisionHeight=10.000000
}
