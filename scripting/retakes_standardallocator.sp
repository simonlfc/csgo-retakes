#include <sourcemod>
#include <cstrike>
#include <clientprefs>
#include "include/retakes.inc"
#include "retakes/generic.sp"

#pragma semicolon 1
#pragma newdecls required

#define MENU_TIME_LENGTH 15

char g_CTRifleChoice[MAXPLAYERS+1][WEAPON_STRING_LENGTH];
char g_TRifleChoice[MAXPLAYERS+1][WEAPON_STRING_LENGTH];
Handle g_hCTRifleChoiceCookie;
Handle g_hTRifleChoiceCookie;

char g_CTPistolChoice[MAXPLAYERS+1][WEAPON_STRING_LENGTH];
char g_TPistolChoice[MAXPLAYERS+1][WEAPON_STRING_LENGTH];
Handle g_hCTPistolChoiceCookie;
Handle g_hTPistolChoiceCookie;

bool g_AwpChoice[MAXPLAYERS+1];
Handle g_hAwpChoiceCookie;


public Plugin myinfo =
{
	name = "CS:GO Retakes: standard weapon allocator",
	author = "splewis",
	description = "Defines a simple weapon allocation policy and lets players set weapon preferences",
	version = PLUGIN_VERSION,
	url = "https://github.com/splewis/csgo-retakes"
};

public void OnPluginStart()
{
	g_hCTRifleChoiceCookie = RegClientCookie( "retakes_ctriflechoice", "", CookieAccess_Private );
	g_hTRifleChoiceCookie = RegClientCookie( "retakes_triflechoice", "", CookieAccess_Private );
	g_hCTPistolChoiceCookie = RegClientCookie( "retakes_ctpistolchoice", "", CookieAccess_Private );
	g_hTPistolChoiceCookie = RegClientCookie( "retakes_tpistolchoice", "", CookieAccess_Private );
	g_hAwpChoiceCookie = RegClientCookie( "retakes_awpchoice", "", CookieAccess_Private );
}

public void OnClientConnected( int client )
{
	g_CTRifleChoice[client] = "m4a1";
	g_TRifleChoice[client] = "ak47";
	g_CTPistolChoice[client] = "usp_silencer";
	g_TPistolChoice[client] = "glock";
	g_AwpChoice[client] = false;
}

public void Retakes_OnGunsCommand( int client )
{
	GiveWeaponsMenu( client );
}

public void Retakes_OnWeaponsAllocated( ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite )
{
	WeaponAllocator( tPlayers, ctPlayers, bombsite );
}

/**
 * Updates client weapon settings according to their cookies.
 */
public void OnClientCookiesCached( int client )
{
	if ( IsFakeClient( client ) )
		return;

	char ctrifle[WEAPON_STRING_LENGTH];
	char trifle[WEAPON_STRING_LENGTH];
	GetClientCookie( client, g_hCTRifleChoiceCookie, ctrifle, sizeof( ctrifle ) );
	GetClientCookie( client, g_hTRifleChoiceCookie, trifle, sizeof( trifle ) );
	g_CTRifleChoice[client] = ctrifle;
	g_TRifleChoice[client] = trifle;

    
	char ctpistol[WEAPON_STRING_LENGTH];
	char tpistol[WEAPON_STRING_LENGTH];
	GetClientCookie( client, g_hCTPistolChoiceCookie, ctpistol, sizeof( ctpistol ) );
	GetClientCookie( client, g_hTPistolChoiceCookie, tpistol, sizeof( tpistol ) );
	g_CTPistolChoice[client] = ctpistol;
	g_TPistolChoice[client] = tpistol;

	g_AwpChoice[client] = GetCookieBool( client, g_hAwpChoiceCookie );
}

static void SetNades( char nades[NADE_STRING_LENGTH] )
{
	int rand = GetRandomInt( 0, 3 );

	switch ( rand )
	{
	case 0:
		nades = "";

	case 1:
		nades = "s";

	case 2:
		nades = "f";

	case 3:
		nades = "h";
	}
}

