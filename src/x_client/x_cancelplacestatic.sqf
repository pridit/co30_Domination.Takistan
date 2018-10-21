// by Xeno
#define THIS_FILE "x_cancelplacestatic.sqf"
#include "x_setup.sqf"
private ["_caller"];

_caller = _this select 1;

GVAR(e_placing_running) = 2;
_caller removeAction (_this select 2);
_caller removeAction GVAR(e_placing_id2);
GVAR(e_placing_id1) = -1000;
GVAR(e_placing_id2) = -1000;