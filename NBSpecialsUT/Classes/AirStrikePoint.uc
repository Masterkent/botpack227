//=============================================================================
// AirStrikePoint.
//
// script by N.Bogenrieder (Beppo)
//
//=============================================================================
class AirStrikePoint expands Keypoint;

var() float Radius;
var() class<pawn> TargetPawnClass;
var() float zAxisCorrection;

defaultproperties
{
     Radius=256.000000
     TargetPawnClass=Class'Engine.Pawn'
     Texture=None
     SoundRadius=128
     SoundVolume=160
}
