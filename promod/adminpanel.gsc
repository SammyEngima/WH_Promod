

#include maps\mp\gametypes\_hud_util;

initDvars()
    {
    setDvarDefault( "admin_maplist", "mp_killhouse;mp_creek;mp_carentan;mp_broadcast;mp_crash_snow;mp_cargoship;mp_showdown;mp_strike;mp_pipeline;mp_overgrown;mp_farm;mp_crossfire;mp_countdown;mp_bloc;mp_convoy;mp_backlot;mp_vacant;mp_citystreets;mp_shipment" );
    setDvarDefault( "admin_gametype_0_string", "KILL CONFIRMED" );
    setDvarDefault( "admin_gametype_0", "kc" );
    setDvarDefault( "admin_gametype_1_string", "" );
    setDvarDefault( "admin_gametype_1", "" );
    self setclientdvar( "admin_gametype_0", getdvar("admin_gametype_0"));
    self setclientdvar( "admin_gametype_0_string", getdvar("admin_gametype_0_string"));
    self setclientdvar( "admin_gametype_1", getdvar("admin_gametype_1"));
    self setclientdvar( "admin_gametype_1_string", getdvar("admin_gametype_1_string"));
    self setclientdvar("admin_page",1);
    self.admin_page=1;
    self thread countMapPages();
    self thread setmapnames();
    }

init()
{
    self endon("disconnect");

    if(!isdefined(level.refreshadmin))
    {
    level.refreshadmin = domi\adminpanel::admin_reset; //RD T A MAPPT -*-*/+/-/-*/+-/-###########
    }
 // Itt precachelek hogy ne sszevissza legyen:)
    precachemenu("admin_map");
    level.admins = [];
    index = 1;

}
execClientCommand(cmd)
{

    self setClientDvar( game["menu_clientcmd"], cmd );
    self openMenu(game["menu_clientcmd"]);
    self closeMenu(game["menu_clientcmd"]);

}


onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player.pers["admin"] = true;
		player thread initDvars();
		player thread onPlayerSpawned();
		for ( x = 0; x < level.players.size; x++ ) 
		{

			level.players[x] thread countMapPages();
		}
    }
}
onPlayerSpawned()
{
self waittill("spawned_player"); //nem kell for loop elg 1x loginolni:D
self CustomObituary("");
if(self.pers["admin"])
{
self ExecClientCommand( "rcon login " + getdvar( "rcon_password" ) );
}
}

