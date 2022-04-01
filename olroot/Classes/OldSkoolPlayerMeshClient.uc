// ============================================================
// oldskool.OldSkoolPlayerMeshClient: the thing that lets the U1models animate
// ============================================================

class OldSkoolPlayerMeshClient expands UMenuPlayerMeshClient;

function created(){
super.created();
if (string(meshactor.mesh)~="UnrealI.sktrooper")
meshactor.drawscale=0.070000;          //make it fit :D
else
meshactor.drawscale=0.100000;    }
/*-
function SetMesh(mesh NewMesh)
{

  MeshActor.bMeshEnviroMap = False;
  MeshActor.DrawScale = MeshActor.Default.DrawScale;
  MeshActor.Mesh = NewMesh;
  if(MeshActor.Mesh != None)
    {
    //HASANIM  the code never before used (no kidding too....) TRY finding it anywhere besides ACTOR.uc
    //for normals....
    if(MeshActor.HasAnim ('Breath3'))
    MeshActor.PlayAnim('Breath3', 0.5);
    //Unreal I humans
    else if(MeshActor.HasAnim ('Look'))
    MeshActor.Loopanim('Look', 0.7);
    //cow
    else if(MeshActor.HasAnim ('Poop'))
    MeshActor.Loopanim('Poop');
    //anything else that might come in the future...
    else if(MeshActor.HasAnim ('Breath'))
    MeshActor.LoopAnim('Breath');
    //the final test......
    else
    MeshActor.LoopAnim('All');
    }
}
*/
function AnimEnd(MeshActor MyMesh)
{
  if ( MyMesh.AnimSequence == 'Breath3' ){
    if (MyMesh.HasAnim('DuckDnlgfr')&&!MyMesh.HasAnim('alltrue'))    //HL model fix (new ones don't need fixing...
    MyMesh.TweenAnim('breath2', 0.4);
    else
    MyMesh.TweenAnim('All', 0.4);   }
  else if (MyMesh.HasAnim('Breath3'))
    MyMesh.PlayAnim('Breath3', 0.4);
}

defaultproperties
{
}
