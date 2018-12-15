// by Xeno
#define THIS_FILE "x_checkhelipilot_wreck.sqf"
#include "x_setup.sqf"
private ["_listin", "_vehicle","_position","_enterer"];

PARAMS_1(_listin);
_enterer = _listin select 2;
__notlocalexit(_enterer);

_vehicle = _listin select 0;
_position = _listin select 1;

if (_position == "driver" && {_enterer == player}) then {    
    [_vehicle] execVM "x_client\x_helilift_wreck.sqf";
};