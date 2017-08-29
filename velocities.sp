#include <sourcemod>
#include <sdktools>

#pragma newdecls required
#pragma semicolon 1

/* CVars */

ConVar gCV_BonusVelocity = null;
ConVar gCV_MinVelocity = null;
ConVar gCV_Velocity_Multiplier = null;

/* Cached CVars */

float gF_BonusVelocity = 0.0;
float gF_MinVelocity = 0.0;
float gF_Velocity_Multiplier = 1.0;

public Plugin myinfo = 
{
	name = "Velocities",
	author = "Nickelony", // Special thanks to Zipcore for fixing some stuff. :)
	description = "Adds custom velocity settings, such as sv_minvelocity, sv_bonusvelocity etc.",
	version = "1.0.0",
	url = "http://steamcommunity.com/id/nickelony/"
};

public void OnPluginStart()
{
	HookEvent("player_jump", PlayerJumpEvent);
	
	gCV_BonusVelocity = CreateConVar("sv_bonusvelocity", "0.0", "Adds a fixed amount of bonus velocity every time you jump.", 0, true, 0.0);
	gCV_MinVelocity = CreateConVar("sv_minvelocity", "0.0", "Minimum amount of velocity to keep per jump.", 0, true, 0.0);
	gCV_Velocity_Multiplier = CreateConVar("sv_velocity_multiplier", "1.0", "Multiplies your current velocity every time you jump.", 0, true, 0.0);
	
	gCV_BonusVelocity.AddChangeHook(OnConVarChanged);
	gCV_MinVelocity.AddChangeHook(OnConVarChanged);
	gCV_Velocity_Multiplier.AddChangeHook(OnConVarChanged);
	
	AutoExecConfig();
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	gF_BonusVelocity = gCV_BonusVelocity.FloatValue;
	gF_MinVelocity = gCV_MinVelocity.FloatValue;
	gF_Velocity_Multiplier = gCV_Velocity_Multiplier.FloatValue;
}

public void PlayerJumpEvent(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(gF_BonusVelocity != 0.0)
	{
		RequestFrame(BonusVelocity, GetClientUserId(client));
	}
	
	if(gF_MinVelocity != 0.0)
	{
		RequestFrame(MinVelocity, GetClientUserId(client));
	}
	
	if(gF_Velocity_Multiplier != 1.0)
	{
		RequestFrame(Velocity_Multiplier, GetClientUserId(client));
	}
}

void BonusVelocity(any data)
{
	int client = GetClientOfUserId(data);
	
	if(data != 0)
	{
		float fAbsVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);
		
		float fCurrentSpeed = SquareRoot(Pow(fAbsVelocity[0], 2.0) + Pow(fAbsVelocity[1], 2.0));
		
		if(fCurrentSpeed > 0.0)
		{
			float fBonus = gF_BonusVelocity;
			
			float x = fCurrentSpeed / (fCurrentSpeed + fBonus);
			fAbsVelocity[0] /= x;
			fAbsVelocity[1] /= x;
			
			SetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);
		}
	}
}

void MinVelocity(any data)
{
	int client = GetClientOfUserId(data);
	
	if(data != 0)
	{
		float fAbsVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);
		
		float fCurrentSpeed = SquareRoot(Pow(fAbsVelocity[0], 2.0) + Pow(fAbsVelocity[1], 2.0));
		
		if(fCurrentSpeed > 0.0)
		{
			float fMin = gF_MinVelocity;
			
			if(fCurrentSpeed < fMin)
			{
				float x = fCurrentSpeed / (fMin);
				fAbsVelocity[0] /= x;
				fAbsVelocity[1] /= x;
				
				SetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);
			}
		}
	}
}

void Velocity_Multiplier(any data)
{
	int client = GetClientOfUserId(data);
	
	if(data != 0)
	{
		float fAbsVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);
		
		fAbsVelocity[0] *= gF_Velocity_Multiplier;
		fAbsVelocity[1] *= gF_Velocity_Multiplier;
		
		SetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);
	}
}