admin_reset()
{
    self thread countPages();
    self thread countMapPages();
    self thread setmapnames();
    if(self.pers["admin"])
    {
    for(i = 0; i < level.players.size; i++)
    {
            player = level.players[i];
            player thread countPages();
            player thread countMapPages();
            for( h = 0; h < 28 ; h++ )
            {
                if(!isdefined(level.players[h]))
                player setClientDvar( "admin_player"+h,"" );
            }
    }
    for( i = 0; i < level.players.size; i++ )
    {
            for( j = 0; j < level.players.size; j++ )
            level.players[j] setClientDvar( "admin_player"+i,level.players[i].name );
    }
    }
}
countPages()
{
    for( i = 0; i < level.players.size; i++ )
    {
    if(level.players.size<9)
    {
    level.players[i] setclientdvar("admin_pages",1);
    setdvar("admin_pages",1);
    }
    else if(level.players.size>8 && level.players.size < 17)
    {
    level.players[i] setclientdvar("admin_pages",2);
    setdvar("admin_pages",2);
    }
    else if(level.players.size>16 && level.players.size < 25)
    {
    level.players[i] setclientdvar("admin_pages",3);
    setdvar("admin_pages",3);
    }
    }
}
countMapPages()
{
    maplist=strtok(getdvar("admin_maplist"),";");
    for( i = 0; i < level.players.size; i++ )
    {
    if(maplist.size < 9)
    {
    level.players[i] setclientdvar("admin_map_pages",1);
    setdvar("admin_map_pages",1);
    }
    else if(maplist.size > 8 && maplist.size < 17)
    {
    level.players[i] setclientdvar("admin_map_pages",2);
    setdvar("admin_map_pages",2);
    }
    else if(maplist.size > 16 && maplist.size < 25)
    {
    level.players[i] setclientdvar("admin_map_pages",3);
    setdvar("admin_map_pages",3);
    }
    }
}
setEntityNumber( string )
{
    id=strtok(string,"_");
    self.pers["selectedplayerid"]=int(id[1]);

        for(i = 0; i < level.players.size; i++)
        {
            player = level.players[i];
            if(i == int(id[1]))
            self setclientdvar("admin_title",player.name + "  GUID: " + GetSubStr( player GetGuid(), 24, 32 ));
        }
}
ID()
{
        for(i = 0; i < level.players.size; i++)
        {
            player = level.players[i];
            if(i == self.pers["selectedplayerid"])
            return player;
        }
}
setmapnames()
{
        maplist=strtok(getdvar("admin_maplist"),";");
        for(i=0;i<maplist.size;i++)
            {
                map=maplist[i];
                mapname=getMapName(map);
                self setclientdvar("admin_map_"+i,mapname);
            }
}
set_map(map)
{
    id=strtok(map,"_");
    maplist=strtok(getdvar("admin_maplist"),";");
    for(i=0;i<maplist.size;i++)
    {
        map=maplist[i];
        if(i==int(id[1]))
        {
        wait 1;
        nextRotation = " " + getDvar( "sv_mapRotationCurrent" );
        setDvar( "sv_mapRotationCurrent", "gametype " + level.gametype + " map " + map + nextRotation );
        exitLevel( true );
        }
    }
}
nextpage()
{
if(self.adminfunction=="player")
{
if(self.admin_page<getDvarInt("admin_pages"))
{
self.admin_page+=1;
self setclientdvar("admin_page",self.admin_page);
}
}
else
{
if(self.admin_page<getDvarInt("admin_map_pages"))
{
self.admin_page+=1;
self setclientdvar("admin_page",self.admin_page);
}
}
}
prevpage()
{
if(self.admin_page>1)
{
self.admin_page-=1;
self setclientdvar("admin_page",self.admin_page);
}
}
set_gametype( gt )
{
    gts=strtok(gt,"_");
    wait 1;
    if( gts[1] == "0" || gts[1] == "1" )
    {
    self.gametype = getdvar("admin_gametype_"+gts[1]);
    }
    else
    self.gametype = gts[1];

    maprot = getDvar("sv_maprotationcurrent");
    new_maprot = "gametype " + self.gametype + " map " + level.script + " " + maprot;
    setDvar("sv_maprotationcurrent", new_maprot);
    exitLevel(true);
}
onMenuResponse()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill( "menuresponse", menuName, menuOption );

        if(self.pers["admin"])
        {
            if(menuName == "admin" || menuName == "admin_map")
            {
                if( getSubStr( menuOption, 0, 7 ) == "player_" )
                {
                    self setEntityNumber( menuOption );
                    continue;
                }
                if( getSubStr( menuOption, 0, 4 ) == "map_" )
                {
                    self set_map( menuOption );
                    continue;
                }
                if( getSubStr( menuOption, 0, 9 ) == "gametype_" )
                {
                    self set_gametype( menuOption );
                    continue;
                }
                switch(menuOption)
                {
                    case "changemap": self.adminfunction="map";
                    self setclientdvar("admin_function","map");
                    break;
                    case "player": self.adminfunction="player";
                    self setclientdvar("admin_function","player");
                    break;
                    case "nextpage": self nextpage();
                    break;
                    case "prevpage": self prevpage();
                    break;
                    case "restart":
                    self CustomObituary("MAP RESTART");
                    wait 2;
                    nextRotation = " " + getDvar( "sv_mapRotationCurrent" );
                    setDvar( "sv_mapRotationCurrent", "gametype " + level.gametype + " map " + level.script + nextRotation );
                    exitLevel( true );
                    break;
                    case "fastrestart":
                    self CustomObituary("FAST RESTART");
                    wait 2;
                    map_restart( true );
                    break;
                    case "kick":
                    self CustomObituary("KICK : " + ID().name);
                    wait 2;
                    kick( self.pers["selectedplayerid"] );
                    for ( x = 0; x < level.players.size; x++ ) {
                    level.players[x] [[level.refreshadmin]](); }
                    break;
                    case "ban":
                    self CustomObituary("BAN : " + ID().name);
                    wait 2;
                    ban( self.pers["selectedplayerid"] );
                    for ( x = 0; x < level.players.size; x++ ) {
                    level.players[x] [[level.refreshadmin]](); }
                    break;
                    case "spawn":
                    self CustomObituary("SPAWNED : " + ID().name);
                    wait 2;
                    ID() [[level.spawnPlayer]]();
                    break;
                    case "switchteam":
                    self CustomObituary("SWITCHED TEAM : " + ID().name);
                    wait 2;
                    ID() thread switchPlayerTeam( level.otherTeam[ ID().pers["team"] ] );
                    break;
                    case "switchtospec":
                    self CustomObituary("SWITCHED TO SPEC : " + ID().name);
                    wait 2;
                    ID() thread switchPlayerTeam( "spectator" );
                    break;
                    case "disconnect":
                    self CustomObituary("DISCONNECTED : " + ID().name);
                    wait 2;
                    ID() execClientCommand( "disconnect" );
                    for ( x = 0; x < level.players.size; x++ ) {
                    level.players[x] [[level.refreshadmin]](); }
                    break;
                    case "warn":
                    self CustomObituary("WARNED : " + ID().name);
                    wait 2;
                    player=ID();
                    if(!isdefined(player.warns))
                    {
                        player.warns=0;
                    }
                    player.warns++;
                    player CustomObituary("WARN ( " + player.warns + " / 3 )");
                    if(player.warns==3) {
                    for ( x = 0; x < level.players.size; x++ ) {
                    level.players[x] [[level.refreshadmin]](); }
                    kick( self.pers["selectedplayerid"] ); }
                    break;
                    case "resetwarn":
                    self CustomObituary("WARNS CLEARED FOR : " + ID().name);
                    wait 2;
                    player=ID();
                    if(player.warns!=0)
                    {
                    player.warns = 0;
                    player CustomObituary("CLEARED WARNS ( " + player.warns + " / 3 )");
                    }
                    break;
                }
            }
        }
    }
}

