// by Xeno
#define THIS_FILE "x_dropammobox_old.sqf"
#include "x_setup.sqf"
private ["_unit", "_caller", "_chatfunc", "_vehicle", "_s", "_height", "_speed", "_time", "_boxpos"];

if (!X_Client) exitWith {};

PARAMS_2(_unit,_caller);

if (_unit == _caller) then {_unit = GVAR(curvec_dialog)};

if (_caller != driver _unit && {!isNil {GV(_unit,GVAR(d_choppertype))}}) exitWith {};

_chatfunc = {
    if (vehicle (_this select 1) == (_this select 0)) then {
        [_this select 0, _this select 2] call FUNC(VehicleChat);
    } else {
        [_this select 1, _this select 2] call FUNC(SideChat);
    };
};

_vehicle = vehicle _caller;
if (__XJIPGetVar(GVAR(num_ammo_boxes)) >= GVAR(MaxNumAmmoboxes)) exitWith {
    _s = format [(localize "STR_DOM_MISSIONSTRING_226"), GVAR(MaxNumAmmoboxes)];
    [_unit, _caller, _s] call _chatfunc;
    [_unit, _caller, (localize "STR_DOM_MISSIONSTRING_227")] call _chatfunc;
};
_height = (position _unit) select 2;
if (_height > 3) exitWith {[_unit, _caller, (localize "STR_DOM_MISSIONSTRING_218")] call _chatfunc};
_speed = speed _unit;
if (_speed > 3) exitWith {[_unit, _caller, (localize "STR_DOM_MISSIONSTRING_219")] call _chatfunc};
_time = time;
if (_time - GVAR(last_ammo_drop) < GVAR(drop_ammobox_time)) exitWith {
    [_unit, _caller, format [(localize "STR_DOM_MISSIONSTRING_228"),GVAR(drop_ammobox_time)]] call _chatfunc;
};
GVAR(last_ammo_drop) = _time;

_boxpos = _unit modelToWorld [4,0,0];
_boxpos set [2, 0];

#ifndef __TT__
[QGVAR(m_box), [_vehicle, _boxpos]] call FUNC(NetCallEvent);
#else
[QGVAR(m_box),[_vehicle, _boxpos, GVAR(player_side)]] call FUNC(NetCallEvent);
#endif

[_unit, _caller, (localize "STR_DOM_MISSIONSTRING_229")] call _chatfunc;
