// by Xeno
#define THIS_FILE "x_checktrucktrans.sqf"
#include "x_setup.sqf"
private ["_vehicle","_position","_enterer","_was_engineon"];

_enterer = _this select 2;
__notlocalexit(_enterer);

PARAMS_2(_vehicle,_position);

_was_engineon = isEngineOn _vehicle;

if (!GVAR(with_ai) && {GVAR(with_ai_features) != 0} && {!(str(_enterer) in GVAR(is_engineer))}) exitWith {
    (localize "STR_DOM_MISSIONSTRING_182") call FUNC(HQChat);
    _enterer action["Eject",_vehicle];
    if (!_was_engineon && {isEngineOn _vehicle}) then {
        _vehicle engineOn false;
        _enterer action ["engineOff", _vehicle];
    };
};
