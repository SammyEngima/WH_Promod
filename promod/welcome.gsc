dlc_msg_go()
{
	
	level.welcomeduration = 4.0;
	
	level thread onPlayerConnect();

}

onPlayerConnect()
{
	for(;;) 
	{

		level waittill( "connected", player );
		
		player.messageDone = undefined;
		
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	for( ;; )
	{
		self waittill( "spawned_player" );
		
 self thread welc_issue( "^1Üdv a szerveren ^7" + self.name + ".", "^7Jó szórakozást kívánunk" );
 }
}

welc_issue( welc1, welc2 )
{
	if( isDefined( self.messageDone ) )
		return;
		
	self.messageDone = true;
	
	self endon( "intermission" );
	self endon( "disconnect" );
	self endon( "killthreads" );
	self endon( "game_ended" );

	notifyData = spawnStruct();
	notifyData.notifyText = welc1;
	notifyData.glowColor = (0.3, 0.6, 0.3);
	notifyData.duration = level.welcomeduration;

	notifyData.sort = 5;
	notifyData.hideWhenInMenu = true;
	self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
	
	wait( 2 );
	
	notifyData = spawnStruct();
	notifyData.notifyText = welc2;
	notifyData.glowColor = (0.3, 0.6, 0.3);
	notifyData.duration = level.welcomeduration;

	notifyData.sort = 5;
	notifyData.hideWhenInMenu = true;
	self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}  