public void WeaponAllocator( ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite )
{
	int tCount = tPlayers.Length;
	int ctCount = ctPlayers.Length;

	char primary[WEAPON_STRING_LENGTH];
	char secondary[WEAPON_STRING_LENGTH];
	char nades[NADE_STRING_LENGTH];
	int health = 100;
	int kevlar = 100;
	bool helmet = true;
	bool kit = true;

	bool giveTAwp = true;
	bool giveCTAwp = true;

	for ( int i = 0; i < tCount; i++ )
	{
		int client = tPlayers.Get( i );

		if ( giveTAwp && g_AwpChoice[client] )
		{
			primary = "weapon_awp";
			giveTAwp = false;
		}
		else if ( StrEqual( g_TRifleChoice[client], "sg556", true ) )
			primary = "weapon_sg556";

		else
			primary = "weapon_ak47";

        if ( StrEqual( g_TPistolChoice[client], "p250", true ) )
		    secondary = "weapon_p250";
        else if ( StrEqual( g_TPistolChoice[client], "tec9", true ) )
		    secondary = "weapon_tec9";
        else if ( StrEqual( g_TPistolChoice[client], "elite", true ) )
		    secondary = "weapon_elite";
        else
		    secondary = "weapon_glock";

		health = 100;
		kevlar = 100;
		helmet = true;
		kit = false;
		SetNades( nades );

		Retakes_SetPlayerInfo( client, primary, secondary, nades, health, kevlar, helmet, kit );
	}

	for ( int i = 0; i < ctCount; i++ )
	{
		int client = ctPlayers.Get( i );

		if ( giveCTAwp && g_AwpChoice[client] )
		{
			primary = "weapon_awp";
			giveCTAwp = false;
		}
		else if ( StrEqual( g_CTRifleChoice[client], "m4a1_silencer", true ) )
			primary = "weapon_m4a1_silencer";

		else if ( StrEqual( g_CTRifleChoice[client], "m4a1", true ) )
			primary = "weapon_m4a1";

		else
			primary = "weapon_aug";

		if ( StrEqual( g_CTPistolChoice[client], "p250", true ) )
		    secondary = "weapon_p250";
        else if ( StrEqual( g_CTPistolChoice[client], "fiveseven", true ) )
		    secondary = "weapon_fiveseven";
        else if ( StrEqual( g_CTPistolChoice[client], "elite", true ) )
		    secondary = "weapon_elite";
        else if ( StrEqual( g_CTPistolChoice[client], "hkp2000", true ) )
		    secondary = "weapon_hkp2000";
        else
		    secondary = "weapon_usp_silencer";

		kit = true;
		health = 100;
		kevlar = 100;
		helmet = true;
		SetNades( nades );

		Retakes_SetPlayerInfo( client, primary, secondary, nades, health, kevlar, helmet, kit );
	}
}

public void GiveWeaponsMenu( int client )
{
    if ( GetClientTeam( client ) == CS_TEAM_CT )
    {
        Menu menu = new Menu( MenuHandler_CTRifle );
        menu.SetTitle( "Select a CT rifle:" );
        menu.AddItem( "m4a1", "M4A4" );
        menu.AddItem( "m4a1_silencer", "M4A1-S" );
        menu.AddItem( "aug", "AUG" );
        menu.Display( client, MENU_TIME_LENGTH );
    }
    else if ( GetClientTeam( client ) == CS_TEAM_T )
    {
        Menu menu = new Menu( MenuHandler_TRifle );
        menu.SetTitle( "Select a T rifle:" );
        menu.AddItem( "ak47", "AK-47" );
        menu.AddItem( "sg556", "SG-556" );
        menu.Display( client, MENU_TIME_LENGTH );
    }
}

