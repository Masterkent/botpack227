//=============================================================================
// TNali.
//=============================================================================
class TNali extends CustomPlayer;

#exec OBJ LOAD FILE="EpicCustomModels.u"
#exec OBJ LOAD FILE="TNaliMeshSkins.utx"

// special animation functions
function PlayDying(name DamageType, vector HitLoc)
{
	if ( Mesh == FallBackMesh )
	{
		Super.PlayDying(DamageType, HitLoc);
		return;
	}
	BaseEyeHeight = Default.BaseEyeHeight;
	PlayDyingSound();

	if ( DamageType == 'Suicided' )
	{
		PlayAnim('Dead',, 0.1);
		return;
	}

	// check for head hit
	if ( DamageType == 'Decapitated' )
	{
		PlayNaliDecap();
		return;
	}

	// check for big hit
	if ( Velocity.Z > 200 )
	{
		if ( FRand() < 0.65 )
			PlayAnim('Dead4',,0.1);
		else
			PlayAnim('Dead2',, 0.1);
		return;
	}

	if ( HitLoc.Z - Location.Z > 0.7 * CollisionHeight )
	{
		if ( FRand() < 0.35  )
			PlayNaliDecap();
		else
			PlayAnim('Dead2',, 0.1);
		return;
	}

	if ( FRand() < 0.6 ) //then hit in front or back
		PlayAnim('Dead',, 0.1);
	else
		PlayAnim('Dead2',, 0.1);
}

function PlayNaliDecap()
{
	local carcass carc;

	if ( class'GameInfo'.Default.bVeryLowGore )
	{
		PlayAnim('Dead2',, 0.1);
		return;
	}

	PlayAnim('Dead3',, 0.1);
	if ( Level.NetMode != NM_Client )
	{
		carc = Spawn(class 'TNaliHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
			carc.Initfor(self);
			carc.RemoteRole = ROLE_SimulatedProxy;
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
	}
}

function B227_PackageRef(Object Obj)
{
	Obj = Texture'TNaliMeshSkins.Ouboudah'; // Force loading package TNaliMeshSkins
}

defaultproperties
{
     DefaultFace="TNaliMeshSkins.nali-Face"
     TeamSkin="T_nali_"
     DefaultCustomPackage="TNaliMeshSkins."
     Deaths(0)=Sound'UnrealShare.Nali.death1n'
     Deaths(1)=Sound'UnrealShare.Nali.death1n'
     Deaths(2)=Sound'UnrealShare.Nali.death2n'
     Deaths(3)=Sound'UnrealShare.Nali.bowing1n'
     Deaths(4)=Sound'UnrealShare.Nali.injur1n'
     Deaths(5)=Sound'UnrealShare.Nali.injur2n'
     DefaultSkinName="TNaliMeshSkins.Ouboudah"
     drown=Sound'UnrealShare.Male.MDrown1'
     breathagain=Sound'UnrealShare.Nali.cough1n'
     Footstep1=Sound'UnrealShare.Cow.walkC'
     Footstep2=Sound'UnrealShare.Cow.walkC'
     Footstep3=Sound'UnrealShare.Cow.walkC'
     HitSound3=Sound'UnrealShare.Nali.injur1n'
     HitSound4=Sound'UnrealShare.Nali.injur2n'
     GaspSound=Sound'UnrealShare.Nali.breath1n'
     UWHit1=Sound'UnrealShare.Male.MUWHit1'
     UWHit2=Sound'UnrealShare.Male.MUWHit2'
     LandGrunt=Sound'UnrealShare.Male.lland01'
     JumpSound=Sound'UnrealShare.Male.MJump1'
     bIsMultiSkinned=False
     SelectionMesh="EpicCustomModels.TNaliMesh"
     HitSound1=Sound'UnrealShare.Nali.fear1n'
     HitSound2=Sound'UnrealShare.Nali.cringe2n'
     MenuName="Nali"
     VoiceType="MultiMesh.NaliVoice"
     Mesh=LodMesh'EpicCustomModels.tnalimesh'
}
