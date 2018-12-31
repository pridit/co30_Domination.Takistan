//#define __DEBUG__
#define THIS_FILE "fn_spawncrew.sqf1"
#include "x_setup.sqf"
/*
    File: spawnCrew.sqf
    Author: Joris-Jan van 't Land

    Description:
    Function to fill all crew positions in a vehicle, including turrets.
    In dummy mode no objects are created and the returned array contains only ones.
    In this mode the function can be used to count the actual crew of an existing vehicle or vehicle type.

    Parameter(s):
    _this select 0: the vehicle (Object)
    _this select 1: the crew's group (Group)
    _this select 2: (optional) dummy mode toggle (Boolean)
    _this select 3: (optional) dummy mode type (String)
    _this select 4: (optional) crew type (String)

    Returns:
    Array of Objects or Scalars - newly created crew or crew count
*/

private ["_vehicle", "_grp"];
PARAMS_2(_vehicle,_grp);

__TRACE_2("","_vehicle","_grp")

private "_dummy";
_dummy = if (count _this > 2) then {_this select 2} else {false};

private "_dummyType";
_dummyType = if (count _this > 3) then {_this select 3} else {""};

private "_crewType";
_crewType = if (count _this > 4) then {_this select 4} else {""};

if (typeName _vehicle != typeName objNull || {typeName _grp != typeName grpNull} || {typeName _dummy != typeName false} || {typeName _dummyType != typeName ""} || {typeName _crewType != typeName ""}) exitWith {[]};
_crewType = [_crewType];

private ["_type", "_entry", "_crew"];
if (!_dummy) then {
    _type = typeOf _vehicle;
} else {
    if (_dummyType != "") then {_type = _dummyType};
};
_entry = configFile >> "CfgVehicles" >> _type;
_crew = [];

private "_hasDriver";
_hasDriver = getNumber (_entry >> "hasDriver");

private ["_crewType", "_unit"];
if (!_dummy && {(_crewType select 0) == ""}) then {_crewType = [side _grp, _entry, _type] call FUNC(selectCrew)};

if (_hasDriver == 1 && {isNull (driver _vehicle)}) then {
    if (!_dummy) then {
        _unit = _grp createUnit [_crewType select 0, position _vehicle, [], 0, "NONE"];
        if (!isNil "_unit" && {!isNull _unit}) then {
            if (GVAR(without_nvg) == 0 && {_unit hasWeapon "NVGoggles"}) then {
                _unit removeWeapon "NVGoggles";
            };
            _unit setVariable ["BIS_noCoreConversations", true];
            _crew set [count _crew, _unit];

            __addDeadAI(_unit)

            _unit setUnitAbility ((GVAR(skill_array) select 0) + (random (GVAR(skill_array) select 1)));

            _unit moveInDriver _vehicle;
        };
    } else {
        _crew set [count _crew, 1];
    };
};

_turrets = [_entry >> "turrets"] call FUNC(returnVehicleTurrets);

_funcSpawnTurrets = {
    private ["_turrets", "_path"];
    PARAMS_2(_turrets,_path);

    private "_i";
    _i = 0;
    while {_i < (count _turrets)} do {
        private ["_turretIndex", "_thisTurret"];
        _turretIndex = _turrets select _i;
        _thisTurret = _path + [_turretIndex];

        if (!_dummy) then {
            // Workaround for YAAB (Yet Another ArmA Bug)
            // don't spawn a commonader in ZSUs, otherwise they don't fire at targets
            // introduced in one of the betas before 1.59
            if (_vehicle isKindOf "ZSU_Base" && {count _thisTurret > 1}) exitWith {};
            if (isNull (_vehicle turretUnit _thisTurret)) then {
                _unit = _grp createUnit [_crewType select 0, position _vehicle, [], 0, "NONE"];
                if (!isNull _unit) then {
                    if (GVAR(without_nvg) == 0 && {_unit hasWeapon "NVGoggles"}) then {
                        _unit removeWeapon "NVGoggles";
                    };
                    _unit setVariable ["BIS_noCoreConversations", true];
                    _crew set [count _crew, _unit];
                    
                    __addDeadAI(_unit)

                    _unit setUnitAbility ((GVAR(skill_array) select 0) + (random (GVAR(skill_array) select 1)));
                    
                    _unit moveInTurret [_vehicle, _thisTurret];
                };
            };
        } else {
            _crew set [count _crew, 1];
        };

        [_turrets select (_i + 1), _thisTurret] call _funcSpawnTurrets;

        _i = _i + 2;
    };
};

[_turrets, []] call _funcSpawnTurrets;

if (!_dummy) then {
    if !(isNull (driver _vehicle)) then {(driver _vehicle) setRank "LIEUTENANT"};
    if !(isNull (gunner _vehicle)) then {(gunner _vehicle) setRank "SERGEANT"};
    if !(isNull (effectiveCommander _vehicle)) then {(effectiveCommander _vehicle) setRank "CORPORAL"};
};

_grp setVariable [QGVAR(gstate), 1];

_crew