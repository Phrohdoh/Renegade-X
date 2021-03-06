/*********************************************************
*
* File: Rx_Defence_AATower_Weapon.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class Rx_Defence_AATower_Weapon extends Rx_Vehicle_Weapon_Reloadable;


var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)


simulated function FireAmmunition()
{
    Super.FireAmmunition();
	WeaponPlaySound( WeaponDistantFireSnd );
}


/*********************************************************************************************
 * HUD and misc
 *********************************************************************************************/

simulated function GetFireStartLocationAndRotation(out vector SocketLocation, out rotator SocketRotation) {
    
    super.GetFireStartLocationAndRotation(SocketLocation, SocketRotation);    
    
    if( (Rx_Bot(MyVehicle.Controller) != None) && (Rx_Bot(MyVehicle.Controller).GetFocus() != None) ) {
        if(class'Rx_Utils'.static.OrientationOfLocAndRotToB(SocketLocation,SocketRotation,Rx_Bot(MyVehicle.Controller).GetFocus()) > 0.3) {
            MaxFinalAimAdjustment = 0.970;
        } else {
            MaxFinalAimAdjustment = 0.990;
        }
    }
}

simulated function bool UsesClientSideProjectiles(byte FireMode)
{
	return false;
}

DefaultProperties
{
    InventoryGroup=16
    
    SecondaryLockingDisabled=false

    // reload config
    ClipSize = 2
    InitalNumClips = 999
    MaxClips = 999
    
    ShotCost(0)=1
    ShotCost(1)=1
    
    ReloadTime(0) = 4.0
    ReloadTime(1) = 4.0
    
    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"
    
    // gun config
    FireTriggerTags(0)="TurretFireL"
    FireTriggerTags(1)="TurretFireR"
    
    AltFireTriggerTags(0)="TurretFireL"
    AltFireTriggerTags(1)="TurretFireR"

    
    VehicleClass=Class'RenX_Game.Rx_Defence_AATower'
    
    FireInterval(0)=0.20
    FireInterval(1)=0.20
    
    Spread(0)=0.05
    Spread(1)=0.05
     
    WeaponFireSnd(0)     = SoundCue'RX_VH_MRLS.Sounds.MRLS_FireCue'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Defence_AATower_Projectile'

    WeaponFireSnd(1)     = SoundCue'RX_VH_MRLS.Sounds.MRLS_FireCue'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Defence_AATower_Projectile'
	
	ReloadSound(0)=SoundCue'RX_VH_Apache.Sounds.SC_Reload_Missiles'
    ReloadSound(1)=SoundCue'RX_VH_Apache.Sounds.SC_Reload_Missiles'
	
	WeaponDistantFireSnd=SoundCue'RX_SoundEffects.Missiles.SC_Missile_DistantFire'
    
    CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5'
    
    // AI
    bRecommendSplashDamage=True

    //==========================================
    //LOCKING PROPERTIES
    //==========================================
    LockAcquiredSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLock_Cue'
    LockLostSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLost_Cue'

    LockTolerance=2.0

    LockRange            = 80000 //2360
    ConsoleLockAim       = 0.992000
    LockAim              = 0.997000
    LockCheckTime        = 0.1
    LockAcquireTime      = 0.2 // change this!!!!!!!!!
    StayLocked           = 0.1 // change this, too

    bTargetLockingActive = true;
}