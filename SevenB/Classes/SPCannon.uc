// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
//SPCannon: Cannon for SP
// Sets teams differently and blows up :P
// myteam=0 means enemy myteam=1 means friend.
// ============================================================

class SPCannon expands TeamCannon;

function bool IsEnemy(pawn p){ //is this a potential enemy?
  If (p==self||p.health<=0||(!p.bisplayer&&p.attitudetoplayer==ATTITUDE_Ignore&&p.target==none))
    return false; //don't shoot enemies who are doing nothing.
  If (p.bisplayer||p.attitudetoplayer>=ATTITUDE_Friendly||(p.IsA('cow')||p.isa('nali')))
    return (myteam==0);
  else if (p.attitudetoplayer==ATTITUDE_Ignore&&p.target==none) //don't shoot enemies who do nothing.
    return false;
  else
    return (myteam==1);
}
auto state Idle
{
  ignores EnemyNotVisible;
  function SeePlayer(Actor SeenPlayer)
  {
  if ( myteam==0&&pawn(seenplayer)!=none&&pawn(seenplayer).bisplayer )
    {
      Enemy = Pawn(SeenPlayer);
      GotoState('ActiveCannon');
    }
  }

  function BeginState()
  {
    Enemy = None;
    settimer(1,true);
  }
  function timer(){
  local pawn apawn;
  local pawn temp;
   for (aPawn=level.pawnlist;apawn!=none;apawn=apawn.nextpawn)
  {
    if (IsEnemy(apawn)&&cansee(aPawn))
     {
      temp=apawn;
      if (apawn.target!=none){
        enemy=apawn; // Set him as enemy
        gotostate('ActiveCannon');  // ATTACK!
        return;
      }
     }
  }
  enemy=temp;
  if (enemy!=none)
    GotoState('ActiveCannon');
  }
}
//blow up on damage take
function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
          Vector momentum, name damageType)
{
  MakeNoise(1.0);
  Health -= NDamage;
  if (Health <0)
  {
    PlaySound(DeActivateSound, SLOT_None,5.0);
    skinnedFrag(class'Fragment1',texture'JCannon1', Momentum,1.0,17);  //ripped from cannon
    spawn(class'UT_SpriteBallExplosion');
    Destroy();
  }
  else if ( instigatedBy == None )
    return;
  else if ( (Enemy == None) && IsEnemy(instigatedby) )
  {
    Enemy = instigatedBy;
    GotoState('ActiveCannon');
  }
}
//from decoration
function skinnedFrag(class<fragment> FragType, texture FragSkin, vector Momentum, float DSize, int NumFrags)
{
  local int i;
  local actor A, Toucher;
  local Fragment s;

  if (Event!='')
    foreach AllActors( class 'Actor', A, Event )
      A.Trigger( Toucher, pawn(Toucher) );
  for (i=0 ; i<NumFrags ; i++)
  {
    s = Spawn( FragType, Owner);
    s.CalcVelocity(Momentum/100,0);
    s.Skin = FragSkin;
    s.DrawScale = DSize*0.5+0.7*DSize*FRand();
  }
}
function Shoot()   //wiped deathmatch plus check
{
	super.Shoot(); // see B227_ModifyProjectileDamage
}

// B227 fix:
state ActiveCannon
{
	event EnemyNotVisible()
	{
		local Pawn P;

		Enemy = none;
		if (MyTeam == 0)
		{
			for (P = Level.PawnList; P != none; P = P.NextPawn)
				if (P.bIsPlayer &&
					!P.bDeleteMe &&
					P.Health > 0 &&
					LineOfSightTo(P))
				{
					Enemy = P;
					Target = Enemy;
					return;
				}
		}
		GotoState('Idle');
	}
}

function B227_ModifyProjectileDamage(Projectile Proj)
{
	Proj.Damage *= 0.4 + 0.3 * Level.Game.Difficulty;
}

defaultproperties
{
     DeActivateSound=Sound'UnrealI.Cannon.CannonExplode'
}
