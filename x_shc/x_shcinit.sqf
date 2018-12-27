// by Xeno
//#define __DEBUG__
#define THIS_FILE "x_shcinit.sqf"
#include "x_setup.sqf"

if !(call FUNC(checkSHC)) exitWith {};

GVAR(allunits_add) = [];
GVAR(allunits_ai_add) = [];
GVAR(delvecsmt) = [];
if (GVAR(doRespawnGroups)) then {
    GVAR(reduce_groups) = [];
};
GVAR(no_more_observers) = false;
GVAR(counterattack) = false;
GVAR(create_new_paras) = false;
GVAR(extra_mission_remover_array) = [];
GVAR(extra_mission_vehicle_remover_array) = [];
GVAR(check_trigger) = objNull;
GVAR(first_time_after_start) = true;
GVAR(nr_observers) = 0;
GVAR(side_mission_resolved) = false;
GVAR(main_target_ready) = false;
GVAR(mt_spotted) = false;

if (GVAR(IS_HC_CLIENT)) then {
    __ccppfln(x_shc\x_f\x_shcfunctions.sqf);
    __ccppfln(i_server.sqf);
};
__cppfln(FUNC(spawnVehicle),x_shc\x_f\fn_spawnvehicle.sqf);
__cppfln(FUNC(spawnCrew),x_shc\x_f\fn_spawncrew.sqf);
__cppfln(FUNC(taskDefend),x_shc\x_f\fn_taskDefend.sqf);
__cppfln(FUNC(makegroup),x_shc\x_makegroup.sqf);
__cppfln(FUNC(objectMapper),x_shc\x_f\fn_objectMapper.sqf);
__cppfln(FUNC(createpara3x),x_shc\x_createpara3x.sqf);

//execFSM "fsms\NotAliveRemover.fsm";
execFSM "fsms\NotAliveRemoverUnits.fsm";
execFSM "fsms\GroupClean.fsm";
if (GVAR(doRespawnGroups)) then {
    execFSM "fsms\ReduceGroups.fsm";
};

if (GVAR(WithRecapture) == 0 && {GVAR(MissionType) != 2}) then {execFSM "fsms\Recapture.fsm"};

if (!GVAR(no_sabotage) && {GVAR(MissionType) != 2}) then {execFSM "fsms\Infilrate.fsm"};

// start air AI (KI=AI) after some time
if (GVAR(MissionType) != 2) then {
    0 spawn {
        scriptName "spawn_x_setupserver_airki";
        sleep 924;
        if (isServer && {!isNil QGVAR(HC_CLIENT_OBJ)}) exitWith {};
        ["KA",GVAR(number_attack_choppers)] execVM "x_shc\x_airki.sqf";
        sleep 801.123;
        ["SU",GVAR(number_attack_planes)] execVM "x_shc\x_airki.sqf";
    };
};

if (count GVAR(with_isledefense) > 0) then {execVM "x_shc\x_isledefense.sqf"};