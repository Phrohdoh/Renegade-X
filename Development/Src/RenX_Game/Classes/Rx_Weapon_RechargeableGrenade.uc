class Rx_Weapon_RechargeableGrenade extends Rx_Weapon_Reloadable;

var() name WeaponThrowGrenadeAnimName[4];

var array<float> DelayFireTime; 

simulated state Active
{
// 	simulated event BeginState( Name PreviousStateName )
// 	{
// 		if (AmmoCount <= 0){			
// 			`log("#### Current Weapon is none");
// 			Rx_Controller(Instigator.Controller).CurrentExplosiveWeapon = none;
// 		}
// 		super.BeginState(PreviousStateName);
// 	}


/*There were small instances (mostly with bots) where the Reload timer would be called in the 'active' state. So added logic here.*/


}




/*********************************************************************************************
 * state Inactive
 * This state is the default state.  It needs to make sure Zooming is reset when entering/leaving
 *Edited to include what to do if the weapon finishes reloading while not in the owner's hand
 *********************************************************************************************/

auto simulated state Inactive
{
	simulated function BeginState(name PreviousStateName)
	{
		local PlayerController PC;

		if ( Instigator != None )
		{
		  PC = PlayerController(Instigator.Controller);
		  if ( PC != None && LocalPlayer(PC.Player)!= none )
		  {
			  PC.SetFOV(PC.DefaultFOV);
		  }
		}

		//If weapons were changed quickly, see if reloading had begun. If not, start it.
		if(!IsTimerActive('ReloadWeaponTimer') && CurrentAmmoInClip <= 0)
		{	
			reloadBeginTime = WorldInfo.TimeSeconds;
			currentReloadTime = ReloadTime[CurrentFireMode];
			SetTimer( ReloadTime[CurrentFireMode], false, 'ReloadWeaponTimer');
			CurrentlyReloading=true; 
			if(bDebugWeapon) 
			{
			`log("Set Reload Weapon Timer(Begin State): " @ ReloadTime[CurrentFireMode]); 	
			}
		}
		//SetTimer( 1.0f, false, 'DoubleCheckReloadTimer'); //sets a timer to make sure lag did not screw up the weapon going into reload status
		
		Super.BeginState(PreviousStateName);
	}

	
	
	/**
	 * @returns false if the weapon isn't ready to be fired.  For example, if it's in the Inactive/WeaponPuttingDown states.
	 */
	simulated function bool bReadyToFire()
	{
		return false;
	}
}


simulated state WeaponFiring
{
	simulated event bool IsFiring()
	{
		return true;
	}

	simulated function RefireCheckTimer()
	{
		// if switching to another weapon, abort firing and put down right away
		if( bWeaponPutDown )
		{
			PutDownWeapon();
			return;
		}

		// If weapon should keep on firing, then do not leave state and fire again.
		if( ShouldRefire() )
		{
			// Hamad: If we have delay, refire according to our delay logic
			if (DelayFireTime[CurrentFireMode] > 0) 
			{
				ClearTimer('DelayFire');
				PlayFireEffects( CurrentFireMode );
			}
			else
				FireAmmunition(); // Else, follow the default implementation

			return;
		}

		// Otherwise we're done firing
		HandleFinishedFiring();
	}

	simulated event BeginState( Name PreviousStateName )
	{

		// If we don't have delays, resume with default implementation
		if (DelayFireTime[CurrentFireMode] <= 0) 
		{
			FireAmmunition();
			TimeWeaponFiring( CurrentFireMode );
		}
		else
			PlayFireEffects( CurrentFireMode ); //Otherwise, use ours

	}

	simulated event EndState( Name NextStateName )
	{
		if(bDebugWeapon)
		{
			`log("End" @ GetStateName() @ "To" @ NextStateName); 
		}
		
		`LogInv("NextStateName:" @ NextStateName);
		// Set weapon as not firing
		ClearFlashCount();
		ClearFlashLocation();
		ClearTimer('RefireCheckTimer');

		NotifyWeaponFinishedFiring( CurrentFireMode );
	}
}



/***********************************************
*Primary Difference for rechargable grenade
*Ignore clearing of the reload timer when switching weapons
*Just keep reloading in the background
************************************************/

state Reloading
{
	function BeginState( name PreviousState )
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".BeginState("$PreviousState$")");
		}

		if (PerBulletReload )
		{
			CurrentReloadState = 2;
			if(!IsTimerActive('PerBulletReloadWeaponTimer')) SetTimer( ReloadTime[CurrentReloadState], false, 'PerBulletReloadWeaponTimer');
		}
		else
		{
		if(!IsTimerActive('ReloadWeaponTimer'))
		{	reloadBeginTime = WorldInfo.TimeSeconds;
			currentReloadTime = ReloadTime[CurrentFireMode];
			SetTimer( ReloadTime[CurrentFireMode], false, 'ReloadWeaponTimer');
			if(bDebugWeapon) 
			{
			`log("Set Reload Weapon Timer(Begin Reload): " @ ReloadTime[CurrentFireMode]); 	
			}
		}
		}

		if(bIronsightActivated)
		{
			if(WorldInfo.Netmode != NM_DedicatedServer)
			{
				if(UTPlayerController(Instigator.Controller) != None)
				{
					EndZoom(UTPlayerController(Instigator.Controller));
				}
			}
		} 
		CurrentlyReloading = true;
		bForceHidden = true;
		Mesh.SetHidden(true);
		ChangeVisibility(false);
			if(WorldInfo.Netmode != NM_DedicatedServer && Rx_Pawn(Owner).isFirstPerson() )
		{
		Rx_Pawn(Owner).CurrentWeaponAttachment.ChangeVisibility(true);
		Rx_Pawn(Owner).SetHandIKEnabled(true);
		Rx_Pawn(Owner).ArmsMesh[0].SetHidden(false);
		}
		
	}

	function EndState( name NextState )
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".EndState("$NextState$")");
		}
		Rx_Pawn(Owner).SetHandIKEnabled(true);
		Rx_Pawn(Owner).ReloadAnim = '';
			}


	function ReloadWeaponTimer()
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".ReloadWeapon()");
		}

		if (bHasInfiniteAmmo) 
		{
			AmmoCount = MaxAmmoCount;
			CurrentAmmoInClip = default.ClipSize;
		}
		else if( AmmoCount >= default.ClipSize )
		{
			CurrentAmmoInClip = default.ClipSize;
		}
		else
		{
			CurrentAmmoInClip = AmmoCount;
		}

		CurrentlyReloading = false;
		bForceHidden = false; //If it's still hidden
		Mesh.SetHidden(false);
		if(WorldInfo.Netmode != NM_DedicatedServer && Rx_Pawn(Owner).isFirstPerson() )
		{
		Rx_Pawn(Owner).CurrentWeaponAttachment.ChangeVisibility(true);
		Rx_Pawn(Owner).SetHandIKEnabled(true);
		Rx_Pawn(Owner).ArmsMesh[0].SetHidden(false);
		}
		
		
		//SetupArmsAnim();
		PostReloadUpdate();

		/**if((PendingFire(0) && CurrentFireMode == 0) || (PendingFire(1) && CurrentFireMode == 1) ) 
		{
			RestartWeaponFiringAfterReload();	
		}
		else*/
		
			GotoState('Active');
		
	}

	simulated function bool bReadyToFire()
	{
		return false;
	}

	// Undo reload
	simulated function PutDownWeapon() 
	{
		
		super(Rx_Weapon).PutDownWeapon();
	}
	
	simulated event bool IsFiring()
	{
		return true;
	}
}

