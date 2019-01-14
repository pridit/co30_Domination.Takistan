// ****************************************************************
// Script file for ArmA II
// Generic Towing script 
// Created by: rundll.exe
// Arguments: [Towing object, Towed object]
// Returns: nothing
// ****************************************************************
#include "x_setup.sqf"
private ["_towFromRear", "_aTpos", "_aPpos", "_wheelPpos", "_dx", "_dy", "_dirdeg", "_xP", "_yP", "_P_axis_offset", "_d_axis", "_dx_axis", "_dy_axis", "_speed", "_dirdeg_axis"];

_vehicleTower = _this select 0;
_vehicleTowee = _this select 1;

_displayName = getText (configFile >> "CfgVehicles" >> typeOf(_vehicleTowee) >> "displayName");

//try to find the class or a base of it in the deflist
dll_tow_i = -1;
dll_tow_class = typeOf (_vehicleTowee);

//go trough config backwards
while {(dll_tow_i < 0) && (dll_tow_class != "All")} do {
    dll_tow_i = GVAR(dll_tow_classlist) find dll_tow_class;
    dll_tow_class = configname (inheritsFrom (configFile >> "CfgVehicles" >> dll_tow_class));
};

_def = GVAR(dll_tow_defs) select dll_tow_i;

_P_axis_offset = (_def select 1) + [0];
_P_wheel_offset = (_def select 2) + [0];

_towFromRear = ((_P_axis_offset select 1) < 0);

// Set the variables to track this process
_vehicleTower setVariable ["dll_tow_isTowing", true, true];
_vehicleTower setVariable ["dll_tow_vehicleTowee", _vehicleTowee, true];
_vehicleTowee setVariable ["dll_tow_vehicleTower", _vehicleTower, true];

_vehicleTowerKilled = _vehicleTower addMPEventHandler ["MPKilled", {
    (_this select 0) setVariable ["dll_tow_isTowing", false, true];
}];

_vehicleToweeKilled = _vehicleTowee addMPEventHandler ["MPKilled", {
    ((_this select 0) getVariable "dll_tow_vehicleTower") setVariable ["dll_tow_isTowing", false, true];
}];

hint format ["%1 attached", _displayName];

_detach = _vehicleTower addAction ["<t color='#e7e700'>Detach</t>", "dll_tow\detach.sqf", [], 5, true, true, "", "player in _target"];

while {_vehicleTower getVariable "dll_tow_isTowing"} do {
    //get global coordinates
    _aTpos = _vehicleTower modelToWorld [0.25, -2, 0];
    _aPpos = _vehicleTowee modelToWorld _P_axis_offset;
    _wheelPpos = _vehicleTowee modelToWorld _P_wheel_offset;

    //get the x and y length of the difference vector
    _dx_axis = (_aTpos select 0) - (_aPpos select 0);
    _dy_axis = (_aTpos select 1) - (_aPpos select 1);		
    _d_axis = sqrt(_dx_axis^2 + _dy_axis^2);//absolute length of diff vector

    if(_d_axis > 0.05) then {		
        //get global distance between the T axis and P wheelpos
        _dx = (_aTpos select 0) - (_wheelPpos select 0);
        _dy = (_aTpos select 1) - (_wheelPpos select 1);		
        _dirdeg = _dx atan2 _dy; //convert to direction in deg

        if (_towFromRear) then {
            _dirdeg = _dirdeg + 180;
        };
    
        //set the direction of P, preserving pitch and bank
        [QGVAR(setVectorDirGlobal), [_vehicleTowee, _dx, _dy, 0]] call FUNC(NetCallEventSTO);
        _vehicleTowee setVectorDir [_dx, _dy, 0];

        //velocity implementation (smoother but elastic)		
        _dirdeg_axis = _dx_axis atan2 _dy_axis;	//get the direction of the difference vector						
        _speed = _d_axis * 4; //control the speed needed to make this distance smaller TWEAK HERE	Higher value means less elasticty, but more choppy.
        _speed = _speed min 15; //set max speed for safety.
        _Pvel = velocity _vehicleTowee;

        sleep 0.1;

        [QGVAR(setVelocityGlobal), [_vehicleTowee, (sin _dirdeg_axis * _speed), (cos _dirdeg_axis * _speed), (_Pvel select 2)]] call FUNC(NetCallEventSTO);
        _vehicleTowee setVelocity [
            (sin _dirdeg_axis * _speed),
            (cos _dirdeg_axis * _speed),
            (_Pvel select 2)
        ]; //set the velocity in the correct direction
        
        [_vehicleTower, 15] execVM "x_client\x_limitspeed.sqf";
    };
};

// We have entered the detached state
[QGVAR(setvel0), _vehicleTowee] call FUNC(NetCallEventSTO);

_vehicleTower removeAction _detach;

_vehicleTower removeMPEventHandler ["MPKilled", _vehicleTowerKilled];
_vehicleTowee removeMPEventHandler ["MPKilled", _vehicleToweeKilled];

_vehicleTower setVariable ["dll_tow_isTowing", false, true];
_vehicleTower setVariable ["dll_tow_vehicleTowee", nil, true];
_vehicleTowee setVariable ["dll_tow_vehicleTower", nil, true];

hint format ["%1 detached", _displayName];