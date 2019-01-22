// by Xeno
//#define __DEBUG__
#define THIS_FILE "x_shcfunctions.sqf"
#include "x_setup.sqf"

FUNC(creategroup) = {
    private ["_grp","_side","_side_str"];
    PARAMS_1(_side);
    _side_str = if (typeName _side == "STRING") then {_side call FUNC(StoreGet)} else {_side};
    _grp = createGroup _side_str;
    // GVAR(gstate)
    // 0 = created
    // 1 = filled with units
    // 2 = reduced
    _grp setVariable [QGVAR(gstate), 0];
    __TRACE_1("creategroup","_grp")
    _grp
};

FUNC(getwparray) = {
    private["_tc", "_radius","_wp_a","_point"];
    PARAMS_2(_tc,_radius);
    _wp_a = [];_wp_a resize 100;
    for "_i" from 0 to 99 do {
        _point = [_tc, _radius] call FUNC(GetRanPointCircle);
        if (count _point == 0) then {
            for "_e" from 0 to 99 do {_point = [_pos_center, _radius] call FUNC(GetRanPointCircle);if (count _point > 0) exitWith {}};
        };
        _wp_a set [_i, _point];
    };
    _wp_a
};

FUNC(getwparray2) = {
    private["_tc", "_radius","_wp_a","_point"];
    PARAMS_2(_tc,_radius);
    _wp_a = [];_wp_a resize 100;
    for "_i" from 0 to 99 do {
        _point = [_tc, _radius] call FUNC(GetRanPointCircleOuter);
        if (count _point == 0) then {
            for "_e" from 0 to 99 do {_point = [_tc, _radius] call FUNC(GetRanPointCircleOuter);if (count _point > 0) exitWith {}};
        };
        _wp_a set [_i, _point];
    };
    _wp_a
};

FUNC(getwparray3) = {
    private ["_pos","_a","_b","_angle","_wp_a","_point"];
    PARAMS_4(_pos,_a,_b,_angle);
    _wp_a = [];_wp_a resize 100;
    for "_i" from 0 to 99 do {
        _point = [_pos, _a, _b, _angle] call FUNC(GetRanPointSquare);
        if (count _point == 0) then {
            for "_e" from 0 to 99 do {_point = [_pos, _a, _b, _angle] call FUNC(GetRanPointSquare);if (count _point > 0) exitWith {}};
        };
        _wp_a set [_i, _point];
    };
    _wp_a
};

FUNC(getunitliste) = {
    private ["_grptype","_how_many","_list","_one_man","_side","_side_char","_unitliste","_vehiclename","_varray"];
    PARAMS_2(_grptype,_side);
    _unitliste = [];_vehiclename = "";_varray = [];
    _side_char = if (typeName _side == "STRING") then {
        switch (_side) do {case "EAST": {"E"};case "WEST": {"W"};case "GUER": {"G"};case "CIV": {"W"};}
    } else {
        switch (_side) do {case east: {"E"};case west: {"W"};case resistance: {"G"};case civilian: {"W"};}
    };
    switch (_grptype) do {
        case "basic": {_list = missionNamespace getVariable format [QGVAR(allmen_%1),_side_char];_unitliste = _list call FUNC(RandomArrayVal)};
        case "specops": {_how_many = ceil random 5; if (_how_many < 2) then {_how_many = 2};_list = missionNamespace getVariable format [QGVAR(specops_%1),_side_char];_unitliste resize _how_many;for "_i" from 0 to _how_many - 1 do {_unitliste set [_i, _list call FUNC(RandomArrayVal)]}};
        case "artiobserver": {_unitliste = [missionNamespace getVariable format[QGVAR(arti_observer_%1),_side_char]]};
        case "heli": {_list = missionNamespace getVariable format [QGVAR(allmen_%1),_side_char];_unitliste = _list call FUNC(RandomArrayVal)};
        case "tank": {_varray = (missionNamespace getVariable format [QGVAR(veh_a_%1), _side_char]) select 0;_vehiclename = _varray call FUNC(RandomArrayVal)};
        case "bmp": {_varray = (missionNamespace getVariable format [QGVAR(veh_a_%1), _side_char]) select 1;_vehiclename = _varray call FUNC(RandomArrayVal)};
        case "brdm": {_varray = (missionNamespace getVariable format [QGVAR(veh_a_%1), _side_char]) select 2;_vehiclename = _varray call FUNC(RandomArrayVal)};
        case "shilka": {_varray = (missionNamespace getVariable format [QGVAR(veh_a_%1), _side_char]) select 3;_vehiclename = _varray call FUNC(RandomArrayVal)};
        case "uaz_mg": {_varray = (missionNamespace getVariable format [QGVAR(veh_a_%1), _side_char]) select 4;_vehiclename = _varray call FUNC(RandomArrayVal)};
        case "uaz_grenade": {_varray = (missionNamespace getVariable format [QGVAR(veh_a_%1), _side_char]) select 5;_vehiclename = _varray call FUNC(RandomArrayVal)};
        case "DSHKM": {_varray = (missionNamespace getVariable format [QGVAR(veh_a_%1), _side_char]) select 6;_vehiclename = _varray call FUNC(RandomArrayVal)};
        case "AGS": {_varray = (missionNamespace getVariable format [QGVAR(veh_a_%1), _side_char]) select 7;_vehiclename = _varray call FUNC(RandomArrayVal)};
        case "D30": {_varray = (missionNamespace getVariable format [QGVAR(veh_a_%1), _side_char]) select 8;_vehiclename = _varray call FUNC(RandomArrayVal)};
        case "uralfuel": {_varray = (missionNamespace getVariable format [QGVAR(veh_a_%1), _side_char]) select 9;_vehiclename = _varray call FUNC(RandomArrayVal)};
        case "uralrep": {_varray = (missionNamespace getVariable format [QGVAR(veh_a_%1), _side_char]) select 10;_vehiclename = _varray call FUNC(RandomArrayVal)};
        case "uralammo": {_varray = (missionNamespace getVariable format [QGVAR(veh_a_%1), _side_char]) select 11;_vehiclename = _varray call FUNC(RandomArrayVal)};
        case "civilian": {_unitliste resize 11; for "_i" from 0 to 10 do {_one_man = GVAR(civilians_t) call FUNC(RandomArrayVal);_unitliste set [_i,_one_man]}};
        case "sabotage": {_how_many = ceil random 11; if (_how_many < 6) then {_how_many = 6};_list = missionNamespace getVariable format [QGVAR(sabotage_%1),_side_char];_unitliste resize _how_many; for "_i" from 0 to _how_many - 1 do {_unitliste set [_i, _list call FUNC(RandomArrayVal)]}};
    };
    [_unitliste, _vehiclename]
};

