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

__ccppfln(x_client\x_setupplayer.sqf);