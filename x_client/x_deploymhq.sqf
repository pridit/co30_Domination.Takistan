// by Xeno
#define THIS_FILE "x_deploymhq.sqf"
#include "x_setup.sqf"
private ["_mhq", "_depltime", "_camotype", "_camo"];
if (!X_Client) exitWith {};

if (!alive player) exitWith {};
if (isNil QGVAR(curvec_dialog)) exitWith {};
if (isNull GVAR(curvec_dialog)) exitWith {};
if (!alive GVAR(curvec_dialog)) exitWith {};

_isthere = true;
_nmhq = nearestObject [player, "LandVehicle"];
_vty = GV(_nmhq,GVAR(vec_type));
if (isNil "_vty") then {_vty = ""};
if (_vty != "MHQ") then {_isthere = false};
if (_isthere && {(vehicle player) in (list GVAR(base_trigger))}) exitWith {(localize "STR_DOM_MISSIONSTRING_212") call FUNC(GlobalChat)};

if (surfaceIsWater (position GVAR(curvec_dialog))) exitWith {(localize "STR_DOM_MISSIONSTRING_213") call FUNC(GlobalChat)};

_mhq = GVAR(curvec_dialog);

_depltime = GV(_mhq,GVAR(MHQ_Depltime));
if (isNil "_depltime") then {_depltime = -1};

if (_depltime > time) exitWith {(localize "STR_DOM_MISSIONSTRING_214") call FUNC(GlobalChat)};

_hxhx = GV(_mhq,GVAR(MHQ_Deployed));
if (isNil "_hxhx") then {_hxhx = false};
if (!_hxhx) then {
    if (count (crew _mhq) > 0) exitWith {(localize "STR_DOM_MISSIONSTRING_215") call FUNC(GlobalChat)};
    _camotype = "Land_CamoNetB_NATO_EP1";
    _pmpos = position _mhq;
    _pmpos set [2, 0];
    if (GVAR(with_mhq_camo) == 0) then {
        _camo = createVehicle [_camotype, _pmpos, [], 0, "NONE"];
        _camo setDir direction _mhq;
        _camo setVectorUp (vectorUp _mhq);
        _camo setPos _pmpos;
        _camo addEventHandler ["handleDamage", {0}];
        _mhq setVariable [QGVAR(MHQ_Camo), _camo, true];
    };
    _mhq setVariable [QGVAR(MHQ_Deployed), true, true];
    [QGVAR(mhqdepl), [_mhq, true]] call FUNC(NetCallEvent);
    _mhq setVariable [QGVAR(MHQ_Depltime), time + 10, true];
} else {
    _camo = GV(_mhq,GVAR(MHQ_Camo));
    if (isNil "_camo") then {_camo = objNull};
    if (!isNull _camo) then {deleteVehicle _camo};
    _mhq setVariable [QGVAR(MHQ_Deployed), false, true];
    [QGVAR(mhqdepl), [_mhq, false]] call FUNC(NetCallEvent);
    _mhq setVariable [QGVAR(MHQ_Depltime), time + 10, true];
};