FUNC(getmixedliste) = {
    private ["_side", "_ret_list", "_list"];
    PARAMS_1(_side);
    _ret_list = [];
    {
        _list = [_x,_side] call FUNC(getunitliste);
        _ret_list set [count _ret_list, [_list select 1, _list select 2]];
    } forEach [switch (floor random 2) do {case 0: {"brdm"};case 1: {"uaz_mg"};}, "bmp", "tank", "shilka"];
    _ret_list
};

FUNC(handleDeadVec) = {
    private ["_v", "_type", "_dir", "_pos", "_vel", "_dv", "_fuel", "_putsmex"];
    PARAMS_1(_v);
    _type = typeOf _v;
    _dir = direction _v;
    _pos = position _v;
    _vel = velocity _v;
    _fuel = (fuel _v) / 2;
    _putsmex = !isNil {GV(_v,GVAR(smvec))};
    {deleteVehicle _x} forEach ([_v] + crew _v);
    _dv = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
    _dv setDir _dir;
    _dv setPos _pos;
    _dv setVelocity _vel;
    _dv setFuel _fuel;
    _dv setDamage 1;
    __addDead(_dv)
    if (_putsmex) then {GVAR(extra_mission_vehicle_remover_array) set [count GVAR(extra_mission_vehicle_remover_array), _dv]};
};

FUNC(makevgroup) = {
    scriptName "spawn_d_fnc_makevgroup";
    private ["_numbervehicles", "_pos", "_vehiclename", "_grp", "_direction", "_crews", "_grpskill", "_n", "_dir", "_vehicle", "_npos", "_radius", "_the_vehicles"];
    PARAMS_6(_numbervehicles,_pos,_vehiclename,_grp,_radius,_direction);
    _the_vehicles = [];
    _crews = [];
    _npos = _pos;
    
    _grpskill = if (_vehiclename isKindOf "StaticWeapon") then {1.0} else {(GVAR(skill_array) select 0) + (random (GVAR(skill_array) select 1))};
    
    _the_vehicles resize _numbervehicles;
    for "_n" from 0 to _numbervehicles - 1 do {
        _dir = if (_direction != -1.111) then {_direction} else {floor random 360};
        
        _vec_array = [_npos, _dir, _vehiclename, _grp] call FUNC(spawnVehicle);
        _vehicle = _vec_array select 0;
        _crews = [_crews, _vec_array select 1] call FUNC(arrayPushStack2);
        
        _the_vehicles set [_n, _vehicle];
        _npos = _vehicle modelToWorld [0,-12,0];
        
        _is_air_vec = false;
        switch (true) do {
            case (_vehicle isKindOf "Tank"): {
                if !((toUpper _vehiclename) in GVAR(heli_wreck_lift_types)) then {
                    _vehicle addEventHandler ["killed", {_this call FUNC(handleDeadVec)}];
                    __addDead(_vehicle)
                };
            };
            case (_vehicle isKindOf "Wheeled_APC"): {
                if !((toUpper _vehiclename) in GVAR(heli_wreck_lift_types)) then {
                    __addDead(_vehicle)
                    _vehicle addEventHandler ["killed", {_this call FUNC(handleDeadVec)}];
                };
            };
            case (_vehicle isKindOf "Car"): {
                if !((toUpper _vehiclename) in GVAR(heli_wreck_lift_types)) then {
                    __addDead(_vehicle)
                    _vehicle addEventHandler ["killed", {_this call FUNC(handleDeadVec)}];
                };
            };
            default {
                if !((toUpper _vehiclename) in GVAR(heli_wreck_lift_types)) then {
                    __addDead(_vehicle)
                };
                if (_vehicle isKindOf "Air") then {_is_air_vec = true};
            };
        };
    };
    (leader _grp) setSkill _grpskill;
    _grp setVariable [QGVAR(gstate), 1];
    [_the_vehicles, _crews]
};

