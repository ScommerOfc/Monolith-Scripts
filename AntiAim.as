bool enableMenu = true;
bool enableOverride = false;
bool lbyBreaker = false;
bool enableRoll = false;
bool enableAtTArgets = false;
uint rollKey = 0;
float yawAngle;
float timeToUpdate;
float pitchAngle;
float rollAngle;
float rollMode;
float leftLimit = 0.0f;
float rightLimit = 0.0f;
CBaseEntity@ target;
CBaseEntity@ player;

void init() {
    RegisterCallback("OnMenu", onMenuCallback);
    RegisterCallback("OnCreateMove", onCreateMove);
}

void onMenuCallback() {
    if(!CheatVars.menuOpen)
        return;

    if(Menu::Begin("Anti-Aim - by ScommerOfc", enableMenu, 0)) {
        Menu::Checkbox("Enable Anti-Aim", enableOverride);
		Menu::SliderFloat("Yaw Add", yawAngle, -40, 40, "%1.f", 1.f);
		Menu::Checkbox("At Targets", enableAtTArgets);
        Menu::SliderFloat("Pitch", pitchAngle , 1, 3, "%1.f", 1.f);
		Menu::Text("1 = Down | 2 = Up | 3 = None");
		Menu::Checkbox("Roll", enableRoll);
		Menu::KeyBinder("Roll Key", rollKey, true);
		Menu::SliderFloat("Roll Angle", rollAngle, -50, 50, "%1.f", 1.f);
		Menu::SliderFloat("Roll Mode", rollMode, 1, 2, "%1.f", 1.f);
		Menu::Text("1 = Static | 2 = Jitter");
		Menu::SliderFloat("Left Limit", leftLimit, 0, 60, "%1.f", 1.f);      		
        Menu::SliderFloat("Right Limit", rightLimit, 0, 60, "%1.f", 1.f);
		Menu::Checkbox("Opposite Breaker", lbyBreaker);
		Menu::Text("---------------------------------------------------");
        Menu::End();
	}
}

bool shouldBreakLby() {
    CBaseEntity @localPlayer = Interfaces.ClientEntityList.GetLocalPlayer();
    if(localPlayer.GetAbsVelocity().Length() > 0.1f) {
        timeToUpdate = Interfaces.Globals.curtime + 0.22; //Fix Curtime
        return false;
    }
    else {
        if(Interfaces.Globals.curtime > timeToUpdate) {
            timeToUpdate = Interfaces.Globals.curtime + 1.1f;
            return true;
        }
    }
    return false;
}

float getPitch(CUserCmd &cmd, bool & sendPacket) {
    bool invertJitter = false;
	bool shouldInvert = false;

	if (sendPacket)
		shouldInvert = true;
	else if (sendPacket && shouldInvert) //-V560
	{
		shouldInvert = false;
		invertJitter = !shouldInvert;
	}

    float pitch = cmd.viewangles.x;

    if(pitchAngle == 1)
        pitch = 89.f;
    else if(pitchAngle == 2)
        pitch = -89.f;
    else if(pitchAngle == 3)
        pitch = 0.f;

    return pitch;
}

float min(float a, float b) {
	if(a > b)
		return b;
	else if(a < b)
		return a;
	else if(a == b)
		return a;
	
	return a;
}

Vector calculateAngle(Vector src, Vector dst) {
	Vector angles;

	Vector delta = src - dst;
	float hyp = delta.Length2D();

	angles.y = atan(delta.y / delta.x) * 57.295779513082f;
	angles.x = atan(-delta.z / hyp) * -57.295779513082f;
	angles.z = 0.0f;

	if (delta.x >= 0.0f)
		angles.y += 180.0f;

	return angles;
}

float getFov(QAngle view_angle,QAngle aim_angle) {
	QAngle delta = aim_angle - view_angle;
	delta.Normalize();

	return min(sqrt(pow(delta.x, 2.0f) + pow(delta.y, 2.0f)), 180.0f);
}

float atTargets(CUserCmd &cmd) {
	CBaseEntity @localPlayer = Interfaces.ClientEntityList.GetLocalPlayer();
	Vector eyePos = localPlayer.GetEyePos();
	
	int maxPlayers = Interfaces.EngineClient.GetMaxClients();
	
	float bestFov = 9999.f;
	
	for (int i = 1 ; i <= maxPlayers ; i++) {
		@player = Interfaces.ClientEntityList.GetBaseEntity(i);
		
		if(!player.IsAlive())
			continue;
		
		CBaseCombatWeapon@ weaponEn = player.GetWeapon();
			
		int idx = weaponEn.GetItemDefinitionIndex();
		if(idx == 0)
			continue;
		if(idx == WEAPON_C4 || idx == WEAPON_HEALTHSHOT)
			continue;
		if(weaponEn.IsGrenade())
			continue;
		
		QAngle angles;
		Interfaces.EngineClient.GetViewAngles(angles);
		float fov = getFov(angles, Math.CalcAngle(eyePos, player.GetAbsOrigin()));
		
		if (fov < bestFov) {
			bestFov = fov;
			@target = player;
		}
	}
	
	if(!target.IsAlive())
		return cmd.viewangles.y + 180;
	
	float bestYaw = calculateAngle(eyePos, player.GetAbsOrigin()).y + 180;
	
	return bestYaw;
}

void runAntiAim(CUserCmd &cmd, bool & sendPacket) {
    if(!enableOverride)
        return;
	
	CBaseEntity @localPlayer = Interfaces.ClientEntityList.GetLocalPlayer();
	float rollAng;
		
	if(rollMode == 1.0f)
		rollAng = rollAngle;
	else if(rollMode == 2.0f)
		rollAng = rollAngle + Util.RandomFloat(-leftLimit, rightLimit);
	if(Input.IsKeyDown(32))
		rollAng = 0;
	
    if(shouldBreakLby() && lbyBreaker) {
        cmd.viewangles.y = 180;
    }
    else {
        cmd.viewangles.y += 180.f; //Gets clamped anyways smh
    }
	
	if(sendPacket) {
		cmd.viewangles.y -= yawAngle + Util.RandomFloat(-leftLimit, rightLimit);
		if(enableRoll)
			cmd.viewangles.z = rollAng;
	}
	else {
		cmd.viewangles.y += 180.f + Util.RandomFloat(-leftLimit, rightLimit);
		if(enableRoll)
			cmd.viewangles.z = rollAng;
	}
	
	Util.FixMovement(cmd, cmd.viewangles, true);
}

void onCreateMove(CUserCmd & cmd, bool & sendPacket) {
    if(Interfaces.ClientEntityList.GetLocalPlayer().GetMoveType() == MOVETYPE::MOVETYPE_LADDER || Interfaces.ClientEntityList.GetLocalPlayer().GetMoveType() == MOVETYPE::MOVETYPE_NOCLIP) //Avoiding Errors
        return;

	CBaseEntity @localPlayer = Interfaces.ClientEntityList.GetLocalPlayer();
    //Just Some Stuff To Avoid Weird Behaviour
	if(localPlayer.GetWeapon().IsGrenade())
		return;
	if(localPlayer.GetFlags() == 128)
		return;
    if(localPlayer is null)
        return;
    if(!localPlayer.IsAlive())
        return;
    if(localPlayer.GetImmune())
        return;
	
	cmd.viewangles.x = getPitch(cmd, sendPacket);

    if(enableOverride)
        runAntiAim(cmd, sendPacket);
    
}
