// by Xeno
#define THIS_FILE "x_helirespawn2.sqf"
#include "x_setup.sqf"
private ["_heli_array", "_vec_a", "_vehicle", "_number_v", "_is_west_chopper", "_i", "_tt", "_ifdamage", "_empty", "_disabled", "_empty_respawn", "_startpos", "_hasbox"];
if (!isServer) exitWith{};

_heli_array = [];
{
    _vec_a = _x;
    _vehicle = _vec_a select 0;
    _number_v = _vec_a select 1;
    _ifdamage = _vec_a select 2;
    _heli_array set [count _heli_array, [_vehicle,_number_v,_ifdamage,-1, position _vehicle,direction _vehicle,typeOf _vehicle,if (_ifdamage) then {-1} else {_vec_a select 3}]];
    
    _vehicle setVariable [QGVAR(OUT_OF_SPACE), -1];
    _vehicle setVariable [QGVAR(vec), _number_v, true];
} forEach _this;
_this = nil;

_isfirst = true;

while {true} do {
    __MPCheck;
    {
        _vec_a = _x;
        _vehicle = _vec_a select 0;
        _ifdamage = _vec_a select 2;
        
        _empty = _vehicle call FUNC(GetVehicleEmpty);
        
        _disabled = false;
        if (!_ifdamage) then {
            _empty_respawn = _vec_a select 3;
            if (_empty && {_empty_respawn == -1} && {_vehicle distance (_vec_a select 4) > 10}) then {
                _vec_a set [3, time + (_vec_a select 7)];
            };
            
            if (_empty && {_empty_respawn != -1} && {time > _empty_respawn}) then {
                _disabled = true;
            } else {
                if (!_empty && {alive _vehicle}) then {_vec_a set [3,-1]};
            };
        };
            
        if (damage _vehicle > 0.9) then {_disabled = true};
        
        if (_empty && {!_disabled} && {alive _vehicle} && {(_vehicle call FUNC(OutOfBounds))}) then {
            _outb = _vehicle getVariable QGVAR(OUT_OF_SPACE);
            if (_outb != -1) then {
                if (time > _outb) then {_disabled = true};
            } else {
                _vehicle setVariable [QGVAR(OUT_OF_SPACE), time + 600];
            };
        } else {
            _vehicle setVariable [QGVAR(OUT_OF_SPACE), -1];
        };
        
        sleep 0.01;
        
        if ((_disabled && {_empty}) || {(_empty && {!alive _vehicle})}) then {
            _hasbox = GV(_vehicle,GVAR(ammobox));
            if (isNil "_hasbox") then {_hasbox = false};
            if (_hasbox) then {[QGVAR(num_ammo_boxes),__XJIPGetVar(GVAR(num_ammo_boxes)) - 1] call FUNC(NetSetJIP)};
            sleep 0.1;
            deleteVehicle _vehicle;
            if (!_ifdamage) then {_vec_a set [3,-1]};
            sleep 0.5;
            _vehicle = objNull;
            _vehicle = createVehicle [_vec_a select 6, _vec_a select 4, [], 0, "NONE"];
            _vehicle setDir (_vec_a select 5);
            _vehicle setPos (_vec_a select 4);
            _vehicle setFuel 1;
            
            _vec_a set [0,_vehicle];
            _heli_array set [_forEachIndex, _vec_a];
            _number_v = _vec_a select 1;
            _vehicle setVariable [QGVAR(OUT_OF_SPACE), -1];
            _vehicle setVariable [QGVAR(vec), _number_v, true];
            [QGVAR(n_v), _vehicle] call FUNC(NetCallEventToClients);
        };
    } forEach _heli_array;
    sleep 20 + random 5;
};