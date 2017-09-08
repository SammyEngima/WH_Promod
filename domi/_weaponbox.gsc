init()
{
	level.addRandomWep = [];
	addRandomWep("weapon_beretta", "beretta_mp");
	addRandomWep("weapon_ak47", "ak47_mp");
	addRandomWep("weapon_remington700", "remington700_mp");
	addRandomWep("weapon_g3", "g3_mp");
	addRandomWep("weapon_USP", "usp_mp");
	addRandomWep("weapon_mp5", "mp5_mp");
	addRandomWep("weapon_m4_mp", "m4_mp");
	addRandomWep("weapon_ak74u", "ak74u_mp");
	addRandomWep("weapon_m14_mp", "m14_mp");
	addRandomWep("weapon_m40a3", "m40a3_mp");
	addRandomWep("weapon_skorpion", "skorpion_mp");
	addRandomWep("weapon_mini_uzi", "uzi_mp");
	addRandomWep("weapon_g36_mp", "g36c_mp");
	addRandomWep("weapon_m16_mp", "m16_mp");
	addRandomWep("weapon_mp44", "mp44_mp");
	thread setupSpawnSpots();
	level.cirleboxfx = loadfx ("misc/ui_flagbase_red");
	thread circlebox();
}

setupSpawnSpots() 
{
	level.spawnx = [];
	level.spots=[];
	level.spawnx["allies"] = getEntArray( "mp_jumper_spawn", "classname" );
	
	level.spawnx["axis"] = getEntArray( "mp_activator_spawn", "classname" );

	if( !level.spawnx["allies"].size )
		level.spawnx["allies"] = getEntArray( "mp_dm_spawn", "classname" );

	for( i = 0; i < level.spawnx["allies"].size; i++ )
	{
		level.spots[i] = Spawn( "script_origin",level.spawnx["allies"][i] getorigin() );
	}
	
	for( i = 0; i < level.spawnx["axis"].size; i++ )
	{
		level.spotsacti[i] = Spawn( "script_origin",level.spawnx["axis"][i] getorigin() );
	}
	

}

circlebox()
{
	self endon("disconnect");
	
	maxrandom=level.spots.size;
	level.randomwepbox=RandomInt(maxrandom);
	spawnspot=level.spots[level.randomwepbox].origin;
	spawn_0 =(spawnspot+(0,0,0));
	spawn_1=(spawnspot+(0,0,25));
	spawn_2=(spawnspot+(0,0,50));

	level waittill("round_started");
	
	circle_0 = spawn("script_model", spawn_0); 
	circle_0.angles=(0,0,0);
	circle_1 = spawn("script_model", spawn_1); 
	circle_1.angles=(0,0,0);
	circle_2 = spawn("script_model", spawn_2); 
	circle_2.angles=(0,0,0);
	
	circle_0 thread playFxbox();
	circle_1 thread playFxbox();
	circle_2 thread playFxbox();
	
	thread AddGlobalbox(circle_0.origin,circle_0.angels);
	
}

AddGlobalbox(ori,angel)
{
	self endon("disconnect");
	
	trigger = spawn( "trigger_radius", ori + ( 0, 0, -40 ), 0, 35, 80 );
	thread AddGlobalTriggerMsgbox(ori,trigger,"^7Nyomj ^9[[{+activate}]] ^7Egy Random Fegyverhez");
	
	while(1)
	{
		trigger waittill("trigger", player);
		if(player usebuttonpressed())
			if(player.randomwep == 0)
				player thread OpenBox(ori);
	}
	wait .05;
}

AddGlobalTriggerMsgbox(ori,owner,msg)
{
	self endon("disconnect");
	
	while(isDefined(owner))
	{
		pl = getentarray("player", "classname");
		for(i=0;i<pl.size;i++)
		{	
			if(!isDefined(pl[i].notified_box))
				pl[i].notified_box = false;
			if(!isDefined(pl[i].randomwep))
				pl[i].randomwep = 0;
				
			if(pl[i].randomwep == 1)
			{
				if(distance(pl[i].origin,ori) <= 50 && !pl[i].notified_box)
				{
					pl[i].notified_box = true;
					pl[i] maps\mp\_utility::setLowerMessage("InUse");
				}
				else if( isDefined(pl[i].notified_box) && pl[i].notified_box && distance(pl[i].origin,ori) >= 50)
				{
					pl[i].notified_box = false;
					pl[i] maps\mp\_utility::clearLowerMessage();
				}
			}
			else
			{
				if(distance(pl[i].origin,ori) <= 50 && !pl[i].notified_box )
				{
					pl[i].notified_box = true;
					pl[i] maps\mp\_utility::setLowerMessage(msg);
				}
				else if( isDefined(pl[i].notified_box) && pl[i].notified_box && distance(pl[i].origin,ori) >= 50)
				{
					pl[i].notified_box = false;
					pl[i] maps\mp\_utility::clearLowerMessage();
				}
			}
		}
		wait .05;
	}
	pl = getentarray("player", "classname");
	for(i=0;i<pl.size;i++)	
		pl[i] maps\mp\_utility::clearLowerMessage();
}

OpenBox(ori)
{
	self.randomwep = 1;
	weapon = spawn( "script_model", ori + (0,0,20) );
	weapon.angles = (0,0,0);
	weapon hide();
	weapon showtoplayer(self);
	weapon moveZ( 30, 3 );
	thread RotateWep(weapon);
	lastnum = weapon createRandomItem(self);
	for( i = 0; i < 26; i++ )
	{
		wait 0.2;
		lastnum = weapon createRandomItem(self, lastnum);
	}
	weaponName = weapon.weaponName;
	weapon thread deleteOverTime(3);
			
	wait 2.5;
	self takeAllWeapons();
	self GiveWeapon(weapon.weaponName);
	self givemaxammo(weapon.weaponName);
	wait .1;
	self SwitchToWeapon(weapon.weaponName);
	self iprintlnbold("^2A ^5te fegyvered ^3" + weapon.weaponName);
	self.randomwep = 0;
}

createRandomItem(player, lastNum)
{
	self endon("disconnect");
	
	if (isdefined(lastNum))
	{
		num = randomInt( level.addRandomWep.size-3 );
		if (num >= lastNum)
		num++;
	}
	else
	{
		num = randomInt( level.addRandomWep.size-2 );
		lastNum = -2;
	}
	
	for (i=0; i<level.addRandomWep.size; i++)
	{
		wep = level.addRandomWep[i];
		if (i == num)
		{
			self Set_WepModel(wep.model);
			self.weaponName = wep.weaponName;
		}
	}
}

addRandomWep(model, weaponName)
{
	precachemodel(model);
	struct = spawnstruct();
	level.addRandomWep[level.addRandomWep.size] = struct;
	struct.model = model;
	struct.weaponName = weaponName;
}

RotateWep(preview)
{
	self endon( "disconnect" );
	self endon( "end_customization" );
	self notify( "stop_wep_rotation" );
	self endon( "stop_wep_rotationn" );
 
	wait 0.05;
	while( isDefined( preview ) )
	{
		preview rotateYaw( 360, 6 );
		wait 6;
	}
}

Set_WepModel( model )
{
        self detachAll();
        self setModel( model );
}

playFxbox()
{
	self endon("disconnect");
	self endon ( "death" );
	
	PlayFX( level.cirleboxfx, self.origin);
}

deleteOverTime(time)
{
	self endon("death");
	wait time;
	self delete();
}