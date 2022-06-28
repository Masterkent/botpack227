//=============================================================================
// MovieHUD.
// Created by Stephen 'Nemesis' Deaver, Yoda and Hugh Macdonald.
//=============================================================================
class MovieHUD expands HUD;

var() string Lines;			// Dialogue Line.
var() color TextColor;			// Current font color for dialogue.
var() int DialogueFontSize;		// Current font size for dialogue.
var() bool bDialogue;			// Is the HUD in Dialogue mode?
var() bool bCredits;			// Are credits running?
var float ScreenHeight;			// Size of screen - Used for credits.
var float ScrollingTime;		// Also used for credits.
var float currentTime;
var float GlobalY;			// Current Y value - Used for credit scrolling
var float vertOffset;
var MovieCredits CreditsInfo;		// CreditsInfo actor to get our credit info from.
var FontInfo MyFonts;			// Font actor to use for font manipulation.
var float ScrollAmount;			// More credits stuff.
var float CreditsLength;
var float TotalLength;			// Total length of whole credits sequence.
var bool bDidScrollInit;		// Were the credits already initlialized?
var string CreditsDivider;
var float DividerWidth;

// Lets spawn our FontInfo to use throughout the entire HUD.
function PostBeginPlay()
{
    MyFonts = spawn(Class'FontInfo');
}

function PostRender(Canvas C)
{    

    DrawHUDOverlay(C);


    // Time to do credits? If so, then initialize them once, then run.
    if(bCredits && CreditsInfo != NONE)
    {
        bDialogue=false;
		if (!bDidScrollInit)
		{
			InitScroll(C);
			bDidScrollInit = true;
		}
        RunCredits(C);
    }

    // Dialogue mode.
    if(bDialogue)
    {
        bCredits = false;
        Dialogue(C);
    }
}

// This function sets up the credits for scrolling.
function InitScroll(Canvas C)
{
    local int CurrentCommand, CurrentSize;
    local string CurrentCredit;
    local float XL, YL, CurrentGap;
    local texture Pic;
    
    TotalLength = 0;
    ScreenHeight = C.ClipY;
	ScrollingTime = CreditsInfo.ScrollingTime;
	CreditsDivider = CreditsInfo.CreditsDivider;
	vertOffset = C.ClipY;
    
    // Run through every creditscript.
    for(CurrentCommand=0;CurrentCommand<500;CurrentCommand++)
    {
        CurrentCredit = CreditsInfo.GetCreditsScript(CurrentCommand);

		// No more credits? Stop execution.
		if(CurrentCredit == "")
            break;

		// Setting some local variables for easy use.
        CurrentSize = CreditsInfo.GetCreditsSize(CurrentCommand);
        SetFontSize(CurrentSize, C);

		CurrentGap = CreditsInfo.GetCreditsGap(CurrentCommand);

		C.StrLen(CurrentCredit, XL, YL);
		
		// Special functions handler. Currently, only the #pic command is supported.

		if (Left(CurrentCredit,1) == "#")
		{		 
			if(Left(CurrentCredit, 4) == "#pic")
   			{
		   	 	Pic = CreditsInfo.GetCreditsPic(CreditsInfo.GetCreditsSize(CurrentCommand));
	   	        TotalLength += (YL * (CurrentGap)) + Pic.VSize;
	    	}
			continue;
		}	

		TotalLength += (YL * (CurrentGap+1));
	}
	
	CreditsLength = TotalLength;
	
	TotalLength += C.ClipY;
}