FUNC(makemgroup) = {
    scriptName "spawn_d_fnc_makemgroup";
    private ["_pos", "_unitliste", "_grp", "_ret"];
    PARAMS_3(_pos,_unitliste,_grp);
    _ret = [];
    {
        _one_unit = _grp createunit [_x, _pos, [], 10,"NONE"];
        if (GVAR(without_nvg) == 0) then {
            if (_one_unit hasWeapon "NVGoggles") then {_one_unit removeWeapon "NVGoggles"};
        };
        _svec = sizeOf _x;
        _isFlat = (position _one_unit) isFlatEmpty [_svec / 2, 150, 0.7, _svec, 0, false, _one_unit];
        if (count _isFlat > 1) then {
            _isFlat set [2,0];
            if (_one_unit distance _isFlat < 50) then {
                _one_unit setPos _isFlat;
            };
        };
        _one_unit setVariable ["BIS_noCoreConversations", true];
        [_one_unit, {__addDead(_this)}] call FUNC(setUnitCode);
        _one_unit setUnitAbility ((GVAR(skill_array) select 0) + (random (GVAR(skill_array) select 1)));
        _ret set [count _ret, _one_unit];
    } foreach _unitliste;
    (leader _grp) setRank "SERGEANT";
    _grp setVariable [QGVAR(gstate), 1];
    _ret
};

FUNC(CreateInf) = {
    scriptName "func_createInf";
    private ["_radius", "_pos", "_nr", "_nrg", "_typenr", "_i", "_newgroup", "_units", "_pos_center", "_do_patrol", "_ret_grps"];
    _pos_center = _this select 4;
    _radius = _this select 5;
    _do_patrol = if (count _this == 7) then {_this select 6} else {false};
    if (_radius < 50) then {_do_patrol = false};
    
    _ret_grps = [];
    _pos = [];
    
    for "_nr" from 0 to 1 do {
        _nrg = _this select (1 + (_nr * 2));
        if (_nrg > 0) then {
            if (GVAR(MissionType) == 2) then {_nrg = _nrg + 2};
            _typenr = _this select (_nr * 2);
            for "_i" from 1 to _nrg do {
                _newgroup = [GVAR(side_enemy)] call FUNC(creategroup);
                _unit_array = [_typenr, GVAR(enemy_side)] call FUNC(getunitliste);
                if (_radius > 0) then {
                    _pos = [_pos_center, _radius] call FUNC(GetRanPointCircle);
                    if (count _pos == 0) then {
                        for "_ee" from 0 to 99 do {_pos = [_pos_center, _radius] call FUNC(GetRanPointCircle);if (count _pos > 0) exitWith {}};
                    };
                } else {
                    _pos = _pos_center;
                };
                _units = [_pos, _unit_array select 0, _newgroup] call FUNC(makemgroup);
                _newgroup allowFleeing 0;
                if (!_do_patrol) then {
                    _newgroup setCombatMode "YELLOW";
                    _newgroup setFormation (["COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","DIAMOND"] call FUNC(RandomArrayVal));
                    _newgroup setFormDir (floor random 360);
                    _newgroup setSpeedMode "NORMAL";
                };
                _ret_grps set [count _ret_grps, _newgroup];
                if (_do_patrol) then {
                    [_newgroup, _pos, [_pos_center, _radius], [5, 15, 30], "this call d_fnc_grmakesearch"] spawn FUNC(MakePatrolWPX);
                } else {
                    _newgroup setVariable [QGVAR(defend), true];
                    [_newgroup, _pos_center] spawn FUNC(taskDefend);
                };
                GVAR(extra_mission_remover_array) = [GVAR(extra_mission_remover_array), _units] call FUNC(arrayPushStack);
                if (GVAR(doRespawnGroups)) then {
                    GVAR(reduce_groups) set [count GVAR(reduce_groups), _newgroup];
                };
            };
        };
    };
    _ret_grps
};

