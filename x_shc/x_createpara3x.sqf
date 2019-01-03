// by Xeno
#define THIS_FILE "x_createpara3x.sqf"
#include "x_setup.sqf"
private ["_type","_startpoint","_attackpoint","_heliendpoint","_number_vehicles","_parachute_type","_make_jump","_stop_it","_current_target_pos","_dummy","_delveccrew"];
if !(call FUNC(checkSHC)) exitWith {};

PARAMS_4(_startpoint,_attackpoint,_heliendpoint,_number_vehicles);

GVAR(should_be_there) = _number_vehicles;

GVAR(c_attacking_grps) = [];

_delveccrew = {
    scriptName "spawn_x_createpara3_delveccrew";
    private ["_crew_vec", "_vehicle", "_time"];
    PARAMS_3(_crew_vec,_vehicle,_time);
    sleep _time;
    {if (!isNull _x) then {_x setDamage 1}} forEach _crew_vec;
    sleep 1;
    if (!isNull _vehicle && {({isPlayer _x} count (crew _vehicle)) == 0}) then {_vehicle setDamage 1};
};

_make_jump = {
    scriptName "spawn_x_createpara3_make_jump";
    private ["_vgrp", "_vehicle", "_attackpoint", "_heliendpoint", "_driver_vec", "_wp", "_stop_me", "_parachute_type", "_dummy", "_current_target_pos", "_paragrp", "_unit_array", "_real_units", "_i", "_type", "_one_unit", "_para", "_grp_array","_crew_vec","_delveccrew"];
    PARAMS_5(_vgrp,_vehicle,_attackpoint,_heliendpoint,_delveccrew);
    
    __TRACE("_make_jump");
    
    _startpos = position _vehicle;
    _driver_vec = driver _vehicle;
    _crew_vec = crew _vehicle;
    
    _wp = _vgrp addWaypoint [_attackpoint, 0];
    _wp setWaypointBehaviour "CARELESS";
    _wp setWaypointSpeed "NORMAL";
    _wp setwaypointtype "MOVE";
    _wp setWaypointFormation "VEE";
    _wp = _vgrp addWaypoint [_heliendpoint, 0];
    
    _vehicle flyInHeight 100;
    
    sleep 10.0231;
    
    _stop_me = false;
    _checktime = time + 300;
    while {[_attackpoint select 0, _attackpoint select 1, 0] distance [getPosASL (leader _vgrp) select 0, getPosASL (leader _vgrp) select 1, 0] > 300} do {
        #ifdef __DEBUG__
        _ddd = _attackpoint distance (leader _vgrp);
        __TRACE_1("",_ddd);
        #endif
        if (isNull _vehicle || {!alive _vehicle} || {!alive _driver_vec} || {!canMove _vehicle}) exitWith {__DEC(GVAR(should_be_there))};
        sleep 0.01;
        if (__XJIPGetVar(GVAR(mt_radio_down)) && {(_attackpoint distance (leader _vgrp) > 1300)}) exitWith {
            [_crew_vec, _vehicle, 1 + random 1] spawn _delveccrew;
            _stop_me = true;
        };
        sleep 0.01;
        if (time > _checktime) then {
            if (_startpos distance position _vehicle < 500) then {
                __DEC(GVAR(should_be_there));
                [_crew_vec, _vehicle, 1 + random 1] spawn _delveccrew;
                _stop_me = true;
            } else {
                _checktime = time + 9999999;
            };
        };
        if (_stop_me) exitWith {};
        sleep 2.023;
    };
    if (_stop_me) exitWith {};
    
    sleep 0.534;
    
    _parachute_type = GVAR(enemy_side) call FUNC(GetParachuteSide);
    
    if (!isNull _vehicle && {alive _vehicle} && {alive _driver_vec} && {canMove _vehicle}) then {
        _dummy = GVAR(target_names) select __XJIPGetVar(GVAR(current_target_index));
        _current_target_pos = _dummy select 0;
        if (!__XJIPGetVar(GVAR(mt_radio_down)) && {(_vehicle distance _current_target_pos < 500)}) then {
            _cur_radius = _dummy select 2;
            __GetEGrp(_paragrp)
            _unit_array = ["heli", GVAR(enemy_side)] call FUNC(getunitliste);
            _real_units = _unit_array select 0;
            _unit_array = nil;
            sleep 0.1;
            {
                _one_unit = _paragrp createunit [_x, [10,10,0], [], 300,"NONE"];
                if (GVAR(without_nvg) == 0) then {
                    if (_one_unit hasWeapon "NVGoggles") then {_one_unit removeWeapon "NVGoggles"};
                };
                _one_unit setVariable ["BIS_noCoreConversations", true];
                [_one_unit, {__addDeadAI(_this)}] call FUNC(setUnitCode);
                _one_unit setSkill ((GVAR(skill_array) select 0) + (random (GVAR(skill_array) select 1)));
                
                _para = createVehicle [_parachute_type, position _vehicle, [], 20, 'NONE'];
                _para setDir random 360;
                _para setpos [(position _vehicle) select 0,(position _vehicle) select 1,((position _vehicle) select 2)- 10];
                _one_unit moveInDriver _para;
                sleep 0.551;
            } forEach _real_units;
            _paragrp allowFleeing 0;
            _paragrp setCombatMode "YELLOW";
            _paragrp setBehaviour "AWARE";
            
            [_paragrp, _current_target_pos, _cur_radius] spawn {
                scriptName "spawn_x_createpara3_usegroup";
                private ["_grp", "_pos", "_rad"];
                PARAMS_3(_grp,_pos,_rad);
                sleep 30;
                if ((_grp call FUNC(GetAliveUnitsGrp)) > 0) then {
                    [_grp, _pos, [_pos, _rad], [10, 20, 50], "this call d_fnc_grmakesearch"] spawn FUNC(MakePatrolWPX);
                    _grp setVariable [QGVAR(PATR),true];
                    if (GVAR(doRespawnGroups)) then {
                        GVAR(reduce_groups) set [count GVAR(reduce_groups), _grp];
                    };
                };
            };
            
            GVAR(c_attacking_grps) set [count GVAR(c_attacking_grps), _paragrp];
            
            sleep 0.112;
            __DEC(GVAR(should_be_there));
            
            while {(_heliendpoint distance (leader _vgrp) > 300)} do {
                if (isNull _vehicle || {!alive _vehicle} || {!alive _driver_vec} || {!canMove _vehicle}) exitWith {};
                sleep 5.123;
            };
            
            if (!isNull _vehicle && {(_heliendpoint distance _vehicle) > 300}) then {
                [_crew_vec, _vehicle, 240 + random 100] spawn _delveccrew;
            } else {
                _vehicle call FUNC(DelVecAndCrew);
            };
            if (!isNull _driver_vec) then {_driver_vec setDamage 1.1};
        };
    } else {
        [_crew_vec, _vehicle, 240 + random 100] spawn _delveccrew;
    };
};

