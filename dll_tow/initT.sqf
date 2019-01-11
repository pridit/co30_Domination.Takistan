_P = _this select 0;
_T = _this select 1;

_towing = (vehicle player) getVariable "dll_tow_towing";

if (isNil "_towing") then {
    _T setVariable ["dll_tow_towing", false];
    _towing = false;
    _T setVariable ["dll_tow_canAttach", true];
    _P setVariable ["dll_tow_canBeTowed", true];
};

if (!_towing) then {
    _P setVariable ["dll_tow_P", _T];
    [_P, _T] spawn dll_tow;
    _T setVariable ["dll_tow_canAttach", false];
    _P setVariable ["dll_tow_canBeTowed", false];
};