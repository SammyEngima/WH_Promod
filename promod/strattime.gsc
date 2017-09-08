#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;

main()
{
  if( game["promod_timeout_called"] )
  {
    thread promod\timeout::main();
    return;
  }
  
  thread stratTime();
  //CSAPATBALANCE
  thread StratTimeBalance();

  level waittill("strat_over");
  players = getentarray( "player", "classname" );
  
  for( i = 0; i < players.size; i++ )
  {
    player = players[i];
    classType = player.pers["class"];
    
    if( ( player.pers["team"] == "allies" || player.pers["team"] == "axis") && player.sessionstate == "playing" && isDefined( player.pers["class"] ) )
    {
      if( isDefined( game["PROMOD_KNIFEROUND"] ) && !game["PROMOD_KNIFEROUND"] || !isDefined( game["PROMOD_KNIFEROUND"] ) )
      {
        if( level.hardcoreMode && getDvarInt( "weap_allow_frag_grenade" ) )
          player giveWeapon("frag_grenade_short_mp");
        else
          if( getDvarInt( "weap_allow_frag_grenade" ) )          
            player giveWeapon("frag_grenade_mp");
              
        if( player.pers[classType]["loadout_grenade"] == "flash_grenade" && getDvarInt( "weap_allow_flash_grenade" ) )
        {
          player setOffhandSecondaryClass("flash");
          player giveWeapon("flash_grenade_mp");
        }
        else if ( player.pers[classType]["loadout_grenade"] == "smoke_grenade" && getDvarInt( "weap_allow_smoke_grenade" ) )
        {
          player setOffhandSecondaryClass("smoke");
          player giveWeapon("smoke_grenade_mp");
        }
        player maps\mp\gametypes\_class::sidearmWeapon();
        player maps\mp\gametypes\_class::primaryWeapon();
      }
      else
        player thread maps\mp\gametypes\_globallogic::removeWeapons();
        
      player allowsprint( true );
      player setMoveSpeedScale( 1.0 - 0.05 * int( isDefined( player.curClass ) && player.curClass == "assault" ) * int( isDefined( game["PROMOD_KNIFEROUND"] ) && !game["PROMOD_KNIFEROUND"] || !isDefined( game["PROMOD_KNIFEROUND"] ) ) );
      player allowjump( true );
    }
  }
  
  UpdateClientNames();
}

stratTime()
{
  thread stratTimer();
  level.strat_over = false;
  strat_time_left = game["PROMOD_STRATTIME"] + level.prematchPeriod * int( getDvarInt( "promod_allow_strattime" ) && isDefined( game["CUSTOM_MODE"] ) && game["CUSTOM_MODE"] && level.gametype == "sd");
  
  while( !level.strat_over )
  {
    players = getentarray( "player", "classname" );
    
    for( i = 0; i < players.size; i++ )
    {
      player = players[i];
      
      if ( ( player.pers["team"]=="allies" || player.pers["team"] == "axis" ) && !isDefined( player.pers["class"] ) )
        player.statusicon = "hud_status_dead";
    }
    
    wait ( 0.25 );
    
    strat_time_left -= 0.25;
    
    if ( strat_time_left == 2 )
      level notify( "default_vision" );
    
    if ( strat_time_left <= 0 || game["promod_timeout_called"] )
      level.strat_over = true;
  }
  
  level notify( "strat_over" );
}

stratTimer()
{
  visionSetNaked( "mpIntro", 0 ); 
  
  //BB
  level.STARTTICK = true;
  
  matchStartText = createServerFontString( "objective", 1.5 );
  matchStartText setPoint( "CENTER", "CENTER", 0, -60 );
  matchStartText.sort = 1001;
  
  if ( isDefined( game["PROMOD_KNIFEROUND"] ) && game["PROMOD_KNIFEROUND"] )
    matchStartText setText( "^1Knife Round ^7(^1Jump ^7= ^1KICK^7)" );
  else
    matchStartText setText( "^1Mehet ^7??" );
  
  wait ( 0.1 );
  
  matchStartText.foreground = false;
  matchStartText.hidewheninmenu = false;
  matchStartText.glowAlpha = 1;
  
  matchStartTimer = createServerTimer( "objective", 1.4 );
  matchStartTimer setPoint( "CENTER", "CENTER", 0, -45 );
  matchStartTimer setTimer( game["PROMOD_STRATTIME"] + level.prematchPeriod * int( getDvarInt( "promod_allow_strattime" ) && isDefined( game["CUSTOM_MODE"] ) && game["CUSTOM_MODE"] && level.gametype == "sd" ) );
  matchStartTimer.sort = 1001;
  matchStartTimer.foreground = false;
  matchStartTimer.hideWhenInMenu = false;
  matchStartTimer.glowAlpha = 1;
  
  level waittill( "default_vision" );
  
  visionSetNaked( getDvar( "mapname" ), 2 );
  
  level waittill( "strat_over" );
  
  //BB
  level.STARTTICK = false;
  
  if( isDefined( matchStartText ) )
    matchStartText destroy();
    
  if( isDefined( matchStartTimer ) )
    matchStartTimer destroy();
}

//BADBOYS-Strattimeközbenbalancejelzése
StratTimeBalance()
{
  wait ( 1.5 );
  
  axisCount = getPlayerCount( "axis" );
  alliesCount = getPlayerCount( "allies" );
  
  if( abs( alliesCount - axisCount ) > 1 )
  {
    iprintlnBold( "BalanceTeams! (" + alliesCount + " vs " + axisCount + ")");
  }
}

getPlayerCount( a )
{
  b = 0;
  c = getentarray( "player", "classname" );
  
  for( d=0; d < c.size; d++)
  {
    if( c[d].pers["team"] == a )
      b++;
  }
  
  return b;
}