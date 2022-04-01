class KKMinigunCannon extends MinigunCannon;

function TakeDamage (int NDamage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
	MakeNoise(1.00);
	Health -= NDamage;
	if ( Health < 0 )
	{
		PlaySound(ActivateSound, SLOT_None,5.0);
		ExplodeFragments(Class'Fragment1',Texture'JCannon1',Momentum,1.00,17);
		Spawn(Class'UT_SpriteBallExplosion');
		Destroy();
	}
	else
	{
		if ( instigatedBy == None )
		{
			return;
		}
		else
		{
			if ( Enemy == None )
			{
				Enemy=instigatedBy;
				GotoState('ActiveCannon');
			}
		}
	}
}

function ExplodeFragments(Class<Fragment> FragType, Texture FragSkin, Vector Momentum, float DSize, int NumFrags)
{
	local int i;
	local Fragment S;

	for(i=0; i < NumFrags; i++ )
	{
		S=Spawn(FragType,Owner);
		S.CalcVelocity(Momentum / 100,0.00);
		S.Skin=FragSkin;
		S.DrawScale=DSize * 0.50 + 0.70 * DSize * FRand();
	}
}

defaultproperties
{
     DeActivateSound=Sound'UnrealI.Cannon.CannonExplode'
}
