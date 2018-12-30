// by Xeno
#define THIS_FILE "x_airki.sqf"
#include "x_setup.sqf"
private ["_type", "_number", "_pos", "_wp_behave", "_heli_type", "_vehicle", "_initial_type", "_grp", "_vehicles", "_funits", "_unit", "_num_p", "_re_random", "_grpskill", "_numair", "_xxx", "_vec_array", "_old_target", "_loop_do", "_dummy", "_current_target_pos", "_wp", "_pat_pos", "_radius", "_old_pat_pos", "_angle", "_x1", "_y1", "_vehicles_number", "_i", "_vecx", "_vec"];
if !(call FUNC(checkSHC)) exitWith {};

PARAMS_2(_type,_number);

_wp_behave = "AWARE";

_initial_type = _type;

while {true} do {
    if (!__XJIPGetVar(GVAR(mt_radio_down))) then {
        while {!GVAR(mt_spotted)} do {sleep 11.32};
    } else {
        while {__XJIPGetVar(GVAR(mt_radio_down))} do {sleep 10.123};
        if (!GVAR(mt_spotted)) then {
            while {!GVAR(mt_spotted)} do {sleep 12.32};
        };
    };
    _grp = objNull;
    _vehicle = objNull;
    _vehicles = [];
    _funits = [];
    _unit = objNull;
    _num_p = call FUNC(PlayersNumber);
    sleep (switch (true) do {
        case (_num_p < 5): {600};
        case (_num_p < 10): {400};
        case (_num_p < 20): {200};
        default {0};
    });
    __MPCheck;
    while {__XJIPGetVar(GVAR(mt_radio_down))} do {sleep 6.123};
    _pos = call FUNC(GetRanPointOuterAir);
    
    _grpskill = 0.6 + (random 0.3);
    
    if (_initial_type == "SU") then {_type = (if ((random 100) > 60) then {"MIMG"} else {"SU"})};
    
    __GetEGrp(_grp)
    _heli_type = "";
    _numair = 0;
    switch (_type) do {
        case "KA": {
            _heli_type = GVAR(airki_attack_chopper) call FUNC(RandomArrayVal);
            _numair = GVAR(number_attack_choppers);
        };
        case "SU": {
            _heli_type = GVAR(airki_attack_plane) call FUNC(RandomArrayVal);
            _numair = GVAR(number_attack_planes);
        };
        case "MIMG": {
            _heli_type = GVAR(light_attack_chopper) call FUNC(RandomArrayVal);
            _numair = GVAR(number_attack_choppers);
        };
    };
    
    waitUntil {sleep 0.323;__XJIPGetVar(GVAR(current_target_index)) >= 0};
    _cdir = [_pos, GVAR(island_center)] call FUNC(DirTo);

    switch (_type) do {
        case "SU": {if ((__XJIPGetVar(GVAR(searchintel)) select 2) == 1) then {[QGVAR(kbmsg), [0]] call FUNC(NetCallEventCTS)}};
        case "KA": {if ((__XJIPGetVar(GVAR(searchintel)) select 3) == 1) then {[QGVAR(kbmsg), [1]] call FUNC(NetCallEventCTS)}};
        case "MIMG": {if ((__XJIPGetVar(GVAR(searchintel)) select 4) == 1) then {[QGVAR(kbmsg), [2]] call FUNC(NetCallEventCTS)}};
    };

    for "_xxx" from 1 to _numair do {
        _vec_array = [[_pos select 0, _pos select 1, 400], _cdir, _heli_type, _grp] call FUNC(spawnVehicle);
        
        _vehicle = _vec_array select 0;
        _vehicle setPos [_pos select 0, _pos select 1, 400];
        _vehicles set [count _vehicles, _vehicle];
        
        _funits = [_funits, (_vec_array select 1)] call FUNC(arrayPushStack2);
    
        _vehicle flyInHeight 200;
        _vehicle setVariable [QGVAR(WreckDeleteTime), 2700, true];
        _vehicle setVariable [QGVAR(WreckMaxRepair), 1, true];
        _vehicle setVariable ["D_VEC_SIDE", 1, true];
        _vehicle execFSM "fsms\Wreckmarker.fsm";
        _vehicle spawn FUNC(AirMarkerMove);
        sleep 0.1;
    };
    
    (leader _grp) setSkill _grpskill;
    
    sleep 1.011;
    
    _grp allowFleeing 0;
    
    _old_target = [0,0,0];
    _loop_do = true;
    waitUntil {sleep 0.323;__XJIPGetVar(GVAR(current_target_index)) >= 0};
    _dummy = GVAR(target_names) select __XJIPGetVar(GVAR(current_target_index));
    _current_target_pos = _dummy select 0;
    _wp = _grp addWayPoint [_current_target_pos, 0];
    _wp setWaypointType "SAD";
    _pat_pos = _current_target_pos;
    [_grp, 1] setWaypointStatements ["never", ""];
    while {_loop_do} do {
        waitUntil {sleep 0.323;__XJIPGetVar(GVAR(current_target_index)) >= 0};
        _dummy = GVAR(target_names) select __XJIPGetVar(GVAR(current_target_index));
        _current_target_pos = _dummy select 0;
        _radius = _dummy select 2;
        
        sleep 3 + random 2;

        _radius = switch (_type) do {
            case "KA": {_radius * 3};
            case "MIMG": {_radius * 3};
            case "SU": {_radius * 5};
            default {_radius};
        };
        
#define __patternpos \
_angle = floor (random 360);\
_x1 = (_current_target_pos select 0) - ((random _radius) * sin _angle);\
_y1 = (_current_target_pos select 1) - ((random _radius) * cos _angle);\
_pat_pos = [_x1, _y1,(_current_target_pos select 2)]

        if (_vehicle distance _current_target_pos < _radius) then {
            if (_type == "KA" || {_type == "MIMG"}) then {
                _old_pat_pos = _pat_pos;
                __patternpos;
                while {_pat_pos distance _old_pat_pos < 100} do {
                    __patternpos;
                    sleep 0.01;
                };
                _pat_pos = _pat_pos call FUNC(WorldBoundsCheck);
                [_grp, 1] setWaypointPosition [_pat_pos, 0];
                _grp setSpeedMode "NORMAL";
                _grp setBehaviour _wp_behave;
                sleep 45.821 + random 15;
            } else {
                __patternpos;
                _pat_pos = _pat_pos call FUNC(WorldBoundsCheck);
                [_grp, 1] setWaypointPosition [_pat_pos, 0];
                _grp setSpeedMode "LIMITED";
                _grp setBehaviour _wp_behave;
                sleep 120 + random 120;
            };
        };

        __MPCheck;

        if (count _vehicles > 0) then {
            _vehicles_number = count _vehicles;
            for "_i" from 0 to _vehicles_number do {
                _vecx = _vehicles select _i;
                if (!isNil "_vecx") then {
                    if (fuel _vecx < 0.1 && canMove _vecx) then {
                        _vecx spawn {
                            private "_vec";
                            _vec = _this;
                            _vec setDamage 1.1;
                            sleep 200;
                            if (!isNull _vec) then {_vec call FUNC(DelVecAndCrew)};
                        };
                        _vehicles set [_i, -1];
                    } else {
                        if (isNull _vecx || {!alive _vecx || !canMove _vecx}) then {
                            _vehicles set [_i, -1];
                        } else {
                            _vecx setFuel 1;
                        };
                    };
                    sleep 0.01;
                };
            };
            _vehicles = _vehicles - [-1];
        };
        if (count _vehicles == 0) then {
            {if (!isNull _x) then {deleteVehicle _x}} forEach _funits;
            _funits = [];
            _vehicles = [];
            _loop_do = false;
        };
    };
    _num_p = call FUNC(PlayersNumber);
    _re_random = switch (true) do {
        case (_num_p < 5): {450};
        case (_num_p < 10): {300};
        case (_num_p < 20): {150};
        default {100};
    };
    sleep (GVAR(airki_respawntime) + _re_random + random (_re_random));
};