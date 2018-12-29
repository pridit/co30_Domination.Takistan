// by Xeno
#include "x_setup.sqf"
#define THIS_FILE "x_createnexttarget.sqf"
private ["_current_target_pos","_current_target_radius","_dummy","_emptyH","_current_target_name"];
if (!isServer) exitWith{};

sleep 1;

[QGVAR(current_target_index),GVAR(maintargets_list) select GVAR(current_counter)] call FUNC(NetSetJIP);
__INC(GVAR(current_counter));

sleep 1.0123;
if (GVAR(first_time_after_start)) then {
    GVAR(first_time_after_start) = false;
    sleep 18.123;
};

GVAR(update_target) = false;
GVAR(main_target_ready) = false;
GVAR(side_main_done) = false;

_dummy = GVAR(target_names) select __XJIPGetVar(GVAR(current_target_index));
_current_target_pos = _dummy select 0;
_current_target_name = _dummy select 1;
_current_target_radius = _dummy select 2;

GVAR(target_radius) = _current_target_radius;
GVAR(mttarget_radius_patrol) = _current_target_radius + 400 + random 400;

_tname = _current_target_name call FUNC(KBUseName);
_tsar = if (GVAR(WithLessArmor) == 0) then {
    ["('Man' countType thislist >= d_man_count_for_target_clear) && {('Tank' countType thislist >= d_tank_count_for_target_clear)} && {('Car' countType thislist  >= d_car_count_for_target_clear)}", "X_JIPH setVariable ['target_clear',false,true];d_update_target=true;['d_update_target'] call d_fnc_NetCallEventToClients;d_kb_logic1 kbTell [d_kb_logic2,d_kb_topic_side,'Attack',['1','','" + _current_target_name + "',['" + _tname + "']],true];deleteVehicle d_check_trigger", ""]
} else {
    ["('Man' countType thislist >= d_man_count_for_target_clear)", "X_JIPH setVariable ['target_clear',false,true];d_update_target=true;['d_update_target'] call d_fnc_NetCallEventToClients;d_kb_logic1 kbTell [d_kb_logic2,d_kb_topic_side,'Attack',['1','','" + _current_target_name + "',['" + _tname + "']],true];deleteVehicle d_check_trigger;", ""]
};

GVAR(check_trigger) = [_current_target_pos, [_current_target_radius + 20, _current_target_radius + 20, 0, false], [GVAR(enemy_side), "PRESENT", false], _tsar] call FUNC(CreateTrigger);

[_current_target_pos, _current_target_radius] execVM "x_shc\x_docreatenexttarget.sqf";

while {!GVAR(update_target)} do {sleep 2.123};

_tsar = ["(X_JIPH getVariable 'd_mt_radio_down') && {d_side_main_done} && {(X_JIPH getVariable 'd_campscaptured') == d_sum_camps} && {('Car' countType thislist <= d_car_count_for_target_clear)} && {('Tank' countType thislist <= d_tank_count_for_target_clear)} && {('Man' countType thislist <= d_man_count_for_target_clear)}", "0 = [] execVM 'x_server\x_target_clear.sqf'", ""];

GVAR(current_trigger) = [_current_target_pos, [_current_target_radius  + 50, _current_target_radius + 50, 0, false],[GVAR(enemy_side), "PRESENT", false], _tsar] call FUNC(CreateTrigger);