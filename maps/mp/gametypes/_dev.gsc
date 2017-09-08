addTestClients()
{
	wait 5;

	for(;;)
	{
		if(getdvarInt("scr_testclients") > 0)
			break;
		wait 1;
	}
	
	testclients = getdvarInt("scr_testclients");
	setDvar( "scr_testclients", 0 );
	for(i = 0; i < testclients; i++)
	{
		ent[i] = addtestclient();

		if (!isdefined(ent[i])) {
			println("Could not add test client");
			wait 1;
			continue;
		}
			
		/*if(i & 1)
			team = "allies";
		else
			team = "axis";*/
			
		ent[i].pers["isBot"] = true;

		if( level.rankedMatch )
			ent[i] thread TestClient("autoassign");
		else
		    ent[i] thread TestClient_mw("autoassign");
	}
	
	thread addTestClients();
}
