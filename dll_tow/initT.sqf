_vehicleTowed = _this select 0;
_towing = (vehicle player) getVariable "dll_tow_towing";

if (isNil "_towing") then {
    (vehicle player) setVariable ["dll_tow_towing", false];
    _towing = false;
    (vehicle player) setVariable ["dll_tow_canAttach", true];
};

if (!_towing) then {
    _vehicleTowed setVariable ["dll_tow_P", (vehicle player)];
    [_vehicleTowed] spawn dll_tow;
    (vehicle player) setVariable ["dll_tow_canAttach", false];
};