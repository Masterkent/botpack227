//=============================================================================
// ControlRotatingMover.
//
// script by N.Bogenrieder (Beppo)
//
//=============================================================================
class ControlRotatingMover expands Mover;

var() bool bControlPitch;
var() bool bControlRoll;
var() bool bControlYaw;
var() bool bReversePitch;
var() bool bReverseRoll;
var() bool bReverseYaw;

var(ControlWeapon) bool bControlFire;
var(ControlWeapon) sound FireSound;
var(ControlWeapon) sound AltFireSound;
var(ControlWeapon) class<projectile> Fire_ProjectileClass; // Fire
var(ControlWeapon) class<projectile> AltFire_ProjectileClass; // AltFire
var(ControlWeapon) float AltFireRate; // ReloadTime for AltFire
var(ControlWeapon) float FireRate; // ReloadTime for Fire
var(ControlWeapon) sound AltReloadSound;
var(ControlWeapon) sound ReloadSound;
var(ControlWeapon) float FirePositionOffset;

var() float maxPitch;
var() float maxRoll;
var() float maxYaw;
var() float minPitch;
var() float minRoll;
var() float minYaw;

var() localized string ActivateMessage; // if activated send this message to cControler/Instigator

var(ControlMovement) bool bLetItMove;
var(ControlEvents) name EndControlEvent; // event after finishing control
var(ControlEvents) bool bReturnToOriginalRotation;
var(ControlEvents) float ReturnTime, ReactivateTime;

var (ControlWeapon) bool bCanUseAmplifier;
var (ControlWeapon) float AmplifierCharge;

var(ControlWeapon) bool bShakeView;
var(ControlWeapon) float ShakeMag; //300
var(ControlWeapon) float ShakeTime; //0.1
var(ControlWeapon) float ShakeVert; //5

var(ControlEvents) name EndControlUnTriggerEvent; // event after finishing control
var(ControlEvents) bool bStopIfFeignDeath;
var(ControlEvents) bool bSendUnTriggerToAll;

var() bool bBlockViewYawMinMax;

var(ControlWeapon) bool bWaitAltFireRelease;
var(ControlWeapon) bool bWaitFireRelease;

var() float KeyMoveTime;
var() bool bUseKeyFrames;

var(ControlWeapon) bool bInstantHit;
var(ControlInstantHit) class<effects> FireEffect;
var(ControlInstantHit) class<effects> WallHitEffect;
var(ControlInstantHit) float InstantHitDamage;
var(ControlInstantHit) class<effects> PawnHitEffect;
var(ControlInstantHit) class<effects> OtherHitEffect;

var(ControlWeapon) enum EZoomMode
{
    ZM_None,                    // no Zooming
// no projectile will be spawned and no instant hit...
    ZM_Fire,                    // Zoom with FireBtn
    ZM_AltFire,                 // Zoom with AltFireBtn
// projectile will be spawned or instant hit...
    ZM_Fire_AND_Projectile,     // Zoom with FireBtn
    ZM_AltFire_AND_Projectile,  // Zoom with AltFireBtn
// Fire AND AltFire for Zooming
    ZM_Both_BTNs,               // with projectile / instant hit
    ZM_Both_BTNs_NoFire,        // no projectile / instant hit
} ZoomMode;

var(ControlInstantHit) enum EIHMode
{
    IHM_Fire_and_AltFire,
    IHM_Fire,
    IHM_AltFire,
} InstantHitMode;

var(ControlEvents) name StartControlEvent; // event after starting control
var(ControlEvents) name StartControlUnTriggerEvent; // event after starting control

var(ControlInstantHit) float InstantHitAccuracy;
var(ControlInstantHit) float AltInstantHitAccuracy;

var(ControlSpecialFire) vector  FireOffset;
var(ControlSpecialFire) bool    bDoubleFire;

// intern used vars
var actor tActor;
var rotator tmpRot;
var int revPitch, revRoll, revYaw;

var weapon cWeapon;
var NoWeaponNoFire NoWeapon;
var float TimePassed, TimeToCheck;
var bool bShoot, bSwitchWeapon;
var bool bChkPitch, bChkRoll, bChkYaw, bChkMinMax;
var vector tmpLoc;
var bool bActive, bNoEncroaching;
var rotator oRot;
var bool bReactivate, bReturnTo;
var Pickup Amp;

var vector      oKeyPos[8];
var rotator     oKeyRot[8];
var vector      oBasePos;
var rotator     oBaseRot;
var byte        oKeyNum;

var bool bFireIH, bAltFireIH, btActIsPlayer;
var int tmpPitch, tmpRoll, tmpYaw;

//var BotInventorySpot BIS;
replication
{
    // Things the server should send to the client.
    reliable if( Role==ROLE_Authority )
        tActor, tmpPitch, tmpRoll, tmpYaw;
}


