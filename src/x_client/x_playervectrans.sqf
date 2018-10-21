// by Xeno
#define THIS_FILE "x_playervectrans.sqf"
#include "x_setup.sqf"
if (isDedicated) exitWith {};

if (isNil QUOTE(FUNC(getOutEHPoints))) then {
    FUNC(getOutEHPoints) = {
        private ["_vec", "_unit", "_var"];
        PARAMS_1(_vec);
        _unit = _this select 2;
        if (!isPlayer _unit) exitWith {};
        if (alive player && {_unit != player} && {alive _unit}) then {
            _var = GV(_unit,GVAR(TRANS_START));
            if (!isNil "_var" && {_var distance position _unit > GVAR(transport_distance)}) then {
                [QGVAR(pas), [player, d_ranked_a select 18]] call FUNC(NetCallEventCTS);
            };
        };
    };
};

#define __vaeh _vec addEventHandler
#define __vreh _vec removeEventHandler

private ["_vec", "_eindex", "_i", "_egoindex"];
_vec = vehicle player;
_eindex = -1;
_egoindex = -1;
while {GVAR(player_in_vec) && {alive player} && {!__pGetVar(xr_pluncon)}} do {
    if (player == driver _vec) then {
        if (_egoindex == -1) then {
            _egoindex = __vaeh ["getout", {_this call FUNC(getOutEHPoints)}];
            {if (_x != player && {isPlayer _x}) then {_x setVariable [QGVAR(TRANS_START), position _vec]}} forEach (crew _vec);
        };
        if (_eindex == -1) then {
            _eindex = __vaeh ["getin",{if (isPlayer (_this select 2)) then {(_this select 2) setVariable [QGVAR(TRANS_START), position (_this select 0)]}}];
        };
    };
    if (player != driver _vec) then {
        if (_eindex != -1) then {
            __vreh ["getin",_eindex];
            _eindex = -1;
        };
        if (_egoindex != -1) then {
            __vreh ["getout",_egoindex];
            _egoindex = -1;
        };
    };
    sleep 0.812;
};
if (_eindex != -1) then {
    __vreh ["getin",_eindex];
};
if (_egoindex != -1) then {
    __vreh ["getout",_egoindex];
};
