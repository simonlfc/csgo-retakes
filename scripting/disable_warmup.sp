#include <cstrike> 
#include <sdktools> 

public void OnPluginStart()
{
    HookEvent("round_start", Event_RoundStart, EventHookMode_Post);
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    if (GameRules_GetProp("m_bWarmupPeriod") == 1) 
    { 
        ServerCommand("mp_warmup_end"); 
        CS_TerminateRound(1.0, CSRoundEnd_GameStart);
    } 
} 