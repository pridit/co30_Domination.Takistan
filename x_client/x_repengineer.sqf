// by Xeno
#define THIS_FILE "x_repengineer.sqf"
#include "x_setup.sqf"
private ["_aid","_caller","_coef","_damage","_damage_ok","_damage_val","_fuel","_fuel_ok","_fuel_val","_rep_count","_breaked_out","_rep_action","_type_name"];

_caller = _this select 1;
_aid = _this select 2;

_truck_near = false;
if (player distance TR7 < 21 || {player distance TR8 < 21}) then {_truck_near = true};
if (!GVAR(eng_can_repfuel) && {!_truck_near}) exitWith {
    hintSilent (localize "STR_DOM_MISSIONSTRING_324");
};

_caller removeAction _aid;
if !(local _caller) exitWith {};

_rep_count = switch (true) do {
    case (GVAR(objectID2) isKindOf "Air"): {0.1};
    case (GVAR(objectID2) isKindOf "Tank"): {0.2};
    default {0.3};
};

_fuel = fuel GVAR(objectID2);
_damage = damage GVAR(objectID2);

_damage_val = _damage / _rep_count;
_fuel_val = (1 - _fuel) / _rep_count;
_coef = switch (true) do {
    case (_fuel_val > _damage_val): {_fuel_val};
    default {_damage_val};
};
_coef = ceil _coef;

hintSilent format [(localize "STR_DOM_MISSIONSTRING_327"),_fuel, _damage];
_type_name = [typeOf (GVAR(objectID2)),0] call FUNC(GetDisplayName);
(format [(localize "STR_DOM_MISSIONSTRING_328"), _type_name]) call FUNC(GlobalChat);
_damage_ok = false;
_fuel_ok = false;
GVAR(cancelrep) = false;
_breaked_out = false;
_breaked_out2 = false;
_rep_action = player addAction[(localize "STR_DOM_MISSIONSTRING_329") call FUNC(RedText),"x_client\x_cancelrep.sqf"];
for "_wc" from 1 to _coef do {
    if (!alive player || {GVAR(cancelrep)}) exitWith {player removeAction _rep_action};
    (localize "STR_DOM_MISSIONSTRING_330") call FUNC(GlobalChat);
    player playMove "AinvPknlMstpSlayWrflDnon_medic";
    sleep 3.0;
    waitUntil {animationState player != "AinvPknlMstpSlayWrflDnon_medic"};
    if (GVAR(cancelrep)) exitWith {_breaked_out = true};
    if (vehicle player != player) exitWith {
        _breaked_out2 = true;
        hintSilent (localize "STR_DOM_MISSIONSTRING_331");
    };
    if (!_fuel_ok) then {_fuel = _fuel + _rep_count};
    if (_fuel >= 1 && {!_fuel_ok}) then {_fuel = 1;_fuel_ok = true};
    if (!_damage_ok) then {_damage = _damage - _rep_count};
    if (_damage <= 0.01 && {!_damage_ok}) then {_damage = 0;_damage_ok = true};
    hintSilent format [(localize "STR_DOM_MISSIONSTRING_327"),_fuel, _damage];
};
if (_breaked_out) exitWith {
    (localize "STR_DOM_MISSIONSTRING_332") call FUNC(GlobalChat);
    player removeAction _rep_action;
};
if (_breaked_out2) exitWith {};
GVAR(eng_can_repfuel) = false;
player removeAction _rep_action;
if (!alive player) exitWith {player removeAction _rep_action};
[QGVAR(rep_ar), GVAR(objectID2)] call FUNC(NetCallEvent);
(format [(localize "STR_DOM_MISSIONSTRING_334"), _type_name]) call FUNC(GlobalChat);
