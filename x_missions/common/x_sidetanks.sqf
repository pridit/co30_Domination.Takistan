// by Xeno
#define THIS_FILE "x_sidetanks.sqf"
#include "x_setup.sqf"
private ["_posi_array","_tank1","_tank2","_tank3","_tank4","_tank5","_tank6","_dirs"];
if !(call FUNC(checkSHC)) exitWith {};

PARAMS_2(_posi_array,_dirs);

GVAR(dead_tanks) = 0;

_tank1 = createVehicle [GVAR(sm_tank), _posi_array select 1, [], 0, "NONE"];
_tank1 setDir (_dirs select 0);
_tank1 setPos (_posi_array select 1);
GVAR(extra_mission_vehicle_remover_array) set [count GVAR(extra_mission_vehicle_remover_array), _tank1];
_tank1 addEventHandler ["killed", {__INC(GVAR(dead_tanks))}];
_tank1 lock true;
sleep 0.512;
_tank2 = createVehicle [GVAR(sm_tank), _posi_array select 2, [], 0, "NONE"];
_tank2 setDir (_dirs select 1);
_tank2 setPos (_posi_array select 2);
GVAR(extra_mission_vehicle_remover_array) set [count GVAR(extra_mission_vehicle_remover_array), _tank2];
_tank2 addEventHandler ["killed", {__INC(GVAR(dead_tanks))}];
_tank2 lock true;
sleep 0.512;
_tank3 = createVehicle [GVAR(sm_tank), _posi_array select 3, [], 0, "NONE"];
_tank3 setDir (_dirs select 2);
_tank3 setPos (_posi_array select 3);
GVAR(extra_mission_vehicle_remover_array) set [count GVAR(extra_mission_vehicle_remover_array), _tank3];
_tank3 addEventHandler ["killed", {__INC(GVAR(dead_tanks))}];
_tank3 lock true;
sleep 0.512;
_tank4 = createVehicle [GVAR(sm_tank), _posi_array select 4, [], 0, "NONE"];
_tank4 setDir (_dirs select 3);
_tank4 setPos (_posi_array select 4);
GVAR(extra_mission_vehicle_remover_array) set [count GVAR(extra_mission_vehicle_remover_array), _tank4];
_tank4 addEventHandler ["killed", {__INC(GVAR(dead_tanks))}];
_tank4 lock true;
sleep 0.512;
_tank5 = createVehicle [GVAR(sm_tank), _posi_array select 5, [], 0, "NONE"];
_tank5 setDir (_dirs select 4);
_tank5 setPos (_posi_array select 5);
GVAR(extra_mission_vehicle_remover_array) set [count GVAR(extra_mission_vehicle_remover_array), _tank5];
_tank5 addEventHandler ["killed", {__INC(GVAR(dead_tanks))}];
_tank5 lock true;
sleep 0.512;
_tank6 = createVehicle [GVAR(sm_tank), _posi_array select 6, [], 0, "NONE"];
_tank6 setDir (_dirs select 5);
_tank6 setPos (_posi_array select 6);
GVAR(extra_mission_vehicle_remover_array) set [count GVAR(extra_mission_vehicle_remover_array), _tank6];
_tank6 addEventHandler ["killed", {__INC(GVAR(dead_tanks))}];
_tank6 lock true;

sleep 2.333;
["specops", 2, "basic", 2, _posi_array select 0,300,true] spawn FUNC(CreateInf);
sleep 2.333;
["shilka", 1, "bmp", 1, "tank", 1, _posi_array select 0,2,400,true] spawn FUNC(CreateArmor);

_dirs = nil;
_posi_array = nil;

{_x lock true} forEach [_tank1, _tank2, _tank3, _tank4, _tank5, _tank6];

sleep 15.321;

while {GVAR(dead_tanks) < 6} do {
    sleep 5.321;
};

#ifndef __TT__
GVAR(side_mission_winner) = 2;
#else
if (GVAR(sm_points_west) > GVAR(sm_points_east)) then {
    GVAR(side_mission_winner) = 2;
} else {
    if (GVAR(sm_points_east) > GVAR(sm_points_west)) then {
        GVAR(side_mission_winner) = 1;
    } else {
        if (GVAR(sm_points_east) == GVAR(sm_points_west)) then {
            GVAR(side_mission_winner) = 123;
        };
    };
};
#endif
GVAR(side_mission_resolved) = true;
if (GVAR(IS_HC_CLIENT)) then {
    [QGVAR(sm_var), GVAR(side_mission_winner)] call FUNC(NetCallEventCTS);
};