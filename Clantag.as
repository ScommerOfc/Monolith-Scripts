bool openMenu = true;
bool enableClantag = false;;
bool femboyHook = false;
bool twintowers = false;
bool customText = false;

//Enter your Custom Clantag here^^
string enterTextHere = "test";

void init() {
    RegisterCallback("OnMenu",OnMenuCallback);
    RegisterCallback("OnPaint", OnPaintCallback);
}

void OnMenuCallback() {
    if(!CheatVars.menuOpen)
        return;

    if(Menu::Begin("Clantag Script - by ScommerOfc", openMenu, 0)) {
		Menu::Checkbox("Enable Clantag Changer", enableClantag);

    if(enableClantag) {
        Menu::Checkbox("Femboyhook", femboyHook);
        Menu::Checkbox("Twintowers", twintowers);
        Menu::Checkbox("Custom Text", customText);
    }

    Menu::End();
    }
}

int last_time = 0;
bool bReset = false;

void OnPaintCallback(D3D9Renderer& renderer) {

    if (!Interfaces.EngineClient.IsInGame() || !Interfaces.EngineClient.IsConnected())
        return;

    int time = Interfaces.Globals.curtime * 5;

    if (femboyHook) {
        if (time != last_time) {
           switch ((time) % 15)  {
                case 1:  Util.ClanTag("F/       "); break;
                case 2:  Util.ClanTag("F3/      "); break;
                case 3:  Util.ClanTag("F3M/     "); break;
                case 4:  Util.ClanTag("F3MB/    "); break;
                case 5:  Util.ClanTag("FEMB0/   "); break;
                case 6:  Util.ClanTag("FEMB0Y/  "); break;
                case 7:  Util.ClanTag("F3MBOY   "); break;
                case 8:  Util.ClanTag("F3MB0Y\  "); break;
                case 9:  Util.ClanTag("F3MB0\   "); break;
                case 10: Util.ClanTag("F3MB\    "); break;
                case 11: Util.ClanTag("F3M\     "); break;
                case 12: Util.ClanTag("F3\      "); break;
                case 13: Util.ClanTag("F\       "); break;
            }
            last_time = time;
        }
        bReset = true;
    }
    if(twintowers) {
        if(time != last_time) {
            switch((time) % 7) {
                case 1: Util.ClanTag("[✈-----|]"); break;
                case 2: Util.ClanTag("[-✈----|]"); break;
                case 3: Util.ClanTag("[--✈---|]"); break;
                case 4: Util.ClanTag("[---✈--|]"); break;
                case 5: Util.ClanTag("[-----✈|]"); break;
            }
            last_time = time;
        }
        bReset = true;
    }
    if(customText) {
        Util.ClanTag(enterTextHere);
    }
} 