//Did not add support to allow this behaviour with bolt action reloading. 



simulated function TimeWeaponFiring( byte FireModeNum )
{
	// if weapon is not firing, then start timer. Firing state is responsible to stopping the timer.
	if( !IsTimerActive('RefireCheckTimer') )
	{
		SetTimer( GetFireInterval(FireModeNum) , true, nameof(RefireCheckTimer) );
	}
}

// Hamad: This is the delay timer function. It'll fire the default implementation and clear itself.
simulated function DelayFire()
{
	FireAmmunition();
	TimeWeaponFiring( CurrentFireMode );
	ClearTimer('DelayFire');
}


// Hamad: Play the animation and activate the delay timer if we are in delay mode
simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	if (DelayFireTime[FireModeNum] > 0) // Do we have delay?
	{
		if( !IsTimerActive('DelayFire') ) 
		{
			if(Rx_Pawn(Owner) != None)
			{
				Rx_Pawn(Owner).TopHalfAnimSlot.PlayCustomAnim(WeaponThrowGrenadeAnimName[CurrentReloadState], 1.0, 0.25, 0.25, false, true);
			}

			SetTimer( DelayFireTime[FireModeNum] , true, 'DelayFire' );
			super.PlayFireEffects(FireModeNum, HitLocation);
		}

	}
	else
	{
		// No delay. Resume default implementation.
		super.PlayFireEffects(FireModeNum, HitLocation);
	}

}

