// A new tree model
// Code by Sergey 'Eater' Levin, 2001

class NCTree1 extends Tree;

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

//#exec TEXTURE IMPORT NAME=Jnctree1 FILE=TEXTURES\nctree1.pcx GROUP=Skins PALETTE=Jnctree1

defaultproperties
{
     Mesh=LodMesh'NaliChronicles.nctree'
     DrawScale=4.000000
     CollisionHeight=120.000000
}
