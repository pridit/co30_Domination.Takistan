// by Xeno
private ["_vehicle", "_poss"];
#include "x_setup.sqf"

_mpos = markerPos QGVAR(sm_8);
_mpos set [2,0];
GVAR(x_sm_pos) = [_mpos]; // index: 8,   Radio tower near Landay
GVAR(x_sm_type) = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client && {!GVAR(IS_HC_CLIENT)}) then {
    GVAR(current_mission_text) = (localize "STR_DOM_MISSIONSTRING_876");
    GVAR(current_mission_resolved_text) = (localize "STR_DOM_MISSIONSTRING_877");
    [(localize "STR_DOM_MISSIONSTRING_876"), "Destroy", _mpos] call FUNC(x_newtask);
};

if (call FUNC(checkSHC)) then {
    __Poss
    _vehicle = createVehicle [GVAR(illum_tower), _poss, [], 0, "NONE"];
    _vehicle setPos _poss;
    _vehicle setVectorUp [0,0,1];
    _vehicle call FUNC(addKilledEHSM);
    sleep 2.22;
    ["specops", 1, "basic", 2, _poss,0] spawn FUNC(CreateInf);
    _vehicle addEventHandler ["handleDamage", {_this call FUNC(CheckMTShotHD)}];
    __AddToExtraVec(_vehicle)
};