simulated function PostBeginPlay()
{
local int i;
    Super.PostBeginPlay();
// Network Client update !!
    settimer(0.01, True);
//BIS
//  BIS = None;
//  if (TriggerActor != None)
//  {
//      BIS = Spawn(class'BotInventorySpot',,,TriggerActor.Location);
//      BIS.MaxDesireAbility = 0.5;
//      BIS.oMaxDesireAbility = 0.5;
//  }

// initialize all Keys and save them in oKey...
    for (i=1; i > 8; i++)
    {
        oKeyPos[i] = KeyPos[i];
        oKeyRot[i] = KeyRot[i];
        KeyPos[i]  = vect(0,0,0);
        KeyRot[i]  = rot(0,0,0);
    }
    oBasePos = Location;
    oBaseRot = Rotation;

    revPitch = 1;   revRoll = 1;    revYaw = 1;
    if (bReversePitch) revPitch = -1;
    if (bReverseRoll) revRoll = -1;
    if (bReverseYaw) revYaw = -1;
    BasePos = Location;
    BaseRot = Rotation;
    oRot = Rotation;
    KeyRot[0] = rot(0,0,0);
    KeyPos[0] = vect(0,0,0);
    if (FirePositionOffset == 0)
        FirePositionOffset = 1;
    // just for performance...
    bChkMinMax = False; bChkPitch = False;
    bChkRoll = False;   bChkYaw = False;

    if (!bControlPitch) {maxPitch = 0; minPitch = 0;}
    if (!bControlYaw) {maxYaw = 0; minYaw = 0;}
    if (!bControlRoll) {maxRoll = 0; minRoll = 0;}

    if  (   (maxPitch != 0)
        ||  (minPitch != 0) )
        bChkPitch = True;
    if  (   (maxRoll != 0)
        ||  (minRoll != 0) )
        bChkRoll = True;
    if  (   (maxYaw != 0)
        ||  (minYaw != 0) )
        bChkYaw = True;
    if  ( bChkPitch || bChkRoll || bChkYaw ) bChkMinMax = True;
    bActive = False;
    bNoEncroaching = False;
    if (AmplifierCharge < 1.0) AmplifierCharge = 1.0;

//  SetCollisionSize(0,0);

    bFireIH = False;
    bAltFireIH = False;

    if (bInstantHit)
    {
        switch InstantHitMode
        {
            case IHM_Fire_and_AltFire:
                bFireIH = True;
                bAltFireIH = True;
                break;
            case IHM_Fire:
                bFireIH = True;
                break;
            case IHM_AltFire:
                bAltFireIH = True;
                break;
        }
    }
    if (ZoomMode == ZM_Fire)
    {
        Fire_ProjectileClass = None;
        bFireIH = False;
    }
    if (ZoomMode == ZM_AltFire)
    {
        AltFire_ProjectileClass = None;
        bAltFireIH = False;
    }

    bShoot = True;

// BIS
//  if (BIS != None) BIS.TurnON();
}

simulated function BeginPlay()
{
	// timer updates real position every second in network play
	if ( Level.NetMode != NM_Standalone )
	{
		settimer(0.0, true);
		if ( Role < ROLE_Authority )
			return;
	}
	// Init key info.
//	Super.BeginPlay();
	KeyNum         = Clamp( KeyNum, 0, ArrayCount(KeyPos)-1 );
	PhysAlpha      = 0.0;

	// Set initial location.
	Move( BasePos + KeyPos[KeyNum] - Location );

	// Initial rotation.
	SetRotation( BaseRot + KeyRot[KeyNum] );

	// find movers in same group
	if ( ReturnGroup == '' )
		ReturnGroup = tag;
}

function ResetKeys()
{
local int i;
    for (i=1; i > 8; i++)
    {
        KeyPos[i] = oKeyPos[i];
        KeyRot[i] = oKeyRot[i];
    }
    BasePos = oBasePos;
    BaseRot = oBaseRot;
}

function ClearKeys()
{
local int i;
    for (i=1; i > 8; i++)
    {
        KeyPos[i]  = vect(0,0,0);
        KeyRot[i]  = rot(0,0,0);
    }
}

// Open the mover.
function DoOpen()
{
    bOpening = true;
    bDelaying = false;
    if(bUseKeyFrames && !bSlave)
    {
        ResetMultipliedYaw();
        ResetKeys();
        KeyNum = 0;
        PrevKeyNum = 0;
        InterpolateTo( 1, KeyMoveTime );
        oKeyNum = KeyNum;
        ClearKeys();
    }
    PlaySound( OpeningSound, SLOT_None );
    AmbientSound = MoveAmbientSound;
}

// Close the mover.
function DoClose()
{
local actor A;
    bOpening = false;
    bDelaying = false;
    if(bUseKeyFrames && !bSlave)
    {
        ResetMultipliedYaw();
        ResetKeys();
        KeyNum = oKeyNum;
        PrevKeyNum = oKeyNum;
        InterpolateTo( Max(0,KeyNum-1), KeyMoveTime );
        ClearKeys();
    }
    PlaySound( ClosingSound, SLOT_None );
    if( Event != '' )
        foreach AllActors( class 'Actor', A, Event )
            A.UnTrigger( Self, Instigator );
    AmbientSound = MoveAmbientSound;
}

