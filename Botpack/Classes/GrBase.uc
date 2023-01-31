//=============================================================================
// GrBase.
//=============================================================================
class GrBase extends ut_Decoration;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

// Steve:  The gun base and the grmock gun must both be played in unison at the same origin for the down animation.
// once down, destroy the mock gun and replace it with the grfinal gun.  It has an origin about it's pivot point
// so that you can rotate it through scripting.

// The ceiling cannon (files CD*.uc) are comprised of the base and the gun.  They are separate so you can
// yaw the gun around though script, while the base remains stationary.

defaultproperties
{
	bStatic=False
	RemoteRole=ROLE_None
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.GrBaseM'
}
