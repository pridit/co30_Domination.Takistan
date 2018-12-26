// by Xeno
//#define __DEBUG__
#define THIS_FILE "x_serverOPC.sqf"
#include "x_setup.sqf"
if (!isServer) exitWith{};
private ["_name", "_uid", "_p", "_lt"];
PARAMS_3(_id, _name, _uid);

__TRACE_2("","_uid","_name")

if (_name == "__SERVER__") exitWith {};
if (_name == __HCNAME) exitWith {
    GVAR(HC_CLIENT_NAME) = _name;
    publicVariable QGVAR(HC_CLIENT_NAME);
    {
        if (name _x == __HCNAME) exitWith {
            GVAR(HC_CLIENT_OBJ) = _x;
        };
    } forEach playableUnits;
    __TRACE_1("","d_HC_CLIENT_OBJ");
};

_p = GV2(GVAR(player_store),_uid);
if (isNil "_p") then {
    _p = [GVAR(AutoKickTime), time, _uid, 0, "", sideUnknown, _name, 0, xr_max_lives, time, [], [], [], true];
    GVAR(player_store) setVariable [_uid, _p];
    __TRACE_2("Player not found","_uid","_name")
} else {
    __TRACE_1("player store before change","_p")
    _pna = _p select 6;
    if (_name != _pna) then {
        [QGVAR(w_n), [_name, _pna]] call FUNC(NetCallEventToClients);
        diag_log (format [localize "STR_DOM_MISSIONSTRING_942", _name, _pna, _uid]);
    };
    _lt = _p select 9;
    if (time - _lt > 600) then {
        _p set [8, xr_max_lives];
    };
    _p set [1, time];
    _p set [6, _name];
    __TRACE_1("player store after change","_p")
};
