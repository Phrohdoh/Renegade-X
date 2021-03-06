class Rx_DmgType_SniperRifle extends Rx_DmgType;

DefaultProperties
{
    KillStatsName=KILLS_SNIPERRIFLE
    DeathStatsName=DEATHS_SNIPERRIFLE
    SuicideStatsName=SUICIDES_SNIPERRIFLE

//  DamageWeaponClass=class'Rx_Weapon_SniperRifle'
    VehicleDamageScaling=0.01f
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1
    bBulletHit=True

    bNeverGibs=true
    bCausesBloodSplatterDecals=false
    lightArmorDmgScaling=0.3		// 0.428
    BuildingDamageScaling=0.009
	MineDamageScaling=1.0
	
	KDamageImpulse=6000
	KDeathUpKick=200

	IconTextureName="T_WeaponIcon_SniperRifle"
}