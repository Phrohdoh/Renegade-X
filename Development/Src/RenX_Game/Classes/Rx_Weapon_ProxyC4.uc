class Rx_Weapon_ProxyC4 extends Rx_Weapon_Deployable;

simulated function WeaponEmpty()
{
	if(AmmoCount <= 0) {
		Rx_InventoryManager(Instigator.InvManager).RemoveWeaponOfClass(self.Class);
// 		if (Rx_Controller(Instigator.Controller).PreviousExplosiveTransactionRecords.Find(self.Class) > -1) {
// 			Rx_Controller(Instigator.Controller).PreviousExplosiveTransactionRecords.RemoveItem(self.Class);
// 		}
		Rx_Controller(Instigator.Controller).CurrentExplosiveWeapon = none;
	} 
	super.WeaponEmpty();
}
function bool Deploy()
{
	if(super(Rx_Weapon_Deployable).Deploy()) {
		destroyOldMinesIfMinelimitReached();
		Rx_TeamInfo(Rx_Game(WorldInfo.Game).Teams[Instigator.GetTeamNum()]).mineCount++;
		return true;
	}
	return false;
}

DefaultProperties
{
	DeployedActorClass=class'Rx_Weapon_DeployedProxyC4'

	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'rx_wp_proxyc4.Mesh.SK_WP_ProxyC4_1P'
		AnimSets(0)=AnimSet'rx_wp_proxyc4.Anims.AS_WP_ProxyC4_1P'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=50.0
	End Object
	
	ArmsAnimSet = AnimSet'rx_wp_proxyc4.Anims.AS_WP_ProxyC4_Arms'

	AttachmentClass = class'Rx_Attachment_ProxyC4'
	
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_ProxyC4'
	
	PlayerViewOffset=(X=10.0,Y=0.0,Z=-2.5)
	FireOffset=(X=25,Y=0,Z=-5)
	
	//-------------- Recoil
	RecoilDelay = 0.07
	RecoilSpreadDecreaseDelay = 0.1
	MinRecoil = -100.0
	MaxRecoil = -50.0
	MaxTotalRecoil = 1000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 10.0
	RecoilDeclinePct = 0.5
	RecoilDeclineSpeed = 2.0
	RecoilSpread = 0.0
	MaxSpread = 0.0
	RecoilSpreadIncreasePerShot = 0.015
	RecoilSpreadDeclineSpeed = 0.25

	ShotCost(0)=1
	ShotCost(1)=0
	FireInterval(0)=+1.0
	FireInterval(1)=+0.0
	ReloadTime(0)=1.0
	ReloadTime(1)=0.0
	
	EquipTime=1.0
//	PutDownTime=0.5

	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_None

    Spread(0)=0.0
	Spread(1)=0.0
	
	ClipSize = 1
	InitalNumClips = 6
	MaxClips = 6
	
	//AmmoCount=6
	//MaxAmmoCount=6
	
	ThirdPersonWeaponPutDownAnim="H_M_C4_PutDown"
	ThirdPersonWeaponEquipAnim="H_M_C4_Equip"

	ReloadAnimName(0) = "weaponequip"
	ReloadAnimName(1) = "weaponequip"
	ReloadAnim3PName(0) = "H_M_C4_Equip"
	ReloadAnim3PName(1) = "H_M_C4_Equip"
	ReloadArmAnimName(0) = "weaponequip"
	ReloadArmAnimName(1) = "weaponequip"

	WeaponFireSnd[0]=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Fire'
	WeaponFireSnd[1]=None

	WeaponPutDownSnd=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Equip'
	ReloadSound(0)=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Equip'
	ReloadSound(1)=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Equip'

	PickupSound=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Equip'
 
	MuzzleFlashSocket=MuzzleFlashSocket
	FireSocket=MuzzleFlashSocket

	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_AutoRifle'

	InventoryGroup=5
	GroupWeight=1
	InventoryMovieGroup=25
	
	// AI Hints:
	//MaxDesireability=0.7
	AIRating=+0.3
	CurrentRating=+0.3
	bFastRepeater=false
	bInstantHit=false
	bSplashJump=false
	bRecommendSplashDamage=true
	bSniping=false
}
