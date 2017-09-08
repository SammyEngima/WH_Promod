#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

finalKillcamWaiter()
{
	if ( !level.inFinalKillcam )
		return;
		
	while (level.inFinalKillcam)
		wait(0.05);
}

postRoundFinalKillcam()
{	
	level notify( "play_final_killcam" );
	resetOutcomeForAllPlayers();
	finalKillcamWaiter();	
}

startFinalKillcam( 
	attackerNum, // entity number of the attacker
	targetNum, // entity number of the target
	killcamentity, // entity to view during killcam aka helicopter or airstrike
	killcamentityindex, // entity number of the above
	killcamentitystarttime, // time at which the killcamentity came into being
	sWeapon, // killing weapon
	deathTime, // time when the player died
	deathTimeOffset, // time between player death and beginning of killcam
	offsetTime, // something to do with how far back in time the killer was seeing the world when he made the kill; latency related, sorta
	attacker // entity object of attacker
)
{	
	setdvar("timescale","1");
	if(attackerNum < 0)
		return;
	
	recordKillcamSettings( attackerNum, targetNum, sWeapon, deathTime, deathTimeOffset, offsetTime, killcamentityindex, killcamentitystarttime, attacker  );
	startLastKillcam();
}

startLastKillcam()
{
	if ( level.inFinalKillcam )
		return;

	if ( !isDefined(level.lastKillCam) )
		return;
	
	level.inFinalKillcam = true;
	level waittill ( "play_final_killcam" );

	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		player closeMenu(); 
		player closeInGameMenu();
		player thread finalKillcam();
	}
	visionSetNaked( getDvar( "mapname" ), 0 );
	
	wait( 0.1 );
	setdvar("timescale","0.74");

	while ( areAnyPlayersWatchingTheKillcam() )
		wait( 0.05 );

	level.inFinalKillcam = false;
	setdvar("timescale","1");
}


areAnyPlayersWatchingTheKillcam()
{
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		if ( isDefined( player.killcam ) )
			return true;
	}
	
	return false;
}

setKillCamEntity( killcamentityindex, delayms )
{
	self endon("disconnect");
	self endon("end_finalkillcam");
	self endon("spawned");
	
	if ( delayms > 0 )
		wait delayms / 1000;
	
	self.killcamentity = killcamentityindex;
}

waitKillcamTime()
{
	self endon("disconnect");
	self endon("end_finalkillcam");

	wait(self.killcamlength - 0.05);
	self notify("end_finalkillcam");
}
setTimeScale(to,time)
{
	difference = (abs(getTime() - time)/1000);
	timescale = getDvarFloat("timescale");
	if(difference != 0) {
	for(i = timescale*20; i >= to*20; i -= 1 )
	{
	wait min(0.05,(int(difference)/int(getDvarFloat("timescale")*20))/20);
	setDvar("timescale",i/20);
	} }
	else
	setDvar("timescale",to);
}
endKillcam()
{
	if(isDefined(self.fkc_timer))
		self.fkc_timer.alpha = 0;
		
	if(isDefined(self.killertext))
	self.killertext.alpha = 0;
		
	self setClientDvar("finalcamplaying", 0);
	
	self.killcam = undefined;
	
	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}

checkForAbruptKillcamEnd()
{
	self endon("disconnect");
	self endon("end_finalkillcam");
	
	while(1)
	{
		if ( self.archivetime <= 0 )
			break;
		wait .05;
	}
	
	self notify("end_finalkillcam");
}

endedFinalKillcamCleanup()
{
	self endon("end_finalkillcam");
	self endon("disconnect");

	level waittill("game_ended");
	self endKillcam(true);
}

recordKillcamSettings( spectatorclient, targetentityindex, sWeapon, deathTime, deathTimeOffset, offsettime, entityindex, entitystarttime, attacker )
{
	if ( !isDefined(level.lastKillCam) )
		level.lastKillCam = spawnStruct();
	
	level.lastKillCam.spectatorclient = spectatorclient;
	level.lastKillCam.weapon = sWeapon;
	level.lastKillCam.deathTime = deathTime;
	level.lastKillCam.deathTimeOffset = deathTimeOffset;
	level.lastKillCam.offsettime = offsettime;
	level.lastKillCam.entityindex = entityindex;
	level.lastKillCam.targetentityindex = targetentityindex;
	level.lastKillCam.entitystarttime = entitystarttime;
	level.lastKillCam.attacker = attacker;
}

