// ****************************************************************
// Script file for ArmA II
// Generic Towing script 
// Created by: rundll.exe
// Arguments: [Towing object, Towed object]
// Returns: nothing
// ****************************************************************
private ["_towfromrear", "_aTpos", "_aPpos", "_wheelPpos", "_dx", "_dy", "_dirdeg", "_xP", "_yP", "_P_axis_offset", "_d_axis", "_dx_axis", "_dy_axis", "_speed", "_dirdeg_axis"];

// usage:
// T is the Towing vehicle
// P is the towed vehcile (orginated from Plane)

//get constants
_P = _this select 0;

_displayName = getText (configFile >> "CfgVehicles" >> typeOf(_P) >> "displayName");
_T_axis_offset = [0.25, -2, 0];
_P_axis_offset = (_P getVariable "dll_tow_front_axis_offset") + [0];
_P_wheel_offset = (_P getVariable "dll_tow_wheel_offset") + [0];

_towfromrear = ((_P_axis_offset select 1) < 0);

(vehicle player) setVariable ["dll_tow_towing", true];//now we know something is coupled
_P setVariable ["dll_tow_T", (vehicle player)]; //P should know who is T

//add EH for killing P or T
_P_EHkilledIdx = _P addeventhandler ["Killed", "((_this select 0) getvariable ""dll_tow_T"") setVariable [""dll_tow_towing"", false]"];
_T_EHkilledIdx = (vehicle player) addeventhandler ["Killed", "(_this select 0) setVariable [""dll_tow_towing"", false]"];

hint format ["%1 attached", _displayName];

_detach = (vehicle player) addAction ["<t color='#e7e700'>Detach</t>", "dll_tow\detach.sqf", [], 5];

while {(vehicle player) getVariable "dll_tow_towing"} do {
    //get global coordinates
    _aTpos = (vehicle player) modelToWorld _T_axis_offset;
    _aPpos = _P modelToWorld _P_axis_offset;
    _wheelPpos = _P modelToWorld _P_wheel_offset;

    //get the x and y length of the difference vector
    _dx_axis = (_aTpos select 0) - (_aPpos select 0);
    _dy_axis = (_aTpos select 1) - (_aPpos select 1);		
    _d_axis = sqrt(_dx_axis^2 + _dy_axis^2);//absolute length of diff vector

    if(_d_axis > 0.05) then {		
        //get global distance between the T axis and P wheelpos
        _dx = (_aTpos select 0) - (_wheelPpos select 0);
        _dy = (_aTpos select 1) - (_wheelPpos select 1);		
        _dirdeg = _dx atan2 _dy; //convert to direction in deg
        
        if (_towfromrear) then {
            _dirdeg = _dirdeg + 180;
        };
    
        //set the direction of P, preserving pitch and bank
        _P setVectorDir [_dx, _dy, 0];
                    
        //velocity implementation (smoother but elastic)		
        _dirdeg_axis = _dx_axis atan2 _dy_axis;	//get the direction of the difference vector						
        _speed = _d_axis * 4; //control the speed needed to make this distance smaller TWEAK HERE	Higher value means less elasticty, but more choppy.
        _speed = _speed min 15; //set max speed for safety.
        _Pvel = velocity _P;
        
        _P setVelocity [
            (sin _dirdeg_axis * _speed),
            (cos _dirdeg_axis * _speed),
            (_Pvel select 2)
        ]; //set the velocity in the correct direction
        
        null = [(vehicle player), 15] execVM "x_client\x_limitspeed.sqf";
    };
};

(vehicle player) removeAction _detach;

//remove EHs
(vehicle player) removeEventHandler ["killed", _T_EHkilledIdx];
_P removeEventHandler ["killed", _P_EHkilledIdx];

//finally, we are not towing anymore
(vehicle player) setVariable ["dll_tow_towing", false];
hint format ["%1 detached", _displayName];