// Interpolation ended.
function InterpolateEnd( actor Other )
{
    local byte OldKeyNum;

    OldKeyNum  = PrevKeyNum;
    PrevKeyNum = KeyNum;
    PhysAlpha  = 0;

    // If more than two keyframes, chain them.
    if( KeyNum>0 && KeyNum<OldKeyNum )
    {
        // Chain to previous.
        InterpolateTo(KeyNum-1,KeyMoveTime);
    }
    else if( KeyNum<NumKeys-1 && KeyNum>OldKeyNum )
    {
        // Chain to next.
        InterpolateTo(KeyNum+1,KeyMoveTime);
    }
}

function ControlWeaponStart()
{
    // put pawns weapon down and replace it with NoWeapon
    // the if() is needed in case that the player controls
    // more than one controlmover
    bSwitchWeapon = False;

    NoWeapon = spawn(class'NoWeaponNoFire', tActor);

    if ( Pawn(tActor).Weapon.class != NoWeapon.class )
    {
        cWeapon = Pawn(tActor).Weapon;
        NoWeapon.SetOwner(tActor);

        Pawn(tActor).Weapon.TweenDown();
        Pawn(tActor).Weapon = NoWeapon;
        Pawn(tActor).PendingWeapon = NoWeapon;
        Pawn(tActor).Weapon.BringUp();
        bSwitchWeapon = True;
    }
    // if the tActor is firing stop firing
    Pawn(tActor).bFire = 0;
    Pawn(tActor).bAltFire = 0;
    // if the tActor is a playerpawn
    // end zoom just for the case the player is holding
    // a rifle (or other weapon) in zoom mode
    if ( tActor.IsA('PlayerPawn') )
        PlayerPawn(tActor).EndZoom();
}

function ControlWeaponEnd()
{
    if (Pawn(tActor).Health <= 0)
    {
        Pawn(tActor).Weapon = None;
        Pawn(tActor).PendingWeapon = None;
    }
    // reactivate pawns weapon
    // the if() is needed in case that the player controls
    // more than one controlmover
    else if (bSwitchWeapon)
    {
        Pawn(tActor).Weapon.TweenDown();
        Pawn(tActor).Weapon = cWeapon;
        Pawn(tActor).PendingWeapon = cWeapon;
        Pawn(tActor).Weapon.BringUp();
    }
    NoWeapon.SetOwner(None);
    NoWeapon.Destroy();
    NoWeapon = None;

    bSwitchWeapon = False;
    // if the tActor is firing stop firing
    Pawn(tActor).bFire = 0;
    Pawn(tActor).bAltFire = 0;
    cWeapon = None;
    Instigator = None;
}

function ControlGroup(actor Other)
{
    local ControlRotatingMover M;
    tActor = Other;
    ForEach AllActors( class'ControlRotatingMover', M, Tag )
    {
        if (M != Self)
            if (!M.bActive)
            {
                if (bNoEncroaching) M.bNoEncroaching = True;
                M.tActor = tActor;
                M.GotoState('PlayerControl','StartIt');
            }
    }
}

function ControlGroupEnd(actor Other)
{
    local ControlRotatingMover M;
    tActor = Other;
    bNoEncroaching = False;

    ForEach AllActors( class'ControlRotatingMover', M, Tag )
    {
        if (M != Self)
            if (M.bActive)
            {
                M.bNoEncroaching = False;
                M.GotoState('PlayerControl','EndIt');
            }
    }
}

function bool EncroachingOn( actor Other )
{
    if (bNoEncroaching)
        Return(False);
    else
        Super.EncroachingOn(Other);
}

function TriggerEndControl()
{
    local actor A;

    if  (   ( EndControlEvent != '' )
        &&  ( tActor != None) )
        foreach allactors(class'Actor', A, EndControlEvent)
        {
            if (A != Self)
                A.Trigger(self, Pawn(tActor));
        }
    if  (   ( EndControlUnTriggerEvent != '' )
        &&  ( tActor != None) )
        foreach allactors(class'Actor', A, EndControlUnTriggerEvent)
        {
            if (A != Self)
                A.UnTrigger(self, Pawn(tActor));
        }
}

function TriggerStartControl()
{
    local actor A;

    if  (   ( EndControlEvent != '' )
        &&  ( tActor != None) )
        foreach allactors(class'Actor', A, StartControlEvent)
        {
            if (A != Self)
                A.Trigger(self, Pawn(tActor));
        }
    if  (   ( EndControlUnTriggerEvent != '' )
        &&  ( tActor != None) )
        foreach allactors(class'Actor', A, StartControlUnTriggerEvent)
        {
            if (A != Self)
                A.UnTrigger(self, Pawn(tActor));
        }
}

function bool IsAMPActive()
{
local Inventory I;
    Amp = None;
    I = Pawn(tActor).FindInventoryType(class'Amplifier');
    if ( Amplifier(I) != None )
        Amp = Amplifier(I);
    if (Amp.bActive)
        return(True);
    else
        return(False);
}

function TurnOffAllOtherEvents()
{
    local actor a;
    if (bSendUnTriggerToAll)
        foreach allactors(class'Actor', a, Tag)
            if (a != Self)
                a.UnTrigger(tActor, Instigator);
}

