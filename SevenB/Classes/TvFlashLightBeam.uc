// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvFlashLightBeam : A hack to be sure it isn't visible for owner in co-op
// Also features new "1337er" colors! :)
// ===============================================================

class TvFlashLightBeam expands FlashLightBeam
	config(SevenB);

var bool bHideMe; // [U227] unused
//we need both vectors as neither the location nor the rotation are replicated!!
var vector DecalPos; //position to spawn the decal at
var vector RepLoc; //replicated location hack
var rotator B227_RepHitNormal;
var bool B227_bRepLowBrightness;

//decal spawning (client and server if rendered)
var SBFlashDecal r, r2;
var vector lastloc;

var bool B227_bNoGoodFlashDecalSupport;

var config bool B227_bLowBrightness;

// -1 - don't use decals for the beam
//  0 - use decals only on 227j+ clients
//  1 - use decals on any client; reattach decals when updating position - may cause visual glitches and game crashing on 227i
//  2 - use decals on any client; respawn decals when updating position - more expensive than reattaching, but works better on 227i
var config int B227_FlashDecalMode;

replication
{
  //-reliable if (Role==Role_authority&&bNetOwner&&!bDemoRecording)
  //-  bHideMe;
  //-reliable if (Role == ROLE_Authority && !bNetOwner)
  //-  DecalPos, RepLoc;
	reliable if (Role == ROLE_Authority && !bNetOwner)
		RepLoc, B227_RepHitNormal;
	reliable if (Role == ROLE_Authority)
		B227_bRepLowBrightness;
}

/*-simulated function PostNetBeginPlay(){ //yes, it is unsafe.. but I must do this for location updates
  if (bHideMe){
    LightType=LT_None;
  }
}*/

simulated event BeginPlay()
{
	super.BeginPlay();
	if (Level.NetMode != NM_DedicatedServer)
		B227_bNoGoodFlashDecalSupport =
			int(Level.EngineVersion) == 227 && int(Level.EngineSubVersion) <= 9; // 227i doesn't attach such decals right
}

function PostBeginPlay()
{
    RepLoc=location; //initialize
}

function Timer() //don't scare creatures when in cutscene
{
  if (tvplayer(Owner)==none||TvPlayer(Owner).PlayerMod!=1)
    MakeNoise(0.3);
}

// update the decal from here
simulated event Tick(float delta)
{
	const B227_DistToWall = 64;
	const B227_DecalDistToWall = 9;

	local vector HitLocation, HitNormal, EndTrace;

	if ((Level.NetMode != NM_Client || bNetOwner) && Pawn(Owner) != none)
	{
		EndTrace = Pawn(Owner).Location + 10000 * vector(Pawn(Owner).ViewRotation);
		if (Trace(HitLocation, HitNormal, EndTrace, Owner.Location, true) == none)
		{
			HitLocation = EndTrace;
			HitNormal = -vector(Pawn(Owner).ViewRotation);
		}
		SetLocation(HitLocation + HitNormal * B227_DistToWall);
		DecalPos = HitLocation + HitNormal * B227_DecalDistToWall;
		if (Role == ROLE_Authority)
		{
			RepLoc = Location;
			B227_RepHitNormal = rotator(HitNormal);
		}
	}
	else
	{
		SetLocation(RepLoc);
		HitNormal = vector(B227_RepHitNormal);
		HitLocation = Location - HitLocation * B227_DistToWall;
		DecalPos = HitLocation + HitNormal * B227_DecalDistToWall;
	}

	if (Level.NetMode != NM_Client)
		B227_bRepLowBrightness = default.B227_bLowBrightness;
	if (B227_bRepLowBrightness && Pawn(Owner) != none)
		LightRadius = FMin(VSize(HitLocation - Pawn(Owner).Location) / 200, 14) + 4.0;

	// decal handling
	if (Level.NetMode == NM_DedicatedServer ||
		B227_FlashDecalMode < 0 ||
		B227_bNoGoodFlashDecalSupport && B227_FlashDecalMode == 0)
	{
		return;
	}

	if (B227_FlashDecalMode == 2)
	{
		if (r != none)
			r.Destroy();
		if (r2 != none)
			r2.Destroy();
		r = none;
		r2 = none;
	}

	if (r == none)
		r = Spawn(class'SBFlashDecal',,, DecalPos, Rotator(HitNormal));
	else //-if (lastloc != DecalPos) // B227 NOTE: if the decal is attached to a moving object, its position must be updated anyway
	{
		r.DetachDecal();
		r.SetLocation(DecalPos);
		r.SetRotation(Rotator(HitNormal));
		r.AttachDecal(100, vect(0, 0, 1));
	}
	if (r2 == none)
		r2 = Spawn(class'SBFlashDecal',,, DecalPos, Rotator(HitNormal));
	else //-if (lastloc != DecalPos)
	{
		r2.DetachDecal();
		r2.SetLocation(DecalPos);
		r2.SetRotation(Rotator(HitNormal));
		r2.AttachDecal(100, vect(0, 0, 1));
	}
	//-lastloc = DecalPos;
}

simulated function Destroyed()
{
  if(r != none)
	r.Destroy();
  if(r2 != none)
	r2.Destroy();
  Super.Destroyed();
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_None
     DrawScale=0.100000
     CollisionRadius=2.000000
     CollisionHeight=2.000000
     LightEffect=LE_None
     //-LightBrightness=212
     LightSaturation=200
     LightRadius=18
}
