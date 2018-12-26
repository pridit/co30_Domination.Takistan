// by Xeno
//#define __DEBUG__
#define THIS_FILE "x_serverOPD.sqf"
#include "x_setup.sqf"
if (!isServer) exitWith{};
private ["_name", "_uid", "_pa", "_oldwtime", "_connecttime", "_newwtime"];
PARAMS_3(_id, _name, _uid);

__TRACE_2("","_name","_uid")

if (_name == "__SERVER__") exitWith {};
if (_name == __HCNAME) exitWith {
    GVAR(HC_CLIENT_OBJ) = nil;
    GVAR(HC_CLIENT_READY) = nil;
};

_pa = GV2(GVAR(player_store),_uid);
if (!isNil "_pa") then {
    __TRACE_1("player store before change","_pa")
    _oldwtime = _pa select 0;
    _connecttime = _pa select 1;
    _newwtime = time - _connecttime;
    if (_newwtime >= _oldwtime) then {
        _newwtime = 0;
    } else {
        _newwtime = _oldwtime - _newwtime;
    };
    _pa set [0, _newwtime];
    _pa set [9, time];
    
    _pl = objNull;
    {
        _un = __getMNsVar2(_x);
        if (!isNil "_un" && {!isNull _un} && {getPlayerUID _un == _uid}) exitWith {_pl = _un};
    } forEach GVAR(player_entities);
    
    if (!isNull _pl) then {
        _pa set [10, weapons _pl];
        _pa set [11, magazines _pl];
        _pa set [12, position _pl];
        _pa set [13, vehicle _pl == _pl];
    } else {
        _pa set [10, []];
        _pa set [11, []];
        _pa set [12, []];
        _pa set [13, true];
    };
    
    (_pa select 4) call FUNC(markercheck);
    __TRACE_1("player store after change","_pa")
};