function ResetMultipliedYaw()
{
    if(!bSlave)
    {
// reset multiplied Rotation.Yaw
        tmpRot = BaseRot;

        while ( BaseRot.Yaw < (-32768+oBaseRot.Yaw) )
            BaseRot.Yaw += 65536;
        while ( BaseRot.Yaw > (32768+oBaseRot.Yaw) )
            BaseRot.Yaw -= 65536;

        while ( BaseRot.Pitch < -32768 )
            BaseRot.Pitch += 65536;
        while ( BaseRot.Pitch > 32768 )
            BaseRot.Pitch -= 65536;

        if (tmpRot != BaseRot)
        {
            tmpRot = BaseRot;
            KeyRot[0] = rot(0,0,0);
            KeyPos[0] = vect(0,0,0);
            KeyNum=0;
            PrevKeyNum=0;
            InterpolateTo(0,0);
        }
    }
    ResetMultipliedPlayerRotation();
}

function ResetMultipliedPlayerRotation()
{
local float DeltaYaw;
    if(!bSlave)
    {
// reset multiplied Rotation.Yaw
        DeltaYaw = Pawn(tActor).ViewRotation.Yaw;
        while ( DeltaYaw < (-32768+oBaseRot.Yaw) )
            DeltaYaw += 65536;
        while ( DeltaYaw > (32768+oBaseRot.Yaw) )
            DeltaYaw -= 65536;
        Pawn(tActor).ViewRotation.Yaw = DeltaYaw;
    }
}

function TraceFire( float Accuracy, float LeftRight)
{
    local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z, NewOffset;
    local actor Other;
    local rotator AdjustedAim;

    NewOffset = FireOffset;
    NewOffset.Y *= LeftRight;

    GetAxes(RealRotation,X,Y,Z);
    StartTrace = RealPosition+Vector(RealRotation)*FirePositionOffset;
// NEW !!
    StartTrace = StartTrace + NewOffset.X * X + NewOffset.Y * Y + NewOffset.Z * Z;

    AdjustedAim = RealRotation;
    EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
        + Accuracy * (FRand() - 0.5 ) * Z * 1000;
    X = vector(AdjustedAim);
    EndTrace += (10000 * X);
    Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
    ProcessTraceHit(Other, HitLocation, HitNormal, X,Y,Z);

    if (FireEffect != None)
        Spawn (FireEffect,,,StartTrace,RealRotation);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
    local int rndDam;

    if (Other == Level)
    {
        if (WallHitEffect != None)
            Spawn(WallHitEffect,,, HitLocation+HitNormal*9, Rotator(HitNormal));
    }
    else if ( (Other!=self) && (Other!=Owner) && (Other != None) )
    {
        if ( !Other.IsA('Pawn') && !Other.IsA('Carcass') )
        {
            if (OtherHitEffect != None)
                spawn(OtherHitEffect,,,HitLocation+HitNormal*9, Rotator(HitNormal));
        }
        else
        {
            if (PawnHitEffect != None)
                spawn(PawnHitEffect,,,HitLocation+HitNormal*9, Rotator(HitNormal));
        }
        if ( Other.IsA('ScriptedPawn') && (FRand() < 0.2) )
            Pawn(Other).WarnTarget(Pawn(tActor), 500, X);
        rndDam = InstantHitDamage + Rand(6);
        if ( FRand() < 0.2 )
            X *= 2;
        Other.TakeDamage(rndDam, Pawn(tActor), HitLocation, rndDam*500.0*X, 'shot');
    }
}

function ProjectileFire(class<projectile> ProjClass, float LeftRight)
{
    local Vector Start, X,Y,Z, NewOffset;
    local Projectile pp;
    local float MultDamage;

    NewOffset = FireOffset;
    NewOffset.Y *= LeftRight;

    tActor.MakeNoise(Pawn(tActor).SoundDampening);
    GetAxes(RealRotation,X,Y,Z);
    Start = RealPosition+Vector(RealRotation)*FirePositionOffset;
// NEW !!
    Start = Start + NewOffset.X * X + NewOffset.Y * Y + NewOffset.Z * Z;

    pp = Spawn(ProjClass,,, Start,RealRotation);

    if (pp != None)
    {
        pp.Instigator = Pawn(tActor);
    // use Amplifier
        if (bCanUseAmplifier)
        {
            if (IsAMPActive())
                MultDamage = Amp.UseCharge(AmplifierCharge);
            else
                MultDamage = 1.0;
            pp.Damage = pp.Damage*MultDamage;
        }
    }
}


