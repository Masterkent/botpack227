class AccelerateMoviePawn expands MoviePawn;

var() vector MovieAcceleration;
var vector CurrentSpeed;
var vector AcceleratedPosition;
var float TimeSinceStartX;
var float TimeSinceStartY;
var float TimeSinceStartZ;
var bool bXAccel;
var bool bYAccel;
var bool bZAccel;

function Tick(float DeltaTime)
{
	log(self$": Tick() called - about to call Super.Tick()");
	Super.Tick(DeltaTime);
	log(self$": Super.Tick() finished...");
	log(self$": bXAccel is currently"@bXAccel);
	log(self$": bYAccel is currently"@bYAccel);
	log(self$": bZAccel is currently"@bZAccel);
	
	if(bXAccel)
	{
		log(self$": bXAccel is true");
		TimeSinceStartX += DeltaTime;
		CurrentSpeed.X = TimeSinceStartX * MovieAcceleration.X;
	}

	if(bYAccel)
	{
		log(self$": bYAccel is true");
		TimeSinceStartY += DeltaTime;
		CurrentSpeed.Y = TimeSinceStartY * MovieAcceleration.Y;
	}

	if(bZAccel)
	{
		log(self$": bZAccel is true");
		TimeSinceStartZ += DeltaTime;
		CurrentSpeed.Z = TimeSinceStartZ * MovieAcceleration.Z;
	}
	
	log(self$": MovieAcceleration ="@MovieAcceleration);
	log(self$": CurrentSpeed ="@CurrentSpeed);
	
	log(self$": CurrentLocation ="@Location);
	
	AcceleratedPosition.X = (Location.X + (CurrentSpeed.X * DeltaTime));
	AcceleratedPosition.Y = (Location.Y + (CurrentSpeed.Y * DeltaTime));
	AcceleratedPosition.Z = (Location.Z + (CurrentSpeed.Z * DeltaTime));
	
	log(self$": AcceleratedLocation ="@AcceleratedPosition);
	
	SetLocation(AcceleratedPosition);
}

function PreBeginPlay()
{
	CurrentSpeed.X = 0;
	CurrentSpeed.Y = 0;
	CurrentSpeed.Z = 0;
}

function ChangeAccel(vector AccelDir)
{
	log(self$": ChangeAccel() called");
	
	if(AccelDir.X > 0)
	{
		log(self$": AccelDir.X > 0");
		bXAccel = true;
		TimeSinceStartX = 0;
	}
	else if(AccelDir.X < 0)
	{
		log(self$": AccelDir.X < 0");
		bXAccel = false;
	}

	if(AccelDir.Y > 0)
	{
		log(self$": AccelDir.Y > 0");
		bYAccel = true;
		TimeSinceStartY = 0;
	}
	else if(AccelDir.Y < 0)
	{
		log(self$": AccelDir.Y < 0");
		bYAccel = false;
	}

	if(AccelDir.Z > 0)
	{
		log(self$": AcelDir.Z > 0");
		bZAccel = true;
		TimeSinceStartZ = 0;
	}
	else if(AccelDir.Z < 0)
	{
		log(self$": AccelDir.Z < 0");
		bZAccel = false;
	}
}

defaultproperties
{
}
