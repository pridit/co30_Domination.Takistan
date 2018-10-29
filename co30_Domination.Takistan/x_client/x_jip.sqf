// by Xeno
//#define __DEBUG__
#define THIS_FILE "x_jip.sqf"
#include "x_setup.sqf"
if (!X_Client) exitWith {};

if (!isNil QGVAR(HC_CLIENT_NAME) && {name player == GVAR(HC_CLIENT_NAME)} && {productVersion select 3 >= 99184}) exitWith {
    __TRACE_1("Headless client found","d_HC_CLIENT_NAME");
    GVAR(IS_HC_CLIENT) = true;
    __ccppfln(x_shc\x_setuphc.sqf);
};

if (!isNil QGVAR(jip_started)) exitWith {};
GVAR(jip_started) = true;

if (GVAR(FastTime) > 0) then {
    0 setOvercast 0;
    0 spawn {
        scriptName "spawn_TimeUpdateScript";
        waitUntil {sleep 0.221;!isNil {__XJIPGetVar(currentTime)}};
        while {true} do {
            sleep 1;
            skipTime (__XJIPGetVar(currentTime) - DayTime);
        };
    };
};

__ccppfln(x_client\x_setupplayer.sqf);

#ifdef __CARRIER__
0 spawn {
    scriptName "spawn_carrierplayersetpos";
    sleep 2;
    player setPosASL [getPosASL player select 0, getPosASL player select 1, 9.26];
};
#endif