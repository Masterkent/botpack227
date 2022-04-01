// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TranslucentCreatureCarcass : This carcass is used for translucent creatures.
// Features:
// Stays translucent when creature dies.
// Spawns bio explosions rather than gibs when gibbed.
// ===============================================================

class TranslucentCreatureCarcass expands olCreatureCarcass;

var vector SurfaceNormal;
var float ChunkFatness;  //for self-destruct

function Initfor(actor Other)
{
  Super.InitFor(Other);
  Style=Other.Style;
  bGreenBlood=scriptedpawn(other).bGreenBlood; //bleeds green.
  ChunkFatness=Fatness;
}
function GibSound()    //gib with bio sound.
{
  PlaySound (class'UT_BioGel'.default.MiscSound,,0.02*DrawScale*mass);
}
//spawn bio explosions. Note: instigator=creature who died.
function CreateReplacement()
{
  local ut_GreenGelPuff f;
  if (bhidden)
    return;
  if ( Bugs != None )
    Bugs.Destroy();
  if ( (Mover(Base) != None) && Mover(Base).bDamageTriggered )
    Base.TakeDamage( 20, instigator, Location, 200*mass* Normal(Velocity), 'Corroded');
  HurtRadius(0.4 * mass * Drawscale, FMin(500, DrawScale * mass*1.4), 'Corroded', 200 * mass * Drawscale, Location+vect(0,0,3));
  f = spawn(class'ut_GreenGelPuff',,,Location + SurfaceNormal*8);
  f.drawscale*=mass*drawscale*0.02;
  f.numBlobs = clamp(CumulativeDamage/20+rand(4)-2,3,13);
  if ( f.numBlobs > 0 )
    f.SurfaceNormal = SurfaceNormal;
}
//snormal catcher:
simulated function Landed(vector HitNormal)
{
  Super.Landed(HitNormal);
  SurfaceNormal=HitNormal;
}
//enlarge and explode.
state Corroding2
{
  function Tick( float DeltaTime )
  {
    ChunkFatness+=18 * DeltaTime;
    drawscale+=0.03 * deltatime;
    fatness = Clamp(ChunkFatness, 0, 255);
    if ( ChunkFatness > 186 )
       Chunkup(100);
  }
  function BeginState()
  {
    Disable('Tick');
  }

Begin:
  Sleep(2.5);
  Enable('Tick');
}
auto state Dying
{
  ignores TakeDamage;

Begin:
  if ( bDecorative && !bReducedHeight )
  {
    ReduceCylinder();
    SetPhysics(PHYS_None);
  }
  Sleep(0.2);
  GotoState('Corroding2');
}

defaultproperties
{
}
