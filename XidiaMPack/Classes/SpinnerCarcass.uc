//=============================================================================
// SpinnerCarcass.
//=============================================================================
class SpinnerCarcass expands CreatureCarcass;

#exec OBJ LOAD FILE="XidiaMPackResources.u" PACKAGE=XidiaMPack

function ForceMeshToExist()
{
  //never called
  Spawn( class 'Spinner' );
}

function InitFor( actor Other )
{
  Super.InitFor( Other );
  if( AnimSequence == 'Death5' )
    bodyparts[7]=None;
}

defaultproperties
{
     bodyparts(0)=LodMesh'XidiaMPack.SpinnerBody'
     bodyparts(1)=LodMesh'XidiaMPack.SpinnerTail'
     bodyparts(2)=LodMesh'XidiaMPack.SpinnerLeg1'
     bodyparts(3)=LodMesh'XidiaMPack.SpinnerLeg2'
     bodyparts(4)=LodMesh'XidiaMPack.SpinnerLeg3'
     bodyparts(5)=LodMesh'XidiaMPack.SpinnerLeg4'
     bodyparts(6)=LodMesh'XidiaMPack.SpinnerClaw'
     bodyparts(7)=LodMesh'XidiaMPack.SpinnerHead'
     ZOffset(1)=0.750000
     ZOffset(2)=0.250000
     ZOffset(3)=0.250000
     ZOffset(4)=0.250000
     ZOffset(5)=0.250000
     ZOffset(7)=0.500000
     bGreenBlood=True
     AnimSequence=Death
     Mesh=LodMesh'XidiaMPack.Spinner'
     CollisionRadius=32.000000
     CollisionHeight=22.000000
     Mass=100.000000
     Buoyancy=100.000000
}
