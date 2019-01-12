// by Xeno
#define THIS_FILE "x_vrespawnn.sqf"
#include "x_setup.sqf"
private ["_vehicles", "_var", "_vec", "_empty", "_disabled", "_lastt"];
if (!isServer) exitWith{};

_vehicles = [];

{
    _vehicles set [count _vehicles, [_x, typeOf _x, position _x, direction _x]];
    _x setVariable [QGVAR(lastusedrr), time];
} forEach _this;

_this = nil;

while {true} do {
    sleep 10;
    
    {
        _var = _x;
        _vec = _var select 0;
        
        _empty = _vec call FUNC(GetVehicleEmpty);
        
        if (_empty) then {
            _disabled = (damage _vec > 0.9);
            
            if (!_disabled) then {
                _lastt = _vec getVariable QGVAR(lastusedrr);
                if (time - _lastt > 600) then {_disabled = true};
            };
            
            if (_disabled || {!alive _vec}) then {
                deleteVehicle _vec;
                _vec = objNull;
                sleep 0.5;
                _vec = createVehicle [_var select 1, _var select 2, [], 0, "NONE"];
                _vec setdir (_var select 3);
                _vec setpos (_var select 2);
                _var set [0, _vec];
                _vec setFuel 1;
            };
        } else {
            _vec setVariable [QGVAR(lastusedrr), time];
        };
        
        sleep 2;
    } forEach _vehicles;
};
