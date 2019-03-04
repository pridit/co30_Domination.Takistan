// by Xeno
#define THIS_FILE "x_targetclear.sqf"
#include "x_setup.sqf"
private ["_current_target_pos","_dummy","_ran","_start_real"];
if (!isServer) exitWith{};

sleep 1.123;

if (!isNull GVAR(f_check_trigger)) then {deleteVehicle GVAR(f_check_trigger)};
deleteVehicle GVAR(current_trigger);
sleep 0.01;

__TargetInfo

GVAR(counterattack) = false;
_start_real = false;
_ran = random 100;
if (_ran > 96) then {
    GVAR(counterattack) = true;
    _start_real = true;	
    GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"CounterattackEnemy",["1","",_current_target_name,[]],true];
    execVM "x_shc\x_counterattack.sqf";
};

while {GVAR(counterattack)} do {sleep 3.123};

if (_start_real) then {
    GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"CounterattackDefeated",true];
    sleep 2.321;
};

GVAR(old_target_pos) =+ ((GVAR(target_names) select __XJIPGetVar(GVAR(current_target_index))) select 0);
GVAR(old_radius) = [(GVAR(target_names) select __XJIPGetVar(GVAR(current_target_index))) select 2];

#ifndef __TT__
_resolved_targets = __XJIPGetVar(resolved_targets);
_resolved_targets set [count _resolved_targets, __XJIPGetVar(GVAR(current_target_index))];
["resolved_targets",_resolved_targets] call FUNC(NetSetJIP);
#endif

sleep 0.5;

if (GVAR(current_counter) < GVAR(MainTargets)) then {
    ["target_clear",true] call FUNC(NetSetJIP);
    [QGVAR(target_clear), ""] call FUNC(NetCallEventToClients);
    __TargetInfo
    _tname = _current_target_name call FUNC(KBUseName);
    GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"Captured",["1","",_current_target_name,[_tname]],true];
    diag_log format ["Main Target: %1/%2 captured (%3)", GVAR(current_counter), GVAR(MainTargets), _current_target_name];
} else {
    ["target_clear",true] call FUNC(NetSetJIP);
    [QGVAR(target_clear), ""] call FUNC(NetCallEventToClients);
    _tname = _current_target_name call FUNC(KBUseName);
    GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"Captured2",["1","",_current_target_name,[_tname]],true];
    diag_log format ["Main Target: %1/%2 captured (%3)", GVAR(current_counter), GVAR(MainTargets), _current_target_name];
};

sleep 2.123;

if (!isNil QGVAR(HC_CLIENT_OBJ)) then {
    [QGVAR(dodel1), [GVAR(HC_CLIENT_OBJ), __XJIPGetVar(GVAR(current_target_index))]] call FUNC(NetCallEventSTO);
} else {
    __XJIPGetVar(GVAR(current_target_index)) execFSM "fsms\DeleteUnits.fsm";
};

sleep 4.321;

if (GVAR(WithJumpFlags) == 1) then {
    if (GVAR(current_counter) < GVAR(MainTargets)) then {execVM "x_server\x_createjumpflag.sqf"};
};

if (count GVAR(respawn_ai_groups) > 0) then {
    {
        {
            private "_v";
            _v = vehicle _x;
            if (_v != _x && {alive _v}) then {_v setDamage 1};
            if (alive _x) then {_x setDamage 1}
        } forEach units (_x select 0)
    } forEach GVAR(respawn_ai_groups);
};

GVAR(del_camps_stuff) = [];
{
    _flag = _x getVariable QGVAR(FLAG);
    _mar = format [QGVAR(camp%1),_x getVariable QGVAR(INDEX)];
    deleteMarker _mar;
    GVAR(del_camps_stuff) set [count GVAR(del_camps_stuff), _x];
    GVAR(del_camps_stuff) set [count GVAR(del_camps_stuff), _flag];
} forEach __XJIPGetVar(GVAR(currentcamps));
[QGVAR(currentcamps),[]] call FUNC(NetSetJIP);
[QGVAR(campscaptured_w),0] call FUNC(NetSetJIP);
[QGVAR(campscaptured_e),0] call FUNC(NetSetJIP);

sleep 0.245;

if (GVAR(delete_mt_vehicles_after_time) != 0) then {
    if (isNil QGVAR(HC_CLIENT_OBJ)) then {
        [GVAR(old_target_pos),GVAR(old_radius)] execFSM "fsms\DeleteEmpty.fsm";
    } else {
        [QGVAR(dodel2), [GVAR(HC_CLIENT_OBJ), [GVAR(old_target_pos), GVAR(old_radius), GVAR(del_camps_stuff)]]] call FUNC(NetCallEventSTO);
        GVAR(del_camps_stuff) = nil;
    };
};

GVAR(run_illum) = false;

if (getMarkerColor QGVAR(main_target_radiotower) == "ColorBlack") then {
    GVAR(mt_spotted) = false;
    if (GVAR(IS_HC_CLIENT)) then {
        [QGVAR(sSetVar), [QGVAR(mt_spotted), false]] call FUNC(NetCallEventCTS);
    };
    [QGVAR(mt_radio_down),true] call FUNC(NetSetJIP);
    deleteMarker QGVAR(main_target_radiotower);
};

if (getMarkerColor QGVAR(main_target_secondary) == "ColorBlack") then {
    [QGVAR(mtsm_done),true] call FUNC(NetSetJIP);
    [QGVAR(mtsm_pos),[0,0,0]] call FUNC(NetSetJIP);
    [QGVAR(mtsm_type),""] call FUNC(NetSetJIP);
    deleteMarker QGVAR(main_target_secondary);
};

if (GVAR(current_counter) < GVAR(MainTargets)) then {
    if (GVAR(MHQDisableNearMT) != 0) then {
        {
            if (alive _x) then {
                _fux = GV(_x,GVAR(vecfuelmhq));
                if (!isNil "_fux") then {
                    if (fuel _x < _fux) then {
                        [QGVAR(setFuel), [_x, _fux]] call FUNC(NetCallEventSTO);
                    };
                    _x setVariable [QGVAR(vecfuelmhq), nil, true];
                };
            };
        } forEach vehicles;
    };
    sleep 15;
    execVM "x_server\x_createnexttarget.sqf";
} else {
    if (GVAR(WithRecapture) == 0) then {
        if (count GVAR(recapture_indices) == 0) then {
            [QGVAR(the_end),true] call FUNC(NetSetJIP);
            0 spawn FUNC(DomEnd);
        } else {
            0 spawn {
                scriptName "spawn_x_target_clear_waitforrecap";
                while {count GVAR(recapture_indices) > 0} do {
                    sleep 2.543;
                };
                [QGVAR(the_end),true] call FUNC(NetSetJIP);
                0 spawn FUNC(DomEnd);
            };
        };
    } else {
        [QGVAR(the_end),true] call FUNC(NetSetJIP);
        0 spawn FUNC(DomEnd);
    };
};