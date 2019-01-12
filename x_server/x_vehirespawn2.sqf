// by Xeno
#define THIS_FILE "x_vehirespawn2.sqf"
#include "x_setup.sqf"
private ["_delay","_disabled","_newveh","_startdir","_startpos","_type","_vehicle"];
if (!isServer) exitWith{};

PARAMS_2(_vehicle,_delay);
_startpos = position _vehicle;
_startdir = getDir _vehicle;
_type = typeOf _vehicle;

while {true} do {
    sleep (_delay + random 15);

    _empty = _vehicle call FUNC(GetVehicleEmpty);
    
    if (_empty && {damage _vehicle > 0.9 || {!alive _vehicle}}) then {
        deleteVehicle _vehicle;
        _vehicle = objNull;
        sleep 0.5;
        _vehicle = createVehicle [_type, _startpos, [], 0, "NONE"];
        _vehicle setDir _startdir;
        _vehicle setPos _startpos;
        _vehicle setFuel 1;
    };
};