public void GivePistolMenu( int client )
{
    if ( GetClientTeam( client ) == CS_TEAM_CT )
    {
        Menu menu = new Menu( MenuHandler_CTPistol );
        menu.SetTitle( "Select a CT pistol:" );
        menu.AddItem( "usp_silencer", "USP-S" );
        menu.AddItem( "hkp2000", "P2000" );
        menu.AddItem( "elite", "Dual Berettas" );
        menu.AddItem( "p250", "P250" );
        menu.AddItem( "fiveseven", "Five-seveN" );
        menu.Display( client, MENU_TIME_LENGTH );
    }
    else if ( GetClientTeam( client ) == CS_TEAM_T )
    {
        Menu menu = new Menu( MenuHandler_TPistol );
        menu.SetTitle( "Select a T rifle:" );
        menu.AddItem( "glock", "Glock-18" );
        menu.AddItem( "elite", "Dual Berettas" );
        menu.AddItem( "p250", "P250" );
        menu.AddItem( "tec9", "Tec-9" );
        menu.Display( client, MENU_TIME_LENGTH );
    }
}

public int MenuHandler_CTRifle( Menu menu, MenuAction action, int param1, int param2 )
{
	if ( action == MenuAction_Select )
	{
		int client = param1;
		char choice[WEAPON_STRING_LENGTH];
		menu.GetItem( param2, choice, sizeof( choice ) );
		g_CTRifleChoice[client] = choice;
		SetClientCookie( client, g_hCTRifleChoiceCookie, choice );
        GivePistolMenu( client );
	}
	else if ( action == MenuAction_End )
		delete menu;
}

public int MenuHandler_TRifle( Menu menu, MenuAction action, int param1, int param2 )
{
	if ( action == MenuAction_Select )
	{
		int client = param1;
		char choice[WEAPON_STRING_LENGTH];
		menu.GetItem( param2, choice, sizeof( choice ) );
		g_TRifleChoice[client] = choice;
		SetClientCookie( client, g_hTRifleChoiceCookie, choice );
		GivePistolMenu( client );
	}
	else if ( action == MenuAction_End )
		delete menu;
}

public int MenuHandler_CTPistol( Menu menu, MenuAction action, int param1, int param2 )
{
	if ( action == MenuAction_Select )
	{
		int client = param1;
		char choice[WEAPON_STRING_LENGTH];
		menu.GetItem( param2, choice, sizeof( choice ) );
		g_CTPistolChoice[client] = choice;
		SetClientCookie( client, g_hCTPistolChoiceCookie, choice );
        GiveAwpMenu( client );
	}
	else if ( action == MenuAction_End )
		delete menu;
}

public int MenuHandler_TPistol( Menu menu, MenuAction action, int param1, int param2 )
{
	if ( action == MenuAction_Select )
	{
		int client = param1;
		char choice[WEAPON_STRING_LENGTH];
		menu.GetItem( param2, choice, sizeof( choice ) );
		g_TPistolChoice[client] = choice;
		SetClientCookie( client, g_hTPistolChoiceCookie, choice );
		GiveAwpMenu( client );
	}
	else if ( action == MenuAction_End )
		delete menu;
}

public void GiveAwpMenu( int client )
{
	Menu menu = new Menu( MenuHandler_AWP );
	menu.SetTitle( "Allow yourself to receive AWPs?" );
	AddMenuBool( menu, true, "Yes" );
	AddMenuBool( menu, false, "No" );
	menu.Display( client, MENU_TIME_LENGTH );
}

public int MenuHandler_AWP( Menu menu, MenuAction action, int param1, int param2 )
{
	if ( action == MenuAction_Select )
	{
		int client = param1;
		bool allowAwps = GetMenuBool( menu, param2 );
		g_AwpChoice[client] = allowAwps;
		SetCookieBool( client, g_hAwpChoiceCookie, allowAwps );
	}
	else if ( action == MenuAction_End )
		delete menu;
}