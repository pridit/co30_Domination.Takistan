// by Xeno
#define THIS_FILE "x_makegroup.sqf"
#include "x_setup.sqf"
private ["_grptype", "_numbervehicles", "_type", "_side", "_grpspeed", "_vehicles", "_grp", "_pos", "_reta", "_fran", "_one", "_unitsinf", "_min", "_max", "_mid", "_wpexec", "_wp_array", "_target_pos", "_grp_in", "_vec_dir", "_add_to_ar_type", "_center_rad", "_unit_array"];

if !(call FUNC(checkSHC)) exitWith {};

PARAMS_8(_grptype,_wp_array,_target_pos,_numbervehicles,_type,_side,_grp_in,_vec_dir);

_add_to_ar_type = if (count _this >= 9) then {_this select 8} else {0}; // respawn 0 = nothing, 1 = main target group, 2 = attack group
_center_rad = if (count _this >= 10) then {_this select 9} else {[]};
_grpspeed = "LIMITED";
_vehicles = [];
_unitsinf = [];

_grp = if (typeName _grp_in == typeName 0) then {[_side] call FUNC(creategroup)} else {_grp_in};
_pos = if (count _wp_array > 1) then {_wp_array call FUNC(RandomArrayVal)} else {_wp_array select 0};

_unit_array = [_grptype, _side] call FUNC(getunitliste);

if (_numbervehicles > 0) then {
    _reta = [_numbervehicles, _pos, _unit_array select 1, _grp, 0,_vec_dir,true] call FUNC(makevgroup);
    _vehicles = [_vehicles, _reta select 0] call FUNC(arrayPushStack2);
    _grp setspeedmode _grpspeed;
} else {
    _unitsinf = [_pos, _unit_array select 0, _grp,true] call FUNC(makemgroup);
};

if (_add_to_ar_type > 0) then {
    if (!(_grptype in ["DSHKM", "AGS", "D30"])) then { // don't add static weapons !!!!, respawn doesn't make sense, they can't travel from the respawn camp to another location
        _add_ar = [_grp, [_grptype, [], _target_pos, _numbervehicles, "patrol2", _side, 0, _vec_dir, _add_to_ar_type, _center_rad, GVAR(enemyai_respawn_pos)]];
        __TRACE_1("","_add_ar")
        GVAR(respawn_ai_groups) set [count GVAR(respawn_ai_groups), _add_ar];
    };
    if (count _vehicles > 0) then {
        GVAR(delvecsmt) = [GVAR(delvecsmt), _vehicles] call FUNC(arrayPushStack2);
    };
    if (count _unitsinf > 0) then {
        GVAR(delinfsm) = [GVAR(delinfsm), _unitsinf] call FUNC(arrayPushStack);
    };
};

_unit_array = nil;
_fran = (floor random 3) + 1;
_grp allowFleeing (_fran / 10);

switch (_type) do {
    case "patrol": {
        _grp setVariable [QGVAR(PATR),true];
        _min = 1 + random 15;
        _max = _min + (1 + random 15);
        _mid = _min + (random (_max - _min));
        _wpexec = if (toUpper _grptype in ["BASIC","SPECOPS"]) then {
            "this call d_fnc_grmakesearch"
        } else {
            ""
        };
        _grp setVariable [QGVAR(wpexec), _wpexec];
        [_grp, _pos, _center_rad, [_min, _mid, _max], _wpexec] call FUNC(MakePatrolWPX);
        if (_numbervehicles == 0 && {GVAR(doRespawnGroups)}) then {
            GVAR(reduce_groups) set [count GVAR(reduce_groups), _grp];
        };
    };
    case "patrol2mt": {
        _grp setVariable [QGVAR(PATR),true];
        _min = 1 + random 15;
        _max = _min + (1 + random 15);
        _mid = _min + (random (_max - _min));
        _wpexec = if (toUpper _grptype in ["BASIC","SPECOPS"]) then {
            "this call d_fnc_grmakesearch"
        } else {
            ""
        };
        _grp setVariable [QGVAR(wpexec), _wpexec];
        [_grp, _pos, _center_rad, [_min, _mid, _max], _wpexec] call FUNC(MakePatrolWPX);
        if (_numbervehicles == 0 && {GVAR(doRespawnGroups)}) then {
            GVAR(reduce_groups) set [count GVAR(reduce_groups), _grp];
        };
    };
    case "patrol2": {
        _grp setVariable [QGVAR(PATR),true];
        _min = 1 + random 15;
        _max = _min + (1 + random 15);
        _mid = _min + (random (_max - _min));
        _wpexec = if (toUpper _grptype in ["BASIC","SPECOPS"]) then {
            "this call d_fnc_grmakesearch"
        } else {
            ""
        };
        _grp setVariable [QGVAR(wpexec), _wpexec];
        [_grp, _pos, _center_rad, [_min, _mid, _max], _wpexec] call FUNC(MakePatrolWPX2);
        if (_numbervehicles == 0 && {GVAR(doRespawnGroups)}) then {
            GVAR(reduce_groups) set [count GVAR(reduce_groups), _grp];
        };
    };
    case "guard": {
        if (toUpper (_grptype) in ["BASIC","SPECOPS"]) then {
            _grp setVariable [QGVAR(defend), true];
            [_grp, _pos] spawn FUNC(taskDefend);
            if (GVAR(doRespawnGroups)) then {
                GVAR(reduce_groups) set [count GVAR(reduce_groups), _grp];
            };
        } else {
            _grp call FUNC(GuardWP);
            _grp setVariable [QGVAR(wpmaker), ["GUARD"]];
        };
    };
    case "guardstatic": {
        if (toUpper (_grptype) in ["BASIC","SPECOPS"]) then {
            _grp setVariable [QGVAR(defend), true];
            [_grp, _pos] spawn FUNC(taskDefend);
            if (GVAR(doRespawnGroups)) then {
                GVAR(reduce_groups) set [count GVAR(reduce_groups), _grp];
            };
        } else {
            _grp call FUNC(GuardWP);
            _grp setVariable [QGVAR(wpmaker), ["GUARD"]];
        };
    };
    case "guardstatic2": {
        _one = _vehicles select 0;
        _one setDir floor random 360;
        _grp setVariable [QGVAR(wpmaker), ["DEFEND2"]];
    };
    case "guardstatic3": { // for units/groups with static weapons
        // move to guard position
        // TODO
    };
    case "attack": {
        [_grp, _target_pos] call FUNC(AttackWP);
        if (_numbervehicles == 0 && {GVAR(doRespawnGroups)}) then {
            GVAR(reduce_groups) set [count GVAR(reduce_groups), _grp];
        };
    };
    case "attackwaves": {
        [_grp, _target_pos] call FUNC(AttackWP);
        if (_numbervehicles == 0 && {GVAR(doRespawnGroups)}) then {
            GVAR(reduce_groups) set [count GVAR(reduce_groups), _grp];
        };
    };
    case "attackeMTWF": {
        [_grp, _target_pos] call FUNC(TakeWFWP);
        if (_numbervehicles == 0 && {GVAR(doRespawnGroups)}) then {
            GVAR(reduce_groups) set [count GVAR(reduce_groups), _grp];
        };
    };
};

_vehicles = nil;