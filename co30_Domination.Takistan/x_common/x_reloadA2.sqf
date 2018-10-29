// by Xeno
#define THIS_FILE "x_reloadA2.sqf"
#include "x_setup.sqf"
private ["_config","_count","_i","_magazines","_object","_type","_type_name"];

PARAMS_1(_object);
__TRACE_1("","_object");
if (typeName _object == "ARRAY") then {
    _obb = objNull;
    {
        if ((_x isKindOf "Helicopter" || _x isKindOf "LandVehicle" || _x isKindOf "Plane") && !(_x isKindOf "HeliH")) exitWith {
            _obb = _x;
        };
    } forEach _object;
    _object = _obb;
};

if (isNull _object) exitWith {};

_type = typeof _object;

if (_object isKindOf "ParachuteBase") exitWith {};

if (isNil {GVAR(reload_time_factor)}) then {GVAR(reload_time_factor) = 1};

if (missionNamespace getVariable QGVAR(reload_engineoff)) then {_object action ["engineOff", _object]};
if (!alive _object) exitWith {};
_object setFuel 0;
_object setVehicleAmmo 1;

_type_name = [_type,0] call FUNC(GetDisplayName);

if (!isDedicated) then {[_object,format [(localize "STR_DOM_MISSIONSTRING_701"), _type_name]] call FUNC(VehicleChat)};

_magazines = getArray(configFile >> "CfgVehicles" >> _type >> "magazines");

if (count _magazines > 0) then {
    _removed = [];
    {
        if (!(_x in _removed)) then {
            _object removeMagazines _x;
            _removed set [count _removed, _x];
        };
    } forEach _magazines;
    {
        if (!isDedicated) then {[_object, format [(localize "STR_DOM_MISSIONSTRING_702"), _x]] call FUNC(VehicleChat)};
        sleep GVAR(reload_time_factor);
        if (!alive _object) exitWith {};
        _object addMagazine _x;
    } forEach _magazines;
};

_count = count (configFile >> "CfgVehicles" >> _type >> "Turrets");

if (_count > 0) then {
    for "_i" from 0 to (_count - 1) do {
        scopeName "xx_reload2_xx";
        _config = (configFile >> "CfgVehicles" >> _type >> "Turrets") select _i;
        _magazines = getArray(_config >> "magazines");
        _removed = [];
        {
            if (!(_x in _removed)) then {
                _object removeMagazines _x;
                _removed set [count _removed, _x];
            };
        } forEach _magazines;
        {
            _mag_disp_name = [_x,2] call FUNC(GetDisplayName);
            if (!isDedicated) then {[_object,format [(localize "STR_DOM_MISSIONSTRING_702"), _mag_disp_name]] call FUNC(VehicleChat)};
            sleep GVAR(reload_time_factor);
            if (!alive _object) then {breakOut "xx_reload2_xx"};
            _object addMagazine _x;
            sleep GVAR(reload_time_factor);
            if (!alive _object) then {breakOut "xx_reload2_xx"};
        } forEach _magazines;
        // check if the main turret has other turrets
        _count_other = count (_config >> "Turrets");
        // this code doesn't work, it's not possible to load turrets that are part of another turret :(
        // nevertheless, I leave it here
        if (_count_other > 0) then {
            for "_i" from 0 to (_count_other - 1) do {
                _config2 = (_config >> "Turrets") select _i;
                _magazines = getArray(_config2 >> "magazines");
                _removed = [];
                {
                    if (!(_x in _removed)) then {
                        _object removeMagazines _x;
                        _removed set [count _removed, _x];
                    };
                } forEach _magazines;
                {
                    _mag_disp_name = [_x,2] call FUNC(GetDisplayName);
                    if (!isDedicated) then {[_object, format [(localize "STR_DOM_MISSIONSTRING_702"), _mag_disp_name]] call FUNC(VehicleChat)};
                    sleep GVAR(reload_time_factor);
                    if (!alive _object) then {breakOut "xx_reload2_xx"};
                    _object addMagazine _x;
                    sleep GVAR(reload_time_factor);
                    if (!alive _object) then {breakOut "xx_reload2_xx"};
                } forEach _magazines;
            };
        };
    };
};
_object setVehicleAmmo 1;

sleep GVAR(reload_time_factor);
if (!alive _object) exitWith {};
if (!isDedicated) then {[_object, (localize "STR_DOM_MISSIONSTRING_704")] call FUNC(VehicleChat)};
_object setDamage 0;
sleep GVAR(reload_time_factor);
if (!alive _object) exitWith {};
if (!isDedicated) then {[_object, (localize "STR_DOM_MISSIONSTRING_705")] call FUNC(VehicleChat)};
while {fuel _object < 0.99} do {
    _object setFuel 1;
    sleep 0.01;
};
sleep GVAR(reload_time_factor);
if (!alive _object) exitWith {};
if (!isDedicated) then {[_object, format [(localize "STR_DOM_MISSIONSTRING_706"), _type_name]] call FUNC(VehicleChat)};

reload _object;