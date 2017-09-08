
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

  for(;;)
  {
    self waittill( "menuresponse", menu, response);

    if( menu == "-1" )
    {
      switch( response )
      {
      
        case "checkmag":
					self thread openwarfare\_checkmagcount::checkweaponsmags();
					break;

        case "cyclefpslag":
               self thread maps\mp\_cyclefpslag::cycleFPSLagometer();
               break;

        case "bxmod_admin":
          if ( 2>= 1 )
          {
             if ( 2>= 1 )
            {
             if( !self.inAdminMenu )
                 { self.inAdminMenu = true; }
              self openmenu (game["menu_admin_player"]);

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