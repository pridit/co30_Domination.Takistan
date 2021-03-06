// by Xeno
#define THIS_FILE "x_vrespawn2.sqf"
#include "x_setup.sqf"

#define __Trans(tkind) _trans = getNumber(configFile >> #CfgVehicles >> typeOf _vehicle >> #tkind)
private ["_vehicle", "_camotype", "_camo", "_i", "_disabled", "_trans", "_empty", "_outb", "_hasbox"];
if (!isServer) exitWith{};

_vec_array = [];
{
    _vehicle = _x select 0;
    _number_v = _x select 1;
    _vec_array set [count _vec_array, [_vehicle,_number_v,position _vehicle,direction _vehicle,typeOf _vehicle]];
    
    _vehicle setVariable [QGVAR(OUT_OF_SPACE), -1];
    _vehicle setVariable [QGVAR(vec), _number_v, true];
    _vehicle setAmmoCargo 0;
    
    if (_number_v < 10 || {(_number_v > 99 && {_number_v < 110})}) then {
        _vehicle addMPEventhandler ["MPKilled", {(_this select 0) call FUNC(MHQFunc)}];
    };
} forEach _this;
_this = nil;

sleep 5;

while {true} do {
    sleep 8 + random 5;
    __MPCheck;
    {
        _vec_a = _x;
        _vehicle = _vec_a select 0;
        
        _disabled = false;
        if (damage _vehicle > 0.9) then {
            _disabled = true;
        } else {
            __Trans(transportAmmo);
            if (_trans > 0) then {
                _vehicle setAmmoCargo 1;
            };
            __Trans(transportRepair);
            if (_trans > 0) then {
                _vehicle setRepairCargo 1;
            };
            __Trans(transportFuel);
            if (_trans > 0) then {
                _vehicle setFuelCargo 1;
            };
        };
        
        _empty = _vehicle call FUNC(GetVehicleEmpty);
        _aliveve = alive _vehicle;

        if (_empty && {!_disabled} && {_aliveve} && {(_vehicle call FUNC(OutOfBounds))}) then {
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

        if (_empty && {_disabled || {!_aliveve}}) then {
            _number_v = _vec_a select 1;
            _hasbox = GV(_vehicle,GVAR(ammobox));
            if (isNil "_hasbox") then {_hasbox = false};
            if (_hasbox) then {[QGVAR(num_ammo_boxes),__XJIPGetVar(GVAR(num_ammo_boxes)) - 1] call FUNC(NetSetJIP)};
            if (_number_v < 10 || {(_number_v > 99 && {_number_v < 110})}) then {
                _dhqcamo = GV(_vehicle,GVAR(MHQ_Camo));
                if (isNil "_dhqcamo") then {_dhqcamo = objNull};
                if (!isNull _dhqcamo) then {deleteVehicle _dhqcamo};
            };
            sleep 0.1;
            deleteVehicle _vehicle;
            sleep 0.5;
            _vehicle = objNull;
            _vehicle = createVehicle [_vec_a select 4, _vec_a select 2, [], 0, "NONE"];
            _vehicle setDir (_vec_a select 3);
            _vehicle setPos (_vec_a select 2);
            _vehicle setFuel 1;
            
            if (_number_v < 10 || {(_number_v > 99 && {_number_v < 110})}) then {
                _vehicle addMPEventhandler ["MPKilled", {(_this select 0) call FUNC(MHQFunc)}];
            };
            
            if (_number_v >= 10 && _number_v < 20) then {
                _vehicle addAction [format [(localize "STR_DOM_MISSIONSTRING_1453"), "Medkits"] call d_fnc_BlueText, "x_client\x_restoreheals.sqf",[],2,false,true,"","alive _target && {(player getVariable 'perkSelfHeal')} && {(player getVariable 'xr_numheals') < 1}"];
            };
            
            if (_number_v >= 20 && _number_v < 30) then {
                _vehicle addAction [format [(localize "STR_DOM_MISSIONSTRING_1453"), "Repair Kits"] call d_fnc_BlueText, "x_client\x_restoreeng.sqf",[],2,false,true,"","alive _target && {(player getVariable 'perkVehicleService')} && {!(player getVariable 'd_eng_can_repfuel')}"];
            };
            
            _vec_a set [0, _vehicle];
            _vec_array set [_forEachIndex, _vec_a];
            _vehicle setVariable [QGVAR(OUT_OF_SPACE), -1];
            _vehicle setVariable [QGVAR(vec), _number_v, true];
            _vehicle setAmmoCargo 0;
            [QGVAR(n_v), _vehicle] call FUNC(NetCallEventToClients);
        };
        sleep 8 + random 5;
    } forEach _vec_array;
};