// Glowy trail around meteor
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCMeteorTrail extends Effects;

function Tick(float DeltaTime) {
	DrawScale=Owner.DrawScale*1.1;
	if (owner == none) destroy();
	setLocation(Owner.Location);
	setRotation(rotator(owner.velocity));
	LightBrightness=128*(LifeSpan/2);
}

defaultproperties
{
     LifeSpan=1.800000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Skin=Texture'Botpack.ChunkGlow.Chunk_a00'
     Mesh=LodMesh'NaliChronicles.meteortrail'
     bUnlit=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=128
     LightHue=32
     LightSaturation=8
     LightRadius=16
     LightPeriod=50
}
