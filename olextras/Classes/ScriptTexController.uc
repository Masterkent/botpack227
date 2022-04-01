// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// ScriptTexController : Controller of Scripted Textures.
// ===============================================================

class ScriptTexController expands PongController
transient;

var ScriptedTexture Tex;

function RenderTexture (ScriptedTexture NewTex){   //called from an actor...
  bRendering=true;
  Tex=NewTex;
  ScaleX=float(Tex.Usize)/200.0;
  ScaleY=float(Tex.Vsize)/100.0;
  Game.DoRender();
  Tex=none;
  bRendering=false;
}
function TextSize( string Text, out float XL, out float YL){
  Tex.TextSize(Text,XL,Yl,Font);
}

function DrawRect( float X, float Y, texture Texy, float RectX, float RectY )
{
  Tex.DrawTile( X*ScaleX, Y*ScaleY, RectX*ScaleX, RectY*ScaleY, 0, 0, Texy.USize, Texy.VSize, Texy, true );
}

function DrawText(float X, float Y, coerce string Text){
  Tex.DrawColoredText(X, Y, Text, Font, DrawColor);
}

defaultproperties
{
     bCanBeSaved=True
}
