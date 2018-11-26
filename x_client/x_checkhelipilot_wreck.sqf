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
    if (GVAR(chophud_on)) then {
        __pSetVar [QGVAR(hud_id), _vehicle addAction [(localize "STR_DOM_MISSIONSTRING_176") call FUNC(GreyText), "x_client\x_sethud.sqf",0,-1,false]];
    } else {
        __pSetVar [QGVAR(hud_id), _vehicle addAction [(localize "STR_DOM_MISSIONSTRING_177") call FUNC(GreyText), "x_client\x_sethud.sqf",1,-1,false]];
    };
    
    [_vehicle] execVM "x_client\x_helilift_wreck.sqf";
};