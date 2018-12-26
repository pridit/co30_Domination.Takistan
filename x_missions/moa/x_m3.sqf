// by Xeno
private ["_vehicle", "_poss"];
#include "x_setup.sqf"

_mpos = markerPos QGVAR(sm_3);
_mpos set [2,0];
_mpos1 = markerPos QGVAR(sm_3_1);
_mpos1 set [2,0];
_mpos2 = markerPos QGVAR(sm_3_2);
_mpos2 set [2,0];
GVAR(x_sm_pos) = [_mpos, _mpos1, _mpos2]; //  steal tank prototype, Timurkalay, array 2 and 3 = infantry and armor positions
GVAR(x_sm_type) = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client && {!GVAR(IS_HC_CLIENT)}) then {
    GVAR(current_mission_text) = (localize "STR_DOM_MISSIONSTRING_852");
    GVAR(current_mission_resolved_text) = (localize "STR_DOM_MISSIONSTRING_769");
    [(localize "STR_DOM_MISSIONSTRING_852"), "Steal", _mpos] call FUNC(x_newtask);
};

if (call FUNC(checkSHC)) then {
    __PossAndOther
    _pos_other2 = GVAR(x_sm_pos) select 2;
    _vehicle = objNull;
    _vehicle = createVehicle [GVAR(sm_tank), _poss, [], 0, "NONE"];
    _vehicle setDir  markerDir QGVAR(sm_3);
    _vehicle setPos _poss;
    sleep 2.123;
    ["specops", 1, "basic", 1, _pos_other,250,true] spawn FUNC(CreateInf);
    sleep 2.321;
    ["shilka", 1, "bmp", 1, "tank", 0, _pos_other2,1,400,true] spawn FUNC(CreateArmor);
    [_vehicle] execVM "x_missions\common\x_sidesteal.sqf";
    _vehicle addMPEventHandler ["MPKilled", {
        if (isServer) then {
            private "_vec";
            PARAMS_2(_vec,_killer);
            __addDead(_vec);
        };
    }];
    _vehicle setDamage 0;
};