FUNC(CreateArmor) = {
    scriptName "func_CreateArmor";
    private ["_numvehicles", "_radius", "_pos", "_nr", "_nrg", "_typenr", "_i", "_newgroup", "_reta", "_pos_center", "_do_patrol", "_ret_grps"];
    _pos_center = _this select 6;
    _numvehicles = _this select 7;
    _radius = _this select 8;
    _do_patrol = if (count _this == 10) then {_this select 9} else {false};
    if (_radius < 50) then {_do_patrol = false};
    _ret_grps = [];
    _pos = [];
    
    for "_nr" from 0 to 2 do {
        _nrg = _this select (1 + (_nr * 2));
        if (_nrg > 0) then {
            if (GVAR(MissionType) == 2) then {_nrg = _nrg + 2};
            _typenr = _this select (_nr * 2);
            for "_i" from 1 to _nrg do {
                _newgroup = [GVAR(side_enemy)] call FUNC(creategroup);
                if (_radius > 0) then {
                    _pos = [_pos_center, _radius] call FUNC(GetRanPointCircle);
                    if (count _pos == 0) then {
                        for "_ee" from 0 to 99 do {_pos = [_pos_center, _radius] call FUNC(GetRanPointCircle);if (count _pos > 0) exitWith {}};
                    };
                } else {
                    _pos = _pos_center;
                };
                _unit_array = [_typenr, GVAR(enemy_side)] call FUNC(getunitliste);
                _reta = [_numvehicles, _pos, _unit_array select 1, _newgroup, 0,-1.111] call FUNC(makevgroup);
                {_x setVariable [QGVAR(smvec), true]} forEach (_reta select 0);
                GVAR(extra_mission_vehicle_remover_array) = [GVAR(extra_mission_vehicle_remover_array), _reta select 0] call FUNC(arrayPushStack2);
                GVAR(extra_mission_remover_array) = [GVAR(extra_mission_remover_array), _reta select 1] call FUNC(arrayPushStack2);
                _newgroup allowFleeing 0;
                if (!_do_patrol) then {
                    _newgroup setCombatMode "YELLOW";
                    _newgroup setFormation (["COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","DIAMOND"] call FUNC(RandomArrayVal));
                    _newgroup setFormDir (floor random 360);
                    _newgroup setSpeedMode "NORMAL";
                };
                _ret_grps set [count _ret_grps, _newgroup];
                if (_do_patrol) then {
                    [_newgroup, _pos, [_pos_center, _radius], [5, 15, 30]] spawn FUNC(MakePatrolWPX)
                };
            };
        };
    };
    _ret_grps
};

FUNC(checknextwf) = {
    private ["_grp", "_istaking", "_camps"];
    PARAMS_1(_grp);
    _grp = _grp call FUNC(getgroup);
    __TRACE_1("checknextwf",_grp)
    _istaking = GV(_grp,GVAR(takingwf));
    if (isNil "_istaking") then {_istaking = false};
    if (_istaking) exitWith {};
    _camps = switch (side _grp) do {
        case east: {GVAR(west_camps)};
        case west: {GVAR(east_camps)};
    };
    if (count _camps > 0) then {
        _target_pos = position (_camps call FUNC(RandomArrayVal));
        [_grp, _target_pos] call FUNC(TakeWFWP);
    } else {
        // TODO: No camps left, and enough units in group, wait for next target and attack
        // if target is not too far away
    };
};

FUNC(OutOfBounds) = {
    private ["_vec", "_p_x", "_vec", "_p_y"];
    _vec = _this;
    _p_x = getPosASL _vec select 0;
    _p_y = getPosASL _vec select 1;
    ((_p_x < 0 || {_p_x > GVAR(island_x_max)}) && {(_p_y < 0 || {_p_y > GVAR(island_y_max)})})
};

