// by Xeno
private ["_ogroup", "_poss", "_leadero"];
#include "x_setup.sqf"

_mpos = markerPos QGVAR(sm_42);
_mpos set [2,0];
GVAR(x_sm_pos) = [_mpos]; // index: 42,   Officer in forrest near Nur
GVAR(x_sm_type) = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client && {!GVAR(IS_HC_CLIENT)}) then {
    GVAR(current_mission_text) = (localize "STR_DOM_MISSIONSTRING_861");
    GVAR(current_mission_resolved_text) = (localize "STR_DOM_MISSIONSTRING_792");
    [(localize "STR_DOM_MISSIONSTRING_861"), "Kidnap", _mpos] call FUNC(x_newtask);
};

if (call FUNC(checkSHC)) then {
    __PossAndOther
    __GetEGrp(_ogroup)
    _sm_vehicle = _ogroup createUnit [GVAR(soldier_officer), _poss, [], 0, "FORM"];
    if (GVAR(without_nvg) == 0) then {
        if (_sm_vehicle hasWeapon "NVGoggles") then {_sm_vehicle removeWeapon "NVGoggles"};
    };
    _sm_vehicle setVariable ["BIS_noCoreConversations", true];
    __addDeadAI(_sm_vehicle)
    _sm_vehicle addEventHandler ["killed", {_this call FUNC(KilledSMTarget500)}];
    removeAllWeapons _sm_vehicle;
    sleep 2.123;
    ["specops", 3, "basic", 2, _poss, 200,true] spawn FUNC(CreateInf);
    sleep 2.123;
    _leadero = leader _ogroup;
    _leadero setRank "COLONEL";
    _ogroup setbehaviour "AWARE";
    _leadero disableAI "MOVE";
    [_sm_vehicle] execVM "x_missions\common\x_sidearrest.sqf";
};