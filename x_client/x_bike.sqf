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

if (_vehicle isKindOf "ATV_US_EP1") then {
    _vehicle addAction [(localize "STR_DOM_MISSIONSTRING_162") call FUNC(BlueText), "x_client\x_flipatv.sqf", 0, -1, false, false, "", "!(player in _target) && {((vectorUp _target) select 2) < 0.6}"];
};

if (_b_mode == 1) then {
    _vehicle spawn {
        scriptName "spawn_x_bike_1";
        private "_vehicle";
        _vehicle = _this;
        [QGVAR(ad), _vehicle] call FUNC(NetCallEventCTS);
        waitUntil {sleep 0.412;!alive player || {!alive _vehicle}};
        sleep 10.123;
        while {true} do {
            if (_vehicle call FUNC(GetVehicleEmpty)) exitWith {deleteVehicle _vehicle};
            sleep 15.123;
        };
    };
} else {
    GVAR(flag_vec) = _vehicle;
    GVAR(vec_end_time) = diag_tickTime + GVAR(VecCreateWaitTime) + 60;
    [QGVAR(ad2), [GVAR(flag_vec),GVAR(vec_end_time)]] call FUNC(NetCallEventCTS);
    GVAR(flag_vec) addEventHandler ["killed", {(_this select 0) spawn {private ["_vec"];_vec = _this;sleep 10.123;while {true} do {if (isNull _vec) exitWith {};if (_vec call FUNC(GetVehicleEmpty)) exitWith {deleteVehicle _vec};sleep 15.123};GVAR(flag_vec) = objNull}}];
};
