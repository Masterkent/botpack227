// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// WaterToggleZone : Triggering causes this zone to toggle between water and land
// ============================================================

class WaterToggleZone expands ZoneInfo;
var () bool bTriggerOnceOnly; //only trigger once?
var bool RepWater; //replicated for client swaps
replication{
  reliable if (role==role_authority)
    RepWater;
}

function PreBeginPlay(){
  Super.PreBeginPlay();
  if (bwaterzone){ //setup other options
     EntrySound=Sound'UnrealShare.DSplash';
     ExitSound=Sound'UnrealShare.WtrExit1';
     EntryActor=Class'UnrealShare.WaterImpact';
     ExitActor=Class'UnrealShare.WaterImpact';
     ViewFlash=vect(-0.078000,-0.078000,-0.078000);
     ViewFog=vect(0.128900,0.195300,0.175780);
     RepWater=true;
  }
}

simulated function Trigger( actor A, pawn EventInstigator )
{
  If (bTriggerOnceOnly)
    Disable('trigger');
  bWaterZone=!bwaterzone;
  if (bWaterZone){ //become water
     EntrySound=Sound'UnrealShare.DSplash';
     ExitSound=Sound'UnrealShare.WtrExit1';
     EntryActor=Class'UnrealShare.WaterImpact';
     ExitActor=Class'UnrealShare.WaterImpact';
     ViewFlash=vect(-0.078000,-0.078000,-0.078000);
     ViewFog=vect(0.128900,0.195300,0.175780);
  }
  else { //become air
     EntrySound=None;
     ExitSound=None;
     EntryActor=None;
     ExitActor=None;
     ViewFlash=vect(0,0,0);
     ViewFog=vect(0,0,0);
  }
  RepWater=bWaterZone;
  A=none;
  //update:
  ForEach ZoneActors (class'actor',A)
    if (A.role>=role_autonomousproxy||level.netmode==nm_standalone){
      if (A.IsA('pawn')){
        If (pawn(A).footregion.zone==self)
          pawn(A).FootZoneChange(self);
        If (pawn(A).Headregion.zone==self)
          pawn(A).HeadZoneChange(self);
        if (A.Region.Zone==Self)
         A.ZoneChange(self);
      }
      else
         A.ZoneChange(self);
   }
}

simulated function Tick(float delta){
  if (level.netmode!=nm_client)
    disable('tick');
   If (repwater!=bwaterzone)
    Trigger(self,none);
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
}
