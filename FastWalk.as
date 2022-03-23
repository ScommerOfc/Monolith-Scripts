bool enableMenu = false;
bool enableFastWalk = false;
uint keyAssign = 0;

void init() {
    RegisterCallback("OnMenu", onMenuCallback);
    RegisterCallback("OnCreateMove", onCreateMove);
}

void onMenuCallback() {
    if(!CheatVars.menuOpen)
        return;

    if(Menu::Begin("Fastwalk - by ScommerOfc", enableMenu, 0)) {
        Menu::Checkbox("Enable Fastwalk", enableFastWalk);
        Menu::SameLine(0.f, 10.f);
        Menu::KeyBinder("FastWalk", keyAssign, true);
        Menu::End();
	}
}

void onCreateMove(CUserCmd & cmd, bool & sendPacket) {
    if(!enableFastWalk || !Input.IsKeyDown(keyAssign))
        return;

    CBaseEntity@ localPlayer = Interfaces.ClientEntityList.GetLocalPlayer();
    Vector getVelocity = localPlayer.GetVelocity();
    float currSpeed = getVelocity.Length2D();

    if(currSpeed < 126.f)
        return;

    float svAcceleration = Interfaces.Cvar.FindVar("sv_accelerate").GetFloat();
    float surfFriction = 1.f;
    float desiredSpeed = 0.f;
    float maxSpeed = svAcceleration * Interfaces.Globals.interval_per_tick * currSpeed * surfFriction;

    if (currSpeed - maxSpeed <= -1.f)
        desiredSpeed = maxSpeed / (currSpeed / (svAcceleration * Interfaces.Globals.interval_per_tick));
    else
        desiredSpeed = maxSpeed;

    Vector nDirection;
    QAngle viewAngles;
    Interfaces.EngineClient.GetViewAngles(viewAngles);
    nDirection.y = viewAngles.y - nDirection.y;

    cmd.forwardmove = nDirection.x * desiredSpeed;
    cmd.sidemove = viewAngles.y - nDirection.y;

}
