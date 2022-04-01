// This enchantment allows the caster to communicate with someone
// Code by Sergey 'Eater' Levin, 2002

class NCPawnEnchantTalk extends NCPawnEnchant;

var NCCommPoint commPoint;
var float sparkTime;

function Timer() {
	local NCDiary diary;
	local Inventory Inv;
	local nccommpoint cp;
	local actor A;

	cp = commPoint;
	if (instigator == none || cp == none) Return;
	NaliMage(instigator).ConvString = cp.ConvStrings[cp.conversenum];
	if (cp.PlayerSpeaks[cp.conversenum] > 0)
		NaliMage(instigator).CurrentTalker = instigator;
	else
		NaliMage(instigator).CurrentTalker = cp;
	instigator.PlaySound(cp.ConvSounds[cp.conversenum],Slot_Talk);
	NaliMage(instigator).TalkBegin = Level.TimeSeconds;
	NaliMage(instigator).TalkLast = NCHUD(NaliMage(instigator).myHUD).modifySpeakTime(cp.convspeaktime[cp.conversenum]);
	if (cp.ConvSounds[cp.conversenum] != None) {
		SetTimer(NCHUD(NaliMage(instigator).myHUD).modifySpeakTime(cp.convspeaktime[cp.conversenum]),false);
		cp.conversenum++;
	}
	else {
		if (cp.ConvEndEvent != '') {
			foreach AllActors( class 'Actor', A, cp.ConvEndEvent )
				A.Trigger( self, self.Instigator );
		}
		if (cp.bNewDiary) {
			cp.bNewDiary = false;
			for( Inv=instigator.Inventory; Inv!=None; Inv=Inv.Inventory ) {
				if (NCDiary(Inv)!=None) {
					diary = NCDiary(Inv);
					NCDiary(Inv).AddMessage(cp.DiaryMsg);
					Pawn(Owner).ClientMessage("New diary entry added! Open diary to read",'Pickup');
					if (!NCDiary(Inv).isInState('Activated') && PlayerPawn(instigator).bFire == 0 && PlayerPawn(instigator).bAltFire == 0) {
						NCDiary(Inv).bTempAct = true;
						NCDiary(Inv).OpenUp();
					}
					Break;
				}
			}
		}
		cp.conversenum = 0;
		if (cp.speakOnce) cp.destroy();
		cp.enchant = none;
		cp = none;
		bFadingOut = true;
		FadeStartTime = Level.TimeSeconds;
	}
}

function Tick(float DeltaTime) {
	local playerpawn pp;
	local rotator newrot;
	local NCMovingSpark s;
	local vector newloc;

	newrot = rotator(instigator.location-location);
	newrot.pitch = 0;
	setRotation(newrot);
	if (bFadingOut) {
		sparkTime+=DeltaTime;
		if (sparkTime >= 0.25) {
			newloc = location;
			newloc.x += Rand(CollisionRadius*2)-CollisionRadius;
			newloc.y += Rand(CollisionRadius*2)-CollisionRadius;
			newloc.z += Rand(CollisionHeight*2);
			sparkTime -= 0.5;
			s=Spawn(Class'NCMovingSpark',,,location,rotator(newloc-location));
			s.travelDist = VSize(newloc-location);
			s.launch();
		}
		Fadeout();
	}
	else {
		if (Level.TimeSeconds-FadeStartTime < FadeTime) {
			sparkTime+=DeltaTime;
			if (sparkTime >= 0.25) {
				sparkTime -= 0.5;
				newloc = location;
				newloc.x += Rand(CollisionRadius*2)-CollisionRadius;
				newloc.y += Rand(CollisionRadius*2)-CollisionRadius;
				newloc.z += Rand(CollisionHeight*2);
				s=Spawn(Class'NCMovingSpark',,,newloc,rotator(location-newloc));
				s.travelDist = VSize(newloc-location);
				s.launch();
			}
			CalculateFade();
		}
	}
}

function CalculateFade() {
	ScaleGlow = (Level.TimeSeconds-FadeStartTime)/FadeTime;
}

function PlayStartAnim() {
	local NCCommPoint sp;
	local bool bGotLoc;

	FadeStartTime = Level.TimeSeconds;
	foreach allactors(Class'NCCommPoint',sp) {
		if (FastTrace(sp.location,location) && VSize(sp.location-location) < sp.mindist && sp.enchant == none) {
			bGotLoc = true;
			commPoint = sp;
		}
	}

	if (!bGotLoc) {
		instigator.clientmessage("Devine communication failed - seek higher ground");
		destroy();
	}
	else {
		commPoint.enchant = self;
		Skin = commPoint.talkerSkin;
		mesh = commPoint.talkerMesh;
		//instigator.clientmessage("Found comm point");
		PlayAnim('Breath');
		SetTimer(FadeTime,false);
	}
}

defaultproperties
{
     FadeTime=2.000000
     bDisplayMesh=True
     bPawnless=True
     LifeSpan=0.000000
     AmbientSound=Sound'NaliChronicles.SFX.ldrainl'
     Mesh=LodMesh'UnrealShare.Nali1'
     SoundRadius=160
     SoundVolume=190
     CollisionRadius=24.000000
     CollisionHeight=48.000000
     bCollideWorld=True
}
