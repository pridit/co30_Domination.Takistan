// ****************************************************************
// Script file for ArmA II
// Generic Towing script 
// Created by: rundll.exe
// Arguments: [Towing object, Towed object]
// Returns: nothing
// ****************************************************************

// usage:
//add functions module on map. and use the following
waituntil {!isnil "bis_fnc_init"};
//dll_tow = compile preprocessfile "dll_tow\tow.sqf";
//[T, P] spawn dll_tow;
// T is the Towing vehicle
// P is the towed vehcile (orginated from Plane)

private ["_towfromrear", "_Tspeed", "_aTpos", "_aPpos", "_wheelPpos", "_dx", "_dy", "_dirdeg", "_xP", "_yP", "_P_axis_offset", "_Taxis", "_Paxis", "_Pwheel", "_d_axis", "_dx_axis", "_dy_axis", "_speed", "_dirdeg_axis"];
//get constants
_T = _this select 0;
_P = _this select 1;
_Pdisplayname = getText (configFile >> "CfgVehicles" >> typeOf(_P) >> "displayName");
_T_axis_offset = (_T getvariable "dll_tow_back_axis_offset") + [0];
_P_axis_offset = (_P getvariable "dll_tow_front_axis_offset") + [0];
_P_wheel_offset = (_P getvariable "dll_tow_wheel_offset") + [0];
_static = _P getVariable "static";
if(isnil("_static")) then {
    _T setVariable ["static", false];
    _static = false;
};
if(isnil("dll_tow_velocity_impl")) then {
    dll_tow_velocity_impl = false;
};
_towfromrear = ((_P_axis_offset select 1) < 0);

//add actions to T
_action_detach = _T addaction ["Detach", "dll_tow\action_detach.sqf"];

_T setVariable ["dll_tow_towing", true];//now we know something is coupled
_P setVariable ["dll_tow_T", _T]; //P should know who is T
//add EH for killing P or T
_P_EHkilledIdx = _P addeventhandler ["Killed", "((_this select 0) getvariable ""dll_tow_T"") setVariable [""dll_tow_towing"", false]"];
_T_EHkilledIdx = _T addeventhandler ["Killed", "(_this select 0) setVariable [""dll_tow_towing"", false]"];

hint format["%1 attached", _Pdisplayname];

while {_T getvariable "dll_tow_towing"} do {
    //get global coordinates
    _aTpos = _T modelToWorld _T_axis_offset;
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
        
        if(_towfromrear) then {
            _dirdeg = _dirdeg + 180;
        };
    
        //set the direction of P, preserving pitch and bank
        _P setVectorDir [
            _dx,
            _dy,
            0
        ];
                    
        //velocity implementation (smoother but elastic)		
        _dirdeg_axis = _dx_axis atan2 _dy_axis;	//get the direction of the difference vector						
        _speed = _d_axis*6; //control the speed needed to make this distance smaller TWEAK HERE	Higher value means less elasticty, but more choppy.
        _speed = _speed min 20; //set max speed for safety.
        _Pvel = velocity _P;
        _P setVelocity [
            (sin _dirdeg_axis * _speed),
            (cos _dirdeg_axis * _speed),
            (_Pvel select 2)
        ]; //set the velocity in the correct direction
    };
};

//remove actions when done
_T removeaction _action_detach;
//remove EHs
_T removeEventHandler ["killed", _T_EHkilledIdx];
_P removeEventHandler ["killed", _P_EHkilledIdx];

//finally, we are not towing anymore
_T setVariable ["dll_tow_towing", false];
hint format["%1 detached", _Pdisplayname];

//and set T to continue searching (temporary here)
[_T] execVM "dll_tow\searchP.sqf";