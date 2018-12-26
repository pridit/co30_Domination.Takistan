// by Xeno
//#define __DEBUG__
#define THIS_FILE "x_docreatenexttarget.sqf"
#include "x_setup.sqf"
private ["_counter", "_tmppos", "_dirn","_current_target_pos", "_current_target_radius"];
if (count _this == 2) then {
    PARAMS_2(_current_target_pos,_current_target_radius);
} else {
    PARAMS_5(_bla,_current_target_pos,_current_target_radius,_bla3,_bla4);
    GVAR(target_radius) = _bla3;
    GVAR(mttarget_radius_patrol) = _bla4;
};

if (isServer && {!isNil QGVAR(HC_CLIENT_OBJ)}) exitWith {
    [QGVAR(docnt), [GVAR(HC_CLIENT_OBJ), _current_target_pos, _current_target_radius, GVAR(target_radius), GVAR(mttarget_radius_patrol)]] call FUNC(NetCallEventSTO);
};

GVAR(delvecsmt) = [];
GVAR(delinfsm) = [];
GVAR(respawn_ai_groups) = [];
//GVAR(non_mt_respawn_ai_groups) = [];
GVAR(mt_done) = false;
    
GVAR(enemyai_respawn_pos) = [getPosATL GVAR(FLAG_BASE), _current_target_pos] call FUNC(posbehind2); // startpoint for random camp location (if needed) plus direction
if (surfaceIsWater (GVAR(enemyai_respawn_pos) select 0)) then {
    private ["_counter", "_tmppos", "_dirn"];
    _counter = 0;
    _tmppos = GVAR(enemyai_respawn_pos) select 0;
    while {surfaceIsWater _tmppos && {_counter < 200}} do {
        _tmppos = [_current_target_pos, ((random 1300) max 900)] call FUNC(GetRanPointCircleOuter);
        __INC(_counter);
    };
    if (surfaceIsWater _tmppos) then {
        //hint ((localize "STR_DOM_MISSIONSTRING_941") + _current_target_name + " found!!!!!");
        //diag_log ((localize "STR_DOM_MISSIONSTRING_941") + _current_target_name + " found!!!!!");
        _tmppos = _current_target_pos;
    };
    
    GVAR(enemyai_respawn_pos) set [0, _tmppos];
    _dirn = [_current_target_pos, _tmppos] call FUNC(DirTo);
    _dirn = _dirn + 180;
    GVAR(enemyai_respawn_pos) set [2, _dirn];
};

GVAR(enemyai_mt_camp_pos) = [GVAR(enemyai_respawn_pos) select 0, 600, 400, GVAR(enemyai_respawn_pos) select 1] call FUNC(GetRanPointSquare);

[_current_target_pos, _current_target_radius] execVM "x_shc\x_createmaintarget.sqf";