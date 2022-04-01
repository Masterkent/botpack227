// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// just tia's code.... fun for me (UsAaR33) to try out as my merc was a tad screwed a while ago. now it is heck of better :P)
// ============================================================

class WarLordguard expands WarLord;
var actor pa;     // used in seeplayer() in 'bumpedinto' and 'following' states
var bool bumped;  // used in 'bumpedinto' and 'following' states
var vector MyPos; // used in bump() in 'bumpedinto' and 'following' states
var int x,y,z;    // For finding distance to player on different axes
var vector Calc;  // Scratch vector


// We want to change what happens when the Bodyguard sees the player so we write
// our own function for it that will run instead of the Warlord's Global
// SeePlayer() function in the ScriptedPawn class.

function SeePlayer(actor SeenPlayer)
  {
        LastSeenPos = SeenPlayer.Location;   // Update the last known position
          // of the player. LastSeenPos is declared globally in the pawn class
        AttitudeToPlayer = ATTITUDE_Friendly; // Hey we're all buddy-buddy here.

// Just in case you did something to piss him off and you ran far enough away
// to get him out of the attacking state and you return, he'll be your friend
// again. I thought about having him let you shoot him without retaliating but
// it just did not fit his demeanor. If you want to be free from worry that you
// may knick your bodyguard with a razorjack or eightball in a firefight and
// bring his fury upon yourself then copy either his 'attacking' state or
// his TakeDamage() function here and add the code to make his attitude to you
// remain friendly no matter what happens.

        gotostate('greetplayer');  // This sends us into our custom states
  }


//*******************************************************************************


state GreetPlayer
 {
    ignores SeePlayer;  // If we don't ignore this it will continually loop
    // us through the above function and we won't ever get to the meat of this state

    function myGreet()  // We don't want this guy constantly jumping up and
    // down and waving at us, so to make it a little more special, 4 out of every
    // 20 myGreet's he will do a little something different.

    {
      local int i;
      i = Frand()*20;
      switch(i)
       {
         case 0:
              LoopAnim('Twirl');                        // You find these
              PlaySound(sound'DeathCry1WL', SLOT_Talk); // animations and sounds in
         break;                                         // the script for the
                                                        // Warlord class.
         case 1:
              LoopAnim('Laugh');
              PlaySound(sound'laugh1WL', SLOT_Talk);
         break;

         case 2:
              LoopAnim('Munch');
              PlaySound(sound'breath1WL', SLOT_Talk);
         break;

         case 3:
              LoopAnim('Point');
              PlaySound(sound'threat1WL', SLOT_Talk);

         break;


         default:
              playwaiting(); // default animation routine
      }

   }


//-------------------------------------------------------------------------------


Begin:
    SetMovementPhysics(); // Initialize
    myGreet();            // See what animation is in order
    sleep(2);             // Wait approx. 2 seconds to build tension
    gotostate('sic_em');  // He sees you so he better get to work before you
                          // fire him
}


//*******************************************************************************

state sic_em
{

 ignores SeePlayer;  // Time to kick ass not dance for the player

function myProtectMaster() // This function looks at all visible scripted
  // pawns to see if any are targeting the player or himself. If they are,
  // the bodyguard gets them.

{
  local scriptedpawn aScriptedPawn;
  foreach VisibleActors( class 'scriptedpawn' , aScriptedPawn )
  {
    if ( (aScriptedPawn != None) && (aScriptedPawn !=self) && (LineOfSightTo(aScriptedPawn)) && (aScriptedPawn.target != None))
     {
      Hated = aScriptedPawn;   // Hate him
          SetEnemy(aScriptedPawn); // Set him as enemy
          gotostate('attacking');  // ATTACK!
          break;
     }
  }
 }

function myNextKill() // This function looks at all visible scripted
          // pawns just to pick a fight with one
 {
  local scriptedpawn aScriptedPawn;
  foreach VisibleActors( class 'scriptedpawn' , aScriptedPawn )
  {
    if ( (aScriptedPawn != None) && (aScriptedPawn !=self) && (LineOfSightTo(aScriptedPawn)))      // I don't like the way you look boy
         {
      Hated = aScriptedPawn;   // I hate you
            SetEnemy(aScriptedPawn); // You are my enemy
            gotostate('attacking');  // Bartender, call an ambulance
            break;
         }
  }
 }
Begin:
 myProtectMaster();       // First is anyone targeting the boss?
 myNextKill();            // If not is anyone around to pick on?
 gotostate('following');  // Let's make sure we stay near the player
}


//*******************************************************************************


state following
{


  function SeePlayer(actor SeenPlayer) // Now we use SeePlayer() to keep track
                                         // of the player's location.
     {
        pa = SeenPlayer;                      // Global store our player
        LastSeenPos = SeenPlayer.Location;    // Update the last known position
                                              // of the player
     }


    function Bump(actor Other)  // We can use our own version of Bump() to
                                // steer our bodyguard into another custom state
    {
      MyPos = Location;         // Global Where am I?
      gotostate('bumpedinto');
    }


//---------------------------------------------------------------------------------


Begin:
    Bumped = False;                         // Bumped flag reset
    SetMovementPhysics();                   // Initialize
    GroundSpeed = 200;                      // Standard walk speed
    LoopAnim('walk',1.4,,);                 // Play walk animation

Moving:
    TurnTo(LastSeenPos);                    // Look at player
    x = abs(pa.location.x - location.x);    // How far away is he?
    y = abs(pa.location.y - location.y);
    z = abs(pa.location.z - location.z);

    if((x > 500) || (y >500) || (z >500))       // This far?
      goto ('run');

   else if((x > 200) || (y >200) || (z >200))  // This far?
      goto('Walk');

    else
      goto('hang');                             // He's close enough


Run:                                            // Running
     GroundSpeed = 400;
     LoopAnim('fly',0.7,,);
     MoveToward(pa, GroundSpeed);
     gotostate ('sic_em');                      // Check for prey

Walk:                                           // Walking
     WaitForLanding();
     GroundSpeed = 200;
     LoopAnim('walk',1.3,,);
     MoveToward(pa, GroundSpeed);
     gotostate ('sic_em');                      // Check for prey

Hang:                                           // Hangin' out

   PlayWaiting();
   sleep(2);
   gotostate ('sic_em');                        // Check for prey

}


//*******************************************************************************

state bumpedinto
{


    function SeePlayer(actor SeenPlayer)  // We just want to see the player one
     {                                    // time and get his position
    pa = SeenPlayer;                  // Then ignore SeePlayer()
        LastSeenPos = SeenPlayer.Location;// for the remainder of this state
        Disable('Seeplayer');             // with this line
     }


    function Bump(actor Other)            // This time we hijack Bump() so that
     {
        Bumped = True;                    // we can set the bumped flag
        MyPos = Location;
    gotostate('bumpedinto');

     }


//---------------------------------------------------------------------------------

Begin:

   MoveTo(MyPos);               // Stay put
   TurnTo(pa.location);         // Turn to player
   if(bumped == True)           // If a bump has occurred
     {
       LoopAnim('walk',1.4,,);  // Back off some random amount
       calc.x = Frand()*100;    // Pick random amount
       calc.y = Frand()*100;
       if(Frand() > 0.5)
         calc.x = 0 - calc.x;
       if(Frand() > 0.5)
         calc.y = 0 - calc.y;
       MyPos.x = MyPos.x + calc.x;
       MyPos.y = MyPos.y + calc.y;
       MoveTo(MyPos);              // Back off by that amount
       TurnTo(MyPos);              // Turn to player
       bumped = false;             // Set flag back
     }
   gotostate('following');
}

defaultproperties
{
}
