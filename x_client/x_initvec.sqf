// by Xeno
#define THIS_FILE "x_initvec.sqf"
#include "x_setup.sqf"
#define __vecmarker _mxname = _car select 2; \
if (str(markerPos _mxname) == "[0,0,0]") then { \
[_mxname, getPosASL _vec,"ICON",_car select 4,[1,1],_mt,0,_car select 3] call FUNC(CreateMarkerLocal);\
} else { \
_mxname setMarkerPosLocal (getPosASL _vec); \
}; \
_vec setVariable [QGVAR(marker), _mxname];\
GVAR(marker_vecs) set [count GVAR(marker_vecs), _vec];

#define __chopmarker _mxname = _car select 2; \
if (str(markerPos _mxname) == "[0,0,0]") then { \
[_mxname, getPosASL _vec,"ICON",_car select 5,[1,1],_car select 6,0,_car select 4] call FUNC(CreateMarkerLocal);\
} else { \
_mxname setMarkerPosLocal (getPosASL _vec); \
}; \
_vec setVariable [QGVAR(marker), _mxname];\
GVAR(marker_vecs) set [count GVAR(marker_vecs), _vec];\
if (count _car > 8) then {_vec setVariable [QGVAR(lift_types), _car select 8]}

#define __chopset _index = _car select 1;\
_vec setVariable [QGVAR(choppertype), _index];\
_vec setVariable [QGVAR(vec_type), "chopper"];\
switch (_index) do {\
    case 0: {_vec addEventHandler ["getin", {[_this,0] call FUNC(checkhelipilot)}]};\
    case 1: {_vec addEventHandler ["getin", {[_this,0] call FUNC(checkhelipilot_wreck)}]};\
    case 2: {_vec addEventHandler ["getin", {[_this,1] call FUNC(checkhelipilot)}]};\
};\
_vec addEventHandler ["getout", {_this call FUNC(checkhelipilotout)}]

#define __sidew _vec setVariable [QGVAR(side), west]
#define __sidee _vec setVariable [QGVAR(side), east]
#define __vecname _vec setVariable [QGVAR(vec_name), _car select 6]
#define __chopname _vec setVariable [QGVAR(vec_name), _car select 7]
#define __checkenterer _vec addEventHandler ["getin", {_this call FUNC(checkenterer)}]
#define __pvecs {if ((_x select 1) == _d_vec) exitWith {_car = _x}} forEach GVAR(p_vecs)
#define __pvecss(sname) {if ((_x select 1) == _d_vec) exitWith {_car = _x}} forEach d_p_vecs_##sname

#define __staticl \
_vec addAction[(localize "STR_DOM_MISSIONSTRING_256") call FUNC(GreyText),"scripts\load_static.sqf",_d_vec,-1,false];\
_vec addAction[(localize "STR_DOM_MISSIONSTRING_257") call FUNC(RedText),"scripts\unload_static.sqf",_d_vec,-1,false]

#define __addchopm _vec addAction [(localize "STR_DOM_MISSIONSTRING_258") call FUNC(GreyText),"x_client\x_vecdialog.sqf",[],-1,false]

#define __halo _vec addAction [(localize "STR_DOM_MISSIONSTRING_259") call FUNC(GreyText),"x_client\x_halo.sqf",[],-1,false,true,"","vehicle player != player && {((vehicle player) call d_fnc_GetHeight) > 50}"]

private "_vec";

_vec = _this;

private "_desm";
_desm = GV(_vec,GVAR(deserted_marker));
if (!isNil "_desm") then {
    if (_desm != "") then {
        [_desm, getPosASL _vec,"ICON","ColorBlack",[1,1], format [(localize "STR_DOM_MISSIONSTRING_260"), [typeOf _vec, 0] call FUNC(GetDisplayName)],0,"Dot"] call FUNC(CreateMarkerLocal);
    };
};

_d_vec = GV(_vec,GVAR(vec));
if (isNil "_d_vec") exitWith {};

if (!isNil {GV(_vec,GVAR(vcheck))}) exitWith {};
_vec setVariable [QGVAR(vcheck), true];

if (_d_vec < 10) exitWith {
    _car = [];
    __pvecs;
    if (count _car > 0) then {
        __mNsSetVar [_car select 0, _vec];
        if (!alive _vec) exitWith {};
        _mt = _car select 5;
        if (!isNil {GV(_vec,GVAR(MHQ_Deployed))} && {GV(_vec,GVAR(MHQ_Deployed))}) then {
            _mt = format [(localize "STR_DOM_MISSIONSTRING_261"), _mt];
        };
        if (str(markerPos (_car select 2)) != "[0,0,0]") then {
            (_car select 2) setMarkerTextLocal _mt;
        };
        __vecmarker;
        _vec setVariable [QGVAR(marker_text), _car select 5];
        __vecname;
    };
    if (!alive _vec) exitWith {};
    _vec addAction [(localize "STR_DOM_MISSIONSTRING_262") call FUNC(GreyText),"x_client\x_vecdialog.sqf",_d_vec,-1,false];
    _vec setVariable [QGVAR(vec_type), "MHQ"];
    _vec setAmmoCargo 0;
};

if (_d_vec < 20) exitWith {
    _car = [];
    __pvecs;
    if (count _car > 0) then {
        __mNsSetVar [_car select 0, _vec];
        if (!alive _vec) exitWith {};
        _mt = _car select 5;
        __vecmarker;
        __vecname;
    };
    if (!alive _vec) exitWith {};
    _vec setAmmoCargo 0;
};

if (_d_vec < 30) exitWith {
    _car = [];
    __pvecs;
    if (count _car > 0) then {
        __mNsSetVar [_car select 0, _vec];
        if (!alive _vec) exitWith {};
        _mt = _car select 5;
        __vecmarker;
        __vecname;
    };
    if (!alive _vec) exitWith {};
    _vec setAmmoCargo 0;
};

if (_d_vec < 40) exitWith {
    _car = [];
    __pvecs;
    if (count _car > 0) then {
        __mNsSetVar [_car select 0, _vec];
        if (!alive _vec) exitWith {};
        _mt = _car select 5;
        __vecmarker;
        __vecname;
    };
    if (!alive _vec) exitWith {};
    if (GVAR(with_ai) || {GVAR(with_ai_features) == 0} || {GVAR(string_player) in GVAR(is_engineer)}) then {
        __staticl;
    } else {
        _vec addEventHandler ["getin", {_this call FUNC(checktrucktrans)}];
    };
    _vec setVariable [QGVAR(vec_type), "Engineer"];
    _vec setAmmoCargo 0;
};

if (_d_vec < 50) exitWith {
    _car = [];
    __pvecs;
    if (count _car > 0) then {
        __mNsSetVar [_car select 0, _vec];
        if (!alive _vec) exitWith {};
        _mt = _car select 5;
        __vecmarker;
        __vecname;
    };
    if (!alive _vec) exitWith {};
    _vec setAmmoCargo 0;
};

if (_d_vec < 400) exitWith {
    _car = [];
    {if ((_x select 3) == _d_vec) exitWith {_car = _x}} forEach GVAR(choppers);
    if (count _car > 0) then {
        if (!alive _vec) exitWith {};
        __mNsSetVar [_car select 0, _vec];
        __chopname;
        __chopmarker;
    };
    if (!alive _vec) exitWith {};
    if (_vec isKindOf "Air") then {
        __addchopm;
        __chopset;
    };
    __halo;
};