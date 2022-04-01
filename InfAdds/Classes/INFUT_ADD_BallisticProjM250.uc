//=============================================================================
// INFUT_ADD_BallisticProjM250.
// Ballistic version of the UT_Tracer for the M16
//
// written by N.Bogenrieder (aka Beppo)
//=============================================================================
class INFUT_ADD_BallisticProjM250 expands INFUT_ADD_BallisticProj;

defaultproperties
{
     MaxRange=32400.000000
     EffectiveRange=19800.000000
     BulletWeight=1.900000
     Damage=50.000000
     WallHitEffectClass=Class'Botpack.UT_HeavyWallHitEffect'
     speed=51231.000000
}
