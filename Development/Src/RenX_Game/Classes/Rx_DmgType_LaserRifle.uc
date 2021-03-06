class Rx_DmgType_LaserRifle extends Rx_DmgType_Burn;

defaultproperties
{
    KillStatsName=KILLS_LASERRIFLE
    DeathStatsName=DEATHS_LASERRIFLE
    SuicideStatsName=SUICIDES_LASERRIFLE

//    DamageWeaponClass=class'Rx_Weapon_LaserRifle'
    DamageWeaponFireMode=2
    VehicleDamageScaling=0.35
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

    CustomTauntIndex=10
    lightArmorDmgScaling=0.52
    BuildingDamageScaling=0.38
	MineDamageScaling=2.0
	
	BleedDamageFactor=0.2
	BleedCount=5

	IconTextureName="T_WeaponIcon_LaserRifle"
}