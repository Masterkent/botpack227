// This enchantment that creates a volanoe that spits out flak and fireballs
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCPawnEnchantFlamegyser extends NCPawnEnchant;

function PlayStartAnim() {
	SetTimer(0.5,true);
}

function Timer() {
	local vector start;
	local NCChunk chunk;
	local NCLavaBall lava;

	// spit fireballs here
	start = Location;
	start.z += CollisionHeight;
 	Spawn( class'ut_spritesmokepuff',,,Start);
	chunk = Spawn(Class'NCChunk',,,Start);
	chunk.NaliOwner = NaliMage(instigator);
	chunk = Spawn(Class'NCChunk',,,Start);
	chunk.NaliOwner = NaliMage(instigator);
	lava = Spawn(Class'NCLavaBall',,,Start);
	lava.NaliOwner = NaliMage(instigator);
}

defaultproperties
{
     FadeTime=2.000000
     bDisplayMesh=True
     SpawnSound=Sound'UnrealShare.General.FatRingSound'
     bPawnless=True
     Physics=PHYS_Falling
     LifeSpan=30.000000
     Mesh=LodMesh'NaliChronicles.volcano'
     DrawScale=3.000000
     CollisionRadius=15.000000
     CollisionHeight=9.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bProjTarget=True
     Mass=1.000000
}
