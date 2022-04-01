// ===============================================================
// SevenB.SbExplodingWall: spawns perminant fragments.
// also can be used for breakingglass. Just set following properties:
//   GlassParticleSize=0.750000
//   NumGlassChunks=16.000000
//   ExplosionSize=100.000000
//   ExplosionDimensions=90.000000
//   NumWallChunks=0
//   NumWoodChunks=0
//   BreakingSound=Sound'UnrealShare.General.BreakGlass'
// ===============================================================

class SbExplodingWall extends ExplodingWall;

Auto State Exploding
{
	singular function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)         //hack to make work as glass
	{
		local int i;
		local bool bAbort;

		if ( bOnlyTriggerable )
			return;

		if ( DamageType != 'All' && ActivatedBy[0]!='All')  //can accept "all" damage
		{
			bAbort = true;
			for ( i=0; i<5; i++ )
				if (DamageType==ActivatedBy[i]) bAbort=False;
			if ( bAbort )
				return;
		}
		Health -= NDamage;
		if ( Health <= 0 )
			Explode(instigatedBy, Momentum);
	}
	function Explode( pawn EventInstigator, vector Momentum)   //spawns perminent fragments
	{
		local int i;
		local Fragment s;
		local actor A;

		if( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
				A.Trigger( Instigator, Instigator );

		Instigator = EventInstigator;
		if ( Instigator != None )
			MakeNoise(1.0);

		PlaySound(BreakingSound, SLOT_None,2.0);

		for (i=0 ; i<NumWallChunks ; i++)
		{
			s = Spawn( class 'PermWallFragments',,,Location+ExplosionDimensions*VRand());
			if ( s != None )
			{
				s.CalcVelocity(vect(0,0,0),ExplosionSize);
				s.DrawScale = WallParticleSize;
				s.Skin = WallTexture;
			}
		}
		for (i=0 ; i<NumWoodChunks ; i++)
		{
			s = Spawn( class 'PermWoodFragments',,,Location+ExplosionDimensions*VRand());
			if ( s != None )
			{
				s.CalcVelocity(vect(0,0,0),ExplosionSize);
				s.DrawScale = WoodParticleSize;
				s.Skin = WoodTexture;
			}
		}
		for (i=0 ; i<NumGlassChunks ; i++)
		{
			s = Spawn( class 'PermGlassFragments', Owner,,Location+ExplosionDimensions*VRand());
			if ( s != None )
			{
				s.CalcVelocity(Momentum, ExplosionSize);
				s.DrawScale = GlassParticleSize;
				s.Skin = GlassTexture;
				s.bUnlit = bUnlitGlass;
				if (bTranslucentGlass) s.Style = STY_Translucent;
			}
		}
		Destroy();
	}
}

defaultproperties
{
	bCollideWorld=False
}