_dummy = GVAR(target_names) select __XJIPGetVar(GVAR(current_target_index));
_current_target_pos = _dummy select 0;
_stop_it = false;

#ifndef __TT__
if ((__XJIPGetVar(GVAR(searchintel)) select 1) == 1) then {
    [QGVAR(kbmsg), [43]] call FUNC(NetCallEventCTS);
};
#endif

for "_i" from 1 to _number_vehicles do {
    if (__XJIPGetVar(GVAR(mt_radio_down))) exitWith {_stop_it = true};
    _dummy = GVAR(target_names) select __XJIPGetVar(GVAR(current_target_index));
    _new_current_target_pos = _dummy select 0;
    if (_new_current_target_pos distance _current_target_pos > 500) exitWith {_stop_it = true};
    __GetEGrp(_vgrp)
    _heli_type = GVAR(transport_chopper) call FUNC(RandomArrayVal);
    _spos = [_startpoint select 0, _startpoint select 1, 300];
    _cdir = [_spos, _attackpoint] call FUNC(DirTo);
    _veca = [_spos, _cdir, _heli_type, _vgrp] call FUNC(spawnVehicle);
    _vehicle = _veca select 0;
    if !((toUpper _heli_type) in GVAR(heli_wreck_lift_types)) then {__addDead(_vehicle)};
    _vehicle spawn FUNC(AirMarkerMove);

    if (GVAR(LockAir) == 0) then {_vehicle lock true};
    sleep 5.012;
    
    _vehicle flyInHeight 100;

    if (__XJIPGetVar(GVAR(mt_radio_down))) exitWith {_stop_it = true};
    
    [_vgrp,_vehicle,_attackpoint,_heliendpoint, _delveccrew] spawn _make_jump;
    
    sleep 40 + random 30;
};

if (_stop_it) exitWith {};

while {GVAR(should_be_there) > 0 && {!__XJIPGetVar(GVAR(mt_radio_down))}} do {sleep 1.021};

if (!__XJIPGetVar(GVAR(mt_radio_down))) then {
    sleep 20.0123;
    if (count GVAR(c_attacking_grps) > 0) then {
        [GVAR(c_attacking_grps)] execVM "x_server\x_handleattackgroups.sqf";
    } else {
        GVAR(c_attacking_grps) = [];
        GVAR(create_new_paras) = true;
    };
};