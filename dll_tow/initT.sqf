_vehicleTower = _this select 0;
_vehicleTowee = _this select 1;

_isTowing = _vehicleTower getVariable "dll_tow_isTowing";

if (isNil "_isTowing") then {
    _vehicleTower setVariable ["dll_tow_isTowing", false, true];
    _isTowing = false;
};

if (!_isTowing) then {
    _vehicleTower setVariable ["dll_tow_isTowing", true, true];
    [_vehicleTower, _vehicleTowee] spawn dll_tow;
};