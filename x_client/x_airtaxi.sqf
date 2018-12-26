// by Xeno
#define THIS_FILE "x_airtaxi.sqf"
#include "x_setup.sqf"
private "_exitj";
if (!X_Client) exitWith {};

if (!GVAR(heli_taxi_available)) exitWith {(localize "STR_DOM_MISSIONSTRING_139") call FUNC(HQChat)};

if (GVAR(FLAG_BASE) distance player < 500) exitWith {(localize "STR_DOM_MISSIONSTRING_140") call FUNC(HQChat)};

[player, (localize "STR_DOM_MISSIONSTRING_141")] call FUNC(SideChat);

sleep 5;

(localize "STR_DOM_MISSIONSTRING_142") call FUNC(HQChat);

GVAR(heli_taxi_available) = false;

[QGVAR(air_taxi), player] call FUNC(NetCallEventCTS);