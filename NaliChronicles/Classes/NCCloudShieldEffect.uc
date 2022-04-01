// Spell effect that causes clouds to orbit the player
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCCloudShieldEffect extends Effects;

auto state Follow
{
	function Tick(float DeltaTime) {
		local vector newLoc;
		local rotator newrot;

		newLoc = Owner.location;
		newLoc.z += Pawn(Owner).eyeheight;
		setLocation(newLoc);
		newrot.pitch = PlayerPawn(Owner).viewrotation.pitch;
		newrot.roll = 0;
		newrot.yaw = rotation.yaw;
		setRotation(newrot);
	}
}

defaultproperties
{
     Physics=PHYS_Rotating
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=Texture'NaliChronicles.Skins.CloudSprite'
     Skin=Texture'NaliChronicles.Skins.CloudSprite'
     Mesh=LodMesh'NaliChronicles.CloudFrame'
     DrawScale=0.125000
     bUnlit=True
     bParticles=True
     bFixedRotationDir=True
     RotationRate=(Yaw=5000)
     DesiredRotation=(Yaw=30000)
}
