// by Xeno
#define THIS_FILE "x_checkhelipilot.sqf"
#include "x_setup.sqf"
private ["_listin", "_no_lift", "_vehicle", "_position", "_enterer", "_exit_it", "_type_enterer"];

PARAMS_1(_listin);
_enterer = _listin select 2;
__notlocalexit(_enterer);

_no_lift = _this select 1;
_vehicle = _listin select 0;
_position = _listin select 1;

if (_position == "driver" && {_enterer == player}) then {
    if (_no_lift == 0) then {        
        [_vehicle] execVM "x_client\x_helilift.sqf";
    };
};