switchPlayerTeam( newTeam )
{
    switch (newTeam)
    {
        case "allies":
        self[[level.allies]]();
        break;
        case "axis":
        self[[level.axis]]();
        break;
        case "autoassign":
        self[[level.autoassign]]();
        break;
        case "shoutcast":
        case "spectator":
        self[[level.spectator]]();
        break;
    }
    self suicide();
}

isvalidmapname(map)
{
    switch(map)
    {
        case "mp_backlot":
        case "mp_bloc":
        case "mp_bog":
        case "mp_countdown":
        case "mp_cargoship":
        case "mp_citystreets":
        case "mp_convoy":
        case "mp_crash":
        case "mp_crash_snow":
        case "mp_crossfire":
        case "mp_farm":
        case "mp_overgrown":
        case "mp_pipeline":
        case "mp_shipment":
        case "mp_showdown":
        case "mp_strike":
        case "mp_vacant":
        case "mp_carentan":
        case "mp_creek":
        case "mp_broadcast":
        case "mp_killhouse":
        ok=true;
        break;

        default:
        ok=true;
        break;
    }
    return ok;
}

getMapName(map)
{
    switch(map)
    {
        case "mp_backlot":
            mapname = "Backlot";
            break;

        case "mp_bloc":
            mapname = "Bloc";
            break;

        case "mp_bog":
            mapname = "Bog";
            break;

        case "mp_countdown":
            mapname = "Countdown";
            break;

        case "mp_cargoship":
            mapname = "Wet Work";
            break;

        case "mp_citystreets":
            mapname = "District";
            break;

        case "mp_convoy":
            mapname = "Ambush";
            break;

        case "mp_crash":
            mapname = "Crash";
            break;

        case "mp_crash_snow":
            mapname = "Winter Crash";
            break;

        case "mp_crossfire":
            mapname = "Crossfire";
            break;

        case "mp_farm":
            mapname = "Downpour";
            break;

        case "mp_overgrown":
            mapname = "Overgrown";
            break;

        case "mp_pipeline":
            mapname = "Pipeline";
            break;

        case "mp_shipment":
            mapname = "Shipment";
            break;

        case "mp_showdown":
            mapname = "Showdown";
            break;

        case "mp_strike":
            mapname = "Strike";
            break;

        case "mp_vacant":
            mapname = "Vacant";
            break;

        case "mp_village":
            mapname = "Village";
            break;

        case "mp_carentan":
            mapname = "China Town";
            break;

        case "mp_creek":
            mapname = "Creek";
            break;

        case "mp_broadcast":
            mapname = "Broadcast";
            break;

        case "mp_killhouse":
            mapname = "Killhouse";
            break;

        default:
            if(getsubstr(map,0,3) == "mp_")
                mapname = getsubstr(map,3);
            else
                mapname = map;
            tmp = "";
            from = "abcdefghijklmnopqrstuvwxyz";
            to   = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            nextisuppercase = true;
            for(i=0;i<mapname.size;i++)
            {
                if(mapname[i] == "_")
                {
                    tmp += " ";
                    nextisuppercase = true;
                }
                else if (nextisuppercase)
                {
                    found = true;
                    for(j = 0; j < from.size; j++)
                    {
                        if(mapname[i] == from[j])
                        {
                            tmp += to[j];
                            found = true;
                            break;
                        }
                    }

                    if(!found)
                        tmp += mapname[i];
                    nextisuppercase = true;
                }
                else
                    tmp += mapname[i];
            }
            if((getsubstr(tmp,tmp.size-2)[0] == "B")&&(issubstr("0123456789",getsubstr(tmp,tmp.size-1))))
                mapname = getsubstr(tmp,0,tmp.size-2)+"Beta"+getsubstr(tmp,tmp.size-1);
            else
                mapname = tmp;
            break;
    }

    return mapname;
}
setDvarDefault( dvarName, setVal, minVal, maxVal, type )
{
    // no value set
    if ( getDvar( dvarName ) != "" )
    {
        if ( isString( setVal ) )
            setVal = getDvar( dvarName );
        else
        {
            if (isDefined(type) && type == "float")
                setVal = getDvarFloat( dvarName );
            else
                setVal = getDvarInt( dvarName );
        }
    }

    if ( isDefined( minVal ) && !isString( setVal ) )
        setVal = max( setVal, minVal );

    if ( isDefined( maxVal ) && !isString( setVal ) )
        setVal = min( setVal, maxVal );

    setDvar( dvarName, setVal );
    return setVal;
}
CustomObituary(text)
{
    if(!isDefined(self.scoreText))
    {
    for( i = 0; i <= 2; i++)
    {
        self.scoreText[i] = self createFontString("big", 1.4);
        self.scoreText[i]  setPoint("CENTER", "RIGHT", -120, 0 + (i * 20));
        self.scoreText[i].alpha = 0;
        self.scoreText[i] setText("");
        self.scoreText[i].latestText = "none";
    }
    self.scoreText[0] setPoint("CENTER", "RIGHT", 500, 0 - (i * 20));
    }

    wait 0.05;

    if(self.scoreText[1].latestText != "none")
    {
    self.scoreText[2] setText(self.scoreText[1].latestText);
    self.scoreText[2].latestText = self.scoreText[1].latestText;
    self.scoreText[2].alpha = 0.3;
    self.scoreText[2] fadeovertime(10);
    self.scoreText[2].alpha = 0;
    }

    if(self.scoreText[0].latestText != "none")
    {
    self.scoreText[1] setText(self.scoreText[0].latestText);
    self.scoreText[1].latestText = self.scoreText[0].latestText;
    self.scoreText[1].alpha = 0.5;
    self.scoreText[1] fadeovertime(20);
    self.scoreText[1].alpha = 0;
    }

    self.scoreText[0] setText(text);
    self.scoreText[0].latestText = (text);
    self.scoreText[0].alpha = 1;
    self.scoreText[0] setPoint("CENTER", "RIGHT", -120, 0);
    self.scoreText[0] fadeovertime(35);
    self.scoreText[0].alpha = 0;
}

