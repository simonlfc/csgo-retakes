#include <sourcemod>
#include <cstrike>
#include <clientprefs>
#include <smlib>
#include "include/retakes.inc"
#include "retakes/generic.sp"

#pragma semicolon 1
#pragma newdecls required

#define MENU_TIME_LENGTH 	15
#define COINTOSS 			Math_GetRandomInt( 0, 100 ) >= 50

char g_CTRifleChoice[MAXPLAYERS+1][WEAPON_STRING_LENGTH];
Handle g_hCTRifleChoiceCookie;

char g_TRifleChoice[MAXPLAYERS+1][WEAPON_STRING_LENGTH];
Handle g_hTRifleChoiceCookie;

char g_CTPistolChoice[MAXPLAYERS+1][WEAPON_STRING_LENGTH];
Handle g_hCTPistolChoiceCookie;

char g_TPistolChoice[MAXPLAYERS+1][WEAPON_STRING_LENGTH];
Handle g_hTPistolChoiceCookie;

bool g_AwpChoice[MAXPLAYERS+1];
Handle g_hAwpChoiceCookie;

bool pistolround = false;
int pistolround_chance = 25;


public Plugin myinfo =
{
	name = "CS:GO Retakes: standard weapon allocator",
	author = "simonlfc",
	description = "Defines a simple weapon allocation policy and lets players set weapon preferences",
	version = PLUGIN_VERSION,
	url = "https://github.com/simonlfc/csgo-retakes"
};

public void OnPluginStart()
{
	g_hCTRifleChoiceCookie = RegClientCookie( "retakes_ctriflechoice", "", CookieAccess_Protected );
	g_hCTPistolChoiceCookie = RegClientCookie( "retakes_ctpistolchoice", "", CookieAccess_Protected );

	g_hTRifleChoiceCookie = RegClientCookie( "retakes_triflechoice", "", CookieAccess_Protected );
	g_hTPistolChoiceCookie = RegClientCookie( "retakes_tpistolchoice", "", CookieAccess_Protected );

	g_hAwpChoiceCookie = RegClientCookie( "retakes_awpchoice", "", CookieAccess_Protected );

	Retakes_MessageToAll("Started plugin");
}

public void OnClientConnected( int client )
{
	g_CTRifleChoice[client] = "weapon_m4a1_silencer";
	g_CTPistolChoice[client] = "weapon_usp_silencer";
	SetClientCookie( client, g_hCTRifleChoiceCookie, g_CTRifleChoice[client] );
	SetClientCookie( client, g_hCTPistolChoiceCookie, g_CTPistolChoice[client] );

	g_TRifleChoice[client] = "weapon_ak47";
	g_TPistolChoice[client] = "weapon_glock";
	SetClientCookie( client, g_hTRifleChoiceCookie, g_TRifleChoice[client] );
	SetClientCookie( client, g_hTPistolChoiceCookie, g_TPistolChoice[client] );

	g_AwpChoice[client] = false;
}

public void Retakes_OnWeaponsAllocated( ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite )
{
	pistolround = Math_GetRandomInt(0, 100) <= pistolround_chance;
	bool helmet = !pistolround;

	if ( pistolround )
		Retakes_MessageToAll("Pistol Round!");

	for ( int i = 1; i <= MaxClients; i++ )
	{
		if ( !IsClientInGame( i ) || IsFakeClient( i ) || GetClientTeam( i ) < CS_TEAM_T )
            continue;

		char primary[WEAPON_STRING_LENGTH];
		char secondary[WEAPON_STRING_LENGTH];
		char nades[NADE_STRING_LENGTH];

		bool kit = GetClientTeam( i ) == CS_TEAM_CT;
		int team = GetClientTeam( i );
		int health = 100;
		int kevlar = 100;
		primary = "";
		GetClientCookie( i, team == CS_TEAM_T ? g_hTPistolChoiceCookie : g_hCTPistolChoiceCookie, secondary, sizeof( secondary ) );

		if ( !pistolround )
		{
			if ( COINTOSS && g_AwpChoice[i] )
				primary = "weapon_awp";
			else
				GetClientCookie( i, team == CS_TEAM_T ? g_hTRifleChoiceCookie : g_hCTRifleChoiceCookie, primary, sizeof( primary ) );
		}

		SetNades( nades );
		Retakes_SetPlayerInfo( i, primary, secondary, nades, health, kevlar, helmet, kit );
	}
}

public void OnClientCookiesCached( int client )
{
	if ( IsFakeClient( client ) )
		return;

	char ctrifle[WEAPON_STRING_LENGTH];
	GetClientCookie( client, g_hCTRifleChoiceCookie, ctrifle, sizeof( ctrifle ) );
	g_CTRifleChoice[client] = ctrifle;

	char trifle[WEAPON_STRING_LENGTH];
	GetClientCookie( client, g_hTRifleChoiceCookie, trifle, sizeof( trifle ) );
	g_TRifleChoice[client] = trifle;

	char ctpistol[WEAPON_STRING_LENGTH];
	GetClientCookie( client, g_hCTPistolChoiceCookie, ctpistol, sizeof( ctpistol ) );
	g_CTPistolChoice[client] = ctpistol;

	char tpistol[WEAPON_STRING_LENGTH];
	GetClientCookie( client, g_hTPistolChoiceCookie, tpistol, sizeof( tpistol ) );
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

public void Retakes_OnGunsCommand( int client )
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
		menu.AddItem( "weapon_galilar", "Galil" );
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

public void GiveAWPMenu( int client )
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

	return 0;
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

		GiveAWPMenu( client );
	}
	else if ( action == MenuAction_End )
		delete menu;

	return 0;
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

	return 0;
}