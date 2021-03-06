class Rx_FamilyInfo_Nod_StealthBlackHand extends Rx_FamilyInfo;

DefaultProperties
{
	FamilyID="Nod"
	Faction="Nod"

	DamagePointsMultiplier  = 0.12667f
	HealPointsMultiplier    = 0.02533f
	PointsForKill           = 0.0f
	MaxHealth               = 200

	CharacterMesh=SkeletalMesh'RX_CH_Nod_SBH.Mesh.SK_CH_StealthBlackHand'
	
	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_Nod_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	//StartWeapons[0] = class'Rx_Weapon_LaserRifle'	
	//StartWeapons[1] = class'Rx_Weapon_Pistol'
	//StartWeapons[2] = class'Rx_Weapon_TimedC4'
	//StartWeapons[3] = class'Rx_Weapon_Grenade'

	InvManagerClass = class'Rx_InventoryManager_Nod_StealthBlackHand' 
}
