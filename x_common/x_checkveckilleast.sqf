// by Xeno
#define THIS_FILE "x_checkveckilleast.sqf"
#include "x_setup.sqf"
private ["_killer", "_killed", "_strkil", "_kpar", "_sidekiller"];
_killer = _this select 1;

if (!isPlayer _killer) exitWith {};

_killed = _this select 0;

_strkil = getPlayerUID _killer;
_kpar = GV(GVAR(player_store),_strkil);
_sidekiller = if (!isNil "_kpar") then {_kpar select 5} else {sideUnknown};

if (_sidekiller == west) then {
    GVAR(points_west) = GVAR(points_west) + (GVAR(tt_points) select 7);
    [QGVAR(vec_killer), [_kpar select 6, "EAST", "US"]] call FUNC(NetCallEventToClients);
};
