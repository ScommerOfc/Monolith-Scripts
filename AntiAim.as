//Menu
bool enableMenu = true;
bool enableOverride = false;

QAngle localAngle;

float desyncYaw;
float startingAngleValue;
float desyncPitch;
float jitterAmount;

//Modes
bool enableJitter = false;
bool enableCustom = false;

void init() {
    RegisterCallback("OnMenu", OnMenuCallback);
    RegisterCallback("OnCreateMove", OnCreateMove);
}

void OnMenuCallback() {
    if(!CheatVars.menuOpen)
        return;

    if(Menu::Begin("Anti-Aim Script - by ScommerOfc", enableMenu, 0)) {
        Menu::Checkbox("Enable Anti-Aim", enableOverride);

            if(enableOverride) {
                Menu::Checkbox("Enable Jitter", enableJitter);
                Menu::Checkbox("Enable Custom", enableCustom);
            }

            if(enableCustom) {
                Menu::SliderFloat("Yaw", desyncYaw, -180, 180, "%1.f", 1.f);
                Menu::SliderFloat("Pitch", desyncPitch , -89, 89, "%1.f", 1.f);
                Menu::SliderFloat("Starting Angle", startingAngleValue , 0, 17, "%1.f", 1.f);
                Menu::SliderFloat("Offset", jitterAmount , 0, 60, "%1.f", 1.f);
            }

    Menu::End();
    }
}

void jitterAA(CUserCmd & cmd, bool & sendPacket) {
    if(Interfaces.ClientEntityList.GetLocalPlayer().GetMoveType() == MOVETYPE::MOVETYPE_LADDER || Interfaces.ClientEntityList.GetLocalPlayer().GetMoveType() == MOVETYPE::MOVETYPE_NOCLIP) //Avoiding Errors
        return;
    
    if(enableJitter) {
        float startingAngle = 15;
        bool swapSide;
        swapSide = !swapSide;

        if(sendPacket) {
            if(swapSide) {
                cmd.viewangles.y = localAngle.y - 170 - startingAngle * 2;
            }
                else {
                    cmd.viewangles.y = localAngle.y - 170 + startingAngle * 2;
                }
                    cmd.viewangles.x = 79;
            }
            else {
                if(swapSide) {
                    cmd.viewangles.y = cmd.viewangles.y + 60 * 2;
                }
            else {
                cmd.viewangles.y = cmd.viewangles.y + 120 * 2;
            }
            cmd.viewangles.x = 79;
        }
    }
}

void customAA(CUserCmd & cmd, bool & sendPacket) {
    if(Interfaces.ClientEntityList.GetLocalPlayer().GetMoveType() == MOVETYPE::MOVETYPE_LADDER || Interfaces.ClientEntityList.GetLocalPlayer().GetMoveType() == MOVETYPE::MOVETYPE_NOCLIP)
        return;

        if(sendPacket) {
           // enableJitter = true;
            cmd.viewangles.y = localAngle.y - desyncYaw - jitterAmount * 2;
            cmd.viewangles.x = desyncPitch;
        }
}

void OnCreateMove(CUserCmd & cmd, bool & sendPacket) {
    CBaseEntity @localPlayer = Interfaces.ClientEntityList.GetLocalPlayer();

    //Just Some Stuff To Avoid Weird Behaviour
    if(localPlayer is null)
        return;
    if(!localPlayer.IsAlive())
        return;
    if(localPlayer.GetImmune())
        return;

    if(enableJitter)
        jitterAA(cmd, sendPacket);
    else if(enableCustom)
        customAA(cmd, sendPacket);
}