// supports also patrols in square areas, including angle
FUNC(MakePatrolWPX) = {
    scriptName "spawn_fnc_MakePatrolWPX";
    private ["_grp", "_start_pos", "_wp_array", "_i", "_wp_pos", "_counter", "_wp", "_wppos", "_pos", "_cur_pos","_no_pos_found", "_wpstatements", "_timeout", "_wp1"];
    PARAMS_3(_grp,_start_pos,_wp_array);
    if (typeName _wp_array == "OBJECT") then {_wp_array = position _wp_array};
    if (typeName _wp_array != "ARRAY") exitWith {};
    if (typeName _start_pos == "OBJECT") then {_start_pos = position _start_pos};
    if (typeName _start_pos != "ARRAY" || {count _start_pos == 0}) exitWith {};
    if (isNull _grp) exitWith {};
    _timeout = if (count _this > 3) then {_this select 3} else {[]};
    _wpstatements = if (count _this > 4) then {_this select 4} else {""};
    _grp setBehaviour "SAFE";
    _cur_pos = _start_pos;
    _no_pos_found = false;
    for "_i" from 0 to (2 + (floor (random 3))) do {
        _wp_pos = switch (count _wp_array) do {
            case 2: {[_wp_array select 0, _wp_array select 1] call FUNC(GetRanPointCircle)};
            case 4: {[_wp_array select 0, _wp_array select 1, _wp_array select 2, _wp_array select 3] call FUNC(GetRanPointSquare)};
        };
        if (count _wp_pos == 0) exitWith {_no_pos_found = true};
        _counter = 0;
        while {_wp_pos distance _cur_pos < ((_wp_array select 1)/6) && {_counter < 100}} do {
            _wp_pos = switch (count _wp_array) do {
                case 2: {[_wp_array select 0, _wp_array select 1] call FUNC(GetRanPointCircle)};
                case 4: {[_wp_array select 0, _wp_array select 1, _wp_array select 2, _wp_array select 3] call FUNC(GetRanPointSquare)};
            };
            if (count _wp_pos == 0) exitWith {};
            __INC(_counter);
        };
        if (count _wp_pos == 0) exitWith {_no_pos_found = true};
        _wp_pos = _wp_pos call FUNC(WorldBoundsCheck);
        _cur_pos = _wp_pos;
        _wp = _grp addWaypoint [_wp_pos, 0];
        _wp setWaypointType "MOVE";
        _wp setWaypointCompletionRadius (0 + random 10);
        if (count _timeout > 0) then {_wp setWaypointTimeout _timeout};
        
        if (_i == 0) then {
            _wp setWaypointSpeed "LIMITED";
            _wp setWaypointFormation "STAG COLUMN";
        };
        if (_wpstatements != "") then {
            _wp setWaypointStatements ["TRUE", _wpstatements];
        };
    };
    if (_no_pos_found) exitWith {
        _wp1 = _grp addWaypoint [_start_pos, 0];
        _wp1 setWaypointType "SAD";
    };
    _wp1 = _grp addWaypoint [_start_pos, 0];
    _wp1 setWaypointType "MOVE";
    _wp1 setWaypointCompletionRadius (10 + random 10);
    if (count _timeout > 0) then {_wp1 setWaypointTimeout _timeout};
    if (_wpstatements != "") then {
        _wp1 setWaypointStatements ["TRUE", _wpstatements];
    };
    _wp = _grp addWaypoint [_start_pos, 0];
    _wp setWaypointType "CYCLE";
    _wp setWaypointCompletionRadius (10 + random 10);
};

// supports also patrols in square areas, including angle
FUNC(MakePatrolWPX2) = {
    scriptName "spawn_fnc_MakePatrolWPX2";
    private ["_grp", "_start_pos", "_wp_array", "_i", "_wp_pos", "_counter", "_wp", "_wppos", "_pos", "_cur_pos","_no_pos_found", "_wpstatements", "_timeout", "_wp1"];
    PARAMS_3(_grp,_start_pos,_wp_array);
    if (typeName _wp_array == "OBJECT") then {_wp_array = position _wp_array};
    if (typeName _wp_array != "ARRAY") exitWith {};
    if (typeName _start_pos == "OBJECT") then {_start_pos = position _start_pos};
    if (typeName _start_pos != "ARRAY" || {count _start_pos == 0}) exitWith {};
    _timeout = if ((count _this) > 3) then {_this select 3} else {[]};
    _wpstatements = if (count _this > 4) then {_this select 4} else {""};
    _grp setBehaviour "AWARE";
    _grp setSpeedMode "FULL";
    _cur_pos = _start_pos;
    _no_pos_found = false;
    for "_i" from 0 to (2 + (floor (random 3))) do {
        _wp_pos = switch (count _wp_array) do {
            case 2: {[_wp_array select 0, _wp_array select 1] call FUNC(GetRanPointCircle)};
            case 4: {[_wp_array select 0, _wp_array select 1, _wp_array select 2, _wp_array select 3] call FUNC(GetRanPointSquare)};
        };
        if (count _wp_pos == 0) exitWith {_no_pos_found = true};
        _counter = 0;
        while {_wp_pos distance _cur_pos < ((_wp_array select 1)/6) && {_counter < 100}} do {
            _wp_pos = switch (count _wp_array) do {
                case 2: {[_wp_array select 0, _wp_array select 1] call FUNC(GetRanPointCircle)};
                case 4: {[_wp_array select 0, _wp_array select 1, _wp_array select 2, _wp_array select 3] call FUNC(GetRanPointSquare)};
            };
            if (count _wp_pos == 0) exitWith {};
            __INC(_counter);
        };
        if (count _wp_pos == 0) exitWith {_no_pos_found = true};
        _wp_pos = _wp_pos call FUNC(WorldBoundsCheck);
        _cur_pos = _wp_pos;
        _wp = _grp addWaypoint [_wp_pos, 0];
        _wp setWaypointType "MOVE";
        _wp setWaypointCompletionRadius (0 + random 10);
        if (count _timeout > 0) then {_wp setWaypointTimeout _timeout};
        
        if (_i > 0) then {
            _wp setWaypointSpeed "LIMITED";
            _wp setWaypointFormation "STAG COLUMN";
            _wp setWaypointBehaviour "SAFE";
        } else {
            _wp setWaypointSpeed "FULL";
            _wp setWaypointBehaviour "AWARE";
            _wp setWaypointFormation "STAG COLUMN";
        };
        if (_wpstatements != "") then {
            _wp setWaypointStatements ["TRUE", _wpstatements];
        };
    };
    if (_no_pos_found) exitWith {
        _wp1 = _grp addWaypoint [_start_pos, 0];
        _wp1 setWaypointType "SAD";
    };
    _wp1 = _grp addWaypoint [_start_pos, 0];
    _wp1 setWaypointType "MOVE";
    _wp1 setWaypointCompletionRadius (10 + random 10);
    if (count _timeout > 0) then {_wp1 setWaypointTimeout _timeout};
    if (_wpstatements != "") then {
        _wp1 setWaypointStatements ["TRUE", _wpstatements];
    };
    _wp = _grp addWaypoint [_start_pos, 0];
    _wp setWaypointType "CYCLE";
    _wp setWaypointCompletionRadius (10 + random 10);
};

