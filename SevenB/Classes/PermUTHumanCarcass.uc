// ===============================================================
// SevenB.PermUTHumanCarcass: perminent carcasses for human (U1 and UT models)
// ===============================================================

class PermUTHumanCarcass extends olCreatureCarcass;
var class<UTHumanCarcass> realUTcarcass;
var bool bFullyDead;    //unreal female 1
var float LastHit; //for ut players
var bool bJerking;
var name Jerks[4];

function Initfor(actor Other)
{
	PermaCarcass=class'olcreaturecarcass'.default.PermaCarcass;  //should have been globalconfig.
	if (classischildof(scriptedpawn(other).default.carcasstype,class'UTHumanCarcass')) //UT carcass
		PrePivot = vect(0,0,3);
	super.Initfor(Other);

	if (ScriptedPawn(Other) != none)
		realUTcarcass = class<UTHumanCarcass>(ScriptedPawn(Other).default.CarcassType); //use default!
	if (realUTcarcass != none)
	{
		bGreenBlood = realUTcarcass.default.bGreenBlood; //copy.
		bPermanent = realUTcarcass.default.bPermanent;
		LifeSpan = realUTcarcass.default.LifeSpan;
	}
}

function GibSound()    //statics.
{
  local int r;
	if (realUTcarcass!=none){ //UT carcass
	  r = Rand(4);
  	PlaySound(realUTcarcass.default.GibSounds[r], SLOT_Interact, 16);
	  PlaySound(realUTcarcass.default.GibSounds[r], SLOT_Misc, 12);
	}
	else
		Super.GibSound();
}

function ReduceCylinder() //different prepivots:
{
	super.ReduceCylinder();
	if (realUTcarcass!=none)
		Prepivot = Prepivot + vect(0,0,1);
	else
		PrePivot = PrePivot - vect(0,0,2);
}

//note: this always uses UT chunks and lacks perminant support for all but 1 chunk
function CreateReplacement()
{
	local class<UTMasterCreatureChunk> MasterReplacement;
  local UTMasterCreatureChunk carc;
  local UT_BloodBurst b;

  if (bHidden)
    return;

  b = Spawn(class'UT_BigBloodHit',,,Location, rot(-16384,0,0));   //why not?
  if ( bGreenBlood )
    b.GreenBlood();
  if (RealUTCarcass!=none)
		MasterReplacement = realUTcarcass.default.MasterReplacement;
	else{ //select UT version of unreal carcasses (for blood decals)
		if (class<HumanCarcass>(RealCarcass).default.MasterReplacement==class'MaleMasterChunk')
			MasterReplacement=class'TMaleMasterChunk';
		else //use female
			MasterReplacement=class'TFemaleMasterChunk';
	}
  carc = Spawn(MasterReplacement,,, Location + CollisionHeight * vect(0,0,0.5));
  if (carc != None)
  {
    if (PermaCarcass)
    	carc.Disable('timer'); //make 1 chunk perminant
		carc.PlayerRep = PlayerOwner;
    carc.Initfor(self);
    carc.Bugs = Bugs;
    if ( Bugs != None )
      Bugs.SetBase(carc);
    Bugs = None;
  }
  else if ( Bugs != None )
    Bugs.Destroy();
}

//other stuff
function Convulse() //female 1 notifies
{
	PlaySound(sound'ConvulseFem',SLOT_Interact);
}

//female 1 convulsing stuff:

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation,
						Vector Momentum, name DamageType)
{
	if ( bJerking || (AnimSequence == 'Dead9') )
  {
    bJerking = true;
    if ( Damage < 23 )
      LastHit = Level.TimeSeconds;
    else
      bJerking = false;
  }
	if (!bFullyDead )
	{
		if (realcarcass!=none && classischildof(realcarcass,class'FemaleBody') && GetAnimGroup(AnimSequence) != 'Dead1' )
			bFullyDead = true;
		else if ( !IsAnimating() )
		{
			if ( FRand() < 0.5 )
				PlayAnim('Dead1A');
			else
				PlayAnim('Dead1B');
			bFullyDead = (FRand() < 0.5);
		}
	}

	Super(CreatureCarcass).TakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);

  if ( bJerking )
  {
    CumulativeDamage = 50;
    Velocity.Z = FMax(Velocity.Z, 40);
    if ( InstigatedBy == None )
    {
      bJerking = false;
      PlayAnim('Dead9B', 1.1, 0.1);
    }
  }
  if ( bJerking && (VSize(InstigatedBy.Location - Location) < 150)
    && (InstigatedBy.Acceleration != vect(0,0,0))
    && ((Normal(InstigatedBy.Velocity) Dot Normal(Location - InstigatedBy.Location)) > 0.7) )
  {
    bJerking = false;
    PlayAnim('Dead9B', 1.1, 0.1);
  }

}

function AnimEnd()
{
  local name NewAnim;

  if ( AnimSequence == 'Dead9' )
    bJerking = true;

  if ( !bJerking )
    Super.AnimEnd();
  else if ( (Level.TimeSeconds - LastHit < 0.2) && (FRand() > 0.02) )
  {
    NewAnim = Jerks[Rand(4)];
    if ( NewAnim == AnimSequence )
    {
      if ( NewAnim == Jerks[0] )
        NewAnim = Jerks[1];
      else
        NewAnim = Jerks[0];
    }
    TweenAnim(NewAnim, 0.15);
  }
  else
  {
    bJerking = false;
    PlayAnim('Dead9B', 1.1, 0.1);
  }
}

defaultproperties
{
     Jerks(0)=GutHit
     Jerks(1)=HeadHit
     Jerks(2)=LeftHit
     Jerks(3)=RightHit
}