// Control the movers rotation
auto state() PlayerControl
{
    function bool HandleDoor(pawn Other)
    {
        return HandleTriggerDoor(Other);
    }

    // used for ControlMoving
    function Bump( actor Other )
    {
        Super.Bump (Other);
        if (bLetItMove && Other.IsA('PlayerPawn') )
        {
            bNoEncroaching = True;
            // Activate the Mover 'Group'
            ControlGroup(Other);
            tActor = Other;
            Trigger(tActor,Pawn(tActor));
//          GotoState('PlayerControl','StartIt');
        }
    }

    function Trigger( actor Other, pawn EventInstigator )
    {
        if (!bActive)
        {
//BIS
//          if (BIS != None) BIS.TurnOFF();

            bActive = True;
            tActor = Other;
            // set the players ViewRotation to prevent
            // the 'spin around effect'
            if (!bSlave)
                Pawn(tActor).ViewRotation = BaseRot;
            numTriggerEvents++;
            SavedTrigger = Other;
            Instigator = EventInstigator;
            if ( SavedTrigger != None )
                SavedTrigger.BeginEvent();
            if ( Pawn(tActor)!=None && Pawn(tActor).bIsPlayer )
                tActor.Instigator.ClientMessage( ActivateMessage );
            if (bControlFire)
                ControlWeaponStart();
            GotoState( 'PlayerControl', 'Open' );
        }
    }

    function UnTrigger( actor Other, pawn EventInstigator )
    {
        if (bActive)
        {
            if (bControlFire)
                ControlWeaponEnd();

            if (bLetItMove)
            {
                if (!bSlave)
                    SetBase(None);
                Disable( 'Bump' );
            }

//          AmbientSound = None;

            TurnOffAllOtherEvents();

            // Restore the Mover 'Group'
            ControlGroupEnd(tActor);

            if (bReturnToOriginalRotation)
            {
                SetTimer(0.0,False);
                BaseRot = oRot;
                KeyNum=0;
                PrevKeyNum=0;
                InterpolateTo(0,ReturnTime);
                GotoState( 'ReturnTo' );
            }
            else
            {
                if (ReactivateTime > 0)
                    GotoState( 'ReactivateWait' );
                else
                {
                    // call the EndControlEvent (Trigger)
                    TriggerEndControl();
                    tActor = None;
                    bActive = False;
                    GotoState( 'PlayerControl', 'Close' );
                }
            }
            numTriggerEvents = 0;
            SavedTrigger = Other;
            Instigator = EventInstigator;
            SavedTrigger.BeginEvent();
        }
    }

    function BeginState()
    {
        numTriggerEvents = 0;
    }

    function StartControl()
    {
        if (bLetItMove)
        {
            SetCollision(False,False,False);
            bCollideWorld = False;
            SetBase(tActor);
            tmpLoc = tActor.Location;
            SetLocation(tActor.Location);
            SetRotation(tActor.Rotation);
        }

        BasePos = Location;
        BaseRot = Rotation;
        oRot = Rotation;
        tmpRot = Rotation;

// reset multiplied Rotation.Yaw
        ResetMultipliedYaw();

//      AmbientSound = MoveAmbientSound;

        if ( tActor.IsA('PlayerPawn') ) btActIsPlayer = True;
        else btActIsPlayer = False;

        GotoState( 'PlayerControl', 'Control' );
    }

    // check current Controler (tActor)
    function bool ChecktActor()
    {
		if (tActor != None)
		{
	        if  (  (Pawn(tActor).Health <= 0)
    	        || (Pawn(tActor) == None)
        	    || (Pawn(tActor).bHidden) )
            	Return (False);
	        else
    	        Return (True);
		}
		else
           	Return (False);
    }

    // min-max check splitted for performance
    function MinMaxCorrection() {
        if ( bchkPitch ) MinMaxPitch();
        if ( bchkRoll ) MinMaxRoll();
        if ( bchkYaw ) MinMaxYaw();
    }
    function MinMaxPitch()  {
        if (maxPitch != 0)
            if ( BaseRot.Pitch > maxPitch )
                BaseRot.Pitch = maxPitch;
        if (minPitch != 0)
            if ( BaseRot.Pitch < minPitch )
                BaseRot.Pitch = minPitch;   }
    function MinMaxRoll()   {
        if (maxRoll != 0)
            if ( BaseRot.Roll > maxRoll )
                BaseRot.Roll = maxRoll;
        if (minRoll != 0)
            if ( BaseRot.Roll < minRoll )
                BaseRot.Roll = minRoll; }
    function MinMaxYaw()
    {
        if (maxYaw != 0)
            if ( BaseRot.Yaw > maxYaw )
            {
                BaseRot.Yaw = maxYaw;
                if (bBlockViewYawMinMax)
                    if (!PlayerPawn(tActor).ViewTarget.IsA('Projectile'))
                        Pawn(tActor).ViewRotation.Yaw = BaseRot.Yaw;
            }
        if (minYaw != 0)
            if ( BaseRot.Yaw < minYaw )
            {
                BaseRot.Yaw = minYaw;
                if (bBlockViewYawMinMax)
                    if (!PlayerPawn(tActor).ViewTarget.IsA('Projectile'))
                        Pawn(tActor).ViewRotation.Yaw = BaseRot.Yaw;
            }
    }

    simulated function Timer()
    {
		if( Level.NetMode == NM_Client )
		{
			if (tActor != None)
			{
				if(  ( Rotation.Pitch != tmpPitch )
				  || ( Rotation.Roll  != tmpRoll  ) 
				  || ( Rotation.Yaw   != tmpYaw   ) )
				{
					tmpRot.Pitch = tmpPitch;
					tmpRot.Roll = tmpRoll;
					tmpRot.Yaw = tmpYaw;
					SetRotation( tmpRot );
				}
				if( RealPosition != Location )
					SetLocation( RealPosition );
			}
			settimer(0.01, true);
		}
		else
		{
	        if (!ChecktActor())
        	    UnTrigger(tActor,Pawn(tActor));
    	    else
	        {
				if( Level.NetMode != NM_Standalone )
				{
				// If this mover is on client side...
					if( Level.NetMode != NM_Client )
					{
				// This mover is on server side.
						if( (Location != RealPosition) || (Rotation != RealRotation) )
						{
							RealPosition = Location;
							RealRotation = Rotation;
							tmpPitch = Rotation.Pitch; // These three vars preserve
							tmpYaw = Rotation.Yaw; // rotator accuracy (i.e. they
							tmpRoll = Rotation.Roll; // avoid network quantizing).
						}
					}
				}
				else
				{
		            RealPosition = Location;
	    	        RealRotation = Rotation;
				}

	            if (ZoomMode != ZM_None)
        	        ZoomIt();

    	        MoveIt();
	        }
        }
    }

    function ZoomIt()
    {
      if (tActor != None)
      {
        if  (   (   (       (ZoomMode == ZM_Fire)
                        ||  (ZoomMode == ZM_Fire_AND_Projectile)
                    )
                &&  ( Pawn(tActor).bFire == 0 )
                )
            ||  (   (       (ZoomMode == ZM_AltFire)
                        ||  (ZoomMode == ZM_AltFire_AND_Projectile)
                    )
                &&  ( Pawn(tActor).bAltFire == 0 )
                )
            ||  (   (       (ZoomMode == ZM_Both_BTNs)
                        ||  (ZoomMode == ZM_Both_BTNs_NoFire)
                    )
                &&  (   ( Pawn(tActor).bFire == 0 )
                    ||  ( Pawn(tActor).bAltFire == 0 )
                    )
                )
            )
            PlayerPawn(tActor).StopZoom();

        if (!PlayerPawn(tActor).bZooming)
        {
            if  (   (   (       (ZoomMode == ZM_Fire)
                            ||  (ZoomMode == ZM_Fire_AND_Projectile)
                        )
                    &&  ( Pawn(tActor).bFire != 0 )
                    )
                ||  (   (       (ZoomMode == ZM_AltFire)
                            ||  (ZoomMode == ZM_AltFire_AND_Projectile)
                        )
                    &&  ( Pawn(tActor).bAltFire != 0 )
                    )
                ||  (   (       (ZoomMode == ZM_Both_BTNs )
                            ||  (ZoomMode == ZM_Both_BTNs_NoFire)
                        )
                    &&  ( Pawn(tActor).bFire != 0 )
                    &&  ( Pawn(tActor).bAltFire != 0 )
                    )
                )
                PlayerPawn(tActor).ToggleZoom();
        }
      }
    }

    function MoveIt()
    {
        if (!ChecktActor())
        {
            UnTrigger(tActor,Pawn(tActor));
            return;
        }
        if  (   (bControlPitch)
            ||  (bControlRoll)
            ||  (bControlYaw) )
        {

    // reset multiplied Rotation
            ResetMultipliedYaw();

    // update Pos and Rot (NEEDED for bSlaves)
            BasePos = RealPosition;
            BaseRot = RealRotation;

    // set up the new BaseRot using the ViewRotation
            if (bControlPitch)
                BaseRot.Pitch = Pawn(tActor).ViewRotation.Pitch * revPitch;
            if (bControlRoll)
                BaseRot.Roll = Pawn(tActor).ViewRotation.Roll * revRoll;
            if (bControlYaw)
                BaseRot.Yaw = Pawn(tActor).ViewRotation.Yaw * revYaw;

    // Pitch correction cause Viewrotation <0 starts by 65535
            if (BaseRot.Pitch > 32768)
                BaseRot.Pitch = (65535 - BaseRot.Pitch) * -1;

    // check the min-max vars
            if (bChkMinMax) MinMaxCorrection();

    // initialize the KeyPos and KeyRot
    // all rotation is done by manipulating the Base
            KeyRot[0] = rot(0,0,0);
            KeyPos[0] = vect(0,0,0);

            KeyRot[0] = oBaseRot;
			KeyPos[0] = oBasePos;
			
            KeyRot[1] = BaseRot - oBaseRot;
			KeyPos[1] = BasePos - oBasePos;

			BaseRot = oBaseRot;
			BasePos = oBasePos;
			

            if(bLetItMove)
                SetLocation(tActor.Location);

//            if  (tmpRot != BaseRot)
            if  (tmpRot != KeyRot[1])
            {
                KeyNum=0;
                PrevKeyNum=0;
                InterpolateTo(1,MoveTime);
            }

//            tmpRot = BaseRot;
            tmpRot = KeyRot[1];
            tmpLoc = tActor.Location;
        }

// use this line for testing your min/max rotation
// just remove the first two '//' press F7 and save the package!
//      tActor.Instigator.ClientMessage( string(BaseRot) );

    // Untrigger if player FeignDeath
        if  (PlayerPawn(tActor).PlayerReplicationInfo.bFeigningDeath
            && bStopIfFeignDeath)
        {
            UnTrigger(tActor,Pawn(tActor));
            return;
        }

        // can this mover fire some projectiles
        if (bControlFire)
        {
        // to prevent firing with multiple weapons
        // if tActor changes weapon
            if ( Pawn(tActor).Weapon.class != NoWeapon.class )
            {
                UnTrigger(tActor,Pawn(tActor));
                return;
            }
            if (bControlFire && bShoot)
            {
                if ( !btActIsPlayer )
                    CheckPawnFireMode();
                else
                {
                    if  (!( (PlayerPawn(tActor).bZooming)
                        &&  (ZoomMode == ZM_Both_BTNs_NoFire)
                        ) )
                    {
                        if (Pawn(tActor).bFire == 1) Shoot(1);
                        else if (Pawn(tActor).bAltFire == 1) Shoot(2);
                    }
                }
            }
        }
    }

    // used for Fire/AltFireRate
    function Tick( float DeltaTime )
    {
        if (!bShoot)
        {
            TimePassed += DeltaTime;
            if  (   (TimePassed > TimeToCheck)
                &&  ( (Pawn(tActor).bFire == 0)    || (!bWaitFireRelease) )
                &&  ( (Pawn(tActor).bAltFire == 0) || (!bWaitAltFireRelease) )
                )
            {
                bShoot = True;
                Disable('Tick');
            }
        }
    }

// if ZoomMode = ZM_(Alt)Fire and controler is not a PlayerPawn
// just one firemode is available
    function CheckPawnFireMode()
    {
        switch ZoomMode
        {
        case ZM_Fire:
            if  (   (Pawn(tActor).bFire == 1)
                ||  (Pawn(tActor).bAltFire == 1) )
                Shoot(2);
            break;
        case ZM_AltFire:
            if  (   (Pawn(tActor).bFire == 1)
                ||  (Pawn(tActor).bAltFire == 1) )
                Shoot(1);
            break;
        default:
            if (Pawn(tActor).bFire == 1) Shoot(1);
            else if (Pawn(tActor).bAltFire == 1) Shoot(2);
            break;
        }
    }

    function ShakeIt(int FMode)
    {
        if (bShakeView && tActor.IsA('PlayerPawn'))
        {
            switch FMode
            {
            case 1:
                if  (   ( bFireIH )
                    ||  ( !bFireIH && Fire_ProjectileClass != None ) )
                    if (PlayerPawn(tActor).ViewTarget != None)
                    {
                        if (PlayerPawn(tActor).ViewTarget.IsA('ViewSpot'))
                            ViewSpot(PlayerPawn(tActor).ViewTarget).ShakeView(ShakeTime, ShakeMag, ShakeVert);
                        else
                            PlayerPawn(tActor).ShakeView(ShakeTime, ShakeMag, ShakeVert);
                    }
                    else
                        PlayerPawn(tActor).ShakeView(ShakeTime, ShakeMag, ShakeVert);
                    break;
            case 2:
                if  (   ( bAltFireIH )
                    ||  ( !bAltFireIH && AltFire_ProjectileClass != None ) )
                    if (PlayerPawn(tActor).ViewTarget != None)
                    {
                        if (PlayerPawn(tActor).ViewTarget.IsA('ViewSpot'))
                            ViewSpot(PlayerPawn(tActor).ViewTarget).ShakeView(ShakeTime, ShakeMag, ShakeVert);
                        else
                            PlayerPawn(tActor).ShakeView(ShakeTime, ShakeMag, ShakeVert);
                    }
                    else
                        PlayerPawn(tActor).ShakeView(ShakeTime, ShakeMag, ShakeVert);
                    break;
            }
        }
    }

    // Fire/AltFire using Fire/AltFireRate (function Tick)
    function Shoot(int FMode)
    {
        ShakeIt(FMode);

        if (FMode == 1)
        {
            if (ZoomMode != ZM_Fire)
                PlaySound(FireSound, SLOT_None,5.0);

            if(bFireIH)
            {
                TraceFire(InstantHitAccuracy, 1);
                if(bDoubleFire)
                    TraceFire(InstantHitAccuracy, -1);
            }
            else if ( Fire_ProjectileClass != None )
            {
// NEW
                ProjectileFire(Fire_ProjectileClass, 1);
                if(bDoubleFire)
                    ProjectileFire(Fire_ProjectileClass, -1);
//              pp = Spawn (Fire_ProjectileClass,,,RealPosition+Vector(RealRotation)*FirePositionOffset,RealRotation);
            }
        }
        else
        {
            if (ZoomMode != ZM_AltFire)
                PlaySound(AltFireSound, SLOT_None,5.0);

            if(bAltFireIH)
            {
                TraceFire(AltInstantHitAccuracy, 1);
                if(bDoubleFire)
                    TraceFire(AltInstantHitAccuracy, -1);
            }
            else if ( AltFire_ProjectileClass != None )
            {
                ProjectileFire(AltFire_ProjectileClass, 1);
                if(bDoubleFire)
                    ProjectileFire(AltFire_ProjectileClass, -1);
//              pp = Spawn (AltFire_ProjectileClass,,,RealPosition+Vector(RealRotation)*FirePositionOffset,RealRotation);
            }
        }

        if (FMode == 1) PlaySound(ReloadSound, SLOT_None,5.0);
        else PlaySound(AltReloadSound, SLOT_None,5.0);

        if (FMode == 1) TimeToCheck = FireRate;
        else TimeToCheck = AltFireRate;
        TimePassed = 0;
        bShoot = False;
        Enable('Tick');
    }
StartIt:
    // used for ControlMoving to activate slaves
    SetTimer(0.0,False);
    Trigger(tActor,Pawn(tActor));
    Stop;
EndIt:
    // used for ControlMoving to deactivate slaves
    SetTimer(0.0,False);
    UnTrigger(tActor,Pawn(tActor));
    Stop;
Open:
    // 'open' the Mover
    if ( DelayTime > 0 )
    {
        bDelaying = true;
        Sleep(DelayTime);
    }
    DoOpen();
    FinishInterpolation();
    FinishedOpening();
    SavedTrigger.EndEvent();
    Pawn(tActor).ViewRotation = Rotation;
    StartControl();
    Stop;
Control:
    // Control the Mover
    Disable('Tick');
    bShoot = True;
    SetTimer(OtherTime,True);
    TriggerStartControl();
    Stop;
Close:
    // 'close' the Mover

//BIS
//  if (BIS != None) BIS.TurnON();

    SetTimer(0.0,False);
    DoClose();
    FinishInterpolation();
    FinishedClosing();
    AmbientSound = None;
    if (bLetItMove)
        GotoState( 'StillTouching' );
    Stop;
DoNothing:
}

