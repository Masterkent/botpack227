//=============================================================================
// chicoship1.
//=============================================================================
class chicoship1 expands Decoration;

#exec OBJ LOAD FILE="OlextrasResources.u" PACKAGE=olextras

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'olextras.chicoship1'
     CollisionRadius=108.000000
     CollisionHeight=32.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
}