// Main credits function.
function RunCredits(Canvas C)
{

    local int CurrentCommand, CurrentAlign, XStart, CurrentSize, OldY;
    local string CurrentCredit, CurrentCredit2, ActualCredit;
    local float CurrentOffset, CreditLen, XL, YL, XL2, YL2, XL3, CurrentGap, boundTop, boundBottom;
    local vector CurrentColour;
    local texture Pic;
    local int PicSizeX,PicSizeY;
    local color BlackColor;
    C.CurX = C.ClipX/2;
    C.CurY = vertOffset;
    
    boundTop = -10;
    boundBottom = C.ClipY + 10;
   
    // Run through every creditscript.
    for(CurrentCommand=0;CurrentCommand<500;CurrentCommand++)
    {
		if(C.CurY > boundBottom)
		{
			break;
		}
        
        C.Style = ERenderStyle.STY_Normal;
        CurrentCredit = CreditsInfo.GetCreditsScript(CurrentCommand);
        CurrentCredit2 = CreditsInfo.GetCreditsScript2(CurrentCommand);

		// No more credits? Stop execution.
		if(CurrentCredit == "")
            break;
        
		// Setting some local variables for easy use.
        CurrentSize = CreditsInfo.GetCreditsSize(CurrentCommand);
        SetFontSize(CurrentSize, C);
        CurrentAlign = CreditsInfo.GetCreditsAlign(CurrentCommand);
        CurrentOffset = CreditsInfo.GetCreditsOffset(CurrentCommand);
		CurrentGap = CreditsInfo.GetCreditsGap(CurrentCommand);
        C.StrLen(CurrentCredit, XL, YL);
        CreditLen = len(CurrentCredit);

		// Special functions handler. Currently, only the #pic command is supported.

		if (Left(CurrentCredit,1) == "#")
		{		 
			if(Left(CurrentCredit, 4) == "#pic")
   			{
   				if(Right(CurrentCredit, 3) == "mod")
   				{
   					C.Style = ERenderStyle.STY_Modulated;
   				}
   				else if(Right(CurrentCredit, 5) == "trans")
   				{
   					C.Style = ERenderStyle.STY_Translucent;
   				}
   				else if(Right(CurrentCredit, 4) == "mask")
   				{
   					C.Style = ERenderStyle.STY_Masked;
   				}
   				else
   				{
   					C.Style = ERenderStyle.STY_Normal;
   				}
		   	 	Pic = CreditsInfo.GetCreditsPic(CreditsInfo.GetCreditsSize(CurrentCommand));
				PicSizeX = Pic.USize;
	   	        PicSizeY = Pic.VSize;
	   	        
	   	        if((C.CurY + PicSizeY) < boundTop)
	   	        {
		    		C.CurY += (YL * (CurrentGap)) + PicSizeY;
	   	        	continue;
	   	        }
	   	        
	       		C.DrawColor = CreditsInfo.GetCreditsColor(CurrentCommand);

	    		if (CreditsInfo.GetCreditsColor(CurrentCommand) == BlackColor) 
	    		{
	    			C.DrawColor = CreditsInfo.MasterColor;
	    		}
	    
	    		switch (CurrentAlign)
           		{
           		case 0:
               		C.CurX = (C.ClipX/2) - (PicSizeX/2);
	         		C.CurX += (C.ClipX/2) * CurrentOffset;
               		break;
           		case 1:
               		C.CurX = 0;
               		C.CurX += C.ClipX * CurrentOffset;
               		break;
           		case 2:
               		C.CurX = C.ClipX - (PicSizeX);
               		C.CurX += C.ClipX * CurrentOffset;
               		break;
           		}         

           		OldY = C.CurY;
	    		C.DrawTile(Pic, PicSizeX, PicSizeY, PicSizeX, PicSizeY, PicSizeX, PicSizeY);
           		C.CurY = OldY;
	    		C.CurY += (YL * (CurrentGap)) + PicSizeY;
	    	}
	    	else
	    	{
				Log ("Unrecognized function: "$CurrentCredit);
			}
		
			continue;
		}
		
		if((C.CurY + (YL * (CurrentGap+1))) < boundTop)
		{
			C.CurY += (YL * (CurrentGap+1));
			continue;
		}


		if(CurrentCredit2 == "")
		{
			ActualCredit = CurrentCredit;
			
			// Align the current text to either the center, right, or left of the screen.
        	switch (CurrentAlign)
        	{
        	case 0:
        	    C.CurX = (C.ClipX/2) - (XL)/2;
        	    C.CurX += (C.ClipX/2) * CurrentOffset;
        	    break;
        	case 1:
        	    C.CurX = 0;
        	    C.CurX += C.ClipX * CurrentOffset;
        	    break;
        	case 2:
        	    C.CurX = C.ClipX - (XL);
        	    C.CurX += C.ClipX * CurrentOffset;
        	    break;
        	}
        }
        else
        {
        	ActualCredit = CurrentCredit$CreditsDivider$CurrentCredit2;
        
        	C.StrLen(CreditsDivider, XL2, YL2);
        	C.StrLen(CurrentCredit2, XL3, YL2);
        	
        	switch (CurrentAlign)
        	{
        	case 0:
        	    C.CurX = (C.ClipX/2) - ((XL2)/2 + XL);
        	    C.CurX += (C.ClipX/2) * CurrentOffset;
        	    break;
        	case 1:
        	    C.CurX = 0;
        	    C.CurX += C.ClipX * CurrentOffset;
        	    break;
        	case 2:
        	    C.CurX = C.ClipX - (XL + XL2 + XL3);
        	    C.CurX += C.ClipX * CurrentOffset;
        	    break;
        	}
        }
	
		// If the color of the text is 0,0,0, then we set it to the default master color.
        C.DrawColor = CreditsInfo.GetCreditsColor(CurrentCommand);
		if (CreditsInfo.GetCreditsColor(CurrentCommand) == BlackColor) 
		{
		   	C.DrawColor = CreditsInfo.MasterColor;
		}

		// Draw the text to the screen!
		OldY = C.CurY;
		C.DrawTextClipped (ActualCredit);
		C.CurY = OldY;
		C.CurY += (YL * (CurrentGap+1));
		if (vertOffset < -CreditsLength)
		{
			bCredits = false;
			bDialogue = true;
		}
    }
}