FUNC(DelVecAndCrew) = {{deleteVehicle _x} forEach ([[_this], crew _this] call FUNC(arrayPushStack2))};

FUNC(TakeWFWP) = {
    private ["_ggrp","_gtarget_pos","_gwp"];
    PARAMS_2(_ggrp,_gtarget_pos);
    _ggrp = _ggrp call FUNC(getgroup);
    __TRACE_2("TakeWFWP",_ggrp,_gtarget_pos)
    _ggrp setbehaviour "AWARE";
    _gwp = _ggrp addWaypoint [_gtarget_pos, 0];
    _gwp setwaypointtype "MOVE";
    _gwp setWaypointCombatMode "YELLOW";
    _gwp setWaypointSpeed "NORMAL";
    _gwp setWaypointTimeout [60, 60 + random 20, 80 + random 20];
    _gwp setWaypointStatements ["TRUE", "call {private '_xxgrp';_xxgrp = this call d_fnc_getgroup; _xxgrp setVariable ['d_takingwf', false];if ((_xxgrp call d_fnc_GetAliveUnitsGrp) > 0) then {[_xxgrp] call d_fnc_checknextwf}}"];
    _ggrp setVariable [QGVAR(takingwf), true];
};

FUNC(GuardWP) = {
    private ["_ggrp"];
    _ggrp = _this;
    _ggrp setCombatMode "YELLOW";
    _ggrp setFormation (["COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","FILE","DIAMOND"] call FUNC(RandomArrayVal));
    _ggrp setFormDir (floor random 360);
    _ggrp setSpeedMode "NORMAL";
    _ggrp setBehaviour "SAFE";
};

FUNC(AttackWP) = {
    private ["_ggrp","_gtarget_pos","_gwp"];
    PARAMS_2(_ggrp,_gtarget_pos);
    _ggrp setbehaviour "AWARE";
    _gwp = _ggrp addWaypoint [_gtarget_pos,30];
    _gwp setwaypointtype "SAD";
    _gwp setWaypointCombatMode "YELLOW";
    _gwp setWaypointSpeed "FULL";
};

FUNC(setUnitCode) = {
    private "_uc";
    (_this select 0) call (_this select 1);
    _uc = (_this select 0) getVariable QGVAR(unitcode);
    if (isNil "_uc") then {
        _uc = [_this select 1];
    } else {
        _uc set [count _uc, _this select 1];
    };
    (_this select 0) setVariable [QGVAR(unitcode), _uc];
};

FUNC(getgroup) = {
    if (tolower (typeName _this) == "group") exitwith {_this};
    group _this
};

FUNC(getnearestbuilding) = {
    private ["_building", "_i"];
    _building = nearestBuilding _this;
    _i = 0;
    while {str(_building buildingPos _i) != "[0,0,0]"} do {__INC(_i)};
    [_building, _i]
};

// by Rommel
FUNC(searchNearby) = {
    scriptName "d_fnc_searchNearby";
    private ["_group", "_leader", "_behaviour", "_array", "_building", "_indices", "_count", "_units", "_timeout", "_unit", "_gstate"];
    _group = (_this select 0) call FUNC(getgroup);
    _gstate = _group getVariable QGVAR(gstate);
    if (isNil "_gstate") then {_gstate = 2};
    if (_gstate == 2) exitWith {};
    _group lockwp true;
    private ["_leader","_behaviour"];
    _leader = leader _group;
    _behaviour = behaviour _leader;
    _group setbehaviour "combat";
    
    private ["_array", "_building", "_indices"];
    _array = _leader call FUNC(getnearestbuilding);
    if (count _array < 2) exitWith {_group lockwp false};
    _building = _array select 0;
    if (_leader distance _building > 200) exitWith {_group lockwp false};
    _indices = _array select 1;
    _group setformdir ([_leader, _building] call FUNC(DirTo));
    
    private ["_count","_units"];
    _units = units _group;
    _count = (count _units) - 1;
    
    _timeout = time + 600;
    
    while {_indices > 0 && {_count > 0} && {_timeout > time}} do {
        sleep 10;
        while {_indices > 0 && {_count > 0} && {_timeout > time}} do {
            private "_unit";
            _unit = _units select _count;
            if (unitready _unit) then {
                _unit commandmove (_building buildingpos _indices);
                _indices = _indices - 1;
            };
            _count = _count - 1;
        };
        _units = units _group;
        _count = (count _units) - 1;
    };
    waituntil {sleep 3;	{unitready _x} count _units >= count (units _group) - 1 || {(_units call FUNC(GetAliveUnits)) == 0} || {time > _timeout}};
    if ((_units call FUNC(GetAliveUnits)) > 0) then {
        {_x dofollow _leader} foreach _units;
        _group setbehaviour _behaviour;
        _group lockwp false;
    };
};

