class Rx_Building_Team_Internals extends Rx_Building_Internals;

var int                     Health;             // Current health of the building
var int                     HealthMax;          // Maximum health of the building
var int                     LowHPWarnLevel;     // under this health-lvl lowHP warnings will be send (critical)
var int                     RepairedHPLevel;    // Repaired message will not play if the building didn't fall below this level of health.
var float                   SavedDmg;           // Since infantry weapons will do fractions of damage it is added here and once it is greater than 1 point of damage it is applied to health
var const float             HealPointsScale;    // How many points per healed HP
var const float             DamagePointsScale;  // How many points per damaged HP 

var repnotify bool          bDestroyed;	        // true if Building is destroyed
var protected int           DestroyerID;        // PlayerID of the player destroyed this building
var PlayerReplicationInfo   Destroyer;          // PRI of the destroyer
var name                    DestructionAnimName;
var bool                    bNoPower;

var bool                    bBuildingRecoverable;

var float                   MessageWaitTime;
var float 					LastBuildingRepairedMessageTime;
var bool                    bCanPlayRepaired;
var repnotify int			DamageLodLevel;

var array<Rx_BuildingAttachment_DmgFx> DmgFx_Lvl0, DmgFx_Lvl1, DmgFx_Lvl2, DmgFx_Lvl3, DmgFx_Lvl4, DmgFx_OnlyLvl1, DmgFx_OnlyLvl2, DmgFx_OnlyLvl3;
var bool DmgFx_Lvl0On, DmgFx_Lvl1On, DmgFx_Lvl2On, DmgFx_Lvl3On, DmgFx_Lvl4On, DmgFx_OnlyLvl1On, DmgFx_OnlyLvl2On, DmgFx_OnlyLvl3On;
// Yeah its icky, but blame UScript for not supporting multi-dimension arrays.
var bool bInitialDamageLod;

enum BuildingAlarm
{
	BuildingDestroyed,
	BuildingUnderAttack,
	BuildingDestructionImminent,
	BuildingRepaired,
};

var const SoundNodeWave     FriendlyBuildingSounds[BuildingAlarm.BuildingAlarm_MAX];
var const SoundNodeWave     EnemyBuildingSounds[BuildingAlarm.BuildingAlarm_MAX];

replication
{
	if( bNetInitial && Role == ROLE_Authority )
		HealthMax;
	if( bNetDirty && Role == ROLE_Authority )
		Health, bDestroyed, DamageLodLevel, bNoPower;
}

