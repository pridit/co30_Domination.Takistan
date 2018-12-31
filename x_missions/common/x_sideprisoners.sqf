// by Xeno
#define THIS_FILE "x_sideprisoners.sqf"
#include "x_setup.sqf"
private ["_posi_a", "_pos", "_newgroup", "_unit_array", "_leader", "_hostages_reached_dest", "_all_dead", "_rescued", "_units", "_winner", "_nobjs", "_retter", "_do_loop", "_i", "_one"];
if !(call FUNC(checkSHC)) exitWith {};

PARAMS_1(_posi_a);
_pos = _posi_a select 0;
_posi_a = nil;

sleep 2;

_newgroup = [GVAR(own_side)] call FUNC(creategroup);
_unit_array = ["civilian", "CIV"] call FUNC(getunitliste);
[_pos, _unit_array select 0, _newgroup] call FUNC(makemgroup);
_leader = leader _newgroup;
_leader setSkill 1;
_unit_array = nil;
sleep 2.0112;
_newgroup allowFleeing 0;
_newgroup setVariable [QGVAR(gstate), 1];
_units = units _newgroup;
{
    removeAllWeapons _x;
    _x setCaptive true;
    _x disableAI "MOVE";
} forEach _units;

sleep 2.333;
["specops", 2, "basic", 2, _pos,100,true] spawn FUNC(CreateInf);
sleep 2.333;
["shilka", 1, "bmp", 1, "tank", 1, _pos,1,140,true] spawn FUNC(CreateArmor);

sleep 32.123;

_hostages_reached_dest = false;
_all_dead = false;
_rescued = false;

while {!_hostages_reached_dest && {!_all_dead}} do {
    __MPCheck;
    if ((_units call FUNC(GetAliveUnits)) == 0) then {
        _all_dead = true;
    } else {
        if (!_rescued) then {
            _leader = leader _newgroup;
            _nobjs = (position _leader) nearEntities ["CAManBase", 20];
            if (count _nobjs > 0) then {
                {
                    if (isPlayer _x && {alive _x}) exitWith {
                        _rescued = true;
                        _retter = _x;
                        {
                            if (!isNull _x && {alive _x}) then {
                                _x setCaptive false;
                                _x enableAI "MOVE";
                            };
                        } forEach _units;
                        [QGVAR(joing), [group _retter, _units]] call FUNC(NetCallEventSTO);
                    };
                    sleep 0.01;
                } forEach _nobjs;
            };
        } else {
            _do_loop = true;
            {
                if (!isNull _x && {alive _x}) then {
                    if ((vehicle _x) distance GVAR(FLAG_BASE) < 20) then {
                        _hostages_reached_dest = true;
                        _do_loop = false;
                    };
                };
                if (!_do_loop) exitWith {};
            } forEach _units;
        };
    };
    sleep 5.123;
};

if (_all_dead) then {
    GVAR(side_mission_winner) = -400;
} else {
    if (_hostages_reached_dest) then {
        if ((_units call FUNC(GetAliveUnits)) > 7) then {
            GVAR(side_mission_winner) = 2;
        } else {
            GVAR(side_mission_winner) = -400;
        };
    } else {
        GVAR(side_mission_winner) = -400;
    };
};

GVAR(side_mission_resolved) = true;
if (GVAR(IS_HC_CLIENT)) then {
    [QGVAR(sm_var), GVAR(side_mission_winner)] call FUNC(NetCallEventCTS);
};

sleep 5.123;

{
    if (!isNull _x) then {
        if (vehicle _x != _x) then {
            _x action ["eject", vehicle _x];
            unassignVehicle _x;
            _x setPos [0,0,0];
        };
        deleteVehicle _x;
    };
} forEach _units;
sleep 0.5321;
if (!isNull _newgroup) then {deleteGroup _newgroup};

_units = nil;
