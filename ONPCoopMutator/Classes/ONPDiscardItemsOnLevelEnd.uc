class ONPDiscardItemsOnLevelEnd expands Info;

function PostBeginPlay()
{
	local float ServerTravelPause;
	ServerTravelPause = float(ConsoleCommand("get IpDrv.TcpNetDriver ServerTravelPause"));
	if (ServerTravelPause < 0.5)
		ConsoleCommand("set IpDrv.TcpNetDriver ServerTravelPause 0.5");
}

function Tick(float DeltaTime)
{
	Level.bNextItems = false;
}

defaultproperties
{
	RemoteRole=ROLE_None
}

