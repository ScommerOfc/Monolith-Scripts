bool enableMenu = false;
bool enableDormant = false;
float minimumDamage = 0.0f;

void init() {
    RegisterCallback("OnMenu", onMenuCallback);
    RegisterCallback("OnCreateMove", onCreateMove);
}

void onMenuCallback() {
    if(!CheatVars.menuOpen)
        return;

    if(Menu::Begin("Dormant Aimbot - by ScommerOfc", enableMenu, 0)) {
        Menu::Checkbox("Enable Dormaint Aimbot", enableDormant);
        Menu::SliderFloat("Minimum Damage", minimumDamage , 0, 100, "%1.f", 1.f);
        Menu::End();
	}
}

void onCreateMove(CUserCmd & cmd, bool & sendPacket) {
    if(!enableDormant)
        return;

    CBaseEntity@ localPlayer = Interfaces.ClientEntityList.GetLocalPlayer();
    CBaseCombatWeapon@ localWeapon = localPlayer.GetWeapon();

    float inacuccary = localWeapon.GetInaccuracy();

    if(localPlayer is null || localWeapon is null)
        return;

    if(!localWeapon.IsGrenade() || localWeapon.GetItemDefinitionIndex() != 59 || !localWeapon.InReload()) { //Exception Handling
        int maxPlayers = Interfaces.EngineClient.GetMaxClients();
        for (int i = 1 ; i <= maxPlayers ; i++) {
            CBaseEntity@ player = Interfaces.ClientEntityList.GetBaseEntity(i);
            if(player.IsEnemy() and player.GetDormant() and player.IsAlive()) { //Filter out targets
                Vector eyeAngles = localPlayer.GetEyePos(); //Shot from this position
                Vector enemyAngle = player.GetHitboxPoint(HITBOX_BODY); //Position to shoot
                player.UpdateVisibility(); //Refresh a last time to ensure dormancy
                if(Util.IsPointHitable(eyeAngles, enemyAngle, localPlayer, player, minimumDamage)) { //Can We Hit For Minumum Damagge???
                    QAngle finalAngle = Math.CalcAngle(eyeAngles, enemyAngle) - localPlayer.GetAimPunchAngle() * 4.f; //Get the final angle to shoot to
                        cmd.viewangles = finalAngle; //Set our view to the angle
                        cmd.buttons |= IN_ATTACK; //Shoot
                }
            }
        }
    }
}
//PS: I am gay
