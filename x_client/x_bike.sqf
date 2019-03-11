// by Xeno
#define THIS_FILE "x_bike.sqf"
#include "x_setup.sqf"
private ["_create_bike", "_disp_name", "_str", "_pos", "_vehicle", "_index", "_parray", "_rank"];
if (!X_Client) exitWith {};

_create_bike = (_this select 3) select 0;
_b_mode = (_this select 3) select 1;

_disp_name = [_create_bike,0] call FUNC(GetDisplayName);

if (vehicle player != player) exitWith {
    _str = format [(localize "STR_DOM_MISSIONSTRING_158"), _disp_name];
    _str call FUNC(GlobalChat);
};

if (isNil {__pGetVar(GVAR(bike_created))}) then {__pSetVar [QGVAR(bike_created), false]};
if (_b_mode == 1 && {__pGetVar(GVAR(bike_created))}) exitWith {(localize "STR_DOM_MISSIONSTRING_159") call FUNC(GlobalChat)};

if (diag_tickTime > GVAR(vec_end_time) && {!isNull GVAR(flag_vec)} && {(GVAR(flag_vec) call FUNC(GetVehicleEmpty))}) then {
    deleteVehicle GVAR(flag_vec);
    GVAR(flag_vec) = objNull;
    GVAR(vec_end_time) = -1;
};
if (_b_mode == 0 && {alive GVAR(flag_vec)}) exitWith {
    (format [(localize "STR_DOM_MISSIONSTRING_160"),0 max (round((GVAR(vec_end_time) - diag_tickTime)/60))]) call FUNC(GlobalChat);
};

_pos = position player;
_str = format [(localize "STR_DOM_MISSIONSTRING_161"), _disp_name];
_str call FUNC(GlobalChat);
sleep 3.123;
__pSetVar [QGVAR(bike_created), true];
_pos = position player;
_vehicle = createVehicle [_create_bike, _pos, [], 0, "NONE"];
_vehicle setDir direction player;
_vehicle setPos _pos;
[QGVAR(n_v), _vehicle] call FUNC(NetCallEventToClients);
player reveal _vehicle;

player moveInDriver _vehicle;

_vehicle spawn {
    scriptName "spawn_x_bike_1";
    private "_vehicle";
    _vehicle = _this;
    [QGVAR(ad), _vehicle] call FUNC(NetCallEventCTS);
    sleep 10.123;
    while {true} do {
        if ({_x distance _vehicle < 50} count playableUnits < 1) then {
            if (_vehicle call FUNC(GetVehicleEmpty)) exitWith {deleteVehicle _vehicle};
        };
        sleep 30;
    };
};
