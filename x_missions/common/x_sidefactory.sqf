// by Xeno
#define THIS_FILE "x_sidefactory.sqf"
#include "x_setup.sqf"
private ["_b1", "_b2", "_b3", "_b1_down", "_b2_down", "_b3_down"];
if !(call FUNC(checkSHC)) exitWith {};

PARAMS_3(_b1,_b2,_b3);

_b1_down = false;
_b2_down = false;
_b3_down = false;

while {!_b1_down && {!_b2_down} && {!_b3_down}} do {
    __MPCheck;
    if (!_b1_down && {!alive  _b1}) then {_b1_down = true};
    if (!_b2_down && {!alive  _b2}) then {_b2_down = true};
    if (!_b3_down && {!alive  _b3}) then {_b3_down = true};
    sleep 5.321;
};

GVAR(side_mission_winner) = 2;
GVAR(side_mission_resolved) = true;
if (GVAR(IS_HC_CLIENT)) then {
    [QGVAR(sm_var), GVAR(side_mission_winner)] call FUNC(NetCallEventCTS);
};