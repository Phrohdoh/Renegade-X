class Rx_BuildingAttachment_PT extends Rx_BuildingAttachment
	abstract;

var TEAM                    TeamNum;
var CylinderComponent       CollisionCylinder;
var StaticMeshComponent PTMesh;

simulated function string GetHumanReadableName()
{
	return "Purchase Terminal";
}

simulated event byte ScriptGetTeamNum()
{
	return TeamNum;
}

simulated function bool AreAircraftDisabled()
{
	local Rx_MapInfo mi;
	mi = Rx_MapInfo(WorldInfo.GetMapInfo());
	if( mi != none )
	{
		return mi.bAircraftDisabled;
	}
	return true;
}

simulated function StartCreditTick()
{
	SetTimer(0.5f,true,'CreditTick');
}

simulated function StopCreditTick()
{
	if (IsTimerActive('CreditTick'))
	{
		ClearTimer('CreditTick');
	}	
}


simulated function StartInsufCreditsTimeout()
{
	SetTimer(5.0f,false,'InsufCreditsTimeout');
}

simulated function StopInsufCreditsTimeout()
{
	if (IsTimerActive('InsufCreditsTimeout'))
	{
		ClearTimer();
	}	
}


// simulated function MenuClose()
// {
// 	StopCreditTick();
// 	StopInsufCreditsTimeout();
// 	if( PTMenu != none )
// 	{
// 		`log("" $self.Class $"================================================");
// 		ScriptTrace();
// 		PTMenu.Close(true);
// 		PTMenu = none;
// 		`log("Rx_BuildingAttachment_PT::Rx_GFxPurchaseMenu pass");
// 	}
// }

defaultproperties
{
	SpawnName     = "_PT"
	SocketPattern = "Pt_"

	RemoteRole          = ROLE_SimulatedProxy
	CollisionType       = COLLIDE_TouchAllButWeapons
	bCollideActors      = True

	Begin Object Class=StaticMeshComponent Name=PTMeshCmp
		StaticMesh                   = StaticMesh'rx_deco_terminal.Mesh.SM_BU_PT'
		CollideActors                = True
		BlockActors                  = True
		BlockRigidBody               = True
		BlockZeroExtent              = True
		BlockNonZeroExtent           = True
		bCastDynamicShadow           = True
		bAcceptsDynamicLights        = True
		bAcceptsLights               = True
		bAcceptsDecalsDuringGameplay = True
		bAcceptsDecals               = True
		RBChannel                    = RBCC_Pawn
		RBCollideWithChannels        = (Pawn=True)
	End Object
	Components.Add(PTMeshCmp)
	PTMesh = PTMeshCmp

	Begin Object Class=CylinderComponent Name=CollisioncMP
		CollisionRadius     = 75.0f
		CollisionHeight     = 50.0f
		BlockNonZeroExtent  = True
		BlockZeroExtent     = false
		bDrawNonColliding   = True
		bDrawBoundingBox    = False
		BlockActors         = False
		CollideActors       = True
	End Object
	CollisionComponent = CollisionCmp
	CollisionCylinder  = CollisionCmp
	Components.Add(CollisionCmp)

	//RemoteRole          = ROLE_SimulatedProxy
	//bCollideActors      = True
	//bBlockActors        = True
	//BlockRigidBody      = True
	//bCollideComplex     = true
	//bWorldGeometry = true
	
}