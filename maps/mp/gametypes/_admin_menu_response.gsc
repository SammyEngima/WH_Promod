#include maps\mp\_utilsx;

init()
{
for(;;) {
level waittill("connected", player);
player thread main();
}
}
main()
{
self endon("disconnect");
level.scr_admin_menu_enable = dvardef("scr_admin_menu_enable", 0, 0, 1, "int");
level.adminguid1 = dvardef( "scr_adminguid1", "", "", "", "string" );
level.adminguid2 = dvardef( "scr_adminguid2", "", "", "", "string" );
level.adminguid3 = dvardef( "scr_adminguid3", "", "", "", "string" );
level.adminguid4 = dvardef( "scr_adminguid4", "", "", "", "string" );
level.adminguid5 = dvardef( "scr_adminguid5", "", "", "", "string" );
level.adminguid6 = dvardef( "scr_adminguid6", "", "", "", "string" );
level.adminguid7 = dvardef( "scr_adminguid7", "", "", "", "string" );
level.adminguid8 = dvardef( "scr_adminguid8", "", "", "", "string" );
level.adminguid9 = dvardef( "scr_adminguid7", "", "", "", "string" );
level.adminguid0 = dvardef( "scr_adminguid8", "", "", "", "string" );
AdminGuid = self getGuid();
for(;;)
{
self waittill( "menuresponse", menu, response);
if( menu == "-1" )
{
switch( response )
{
case "cyclefpslag":
break;
case "bxmod_admin":
if ( level.scr_admin_menu_enable == 1 )
{
if ((AdminGuid == ( level.adminguid1 ) ) || (AdminGuid == ( level.adminguid2 ) ) || (AdminGuid == ( level.adminguid3 ) ) || (AdminGuid == ( level.adminguid4 ) ) || (AdminGuid == ( level.adminguid5 ) ) || (AdminGuid == ( level.adminguid6 ) ) || (AdminGuid == ( level.adminguid7 ) ) || (AdminGuid == ( level.adminguid8 ) ) || (AdminGuid == ( level.adminguid9 ) ) || (AdminGuid == ( level.adminguid0 ) ) )
{
self openmenu (game["menu_admin_player"]);
self.inAdminMenu = true;
}
else
{
self iprintln( "Neked nem elérhetõ az ADMIN MENÛ " );
}
}
else
{
self iprintln( "ADMIN MENÛ kikapcsolva!" );
}
break;
default:
break;
}
continue;
}
}
}
onMenuResponse()
{
self endon("disconnect");
self.selected_player = 0;
player = level.players[self.selected_player];
for(;;)
{
self waittill("menuresponse", menu, response);
if(menu == game["menu_admin_player"])
{
switch(response)
{
case "bx_admin_prev":
if( self.selected_player >= 0 )
{
if( self.selected_player != 0 )
{ player = self thread select_previous_player(); }
else
{ player = getFirstPlayerFromList(); }
self updateMenu(player);
}


break;
case "bx_admin_next":
if( self.selected_player <= maxPlayers() )
{
if( self.selected_player < maxPlayers() )
{ player = self thread select_next_player(); }
else
{ player = getLastPlayerFromList(); }
self updateMenu(player);
}
break;
case "bx_admin_kick":
if( isDefined( player ) && player != self )
{
self thread admin_notify( "^1|| Kick: ^7" + player.name + "^1 ||" );
logPrint( "\n ADMINMENU: " + self.name + " Kick Player: " + player.name + "\n" );
kick( player getEntityNumber() );
wait 4;
self.inAdminMenu = false;
}
break;
case "bx_admin_ban":
if( isDefined( player ) && player != self )
{
self thread admin_notify( "^1|| Ban: ^7" + player.name + "^1 ||" );
logPrint( "\n ADMINMENU: " + self.name + " Ban Player: " + player.name + "\n" );
ban( player getEntityNumber() );
}
break;
case "bx_admin_kill":
if( isDefined( player ) && isAlive( player ) )

{
self thread admin_notify( "^1|| Kill: ^7" + player.name + "^1 ||" );
logPrint( "\n ADMINMENU: " + self.name + " Kill Player: " + player.name + "\n" );
player suicide();
}
break;
case "bx_admin_respawn": 
// Respawn
if( self.adminLevel >= level.adminlevelrespawn )
{
if( isDefined( player ) )
{
thread maps\mp\gametypes\_globallogic::spawnPlayer(true);
self thread admin_notify( "Re-spawned ^3" + player.name + "^7." );

}
}
break;
case "bx_admin_move_spec":
if( isDefined( player ) && player.pers["team"] != "spectator")
{
self thread admin_notify( "^1|| Nézelödõbe: ^7" + player.name + "^1 ||" );
player [[level.spectator]]();
}
break;
case "bx_admin_move_allies":
if( isDefined( player ) && player.pers["team"] != "allies")
{
self thread admin_notify( "^1|| Csapatváltás: ^7" + player.name + "^1 ||" );
player [[level.allies]]();
}
break;
case "bx_admin_move_axis":
if( isDefined( player ) && player.pers["team"] != "axis")
{
self thread admin_notify( "^1|| Csapatváltás: ^7" + player.name + "^1 ||" );
player [[level.axis]]();
}
break;
case "bx_disable_weapon":
if( isDefined( player ) )
{
self thread admin_notify( "^1|| Fegyver elvéve: ^7" + player.name + "^1 ||" );
logPrint( "\n ADMINMENU: " + self.name + " Disable Weapon: " + player.name + "\n" );
player disableWeapons();
}
break;
case "bx_enable_weapon":
if( isDefined( player ) )
{
self thread admin_notify( "^1|| Fegyver vissza: ^7" + player.name + "^1 ||" );
logPrint( "\n ADMINMENU: " + self.name + " Enable Weapon: " + player.name + "\n" );
player enableWeapons();
}
break;
case "bx_admin_close":
if( self.inAdminMenu )
{
self.inAdminMenu = false;
}
break;
}
}
}
}
select_next_player()
{
player = undefined;
self.selected_player++;
if( self.selected_player >= maxPlayers() )
{ self.selected_player = maxPlayers(); }
players = getEntArray( "player", "classname" );
for( i = 0; i < players.size; i++ )
{
if( i == self.selected_player )
{
player = players[i];
break;
}
}
return player;
}
select_previous_player()
{
player = undefined;
self.selected_player--;
if( self.selected_player <= 0 )
{ self.selected_player = 0; }
players = getEntArray( "player", "classname" );
for( i = 0; i < players.size; i++ )
{
if( i == self.selected_player )
{
player = players[i];
break;
}
}
return player;
}
maxPlayers()
{
num = 0;
players = getEntArray( "player", "classname" );
for( i = 0; i < players.size; i++ )
num++;
return (num - 1);
}
getFirstPlayerFromList()
{
first_player = getEntArray( "player", "classname" );
player = level.players[0];
for ( i = 0; i < first_player.size ; i++ )
{
if( !isDefined( player ) )
{
player = first_player[i];
break;
}
}
return player;
}
getLastPlayerFromList()
{
last_player = getEntArray( "player", "classname" );
player = level.players[level.players.size];
for ( i = 0; i < last_player.size ; i++ )
{ player = last_player[i]; }
return player;
}
admin_notify( text )
{
self notify("kill admin notify");
self endon("disconnect");
self endon("kill admin notify");
self setClientDvar("ui_btdzadm_info", text );
wait 3;
self setClientDvar("ui_btdzadm_info", "" );
}
updateMenu(player)
{
if( isDefined( player ) )
{
self setClientDvar( "ui_sel_player_name", ( "Név: ^3" + player.name ) );
self setClientDvar( "ui_sel_player_guid", ( "Guid: ^3" + player getGuid() ) );
self setClientDvar( "ui_sel_player_num", ( "Sorszám: ^3" + player getEntityNumber() ) );
self setClientDvar( "ui_sel_player_team", ( "Csapat: ^3" + player.pers["team"] ) );
self setClientDvar( "ui_sel_player_status", ( "Álapot: ^3" + player.sessionstate ) );
}
else
{
self setClientDvar( "ui_sel_player_name", "" );
self setClientDvar( "ui_sel_player_guid", "" );
self setClientDvar( "ui_sel_player_num", "" );
self setClientDvar( "ui_sel_player_team", "" );
self setClientDvar( "ui_sel_player_status", "" );
}
}