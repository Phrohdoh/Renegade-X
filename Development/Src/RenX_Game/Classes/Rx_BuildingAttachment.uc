class Rx_BuildingAttachment extends Actor;

var const string            SpawnName;
var const string            SocketPattern;  // What is matched to see if this attachment is spawned on a socket
var Rx_Building_Internals   OwnerBuilding;
var bool                    bDamageParent;  // if true any damage this attachment takes is applied to the owning building
var bool                    bHealParent;    // if true any healing this attachment takes is applied to the owning building
var bool                    bAttachmentDebug;
var bool                    bSpawnOnClient;

replication
{
   if ( bNetInitial && Role==ROLE_Authority )
	  OwnerBuilding;
}

simulated function Init( Rx_Building_Internals inBuilding, optional name SocketName )
{
	SetOwner(inBuilding);
	OwnerBuilding = inBuilding;
	bAttachmentDebug = OwnerBuilding.bBuildingDebug;
}

event TakeDamage( int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser )
{
	if ( bDamageParent )
	{
		OwnerBuilding.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	}
		
}

simulated function byte GetTeamNum() 
{
	if (OwnerBuilding != none && OwnerBuilding.BuildingVisuals != none)
		return OwnerBuilding.BuildingVisuals.GetTeamNum();
	else if (OwnerBuilding != none)
		return OwnerBuilding.GetTeamNum();
	else 
		return super.GetTeamNum();
}

simulated function float getBuildingHealthPct()
{
	if (OwnerBuilding != none && OwnerBuilding.BuildingVisuals != none)
	{
		return float(OwnerBuilding.BuildingVisuals.GetHealth()) / float(OwnerBuilding.BuildingVisuals.GetMaxHealth());
	}
	else return -1;
}

simulated function string GetHumanReadableName()
{
	if (OwnerBuilding != none && OwnerBuilding.BuildingVisuals != none)
	{
		return OwnerBuilding.BuildingVisuals.GetHumanReadableName();
	}
	else return super.GetHumanReadableName();
}

event bool HealDamage( int Amount, Controller Healer, class<DamageType> DamageType )
{
	if ( bHealParent )
	{
		return OwnerBuilding.HealDamage(Amount,Healer,DamageType);
	}
	return false;
}

DefaultProperties
{
	bDamageParent   		= True
	bHealParent     		= True
	bAlwaysRelevant     	= True
	bOnlyDirtyReplication 	= True
	NetUpdateFrequency  	=  10
	bSpawnOnClient          = False
}