FUNC(grmakesearch) = {
    private ["_xxgrp"];
    _xxgrp = _this call FUNC(getgroup);
    if ((_xxgrp call FUNC(GetAliveUnitsGrp)) > 1 && {(random 100) > 60}) then {
        [_this] spawn FUNC(searchNearby);
    };
};

FUNC(GetEnemyFlagType) = {("F" + GVAR(enemy_side)) call FUNC(StoreGet)};
FUNC(GetOwnFlagType) = {("F" + GVAR(own_side)) call FUNC(StoreGet)};
FUNC(GetSideFlagType) = {("F" + _this) call FUNC(StoreGet)};

FUNC(selectCrew) = {
    /*
    File: selectCrew.sqf
    Author: Joris-Jan van 't Land
    
    Description:
    Return an appropriate crew type for a certain vehicle.
    
    Parameter(s):
    _this select 0: side (Side)
    _this select 1: vehicle config entry (Config)
    
    Returns:
    Array - crew type, cargo types (array) for Wheeled APCs
    */
    if (count _this < 2) exitWith {};
    private ["_side", "_entry", "_type"];
    PARAMS_3(_side,_entry,_type);
    if (typeName _side != typeName sideEnemy || {typeName _entry != typeName configFile}) exitWith {""};
    private ["_crew", "_typcargo"];
    _crew = "";
    _typcargo = [];
    _crew = getText (_entry >> "crew");
    if (_crew == "") then {
        switch (_side) do {
            case west: {_crew = GVAR(vec_spawn_default_Crew) select 0};
            case east: {_crew = GVAR(vec_spawn_default_Crew) select 1};
            default {};
        };
    } else {
        if (_type isKindOf "Car" || {_type isKindOf "Tracked_APC"}) then {
            _typcargo = (getArray (_entry >> "typicalCargo")) - [_crew,"Soldier"];
        };
    };
    [_crew, _typcargo]
};

FUNC(SideMissionResolved) = {
    if (isNil QGVAR(HC_CLIENT_OBJ)) then {
        execFSM "fsms\XClearSidemission.fsm";
    } else {
        [QGVAR(smclear), GVAR(HC_CLIENT_OBJ)] call FUNC(NetCallEventSTO);
    };
    if (X_SPE) then {
        deleteMarkerLocal (format ["XMISSIONM%1", __XJIPGetVar(GVAR(current_mission_index)) + 1]);
        if (GVAR(x_sm_type) == "convoy") then {deleteMarkerLocal (format ["XMISSIONM2%1", __XJIPGetVar(GVAR(current_mission_index)) + 1])};
    };
    [QGVAR(sm_res_client), [GVAR(side_mission_winner), ""]] call FUNC(NetCallEventToClients);
    if (GVAR(side_mission_winner) > 0) then {
        GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"MissionAccomplished",true];
        diag_log format ["Side Target: completed (m%1)", __XJIPGetVar(GVAR(current_mission_index))];
    };
    if (GVAR(side_mission_winner) in [-1,-2,-300,-400,-500,-600,-700,-878,-879]) then {
        [QGVAR(kbmsg), [35]] call FUNC(NetCallEventCTS);
        if (!X_SPE) then {GVAR(side_mission_winner) = 0};
        diag_log format ["Side Target: failed (m%1)", __XJIPGetVar(GVAR(current_mission_index))];
    };
    [QGVAR(current_mission_index),-1] call FUNC(NetSetJIP);
    0 spawn {
        sleep 15;
        [QGVAR(getSM)] call FUNC(NetCallEventCTS);
    };
};

FUNC(CheckMTShotHD) = {
    private ["_tower", "_r", "_val"];
    PARAMS_1(_tower);
    _r = 0;
    if ((toUpper(getText(configFile >> "CfgAmmo" >> (_this select 4) >> "simulation")) in GVAR(hd_sim_types)) || {((_this select 4) == "ACE_PipebombExplosion")}) then {
        _r = _this select 2;
    } else {
        if (GVAR(MTTowerSatchelsOnly) == 1 && {getText(configFile >> "CfgAmmo" >> (_this select 4) >> "CraterEffects") == "BombCrater"}) then {
            _r = _this select 2;
        };
    };
    _val = _tower getVariable QGVAR(damt);
    if (isNil "_val") then {_val = 0};
    _r = _r + _val;
    _tower setVariable [QGVAR(damt), _r];
    _r
};

