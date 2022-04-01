// Used by fire shield spell to harm those around the player
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCFireShieldHurter extends Actor;

var NCFireShield armor;

auto state Follow
{
	function BeginState() {
		if (Owner != none) {
			SetCollisionSize(Owner.CollisionRadius*4.5,Owner.CollisionRadius);
		}
		SetTimer(0.5,true);
	}

	function Timer() { // hurt stuff
		local actor Victims;
		local float damageScale, dist;
		local vector dir;

		foreach VisibleCollidingActors( class 'Actor', Victims, CollisionRadius, Owner.Location )
		{
			if( Victims != self && Victims != owner && ((Projectile(Victims) == None) || (Victims.instigator != pawn(owner))))
			{
				dir = Victims.Location - Owner.location;
				dist = FMax(1,VSize(dir));
				dir = dir/dist;
				Victims.TakeDamage
				(
					15,
					Pawn(Owner),
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					(1000 * dir),
					'burned'
				);
				if (Pawn(Victims) != none && Nali(Victims) == None && NaliWarrior(Victims) == none)
					armor.damCaused(15);
				if (ScriptedPawn(Victims) != none && !ScriptedPawn(Victims).isInState('Retreating') && !ScriptedPawn(Victims).isInState('Dying'))
					ScriptedPawn(Victims).goToState('Retreating');
			}
		}
	}

	function Tick(float DeltaTime) {
		local vector newLoc;
		local rotator newrot;

		newLoc = Owner.location;
		newLoc.z -= Pawn(Owner).CollisionHeight;
		newLoc.z += CollisionHeight;
		setLocation(newLoc);
	}
}

defaultproperties
{
     Physics=PHYS_Rotating
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
     Style=STY_Translucent
     Skin=FireTexture'UnrealShare.Effect55.fireeffect55'
     Mesh=LodMesh'NaliChronicles.FireFrame'
     DrawScale=3.000000
     bUnlit=True
     bCollideActors=True
     bFixedRotationDir=True
     RotationRate=(Yaw=5000)
     DesiredRotation=(Yaw=30000)
}
