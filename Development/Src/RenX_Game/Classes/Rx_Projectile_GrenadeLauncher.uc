class Rx_Projectile_GrenadeLauncher extends Rx_Projectile;

/**
 * Set the initial velocity and cook time
 */
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
//    SetTimer(4.0+FRand()*0.5,false);                  // Grenade begins unarmed
//    RandSpin(100000);
}

function Init(vector Direction)
{
    super.Init(Direction);

    TossZ = TossZ + (FRand() * TossZ / 2.0) - (TossZ / 4.0);
    Velocity.Z += TossZ;
    Acceleration = AccelRate * Normal(Velocity);
}


/**
 * When a grenade enters the water, kill effects/velocity and let it sink
 */
simulated function PhysicsVolumeChange( PhysicsVolume NewVolume )
{
    if ( WaterVolume(NewVolume) != none )
    {
        Velocity *= 0.15;
    }

    Super.PhysicsVolumeChange(NewVolume);
}

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(0.85f);
}


DefaultProperties
{

    ImpactSound=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Bounce'

    ProjFlightTemplate=ParticleSystem'RX_FX_Munitions.Missile.P_GrenadeLauncher'
	AmbientSound=SoundCue'RX_WP_GrenadeLauncher.Sounds.SC_GrenadeLauncher_Ambient'

    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_WhiteSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
	
    DrawScale= 1.0
    
    Physics=PHYS_Falling
	
	CustomGravityScaling=1.5
    
    MyDamageType=class'Rx_DmgType_GrenadeLauncher'
    
    TossZ=100 	// 150.0
    Speed=4000 	// 2000
    MaxSpeed=4000
	TerminalVelocity=4000.0
    AccelRate=0
    LifeSpan=1.0
    Damage=70
    DamageRadius=250
    MomentumTransfer=50000
	HeadShotDamageMult=2.0

    bCollideComplex=true
    bCollideWorld=true
    bBounce=true
    bNetTemporary=false
    bRotationFollowsVelocity=true
    bBlockedByInstigator=true
    bSuppressExplosionFX=false // Do not spawn hit effect in mid air
	bWaitForEffectsAtEndOfLifetime = true
    bWaitForEffects=true
	ExplosionLightClass=Class'RenX_Game.Rx_Light_Tank_Explosion'
}
