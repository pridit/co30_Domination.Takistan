// by Xeno
#define THIS_FILE "x_sidetrains.sqf"
#include "x_setup.sqf"
private ["_pos", "_trains"];
if !(call FUNC(checkSHC)) exitWith {};

PARAMS_2(_pos,_trains);
GVAR(dead_trains) = 0;

{
    _x addEventHandler ["killed", {__INC(GVAR(dead_trains))}];
    __AddToExtraVec(_x)
} forEach _trains;

sleep 2.333;
["specops", 2, "basic", 2, _pos,200,true] spawn FUNC(CreateInf);
sleep 2.333;
["shilka", 1, "bmp", 1, "tank", 1, _pos,2,300,true] spawn FUNC(CreateArmor);

sleep 15.321;

while {GVAR(dead_trains) < 4} do {
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