function ReloadWeaponTimer() /*One more for out of state*/
	{

	if(bDebugWeapon) 
	{
		`log("------Called ReloadWeaponTimer() out of Reload State----" @ GetStateName()); 
	}
	
		if (bHasInfiniteAmmo) 
		{
			AmmoCount = MaxAmmoCount;
			CurrentAmmoInClip = default.ClipSize;
		}
		else if( AmmoCount >= default.ClipSize )
		{
			CurrentAmmoInClip = default.ClipSize;
		}
		else
		{
			CurrentAmmoInClip = AmmoCount;
		}
		
	
		CurrentlyReloading = false;
		bForceHidden = false; //If it's still hidden
		Mesh.SetHidden(false);
		
		PostReloadUpdate();
	}

simulated function PlayWeaponReloadAnim() 
{} //Do not play reloading animations... as they are utterly creepy in slow motion

simulated function DrawCrosshair( Hud HUD )
{
	local float x,y;
	local UTHUDBase H;
	local Pawn MyPawnOwner;
	local actor TargetActor;
	local int targetTeam, rectColor;
	local int MineNum, MaxMineNum;
	local color TempColor;
	local float MineTextL, MineTextH, MineEmphasisScale;
	
	// rectColor is an integer representing what we will pass to the texture's parameter(ReticleColourSwitcher):
	// 0=Default, 1=Red, 2=Green, 3=Yellow
	rectColor = 0;	
	
	H = UTHUDBase(HUD);
	if ( H == None )
		return;
	
	
	MineNum=Rx_HUD(H).HudMovie.CurrentNumMines;
	MaxMineNum=Rx_HUD(H).HudMovie.CurrentMaxMines;
	
	CrosshairWidth = default.CrosshairWidth + RecoilSpread*RecoilSpreadCrosshairScaling;	
	CrosshairHeight = default.CrosshairHeight + RecoilSpread*RecoilSpreadCrosshairScaling;
		
	CrosshairLinesX = H.Canvas.ClipX * 0.5 - (CrosshairWidth * 0.5);
	CrosshairLinesY = H.Canvas.ClipY * 0.5 - (CrosshairHeight * 0.5);	
	
	MyPawnOwner = Pawn(Owner);

	//determines what we are looking at and what color we should use based on that.
	if (MyPawnOwner != None)
	{
		TargetActor = Rx_Hud(HUD).GetActorWeaponIsAimingAt();
		if (Pawn(TargetActor) == None && Rx_Weapon_DeployedActor(TargetActor) == None && 
			Rx_Building(TargetActor) == None && Rx_BuildingAttachment(TargetActor) == None)
		{
			TargetActor = (TargetActor == None) ? None : Pawn(TargetActor.Base);
		}
		
		if(TargetActor != None)
		{
			targetTeam = TargetActor.GetTeamNum();
			
			if (targetTeam == 0 || targetTeam == 1) //has to be gdi or nod player
			{
				if (targetTeam != MyPawnOwner.GetTeamNum())
				{
					if (!TargetActor.IsInState('Stealthed') && !TargetActor.IsInState('BeenShot'))
						rectColor = 1; //enemy, go red, except if stealthed (else would be cheating ;] )
				}
				else
					rectColor = 2; //Friendly
			}
		}
	}
	
	if (!HasAnyAmmo()) //no ammo, go yellow
		rectColor = 3;
	else
	{
		if (CurrentlyReloading || CurrentlyBoltReloading || BoltActionReload && HasAmmo(CurrentFireMode) && IsTimerActive('BoltActionReloadTimer')) //reloading, go yellow
			rectColor = 3;
	}

	CrosshairMIC2. SetScalarParameterValue('ReticleColourSwitcher', rectColor);
	CrosshairDotMIC2. SetScalarParameterValue('ReticleColourSwitcher', rectColor);
	
	H.Canvas.SetPos( CrosshairLinesX, CrosshairLinesY );
	if(bDisplayCrosshair) {
		H.Canvas.DrawMaterialTile(CrosshairMIC2, CrosshairWidth, CrosshairHeight);
	}

	CrosshairLinesX = H.Canvas.ClipX * 0.5 - (default.CrosshairWidth * 0.5);
	CrosshairLinesY = H.Canvas.ClipY * 0.5 - (default.CrosshairHeight * 0.5);
	GetCrosshairDotLoc(x, y, H);
	H.Canvas.SetPos( X, Y );
	if(bDisplayCrosshair) {
		H.Canvas.DrawMaterialTile(CrosshairDotMIC2, default.CrosshairWidth, default.CrosshairHeight);
		
		//Draw Mine Limit
		H.Canvas.Font=Font'RenXTargetSystem.T_TargetSystemPercentage';
		H.Canvas.StrLen("Mines: " $ MineNum $ "/" $ MaxMineNum, MineTextL,MineTextH)	; //I wasn't going to center it.. but baah, I'm going to center it. 
		
		TempColor=H.Canvas.DrawColor;
		if(float(MineNum)/float(MaxMineNum) < 0.5) 
		{
			H.Canvas.SetDrawColor(0,255,0,255); //Green
			MineEmphasisScale=1;
		}
		if(float(MineNum)/float(MaxMineNum) >= 0.5) 
		{
			H.Canvas.SetDrawColor(255,255,0,255); //Yeller
			MineEmphasisScale=1.2;
		}
		
		if(float(MineNum/MaxMineNum) >= 0.90)
		{
			H.Canvas.SetDrawColor(255,0,0,255); //Red
			MineEmphasisScale=1.4;
		}
		
		H.Canvas.SetPos(
		X+(default.CrosshairWidth/2)-(MineTextL*MineEmphasisScale)/2,
		Y+default.CrosshairHeight/5);
		
		
		if(bDebugWeapon)
		{
		H.Canvas.DrawText( (GetTimerRate('ReloadWeaponTimer') - GetTimerCount('ReloadWeaponTimer')) ,true,1,1);
		H.Canvas.DrawColor=TempColor;
		}
	}
	DrawHitIndicator(H,x,y);
}

function DoubleCheckReloadTimer()

{
	if(!IsTimerActive('ReloadWeaponTimer') && CurrentAmmoInClip <= 0 )
		{	reloadBeginTime = WorldInfo.TimeSeconds;
			currentReloadTime = ReloadTime[CurrentFireMode];
			SetTimer( ReloadTime[CurrentFireMode], false, 'ReloadWeaponTimer');
			CurrentlyReloading = true;
			bForceHidden = true;
			Mesh.SetHidden(true);
			ChangeVisibility(false);
		}
}

simulated function RestartWeaponFiringAfterReload(); //Force the individual to click at the right time.

DefaultProperties
{
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Grenade.Mesh.SK_Grenade_1P'
		AnimSets(0)=AnimSet'RX_WP_Grenade.Anims.AS_Grenade_1P'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=55.0
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Grenade.Mesh.SK_Grenade_1P'
		Scale=2.5
	End Object
	
	ArmsAnimSet = AnimSet'RX_WP_Grenade.Anims.AS_Grenade_Arms'

	AttachmentClass = class'Rx_Attachment_Grenade'
	
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_Greande'
	
	PlayerViewOffset=(X=0.0,Y=0.0,Z=0.0)
	
	FireOffset=(X=0,Y=10,Z=0)
	
	//-------------- Recoil
	RecoilDelay = 0.0
	MinRecoil = 0.0
	MaxRecoil = 0.0
	MaxTotalRecoil = 0.0
	RecoilYawModifier = 0.0 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 0.0
	RecoilDeclinePct = 0.0
	RecoilDeclineSpeed = 0.0
	MaxSpread = 0.0
	RecoilSpreadIncreasePerShot = 0.0
	RecoilSpreadDeclineSpeed = 0.0
	RecoilSpreadDecreaseDelay = 0.0
	RecoilSpreadCrosshairScaling = 10000;

	ShotCost(0)=1
	ShotCost(1)=1
	FireInterval(0)=+0.75
	FireInterval(1)=+0.75
	ReloadTime(0) = 10.0 //These should be pretty long 
	ReloadTime(1) = 10.0 //These should be pretty long
	DelayFireTime(0) = 0.54375;
	DelayFireTime(1) = 0.54375;
	bHasInfiniteAmmo=true //Should Always be true. 
	
	
	EquipTime=0.6
//	PutDownTime=0.35
	
	WeaponRange=2800.0

    LockerRotation=(pitch=0,yaw=0,roll=-16384)

	WeaponFireTypes(0)=EWFT_Projectile
    WeaponFireTypes(1)=EWFT_Projectile
    
    WeaponProjectiles(0)=class'Rx_Projectile_Grenade'
    WeaponProjectiles(1)=class'Rx_Projectile_Grenade_Alt'

    Spread(0)=0.0
    Spread(1)=0.0
	
	ClipSize = 1
	InitalNumClips = 3
	MaxClips = 3

//	AmmoCount=2
//	LockerAmmoCount=2
//	MaxAmmoCount=2

	ThirdPersonWeaponPutDownAnim="H_M_C4_PutDown"
	ThirdPersonWeaponEquipAnim="H_M_C4_Equip"

	ReloadAnimName(0) = "weaponequip"
	ReloadAnimName(1) = "weaponequip"
	ReloadAnim3PName(0) = "H_M_C4_Equip"
	ReloadAnim3PName(1) = "H_M_C4_Equip"
	ReloadArmAnimName(0) = "weaponequip"
	ReloadArmAnimName(1) = "weaponequip"

	WeaponThrowGrenadeAnimName(0) = "H_M_Grenade_Toss"
	WeaponThrowGrenadeAnimName(1) = "H_M_Grenade_Toss"

	WeaponFireSnd[0]=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Throw'
	WeaponFireSnd[1]=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Throw'

	WeaponPutDownSnd=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Equip'
	ReloadSound(0)=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Equip'
	ReloadSound(1)=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Equip'

	PickupSound=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Equip'

	FireSocket="MuzzleFlashSocket"

	MuzzleFlashSocket="MuzzleFlashSocket"
	MuzzleFlashPSCTemplate=none
	MuzzleFlashDuration=3.3667
	MuzzleFlashLightClass=none

    CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_GrenadeLauncher'
	CrosshairDotMIC = MaterialInstanceConstant'RenX_AssetBase.Null_Material.MI_Null_Glass' // MaterialInstanceConstant'RenXHud.MI_Reticle_Dot'
	
	CrosshairWidth = 256
	CrosshairHeight = 256

	InventoryGroup=5
	InventoryMovieGroup=27
	
	bDebugWeapon=false
	
	WeaponIconTexture=Texture2D'RX_WP_Grenade.UI.T_WeaponIcon_Grenade'
	
	// AI Hints:
	// MaxDesireability=0.3
	AIRating=+0.3
    CurrentRating=+0.3
    bFastRepeater=false
    bInstantHit=false
    bSplashJump=false
    bRecommendSplashDamage=true
    bSniping=false   	
	
	// IronSight:
	bIronSightCapable = false	
	IronSightViewOffset=(X=-5,Y=-4.5,Z=2.85)
	IronSightBobDamping=6
	IronSightPostAnimDurationModifier=0.2
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=35.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=180.0
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=11
}
