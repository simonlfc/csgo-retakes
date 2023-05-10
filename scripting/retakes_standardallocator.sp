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
	url = "https://github.com/simonlfc/csgo-retakes"
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
	g_CTRifleChoice[client] = "weapon_m4a1_silencer";
	g_TRifleChoice[client] = "weapon_ak47";
	g_CTPistolChoice[client] = "weapon_usp_silencer";
	g_TPistolChoice[client] = "weapon_glock";
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
		break;

	case 1:
		nades = "s";
		break;

	case 2:
		nades = "f";
		break;

	case 3:
		nades = "h";
		break;
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

	for ( int i = 0; i < tCount; i++ )
	{
		int client = tPlayers.Get( i );
		primary = g_AwpChoice[client] ? "weapon_awp" : g_TRifleChoice[client];
		secondary = g_TPistolChoice[client];

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
		primary = g_AwpChoice[client] ? "weapon_awp" : g_CTRifleChoice[client];
		secondary = g_CTPistolChoice[client];

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
	Menu menu = new Menu( MenuHandler_Rifle );
    if ( GetClientTeam( client ) == CS_TEAM_CT )
    {
        menu.SetTitle( "Select a CT rifle:" );
        menu.AddItem( "weapon_m4a1", "M4A4" );
        menu.AddItem( "weapon_m4a1_silencer", "M4A1-S" );
        menu.AddItem( "weapon_aug", "AUG" );
    }
    else if ( GetClientTeam( client ) == CS_TEAM_T )
    {
        menu.SetTitle( "Select a T rifle:" );
        menu.AddItem( "weapon_ak47", "AK-47" );
        menu.AddItem( "weapon_galil", "Galil" );
        menu.AddItem( "weapon_sg556", "SG-556" );
    }
	menu.Display( client, MENU_TIME_LENGTH );
}

public void GivePistolMenu( int client )
{
	Menu menu = new Menu( MenuHandler_Pistol );
    if ( GetClientTeam( client ) == CS_TEAM_CT )
    {
        menu.SetTitle( "Select a CT pistol:" );
        menu.AddItem( "weapon_usp_silencer", "USP-S" );
        menu.AddItem( "weapon_hkp2000", "P2000" );
        menu.AddItem( "weapon_elite", "Dual Berettas" );
        menu.AddItem( "weapon_p250", "P250" );
        menu.AddItem( "weapon_fiveseven", "Five-seveN" );
        menu.AddItem( "weapon_deagle", "Desert Eagle" );
    }
    else if ( GetClientTeam( client ) == CS_TEAM_T )
    {
        menu.SetTitle( "Select a T pistol:" );
        menu.AddItem( "weapon_glock", "Glock-18" );
        menu.AddItem( "weapon_elite", "Dual Berettas" );
        menu.AddItem( "weapon_p250", "P250" );
        menu.AddItem( "weapon_tec9", "Tec-9" );
        menu.AddItem( "weapon_deagle", "Desert Eagle" );
    }
	menu.Display( client, MENU_TIME_LENGTH );
}

public void GiveAwpMenu( int client )
{
	Menu menu = new Menu( MenuHandler_AWP );
	menu.SetTitle( "Allow yourself to receive AWPs?" );
	AddMenuBool( menu, true, "Yes" );
	AddMenuBool( menu, false, "No" );
	menu.Display( client, MENU_TIME_LENGTH );
}

public int MenuHandler_Rifle( Menu menu, MenuAction action, int client, int choice )
{
	if ( action == MenuAction_Select )
	{
		char buffer[WEAPON_STRING_LENGTH];
		menu.GetItem( choice, buffer, sizeof( buffer ) );

		if ( GetClientTeam( client ) == CS_TEAM_CT )
		{
			g_CTRifleChoice[client] = buffer;
			SetClientCookie( client, g_hCTRifleChoiceCookie, buffer );
		}

		if ( GetClientTeam( client ) == CS_TEAM_T )
		{
			g_TRifleChoice[client] = buffer;
			SetClientCookie( client, g_hTRifleChoiceCookie, buffer );
		}
		
        GivePistolMenu( client );
	}
	else if ( action == MenuAction_End )
		delete menu;
}

public int MenuHandler_Pistol( Menu menu, MenuAction action, int client, int choice )
{
	if ( action == MenuAction_Select )
	{
		char buffer[WEAPON_STRING_LENGTH];
		menu.GetItem( choice, buffer, sizeof( buffer ) );

		if ( GetClientTeam( client ) == CS_TEAM_CT )
		{
			g_CTPistolChoice[client] = buffer;
			SetClientCookie( client, g_hCTPistolChoiceCookie, buffer );
		}

		if ( GetClientTeam( client ) == CS_TEAM_T )
		{
			g_TPistolChoice[client] = buffer;
			SetClientCookie( client, g_hTPistolChoiceCookie, buffer );
		}
        GivePistolMenu( client );
	}
	else if ( action == MenuAction_End )
		delete menu;
}

public int MenuHandler_AWP( Menu menu, MenuAction action, int client, int choice )
{
	if ( action == MenuAction_Select )
	{
		bool allowAwps = GetMenuBool( menu, choice );
		g_AwpChoice[client] = allowAwps;
		SetCookieBool( client, g_hAwpChoiceCookie, allowAwps );
	}
	else if ( action == MenuAction_End )
		delete menu;
}