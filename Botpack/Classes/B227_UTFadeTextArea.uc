class B227_UTFadeTextArea extends UWindowWrappedTextArea;

var float FadeTime[32];
var font MyFont;

var int ScrollingOffset;
var int NumLines, PrintLines;

var bool bAutoScrolling, bNowAutoScrolling, bMousePassThrough;

var int CurrentPendingString;
var string PendingString[20];

var int FadeLines;

var float FadeFactor;

function Created()
{
	Super.Created();
}

function BeforePaint( Canvas C, float X, float Y)
{
	local int i;

	C.Font = MyFont;
	for (i=0; i<20; i++)
	{
		if (PendingString[i] != "")
		{
			AddString(C, i);
			PendingString[i] = "";
		}
	}
}

function Paint( Canvas C, float X, float Y )
{
	local int i, Line;
	local int TempHead, TempTail;
	local float XL, YL;
	local bool bNextLine;

	C.Font = MyFont;
	C.DrawColor = TextColor;

	C.TextSize("TEST", XL, YL);
	VisibleRows = WinHeight / YL;

	TempHead = Head;
	TempTail = Tail;
	Line = TempTail + ScrollingOffset;

	bNextLine = True;
	for (i=0; i<NumLines; i++)
	{
		bNextLine = LocalWrappedClipText(C, 0, YL*i, Line, TextArea[Line], false, bNextLine);
		Line++;
	}

	if (bNowAutoScrolling)
	{
		if (FadeLines-1 == VisibleRows+ScrollingOffset)
			ScrollingOffset++;
	}

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
}

function Tick(float Delta)
{
	local int i;

	FadeLines = 0;
	// Update FadeTime
	for (i=0; i<NumLines; i++)
	{
		if (FadeTime[i] >= 0.0) {
			FadeLines++;
			FadeTime[i] += Delta*FadeFactor;
		} else if (FadeTime[i] == -2.0) {
			FadeLines++;
		}
	}
	if ((NumLines != 0) && (FadeTime[NumLines-1] == -2.0))
		bNowAutoScrolling = False;
}

// 227 adds default argument to AddText -> breaks compatibility, unsafe for use
function B227_AddText(string S)
{
	PendingString[CurrentPendingString] = S;
	CurrentPendingString++;
}

function AddString(Canvas C, int Index)
{
	local string S, Out, Temp, Line;
	local int WordBoundary, TotalPos;
	local float W, H;
	local float X, Y;
	local bool bSentry;

	S = PendingString[Index];

	// Early out for small lines.
	C.TextSize(S, X, Y);
	if (X < WinWidth)
	{
		NumLines++;
		Super.AddText(S);
		return;
	}

	// Cut up large lines.
	X = 0;
	bSentry = True;
	while( bSentry )
	{
		// Get the line to be drawn.
		if(Out == "")
			Out = S;

		// Find the word boundary.
		WordBoundary = InStr(Out, " ");

		// Get the current word.
		C.SetPos(0, 0);
		if(WordBoundary == -1)
			Temp = Out;
		else
			Temp = Left(Out, WordBoundary)$" ";
		TotalPos += WordBoundary;

		C.TextSize(Temp, W, H);

		if(W+X > WinWidth)
		{
			NumLines++;
			Super.AddText(Line);
			Line = "";
			X = 0;
		}
		Line = Line$Temp;
		X += W;

		Out = Mid(Out, Len(Temp));
		if (Out == "")
			bSentry = False;
	}
	NumLines++;
	Super.AddText(Line);
}

function bool LocalWrappedClipText(Canvas C, float X, float Y, int I, coerce string S, optional bool bCheckHotkey, optional bool bInitFadeTime)
{
	local float FadeCount, X2, Y2, XL, YL;
	local int FadeChar, FadeLength;

	if (S == "")
		return true;

	C.Style = 3;

	if (FadeTime[I] == -1.0 && bInitFadeTime)
	{
		// If first update, just set the FadeTime to zero.
		FadeTime[I] = 0.0;
		return false;
	} else if (FadeTime[I] == -2.0) {
		DrawTextClipped(C, X, Y, S, bCheckHotKey);
		return true;
	}

	for ( FadeChar = 0; FadeTime[I] - (FadeChar * 0.1) > 0.0; FadeChar++ )
	{
		FadeCount = FadeTime[I] - (FadeChar * 0.1);
		if ((FadeChar == Len(S) - 1) && (255 * (1.0 - FadeCount) < 0))
			FadeTime[I] = -2.0;

		C.DrawColor.R = Min(255 * (0.0 + FadeCount), TextColor.R);
		C.DrawColor.G = Min(255 * (0.0 + FadeCount), TextColor.G);
		C.DrawColor.B = Min(255 * (0.0 + FadeCount), TextColor.B);
		DrawTextClipped(C, X+X2, Y+Y2, Mid(S, FadeChar, 1));
		C.TextSize(Left(S, FadeChar+1), XL, YL);
		X2 = XL;

		FadeLength = XL;
	}
	C.Style = 1;
	C.TextSize(S, XL, YL);
	if (XL == FadeLength)
		return true;

	return false;
}

function Clear()
{
	local int i;

	Super.Clear();
	for (i=0; i<750; i++) {
		TextArea[i] = "";
	}
	for (i=0; i<32; i++) {
		FadeTime[i] = -1.0;
	}

	ScrollingOffset = 0;

	if (bAutoScrolling)
		bNowAutoScrolling = True;

	NumLines = 0;
	CurrentPendingString = 0;
}

function bool CheckMousePassThrough(float X, float Y)
{
	if (bMousePassThrough)
		return True;
	else
		return False;
}

function DrawTextClipped(Canvas C, float X, float Y, string S, optional bool bCheckHotKey)
{
	C.SetPos(WinLeft + X, WinTop + Y);
	C.DrawTextClipped(S, bCheckHotKey);
}

defaultproperties
{
     FadeTime(0)=-1.000000
     FadeFactor=2.000000
}