FUNC(CheckMTHardTarget) = {
    private ["_vehicle", "_trigger", "_trigger2","_hdeh"];
    PARAMS_1(_vehicle);
    [_vehicle] execFSM "fsms\XRemoveVehiExtra.fsm";
    _vehicle addEventHandler ["killed", {
        GVAR(mt_spotted) = false;
        if (GVAR(IS_HC_CLIENT)) then {
            [QGVAR(sSetVar), [QGVAR(mt_spotted), false]] call FUNC(NetCallEventCTS);
        };
        [QGVAR(mt_radio_down),true] call FUNC(NetSetJIP);
        deleteMarker QGVAR(main_target_radiotower);
        #ifndef __TT__
        [QGVAR(kbmsg), [37]] call FUNC(NetCallEventCTS);
        #else
        [QGVAR(kbmsg), [38]] call FUNC(NetCallEventCTS);
        _killedby = switch (_this select 1) do {case west: {"US"};case east: {"EAST"};default {"N"};};
        if (_killedby != "N") then {
            [QGVAR(kbmsg), [39, _killedby]] call FUNC(NetCallEventCTS);
        };
        #endif
    }];
    _hdeh = _vehicle addEventHandler ["handleDamage", {_this call FUNC(CheckMTShotHD)}];
};

FUNC(GetSMTargetMessage) = {
    switch (_this) do {
        case "gov_dead": {(localize "STR_DOM_MISSIONSTRING_949")};
        #ifdef __CO__
        case "radar_down": {(localize "STR_DOM_MISSIONSTRING_950")};
        #endif
        #ifdef __OA__
        case "radar_down": {(localize "STR_DOM_MISSIONSTRING_951")};
        #endif
        case "ammo_down": {(localize "STR_DOM_MISSIONSTRING_952")};
        case "apc_down": {(localize "STR_DOM_MISSIONSTRING_953")};
        case "hq_down": {(localize "STR_DOM_MISSIONSTRING_954")};
        case "light_down": {(localize "STR_DOM_MISSIONSTRING_955")};
        case "heavy_down": {(localize "STR_DOM_MISSIONSTRING_956")};
        case "artrad_down": {(localize "STR_DOM_MISSIONSTRING_957")};
        case "airrad_down": {(localize "STR_DOM_MISSIONSTRING_958")};
        case "lopo_dead": {(localize "STR_DOM_MISSIONSTRING_959")};
        case "dealer_dead": {(localize "STR_DOM_MISSIONSTRING_960")};
        case "sec_over": {(localize "STR_DOM_MISSIONSTRING_961")};
    };
};

FUNC(MTSMTargetKilled) = {
    private "_type";
    _type = _this select (count _this - 1);
    GVAR(side_main_done) = true;
    if (GVAR(IS_HC_CLIENT)) then {
        [QGVAR(sSetVar), [QGVAR(side_main_done), true]] call FUNC(NetCallEventCTS);
    };
    private "_s";
    _s = (if (side (_this select 1) == GVAR(side_player)) then {_type} else {"sec_over"}) call FUNC(GetSMTargetMessage);
    [QGVAR(kbmsg), [42, _s]] call FUNC(NetCallEventCTS);
    ["sec_kind",0] call FUNC(NetSetJIP);
};

#ifndef __TT__
GVAR(airmarker_counter) = 0;
FUNC(AirMarkerMove) = {
    scriptName "d_fnc_AirMarkerMove";
    private ["_vec", "_markern"];
    _vec = _this;
    sleep 30;
    if (!isNull _vec && {alive _vec} && {canMove _vec}) then {
        _markern = str(_vec) + str(GVAR(airmarker_counter));
        __INC(GVAR(airmarker_counter));
        [_markern, [0,0,0],"ICON","ColorRed",[0.5,0.5],(localize "STR_DOM_MISSIONSTRING_963"),0,"Air"] call FUNC(CreateMarkerGlobal);
        while {!isNull _vec && {alive _vec} && {canMove _vec}} do {
            _markern setMarkerPos getPosASL _vec;
            sleep (3 + random 1);
        };
        deleteMarker _markern;
    };
};

GVAR(isledefmarker_counter) = 0;
FUNC(IsleDefMarkerMove) = {
    scriptName "d_fnc_IsleDefMarkerMove";
    private ["_grp", "_markern"];
    _grp = _this;
    sleep 30;
    if (!isNull _grp && {(_grp call FUNC(GetAliveUnitsGrp)) > 0}) then {
        _markern = str(_grp) + "i_d_f_m" + str(GVAR(IsleDefMarkerMove));
        __INC(GVAR(IsleDefMarkerMove));
        [_markern, [0,0,0],"ICON","ColorRed",[0.5,0.5],(localize "STR_DOM_MISSIONSTRING_964"),0,GVAR(isle_defense_marker)] call FUNC(CreateMarkerGlobal);
        while {!isNull _grp && {(_grp call FUNC(GetAliveUnitsGrp)) > 0}} do {
            private "_lead";
            _lead = leader _grp;
            if (!isNull _lead) then {
                _markern setMarkerPos getPosASL _lead;
            };
            sleep (10 + random 10);
        };
        deleteMarker _markern;
    };
};
#endif