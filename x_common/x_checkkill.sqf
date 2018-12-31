// by Xeno
#define THIS_FILE "x_checkkill.sqf"
#include "x_setup.sqf"
private ["_killed","_killer","_killedfriendly"];
PARAMS_2(_killed,_killer);

if (local _killed) then {
    [0] call FUNC(x_playerspawn);
};

if (!isServer) exitWith {};

_killedfriendly = (side (group _killer) == side (group _killed));

__addDeadAI(_killed)

if (!isNull _killer && {isPlayer _killer} && {vehicle _killer != vehicle _killed}) then {
    _par = GVAR(player_store) getVariable (getPlayerUID _killed);
    __TRACE_1("_killed",_par);
    _namep = if (isNil "_par") then {"Unknown"} else {_par select 6};
    _par = GVAR(player_store) getVariable (getPlayerUID _killer);
    __TRACE_1("_killer",_par);
    _namek = if (isNil "_par") then {"Unknown"} else {_par select 6};
    [_namek, _namep, _killer] call FUNC(TKKickCheck);
    [QGVAR(unit_tk), [_namep,_namek]] call FUNC(NetCallEventToClients);
};
