// Sea blast - a whole mass of sea - things
// Code by Sergey 'Eater' Levin, 2001

class NCSeaBlast extends NCMagicProj;

state Flying
{
	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
						vector momentum, name damageType ) {
		Explode(Location,Vector(Rotation));
	}

	function ProcessTouch (Actor Other, vector HitLocation)
	{
		If ( (Other!=Instigator) && (NCSeaBlast(Other) == none) ) {
			//DealOutExp(Other);
			//Other.TakeDamage(damage,instigator,hitlocation,vector(rotation*MomentumTransfer),MyDamageType);
			Explode(HitLocation,Normal(HitLocation-Other.Location));
		}
	}

	function Explode(vector HitLocation, vector HitNormal) {
		local vector start;
		local UT_SpriteBallChild E;
		local int i;
		local float f;

		ExpHurtRadius(Damage,Damage*0.75, MyDamageType, MomentumTransfer, HitLocation );
		start = Location + 10 * HitNormal;
 		E = Spawn( class'UT_SpriteBallChild',,,Start);
		E.Texture = Texture'UnrealShare.DispExpl.DSEB_A00';
		while (i < 5) {
			E.SpriteAnim[i] = Texture'UnrealShare.DispExpl.DSEB_A00';
			i++;
		}
		E.DrawScale = 2;
		f = DrawScale;
		while (f > 0) {
			Spawn(class'NCSeaPiece',,,Start);
			f -= 0.5;
		}
		destroy();
	}

	function BeginState()
	{
		Super.BeginState();
		Velocity = vector(Rotation) * speed;
	}

	Begin:
	LifeSpan=Default.LifeSpan;
	//sleep(2.0);
	//setPhysics(PHYS_Falling);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
}

defaultproperties
{
     speed=1500.000000
     Damage=5.000000
     MomentumTransfer=80000
     MyDamageType=Drowned
     ImpactSound=Sound'Botpack.BioRifle.GelHit'
     MiscSound=Sound'UnrealShare.General.Explg02'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=12.000000
     AnimSequence=Flying
     Style=STY_Translucent
     Texture=Texture'UnrealShare.Skin.Jburst1'
     Mesh=LodMesh'Botpack.BioGelm'
     DrawScale=2.000000
     bMeshEnviroMap=True
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     bProjTarget=True
}
