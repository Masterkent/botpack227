//=============================================================================
// SpinnerCarcass.
//=============================================================================
class SpinnerCarcass expands CreatureCarcass;

#exec OBJ LOAD FILE="SevenBResources.u" PACKAGE=SevenB

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
     bodyparts(0)=LodMesh'SevenB.SpinnerBody'
     bodyparts(1)=LodMesh'SevenB.SpinnerTail'
     bodyparts(2)=LodMesh'SevenB.SpinnerLeg1'
     bodyparts(3)=LodMesh'SevenB.SpinnerLeg2'
     bodyparts(4)=LodMesh'SevenB.SpinnerLeg3'
     bodyparts(5)=LodMesh'SevenB.SpinnerLeg4'
     bodyparts(6)=LodMesh'SevenB.SpinnerClaw'
     bodyparts(7)=LodMesh'SevenB.SpinnerHead'
     ZOffset(1)=0.750000
     ZOffset(2)=0.250000
     ZOffset(3)=0.250000
     ZOffset(4)=0.250000
     ZOffset(5)=0.250000
     ZOffset(7)=0.500000
     bGreenBlood=True
     AnimSequence=Death
     Mesh=LodMesh'SevenB.Spinner'
     CollisionRadius=32.000000
     CollisionHeight=22.000000
     Mass=100.000000
     Buoyancy=100.000000
}
