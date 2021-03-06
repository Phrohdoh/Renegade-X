class Rx_FamilyInfo_GDI_Deadeye extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="GDI"
	Faction="GDI"

	DamagePointsMultiplier  = 0.1f
    HealPointsMultiplier    = 0.02f
    PointsForKill           = 0.0f
	MaxHealth               = 200

	CharacterMesh=SkeletalMesh'rx_ch_gdi_deadeye.Mesh.SK_CH_Deadeye'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	/*
	StartWeapons[0] = class'Rx_Weapon_SniperRifle_GDI'
	StartWeapons[1] = class'Rx_Weapon_Pistol'
	StartWeapons[2] = class'Rx_Weapon_TimedC4'
	StartWeapons[3] = class'Rx_Weapon_Grenade'
	*/

	InvManagerClass = class'Rx_InventoryManager_GDI_Deadeye'
}