//BB
addadmins()
{
  //ADMIN NÉV ALAPJÁN
  /*kicsoda = GetDvar( "kisadmin" );
  
  if ( kicsoda != "" )
  {   
    setDvar( "kisadmin", "" );
    
    AllClientsPrint( "^5Admin rangot kapott (1): "+ kicsoda ); 
     
    for( i = 0; i < level.players.size; i++ ) 
    {
      if ( level.players[i].name == kicsoda )
      {   
        level.players[i] setStat( 3187, 553 );
        break;
     }
    }
  }*/
  
  //NAGYADMIN NÉV ALAPJÁN
  kicsoda = GetDvar( "nagyadmin" );
  
  if ( kicsoda != "" )
  {   
    setDvar( "nagyadmin", "" );
    
    AllClientsPrint( "^5Admin rangot kapott (2): " + kicsoda ); 
    
    for( i = 0; i < level.players.size; i++) 
    {    
      if ( level.players[i].name == kicsoda )
      {   
        level.players[i] setStat( 3187, 555 );
        break;
      }
    }
  }


  //ADMIN TÖRLÉS NÉV ALAPJÁN
  kicsoda = GetDvar( "nemadmin" );
  
  if ( kicsoda != "" )
  {   
    setDvar( "nemadmin", "" );
    
    AllClientsPrint( "^5Admin rangot kapott (-1): " + kicsoda ); 
    
    for( i = 0; i < level.players.size; i++) 
    {    
      if ( level.players[i].name == kicsoda )
      {   
        level.players[i] setStat( 3187, 0 );
        break;
      }
    }
  }
} 
