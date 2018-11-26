// by Xeno
private "_poss";
#include "x_setup.sqf"

_mpos = markerPos QGVAR(sm_50);
_mpos set [2,0];
GVAR(x_sm_pos) = [_mpos]; // index: 50,   Artillery base
GVAR(x_sm_type) = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client && {!GVAR(IS_HC_CLIENT)}) then {
    GVAR(current_mission_text) = localize "STR_DOM_MISSIONSTRING_1448";
    GVAR(current_mission_resolved_text) = (localize "STR_DOM_MISSIONSTRING_810");
    [(localize "STR_DOM_MISSIONSTRING_1448"), "Destroy", _mpos] call FUNC(x_newtask);
};

if (call FUNC(checkSHC)) then {
    __Poss
    [_poss] execVM "x_missions\common\x_sidearti.sqf";
};