// Return to original rotation and call the EndControlEvent
state ReturnTo
{
    function Tick( float DeltaTime )
    {
        TimePassed += DeltaTime;
        if (TimePassed > TimeToCheck)
        {
            bReturnTo = True;
            Disable('Tick');
        }
    }

    function Timer()
    {
        if (bReturnTo)
        {
            SetTimer(0.0,False);
            // call the EndControlEvent (Trigger)
            TriggerEndControl();
            tActor = None;
            if (ReactivateTime > 0)
                GotoState( 'ReactivateWait' );
            else
            {
                bActive = False;
                GotoState( 'PlayerControl', 'Close' );
            }
        }
    }

Begin:
    // Return to original rotation
    TimeToCheck = ReturnTime;
    TimePassed = 0;
    bReturnTo = False;
    Enable('Tick');
    SetTimer(0.02,True);
}

// wait for reactivation
state ReactivateWait
{
    function Tick( float DeltaTime )
    {
        TimePassed += DeltaTime;
        if (TimePassed > TimeToCheck)
        {
            bReactivate = True;
            Disable('Tick');
        }
    }

    function Timer()
    {
        if (bReactivate)
        {
            SetTimer(0.0,False);
            // call the EndControlEvent (Trigger)
            TriggerEndControl();
            tActor = None;
            bActive = False;
            GotoState( 'PlayerControl', 'Close' );
        }
    }

Begin:
    TimeToCheck = ReactivateTime;
    TimePassed = 0;
    bReactivate = False;
    Enable('Tick');
    SetTimer(0.02,True);
}