finalKillcam()
{
	self endon("disconnect");
	level endon("game_ended");
	
	self notify( "end_killcam" );
	
	postDeathDelay = (getTime() - level.lastKillCam.deathTime) / 1000;
	predelay = postDeathDelay + level.lastKillCam.deathTimeOffset;

	camtime = calcKillcamTime( level.lastKillCam.weapon, level.lastKillCam.entitystarttime, predelay, false, undefined );
	postdelay = calcPostDelay();

	killcamoffset = camtime + predelay;
	killcamlength = camtime + postdelay - 0.05; // We do the -0.05 since we are doing a wait below.

	killcamstarttime = (gettime() - killcamoffset * 1000);

	self notify ( "begin_killcam", getTime() );

	self.sessionstate = "spectator";
	self.spectatorclient = level.lastKillCam.spectatorclient;
	self.killcamentity = -1;
	if ( level.lastKillCam.entityindex >= 0 )
		self thread setKillCamEntity( level.lastKillCam.entityindex, level.lastKillCam.entitystarttime - killcamstarttime - 100 );
	self.killcamtargetentity = level.lastKillCam.targetentityindex;
	self.archivetime = killcamoffset;
	self.killcamlength = killcamlength;
	self.psoffsettime = level.lastKillCam.offsettime;

	// ignore spectate permissions
	self allowSpectateTeam("allies", true);
	self allowSpectateTeam("axis", true);
	self allowSpectateTeam("freelook", false);
	self allowSpectateTeam("none", false);

	self thread endedFinalKillcamCleanup();
	
	// wait till the next server frame to allow code a chance to update archivetime if it needs trimming
	wait 0.05;

	if ( self.archivetime <= predelay ) // if we're not looking back in time far enough to even see the death, cancel
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;

		self notify ( "end_finalkillcam" );
		
		return;
	}
	
	self thread checkForAbruptKillcamEnd();

	self.killcam = true;

	self addKillcamTimer(camtime);
	self addKillcamKiller(level.lastKillCam.attacker.name);
	self setClientDvar("finalcamplaying", 1);
	
	self thread waitKillcamTime();
	//self thread waitFinalKillcamSlowdown( killcamstarttime );

	self waittill("end_finalkillcam");

	self endKillcam();
	self spawnEndOfFinalKillCam();
}

// This puts the player to the intermission point as a spectator once the killcam is over.
spawnEndOfFinalKillCam()
{
	self freezeControls( true );
	[[level.spawnSpectator]]();
	self freezeControls( true );
}

checkWeaponAndSetDistance(sWeapon)
{
	camtime = 5;
	if (sWeapon == "artillery_mp")
	{
		camdist = 128;
		camtime = 1.3;
	}
	else if(isSubStr(sWeapon,"gl_") && ! isSubStr(sWeapon,"_gl_"))
	{
		camdist = 40;
		camtime = 5;
	}
	else if(sWeapon == "rpg_mp")
		camdist = 40;
	else if(sWeapon == "frag_grenade_mp")
	{
		camdist = 20;
		camtime = 4.5;
	}
	else if(sWeapon == "c4_mp")
	{
		camdist = 40;
		camtime = 4.5;
	}
	else if(sWeapon == "claymore_mp")
	{
		camdist = 40;
		camtime = 4.5;
	}
	else if(sWeapon == "cobra_20mm_mp")
	{
		camdist = 40;
		camtime = 3;
	}
	else if(sWeapon == "cobra_FFAR_mp" || sWeapon == "hind_FFAR_mp")
		camdist = 60;
	else
		camdist = 40;
		
	self setClientDvar("cg_airstrikeKillCamDist",camdist);
	
	return camtime;
}
calcKillcamTime( sWeapon, entitystarttime, predelay, respawn, maxtime )
{
	camtime = 0.0;
	
	camtime = checkWeaponAndSetDistance(sWeapon);
	
	if (isdefined(maxtime)) {
		if (camtime > maxtime)
			camtime = maxtime;
		if (camtime < .05)
			camtime = .05;
	}
	
	return camtime;
}

calcPostDelay()
{
	postdelay = 0;
	
		// time after player death that killcam continues for
	if (getDvar( "scr_killcam_posttime") == "")
	{
		postdelay = 2;
	}
	else 
	{
		postdelay = getDvarFloat( "scr_killcam_posttime");
		if (postdelay < 0.05)
			postdelay = 0.05;
	}
	
	return postdelay;
}
moveKiller()
{
	self endon("disconnect");
	self endon("end_finalkillcam");

	for(;;)
	{
		self moveOverTime(2);
		self.x += 40;
		wait 2.1;
		self moveOverTime(2);
		self.x -= 40;
		wait 2.1;
	}
}
addKillcamKiller(name)
{	
	if(! isDefined( self.killertext ) )
	{
	self.killertext = createFontString("default", level.lowerTextFontSize);
	self.killertext setPoint("BOTTOM", "BOTTOM", 0, -100);
	self.killertext.archived = false;
	self.killertext.alpha = 1;
	}
	self.killertext setText(name);
	self.killertext.alpha = 1;
	self.killertext thread moveKiller();
}
addKillcamTimer(camtime)
{
	if (! isDefined(self.fkc_timer))
	{
			self.fkc_timer = createFontString("big", 2.0);
			self.fkc_timer.archived = false;
			self.fkc_timer.x = 0;
			self.fkc_timer.alignX = "center";
			self.fkc_timer.alignY = "middle";
			self.fkc_timer.horzAlign = "center_safearea";
			self.fkc_timer.vertAlign = "top";
			self.fkc_timer.y = 50;
			self.fkc_timer.sort = 1;
			self.fkc_timer.font = "big";
			self.fkc_timer.foreground = true;
			self.fkc_timer.color = (0.85,0.85,0.85);
			self.fkc_timer.hideWhenInMenu = true;
	}
	self.fkc_timer.y = 50;
	self.fkc_timer.alpha = 1;
	self.fkc_timer setTenthsTimer(camtime);
}

resetOutcomeForAllPlayers()
{
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		player notify ( "reset_outcome" );
	}
}
