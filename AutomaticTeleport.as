bool enableMenu = false;
bool enableTeleport = false;

void init() {
    RegisterCallback("OnMenu", onMenuCallback);
    RegisterCallback("OnCreateMove", onCreateMove);
}

void onMenuCallback() {
    if(!CheatVars.menuOpen)
        return;

    if(Menu::Begin("Dormant Aimbot - by ScommerOfc", enableMenu, 0)) {
        Menu::Checkbox("Enable Teleport In Air", enableTeleport);
        Menu::End();
	}
}

void onCreateMove(CUserCmd & cmd, bool & sendPacket) {
    if(!enableTeleport)
        return;

    CBaseEntity@ localPlayer = Interfaces.ClientEntityList.GetLocalPlayer();
    CBaseCombatWeapon@ localWeapon = localPlayer.GetWeapon();
    bool shouldTeleport;
   	bool isDT = Config.GetMenuBool("gTRuP");

    if(localWeapon.IsGrenade() || localWeapon.GetItemDefinitionIndex() == 59)
        shouldTeleport = false;

    int maxPlayers = Interfaces.EngineClient.GetMaxClients();
    for (int i = 1 ; i <= maxPlayers ; i++)  {
        CBaseEntity@ player = Interfaces.ClientEntityList.GetBaseEntity(i);

        Vector localEyePos = localPlayer.GetEyePos();
        Vector enemyBodyPos = player.GetHitboxPoint(HITBOX_BODY);

		if(Util.IsPointVisible(localEyePos, enemyBodyPos, 0.0f))
			shouldTeleport = true;
    
		if(shouldTeleport && player.GetDormant() == false && player.IsEnemy() && player.IsAlive()) {
				isDT = false;
		}
	}
}