state StillTouching
{

    function Bump( actor Other ) {}

    function Timer()
    {
    local pawn P;
        P = None;
// TouchingActors isn't working... so
        foreach RadiusActors(class'Pawn',P, CollisionRadius)
            break;
        if (P == None)
        {
            SetTimer(0.0,False);
            Enable( 'Bump' );
            SetCollision(True,True,True);
            GotoState( 'PlayerControl', 'DoNothing');
        }
    }

Begin:
    SetTimer(1.0, True);
}

defaultproperties
{
     bControlPitch=True
     bControlYaw=True
     FireSound=Sound'UnrealShare.Eightball.EightAltFire'
     AltFireSound=Sound'UnrealShare.Eightball.EightAltFire'
     Fire_ProjectileClass=Class'UnrealShare.Rocket'
     AltFire_ProjectileClass=Class'UnrealShare.Rocket'
     AltFireRate=0.800000
     FireRate=0.800000
     AltReloadSound=Sound'UnrealShare.Eightball.Loading'
     ReloadSound=Sound'UnrealShare.Eightball.Loading'
     FirePositionOffset=100.000000
     ActivateMessage="You control the ..."
     AmplifierCharge=40.000000
     shakemag=300.000000
     shaketime=0.100000
     shakevert=5.000000
     KeyMoveTime=2.000000
     FireEffect=Class'UnrealShare.BlackSmoke'
     WallHitEffect=Class'UnrealShare.LightWallHitEffect'
     InstantHitDamage=8.000000
     OtherHitEffect=Class'UnrealShare.SpriteSmokePuff'
     InstantHitAccuracy=0.100000
     AltInstantHitAccuracy=0.800000
     MoverEncroachType=ME_IgnoreWhenEncroach
     NumKeys=0
     MoveTime=0.020000
     OtherTime=0.020000
     bUseTriggered=True
     bDynamicLightMover=True
     InitialState=PlayerControl
     bDirectional=True
}
