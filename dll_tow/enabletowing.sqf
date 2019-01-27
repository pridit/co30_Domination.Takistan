#include "x_setup.sqf"

dll_tow = compile preprocessfile "dll_tow\tow.sqf";
dll_tow_bbox = compile preprocessfile "dll_tow\bbox.sqf";

_objs = nearestObjects [position (vehicle player), GVAR(dll_tow_classlist), 30];
_vehicle = _objs select 0;

if (isNil "_vehicle" || {!alive _vehicle) exitWith {
    hint "This aircraft cannot be towed";
};

_vehicleTower = (vehicle player);
_vehicleTowee = _vehicle;

[_vehicleTower, _vehicleTowee] execVM "dll_tow\initT.sqf";