simulated event ReplicatedEvent( name VarName )
{
	if( VarName == 'bDestroyed' )
	{
		PlayDestructionAnimation();
	}
	else if( VarName == 'DamageLodLevel' )
	{
		ChangeDamageLodLevel(DamageLodLevel);
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated function Init( Rx_Building Visuals, bool isDebug )
{
	// Martin P. (JeepRubi): Bugfix: Only do this on the server, it will be replicated to clients.
	if (Role == ROLE_Authority)
	{
		Health = Visuals.HealthMax;
		HealthMax = Visuals.HealthMax;
	}
	
	if (TeamID == TEAM_UNOWNED)
	{
		loginternal(self.Class@"has team set to TEAM_UNOWNED");
		`Log(self.Class@"has team set to TEAM_UNOWNED",bBuildingDebug,'Buildings');
	}

	super.Init(Visuals,isDebug);
	ChangeDamageLodLevel(DamageLodLevel);
}

simulated function int GetHealth() 
{
	return Health; 
}

simulated function int GetMaxHealth() 
{
	return HealthMax; 
}

simulated function bool IsDestroyed()
{
	return bDestroyed;
}

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser) 
{

	local float CurDmg;
	local int TempDmg;
	local float Scr;
	local int dmgLodLevel;

	if ( GetTeamNum() == EventInstigator.GetTeamNum() || bDestroyed || Role < ROLE_Authority || Health <= 0 || DamageAmount <= 0 )
		return;

	// handle non-dmg
	if (DamageType == None) 
	{
		DamageType = class'DamageType';
	}

	if (EventInstigator != None)
	{
		CurDmg = Float(DamageAmount);
		if (class<Rx_DmgType>(DamageType) != None)
		{
			// calculate saved damg and save it
			CurDmg = Float(DamageAmount) * class<Rx_DmgType>(DamageType).static.BuildingDamageScalingFor();
		 
			DamageAmount *= class<Rx_DmgType>(DamageType).static.BuildingDamageScalingFor();
			
		    if(DamageAmount < CurDmg)
		    {
		    	SavedDmg += CurDmg - Float(DamageAmount);	
		    }
		    
		    if (SavedDmg >= 1)
		    {
		    	DamageAmount += SavedDmg; 
		    	TempDmg = SavedDmg;
		    	SavedDmg -= Float(TempDmg);		   
		    }			
			
		}
		Scr = CurDmg * DamagePointsScale;
		// add score (or sub, if bIsFriendlyFire is on)
		if (GetTeamNum() != EventInstigator.GetTeamNum() && Rx_PRI(EventInstigator.PlayerReplicationInfo) != None)
		{
			Rx_PRI(EventInstigator.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Scr);
		}
	}


	DamageAmount = Max(DamageAmount, 0);
	//bForceNetUpdate = True;

	Health = Max(Health - DamageAmount, 0);

	if (Health <= 0) 
	{
		bDestroyed = True;
		Destroyer = EventInstigator.PlayerReplicationInfo;
		BroadcastLocalizedMessage(MessageClass,BuildingDestroyed,EventInstigator.PlayerReplicationInfo,,self);
		Rx_Game(WorldInfo.Game).LogBuildingDestroyed(Destroyer, self, DamageType);

		PlayDestructionAnimation();
		Rx_Game(WorldInfo.Game).CheckBuildingsDestroyed(Self);
	}
	else if (DamageAmount > 0) 
	{
		TriggerBuildingUnderAttackMessage(EventInstigator);
	}

	if (!bCanPlayRepaired && Health <= RepairedHPLevel)
		bCanPlayRepaired = true;
	
	dmgLodLevel = GetBuildingHealthLod();
	if(dmgLodLevel != DamageLodLevel) {
		DamageLodLevel = dmgLodLevel;
		ChangeDamageLodLevel(dmgLodLevel);
	}

	super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	`log(self.Class@ "taking" @DamageAmount@ "damage."@SavedDmg@"damage saved -" @Health@ "remaining",bBuildingDebug,'Buildings');
}

function TriggerBuildingUnderAttackMessage(Controller EventInstigator)
{
	if( Rx_Game(WorldInfo.Game).CanPlayBuildingUnderAttackMessage(GetTeamNum()) )
	{
		if (Health <= LowHPWarnLevel) 
			BroadcastLocalizedTeamMessage(GetTeamNum(),MessageClass,BuildingDestructionImminent,EventInstigator.PlayerReplicationInfo,,self);
		else
			BroadcastLocalizedMessage(MessageClass,BuildingUnderAttack,EventInstigator.PlayerReplicationInfo,,self);
	}
	Rx_Game(WorldInfo.Game).ResetBuildingUnderAttackEvaTimer(GetTeamNum());
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	local int RealAmount;
	local float Scr;
	local int dmgLodLevel;

	Amount = Amount*2;
	if (Health > 0 && Health < HealthMax && Amount > 0 && Healer != None && Healer.GetTeamNum() == GetTeamNum() )
	{
		RealAmount = Min(Amount, HealthMax - Health);

		if (RealAmount > 0)
		{

			if (Health >= HealthMax && SavedDmg > 0.0f)
			{
				SavedDmg = FMax(0.0f, SavedDmg - Amount);
				Scr = SavedDmg * HealPointsScale;
				Rx_PRI(Healer.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Scr);
			}

			Scr = RealAmount * HealPointsScale;
			Rx_PRI(Healer.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Scr);
		}


		Health = Min(HealthMax, Health + Amount);

		if ( Health >= HealthMax )
		{
			if (RealAmount > 0 && (WorldInfo.TimeSeconds - LastBuildingRepairedMessageTime > 10) && bCanPlayRepaired )
			{
				BroadcastLocalizedTeamMessage(GetTeamNum(),MessageClass,BuildingRepaired,Healer.PlayerReplicationInfo,,self);
				LastBuildingRepairedMessageTime = WorldInfo.TimeSeconds;
			}
			bCanPlayRepaired = false;
		}

		dmgLodLevel = GetBuildingHealthLod();
		if(dmgLodLevel != DamageLodLevel) {
			DamageLodLevel = dmgLodLevel;
			ChangeDamageLodLevel(dmgLodLevel);
		}
		//bForceNetUpdate = True;

		return True;
	}

	return False;
}

function int GetBuildingHealthLod() {
	
	local int perc;
	if(Health <= 0) {
		return 4;
	} else if(health == GetMaxHealth()) {
		return 1;	
	}
	perc = health/(GetMaxHealth()/100);
	if(perc > 66) {
		if(DamageLodLevel == 2) {
			if(perc >= 80) 
				return 1;
			else
				return 2;
		} 
		return 1;
	} else if(perc > 33) {
		if(DamageLodLevel == 3) {
			if(perc >= 50) 
				return 2;
			else
				return 3;
		} 	
		return 2;		
	} else if(perc > 0) {
		return 3;		
	}
	return health/400;						
}

simulated function ChangeDamageLodLevel(int newDmgLodLevel) 
{
	local int i;
	
	if(WorldInfo.NetMode != NM_DedicatedServer) 
	{
		for(i = 0; i < BuildingVisuals.StaticMeshPieces.length; i++) 
		{
			BuildingVisuals.StaticMeshPieces[i].ForcedLodModel = newDmgLodLevel; 
			BuildingVisuals.StaticMeshPieces[i].ForceUpdate(true);
		}

		if (newDmgLodLevel >= 1)
			DmgFxEnableLevel(1, true);
		else
			DmgFxEnableLevel(1, false);

		if (newDmgLodLevel >= 2)
			DmgFxEnableLevel(2, true);
		else
			DmgFxEnableLevel(2, false);

		if (newDmgLodLevel >= 3)
			DmgFxEnableLevel(3, true);
		else
			DmgFxEnableLevel(3, false);

		if (newDmgLodLevel >= 4)
		{
			DmgFxEnableLevel(4, true);
			DmgFxEnableLevel(0, false);
		}
		else
		{
			DmgFxEnableLevel(4, false);
			DmgFxEnableLevel(0, true);
		}

		DmgFxEnableLevel(-1, newDmgLodLevel==1);
		DmgFxEnableLevel(-2, newDmgLodLevel==2);
		DmgFxEnableLevel(-3, newDmgLodLevel==3);

		if (bInitialDamageLod)
			bInitialDamageLod = false;
	}
}

simulated function DmgFxEnableLevel(int lvl, bool on)
{
	// More icky
	local Rx_BuildingAttachment_DmgFx fx;
	switch (lvl)
	{
	case 0:
		if (DmgFx_Lvl0On == on)
			return;
		if (on)
			foreach DmgFx_Lvl0(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_Lvl0(fx)
				fx.TurnOff();
		DmgFx_Lvl0On = on;
		break;
	case 1:
		if (DmgFx_Lvl1On == on)
			return;
		if (on)
			foreach DmgFx_Lvl1(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_Lvl1(fx)
				fx.TurnOff();
		DmgFx_Lvl1On = on;
		break;
	case 2:
		if (DmgFx_Lvl2On == on)
			return;
		if (on)
			foreach DmgFx_Lvl2(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_Lvl2(fx)
				fx.TurnOff();
		DmgFx_Lvl2On = on;
		break;
	case 3:
		if (DmgFx_Lvl3On == on)
			return;
		if (on)
			foreach DmgFx_Lvl3(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_Lvl3(fx)
				fx.TurnOff();
		DmgFx_Lvl3On = on;
		break;
	case 4:
		if (DmgFx_Lvl4On == on)
			return;
		if (on)
			foreach DmgFx_Lvl4(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_Lvl4(fx)
				fx.TurnOff();
		DmgFx_Lvl4On = on;
		break;
	case -1:
		if (DmgFx_OnlyLvl1On == on)
			return;
		if (on)
			foreach DmgFx_OnlyLvl1(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_OnlyLvl1(fx)
				fx.TurnOff();
		DmgFx_OnlyLvl1On = on;
		break;
	case -2:
		if (DmgFx_OnlyLvl2On == on)
			return;
		if (on)
			foreach DmgFx_OnlyLvl2(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_OnlyLvl2(fx)
				fx.TurnOff();
		DmgFx_OnlyLvl2On = on;
		break;
	case -3:
		if (DmgFx_OnlyLvl3On == on)
			return;
		if (on)
			foreach DmgFx_OnlyLvl3(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_OnlyLvl3(fx)
				fx.TurnOff();
		DmgFx_OnlyLvl3On = on;
		break;
	}
}

simulated function AddDmgFx(Rx_BuildingAttachment_DmgFx fx, int level)
{
	switch (level)
	{
	case 0:
		DmgFx_Lvl0.AddItem(fx);
		break;
	case 1:
		DmgFx_Lvl1.AddItem(fx);
		break;
	case 2:
		DmgFx_Lvl2.AddItem(fx);
		break;
	case 3:
		DmgFx_Lvl3.AddItem(fx);
		break;
	case 4:
	case -4:
		DmgFx_Lvl4.AddItem(fx);
		break;
	case -1:
		DmgFx_OnlyLvl1.AddItem(fx);
		break;
	case -2:
		DmgFx_OnlyLvl2.AddItem(fx);
		break;
	case -3:
		DmgFx_OnlyLvl3.AddItem(fx);
		break;
	default:
		`log("DMGFX ERROR -"@fx@"("$fx.SocketPattern$") was not added to a DmgFx array in"@self);
		break;
	}
}

function PowerLost()
{
	bNoPower = true;
}

simulated function PlayDestructionAnimation() 
{
	// refuse on server
	if (WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer)
		return;

	if( BuildingSkeleton.FindAnimSequence(DestructionAnimName) == none ) 
	{
		`Log("CLIENT - PlayDestructionAnimation() refused - no animation found!");
		return;
	}
	
	`log("Playing Destruction Animation ("$DestructionAnimName$")",bBuildingDebug,'Buildings');
	BuildingSkeleton.PlayAnim(DestructionAnimName);

	bBuildingRecoverable ? GotoState('IsDestroyedRecoverable') : GotoState('IsDestroyedIgnoreAll');
}

// TODO: for later game modes:
simulated state IsDestroyedIgnoreAll 
{
	ignores Touch, UnTouch, TakeDamage, HealDamage;

	simulated event BeginState(Name PreviousStateName) 
	{
		//`Log ("SERVER - Building was destroyed!!");
	}
}

// TODO: for later game modes:
simulated state IsDestroyedRecoverable 
{
	ignores Touch, UnTouch;

	simulated event BeginState(Name PreviousStateName) 
	{
		//`Log ("SERVER - Building was destroyed and is recoverable!!");
	}
}

simulated function SoundNodeWave GetAnnouncment(int alarm, int teamNum )
{
	if ( teamNum == GetTeamNum() )
	{
		return FriendlyBuildingSounds[alarm];
	} 
	else
	{
		return EnemyBuildingSounds[alarm];
	}

}

static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	local string str;
	 
	if(Switch == 0)
	{
		if(FRand() < 0.5)
		{
			str = Repl(class'Rx_Message_Buildings'.default.BuildingBroadcastMessages[0], "`PlayerName`", RelatedPRI_1.PlayerName);
			return Repl(str, "`BuildingName`", default.BuildingName);
		}
		else
		{
			str = Repl(class'Rx_Message_Buildings'.default.BuildingBroadcastMessages[1], "`PlayerName`", RelatedPRI_1.PlayerName);
			return Repl(str, "`BuildingName`", default.BuildingName);
		}
	}
	return "";
}

DefaultProperties
{
	/***************************************************/
	/*               Building Variables                */
	/***************************************************/	
	DamagePointsScale       = 0.15f
	HealPointsScale         = 0.10f

	HealthMax               = 4000
	DestructionAnimName     = "BuildingDeath"
	LowHPWarnLevel          = 200 // critical Health level
	RepairedHPLevel         = 3400 // 85%
	bBuildingRecoverable    = false
	TeamID                  = 255
	MessageClass            = class'Rx_Message_Buildings'
	MessageWaitTime         = 15.0f

	DamageLodLevel          = 1
	bInitialDamageLod       = true
}
