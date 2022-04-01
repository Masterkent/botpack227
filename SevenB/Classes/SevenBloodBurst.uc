// ===============================================================
// SevenB.SevenBloodBurst: Blood that obeys the laws of physics.  Falls to ground.. has velocity, etc.
// ===============================================================

class SevenBloodBurst extends BloodBurst;

simulated function AnimEnd()
{
  	if (Physics==Phys_None)
			Destroy();
}

 simulated function PreBeginPlay()    //gore stuff for client
  {
  if( class'GameInfo'.Default.bVeryLowGore )
    GreenBlood();
  }

simulated function Tick(float delta){ //might look a bit better?
	SetRotation(rotator(velocity));
}
simulated function PostBeginPlay()
{
//	PlayAnim  ( 'Burst', 0.2 ); //?? new anim?
  LoopAnim('trail',0.9,0.1); //?
	if (region.zone.bwaterzone)
		SetPhysics(Phys_None);
	else
		Velocity = (Vector(Rotation)+VRand()) * 400 * FRand();     //change?
}

simulated function SpawnDecal (vector HitNormal){
	local decal a;
	local int i;
	if (Level.NetMode != NM_DedicatedServer){
	 if (Texture != texture'BloodSGrn'){
       a=spawn(class'olBloodSplat',,,Location + 20 * (HitNormal + VRand()), rotator(HitNormal));
           //check b0rked texture:
    	if (a!=none && a.texture==Texture'BloodSplat2'){
    		a.DetachDecal();
    		if ( Level.bDropDetail )
		   	 i=4;
		  	else
    			i=rand(9);
				if (i>=1)     //prevent usage of #1 (bloodsplat2)
					i++;
				a.Texture=BloodSplat(a).splats[i];
    		a.AttachToSurface();
   	 	}
  	}
    else
       spawn(class'GreenBloodSplat',,,Location + 20 * (HitNormal + VRand()), rotator(HitNormal));
	}
}
simulated function Landed( vector HitNormal )
{
	 SpawnDecal(HitNormal);
   Destroy();
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	SpawnDecal(HitNormal);
  Destroy();
}

defaultproperties
{
     Physics=PHYS_Falling
     DrawScale=0.150000
     bUnlit=False
     CollisionRadius=0.300000
     CollisionHeight=0.100000
     bCollideWorld=True
}
