// by Xeno
private ["_vehicle", "_poss"];
#include "x_setup.sqf"

_mpos = markerPos QGVAR(sm_10);
_mpos set [2,0];
_mpos2 = markerPos QGVAR(sm_10_1);
_mpos2 set [2,0];
GVAR(x_sm_pos) = [_mpos, _mpos2]; // index: 10,   Artillery at top of mount Sanginakt
GVAR(x_sm_type) = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client && {!GVAR(IS_HC_CLIENT)}) then {
    GVAR(current_mission_text) = (localize "STR_DOM_MISSIONSTRING_825");
    GVAR(current_mission_resolved_text) = (localize "STR_DOM_MISSIONSTRING_731");
    [(localize "STR_DOM_MISSIONSTRING_825"), "Destroy", _mpos] call FUNC(x_newtask);
};

if (call FUNC(checkSHC)) then {
    __PossAndOther
    _vehicle = objNull;
    _vehicle = createVehicle [GVAR(sm_arty), _poss, [], 0, "NONE"];
    _vehicle setPos _poss;
    _vehicle addEventHandler ["killed", {_this call FUNC(KilledSMTargetNormal); _this call FUNC(handleDeadVec)}];
    _vehicle lock true;
    sleep 2.21;
    ["specops", 1, "basic", 2, _poss,0] spawn FUNC(CreateInf);
    sleep 2.045;
    ["shilka", 1, "bmp", 1, "tank", 0, _pos_other,1,0] spawn FUNC(CreateArmor);
};