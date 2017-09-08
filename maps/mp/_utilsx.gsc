#include maps\mp\gametypes\_hud_util;


dvardef( varname, vardefault, min, max, type )
{
  if( isDefined( level.script ) )
    mapname = level.script;
  else
    mapname = toLower( getdvar("mapname") );

  if( isDefined( level.gametype ) )
    gametype = level.gametype;
  else
    gametype = getdvar( "g_gametype" );

  both = gametype + "_" + mapname;

  tempvar = varname + "_" + gametype;
  if( getdvar( tempvar ) != "" )
    varname = tempvar;

  tempvar = varname + "_" + mapname;
  if( getdvar( tempvar ) != ""  )
    varname = tempvar;

  tempvar = varname + "_" + both;
  if( getdvar( tempvar ) != "" )
    varname = tempvar;

  switch( type )
  {
    case "float":
      if( getdvar( varname ) == "" )
        definition = vardefault;
      else
        definition = getdvarfloat( varname );
      break;

    case "string":
      if( getdvar( varname ) == "" )
        definition = vardefault;
      else
        definition = getdvar( varname );
      break;

    case "int":
    default:
      if( getdvar( varname ) == "" )
        definition = vardefault;
      else
        definition = getdvarint( varname );
      break;
  }

  if( ( type == "int" || type == "float" ) && definition < min )
    definition = min;


  if( ( type == "int" || type == "float" ) && definition > max )
    definition = max;

  return definition;
}

setDvarDef( dvar, value )
{
  if( isdefined( level.script ) )
    mapname = level.script;
  else
    mapname = getDvar( "mapname" );

  if( isdefined( level.gametype ) )
    gametype = level.gametype;
  else
    gametype = getDvar( "g_gametype" );

  suffixed_dvar = dvar + "_" + gametype + "_" + mapname;

  setDvar( suffixed_dvar, value );
}

setClientDvarDef( dvar, value )
{
  if( isdefined( level.script ) )
    mapname = level.script;
  else
    mapname = getDvar( "mapname" );

  if( isdefined( level.gametype ) )
    gametype = level.gametype;
  else
    gametype = getDvar( "g_gametype" );

  suffixed_dvar = dvar + "_" + gametype + "_" + mapname;

  self setClientDvar( suffixed_dvar, value );
}

