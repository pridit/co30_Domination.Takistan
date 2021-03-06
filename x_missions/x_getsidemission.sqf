// by Xeno
#define THIS_FILE "x_getsidemission.sqf"
#include "x_setup.sqf"
private ["_mfolder"];
if (!isServer) exitWith{};

if (__XJIPGetVar(all_sm_res)) exitWith {};

if (GVAR(current_mission_counter) == GVAR(number_side_missions)) exitWith {
    ["all_sm_res",true] call FUNC(NetSetJIP);
    ["all_sm_res"] call FUNC(NetCallEvent);
    #ifndef __TT__
    GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"AllSMissionsResolved",true];
    #else
    GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"HQ_W","AllSMissionsResolved",true];
    GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"HQ_E","AllSMissionsResolved",true];
    #endif
};

if (GVAR(MissionType) != 2) then {
    while {!GVAR(main_target_ready)} do {sleep 2.321};
};

_current_mission_index = GVAR(side_missions_random) select GVAR(current_mission_counter);
__INC(GVAR(current_mission_counter));

GVAR(extra_mission_remover_array) = [];
GVAR(extra_mission_vehicle_remover_array) = [];

//_current_mission_index = _this select 0;
//_current_mission_index = 25;

_mfolder = "x_missions\moa\%2%1.sqf";

if (isNil QGVAR(HC_CLIENT_OBJ)) then {
    execVM (format [_mfolder, _current_mission_index, GVAR(mission_filename)]);
} else {
    [QGVAR(hcexecsm), [GVAR(HC_CLIENT_OBJ), format [_mfolder, _current_mission_index, GVAR(mission_filename)]]] call FUNC(NetCallEventSTO);
};

sleep 7.012;
[QGVAR(current_mission_index),_current_mission_index] call FUNC(NetSetJIP);
[QGVAR(up_m)] call FUNC(NetCallEventToClients);
GVAR(side_mission_resolved) = false;
GVAR(side_mission_winner) = 0;

sleep 7.012;
GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"NewMission",true];

// sleep 30;
// GVAR(side_mission_resolved) = true;
// GVAR(side_mission_winner) = 1;
// [QGVAR(sm_var), GVAR(side_mission_winner)] call FUNC(NetCallEventCTS);