function DrawHUDOverlay(Canvas C)
{
}

// Called by CreditsInfo actor to get the credits rolling.
function StartCredits(MovieCredits CredInfo)
{
    CreditsInfo=CredInfo;
    bCredits=true;
}


// Scroll the credits up the screen.
function Tick(float DeltaTime)
{
    if(bCredits)
    {
    		vertOffset = (-(currentTime / ScrollingTime) * totalLength) + ScreenHeight;
			currentTime += DeltaTime;
    }
}

// Use MyFonts to set a font size.
function SetFontSize(int FontSize, Canvas C)
{
    switch(FontSize)
    {
        case 1:
            C.Font = MyFonts.GetACompletelyUnreadableFont(C.ClipX);
            break;
        case 2:
            C.Font = MyFonts.GetAReallySmallFont(C.ClipX);
            break;
        case 3:
            C.Font = MyFonts.GetSmallestFont(C.ClipX);
            break;
        case 4:
            C.Font = MyFonts.GetSmallFont(C.ClipX);
            break;
        case 5:
            C.Font = MyFonts.GetMediumFont(C.ClipX);
            break;
        case 6:
            C.Font = MyFonts.GetBigFont(C.ClipX);
            break;
        case 7:
            C.Font = MyFonts.GetHugeFont(C.ClipX);
            break;
    }

}

// Set up HUD for Dialogue.
function SetUpDialogue(string Dialogue, int NewSize, color NewColor)
{
    Lines = Dialogue;
        
    if(NewSize > 0 && NewSize <= 7)
        DialogueFontSize = NewSize;
        
    TextColor = NewColor;
    
    bDialogue = true;
}

// Draw Dialogue to the screen.
function Dialogue(canvas C)
{
    local float XOffset, YOffset;
    local int LinesLength;

    LinesLength = len(Lines);
    
    XOffset = C.ClipX * 0.1;
    YOffset = C.ClipY * 0.9;
    C.SetPos(XOffset, YOffset);

    SetFontSize (DialogueFontSize, C);

    C.DrawColor = TextColor;
    C.DrawText(Lines, False);
}

defaultproperties
{
				TextColor=(R=255)
				DialogueFontSize=3
				ScrollingTime=5.000000
}
