// by Xeno
#define THIS_FILE "x_checkkilleast.sqf"
#include "x_setup.sqf"
private ["_killed", "_killer", "_killedfriendly", "_par", "_par1", "_namep", "_namek"];

PARAMS_2(_killed,_killer);

if (local _killed) then {
    [0] call FUNC(x_playerspawn);
};

if (!isServer) exitWith {};

__addDeadAI(_killed)

_killedfriendly = (side (group _killer) == side (group _killed));

if (!isNull _killer && {isPlayer _killer} && {vehicle _killer != vehicle _killed}) then {
    _par1 = GVAR(player_store) getVariable (getPlayerUID _killed);
    __TRACE_1("",_par1);
    _namep = if (isNil "_par1") then {"Unknown"} else {_par1 select 6};
    _par = GVAR(player_store) getVariable (getPlayerUID _killer);
    _namek = if (isNil "_par") then {"Unknown"} else {_par select 6};
    if (!_killedfriendly) then {
        GVAR(points_west) = GVAR(points_west) + (GVAR(tt_points) select 8);
        [QGVAR(u_k), [_namek, _namep, "WEST"]] call FUNC(NetCallEventToClients);
    } else {
        [_namek, _namep, _killer] call FUNC(TKKickCheck);
        [QGVAR(unit_tk), [_namep,_namek]] call FUNC(NetCallEventToClients);
    };
};