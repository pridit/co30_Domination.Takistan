// by Xeno
private ["_vehicle", "_poss"];
#include "x_setup.sqf"

_mpos = markerPos QGVAR(sm_24);
_mpos set [2,0];
GVAR(x_sm_pos) = [_mpos]; // index: 24,   Fuel station in camp near Gospandi
GVAR(x_sm_type) = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client && {!GVAR(IS_HC_CLIENT)}) then {
    GVAR(current_mission_text) = (localize "STR_DOM_MISSIONSTRING_844");
    GVAR(current_mission_resolved_text) = (localize "STR_DOM_MISSIONSTRING_758");
    [(localize "STR_DOM_MISSIONSTRING_844"), "Destroy", _mpos] call FUNC(x_newtask);
};

if (call FUNC(checkSHC)) then {
    __Poss
    _vehicle = createVehicle [GVAR(fuel_station), _poss, [], 0, "NONE"];
    _vehicle setDir (markerDir QGVAR(sm_24));
    _vehicle setPos _poss;
    _vehicle call FUNC(addKilledEHSM);
    sleep 2.22;
    ["shilka", 1, "bmp", 1, "tank", 1, _poss,1,350,true] spawn FUNC(CreateArmor);
    sleep 2.123;
    ["specops", 1, "basic", 2, _poss,250,true] spawn FUNC(CreateInf);
    __AddToExtraVec(_vehicle)
};