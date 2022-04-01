// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// PongController : A "Controller" to allow for canvas or scripted Texture calls to work.
// Scaling is done here as well.
// default controller is Canvas.
// ===============================================================

class PongController expands Object
transient;

//Generic:
var bool bRendering; //if render cycle is safe.
var PongGame Game; //actual Pong Game.
var float ScaleX, ScaleY;
var font    Font;
var color   DrawColor;       // Color for drawing.
var bool bCanBeSaved;
//canvas only:
var Canvas Canvas;

final function SetFont (font NewF){
  Font=NewF;
  if (Canvas!=none)
    Canvas.Font=newF;
}

final function SetColor (Color NewC){
  DrawColor=NewC;
  if (Canvas!=none)
    Canvas.DrawColor=newC;
}

final function PongGame Initialize(Actor Control, optional PongGame NewGame){
  Game=NewGame;
  if (Game==none)
    Game=Control.Spawn(class'PongGame');
  Game.Renderer=self;
  Game.SoundActor=Control;
  Game.bCanBeSaved=bCanBeSaved;
  return Game;
}

function PostRender (Canvas C){
  bRendering=true;
  Canvas=C;
  C.SetPos(0,0);
  Canvas.DrawTile( texture'BlackTexture', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256 );
  C.Font=Font;
  C.DrawColor=DrawColor;
  ScaleX=C.ClipX/200;
  ScaleY=C.ClipY/100;
  Game.DoRender();
  Canvas=none;
  bRendering=false;
}

function TextSize( string Text, out float XL, out float YL){
  Canvas.StrLen(Text,XL,Yl);
}

function DrawRect( float X, float Y, texture Tex, float RectX, float RectY )
{
  local float RealX, RealRectX;
  RealX=fmax(X,0);
  Canvas.SetPos(RealX*ScaleX,Y*ScaleY);
  RealRectX=RectX;
  if (X+RectX>200)
    RealRectX=200-X;
  Canvas.Style=2;
  Canvas.DrawTile( Tex, ScaleX*fmin(RectX-abs(RealX-X),RealRectX), RectY*ScaleY, fmax(0,Tex.Usize*(RealX-X)/RectX), 0, fmin(Tex.USize*(1-abs(RealX-X)/RectX),Tex.Usize*RealRectX/RectX), Tex.VSize );
  Canvas.Style=1;
}

final function CenterText(string Text, optional bool NoAutoColor){
  local float Xl, Yl;
  if (!NoAutoColor){
    DrawColor.R=0;
    DrawColor.G=146;
    DrawColor.B=0;
  }
  TextSize(Text,Xl,YL);
  DrawText((200*ScaleX-Xl)/2,(100*ScaleY-YL)/2,Text);
}

function DrawText(float X, float Y, coerce string Text){
  Canvas.SetPos(X,Y);
  Canvas.DrawText(Text);
}

defaultproperties
{
     Font=Font'Engine.MedFont'
     DrawColor=(R=255,G=255,B=255)
}
