//=============================================================================
// INFIL_UTM2_50.
//
// written by N.Bogenrieder (aka Beppo)
//=============================================================================
class INFIL_UTM2_50 expands INFUT_ADD_Turret;

#exec OBJ LOAD FILE="InfAddsResources.u" PACKAGE=InfAdds

// Sounds.

// Icons.


// FiringRate = RPM transformed in time between each shot
// ie. 1 / (500 / 60) = 1 / 500 * 60 = 0.12

defaultproperties
{
     AmmoBeltConnClass=Class'InfAdds.INFUT_ADD_50Spoon'
     AmmoShellCaseClass=Class'InfAdds.INFUT_ADD_50Shell'
     EjectBeltConnOffset=(X=-3.000000,Z=1.800000)
     EjectShellCaseOffset=(X=-12.000000,Z=-4.000000)
     FireProjectileOffset=(X=64.000000)
     ProjectileClass=Class'InfAdds.INFUT_ADD_BallisticProjM250'
     ProjectileClassHidden=Class'InfAdds.INFUT_ADD_BallisticHiddenM250'
     DetFragmentTexture=Texture'InfAdds.Skins.Jm2_501'
     FiringRate=0.120000
     ActivateMessage="You control the M2HB !"
     NoAmmoMessage="The M2HB has run out of ammo !"
     TurretWeaponClass=Class'InfAdds.INFUT_ADD_TurretWeaponM250'
     Sound_Activate=Sound'InfAdds.M250.M250Activate'
     Sound_EmptyClip=Sound'InfAdds.M250.M250Empty'
     Sound_Firing=Sound'InfAdds.M250.M250Fire'
     MuzzleEffectClass=Class'InfAdds.INFUT_ADD_CannonMuzzleM250'
     MuzzleOffset=(X=48.000000)
     Mesh=LodMesh'InfAdds.INFIL_UTM2_50'
     DrawScale=2.000000
     CollisionRadius=40.000000
     CollisionHeight=16.000000
}
