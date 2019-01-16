// by Xeno
#define THIS_FILE "x_showstatus.sqf"
#include "x_setup.sqf"
#define __ctrl(vctrl) _ctrl = _XD_display displayCtrl vctrl
#define __ctrl2(ectrl) (_XD_display displayCtrl ectrl)
private ["_ctrl","_current_target_name","_s","_target_array2","_XD_display"];
if (!X_Client) exitWith {};

disableSerialization;

createDialog "XD_StatusDialog";

_XD_display = __uiGetVar(X_STATUS_DIALOG);

_mmexit = false;
_hxhx = __pGetVar(GVAR(p_isadmin));
if (isNil "_hxhx") then {_hxhx = false};
if (_hxhx) then {
    if (!(serverCommandAvailable "#shutdown") && {isMultiplayer}) exitWith {
        [QGVAR(p_f_b_k), [player, GVAR(name_pl), 3]] call FUNC(NetCallEventCTS);
        _mmexit = true;
    };	
} else {
    __ctrl2(123123) ctrlShow false;
};
if (_mmexit) exitWith {};

if (isNil QGVAR(server_name)) then {
        __ctrl2(777) ctrlShow false;
        __ctrl2(778) ctrlShow false;
} else {
    __ctrl2(778) ctrlSetText GVAR(server_name);
};

__ctrl2(1010) ctrlShow false;

_target_array2 = [];
_current_target_name = "";

if (__XJIPGetVar(GVAR(current_target_index)) != -1) then {
    __TargetInfo
} else {
    _current_target_name = (localize "STR_DOM_MISSIONSTRING_539");
};

_s = switch (true) do {
    case __XJIPGetVar(all_sm_res): {(localize "STR_DOM_MISSIONSTRING_522")};
    case (__XJIPGetVar(GVAR(current_mission_index)) == -1): {(localize "STR_DOM_MISSIONSTRING_540")};
    default {GVAR(current_mission_text)};
};
__ctrl2(11002) ctrlSetText _s;

if (GVAR(WithRevive) == 1) then {
    __ctrl2(30000) ctrlShow false;
    __ctrl2(30001) ctrlShow false;
} else {
    __ctrl2(30001) ctrlSetText str(__pGetVar(xr_lives));
};

__ctrl2(11018) ctrlSetText (localize "STR_DOM_MISSIONSTRING_548");

__ctrl2(11003) ctrlSetText _current_target_name;

_s = format ["%1/%2", (count __XJIPGetVar(resolved_targets) + 1), GVAR(MainTargets)];
__ctrl2(11006) ctrlSetText _s;

__ctrl2(11233) ctrlSetText str(score player);

__ctrl(11278);
#ifndef __TT__
_ctrl ctrlSetText format ["%1/%2", __XJIPGetVar(GVAR(campscaptured)), count __XJIPGetVar(GVAR(currentcamps))];
#else
if (playerSide == west) then {
    _ctrl ctrlSetText format ["%1/%2", __XJIPGetVar(GVAR(campscaptured_w)), count __XJIPGetVar(GVAR(currentcamps))];
} else {
    _ctrl ctrlSetText format ["%1/%2", __XJIPGetVar(GVAR(campscaptured_e)), count __XJIPGetVar(GVAR(currentcamps))];
};
#endif

_s = format [(localize "STR_DOM_MISSIONSTRING_549"), round(overcast * 100), round (rain * 100)];
__ctrl2(11013) ctrlSetText _s;

__ctrl(11009);
_ctrl ctrlSetText (localize "STR_DOM_MISSIONSTRING_552");

_s = "";
if (__XJIPGetVar(GVAR(current_target_index)) != -1) then {
    _s = switch (__XJIPGetVar(sec_kind)) do {
        case 1: {
            format [(localize "STR_DOM_MISSIONSTRING_554"), _current_target_name]
        };
        case 2: {
#ifdef __CO__
            format [(localize "STR_DOM_MISSIONSTRING_555"), _current_target_name]
#endif
#ifdef __OA__
            format [(localize "STR_DOM_MISSIONSTRING_556"), _current_target_name]
#endif
        };
        case 3: {
#ifndef __TT__
            format [(localize "STR_DOM_MISSIONSTRING_557"), _current_target_name]
#else
            format [(localize "STR_DOM_MISSIONSTRING_558"), _current_target_name]
#endif
        };
        case 4: {
#ifndef __TT__
            format [(localize "STR_DOM_MISSIONSTRING_559"), _current_target_name]
#else
            format [(localize "STR_DOM_MISSIONSTRING_560"), _current_target_name]
#endif
        };
        case 5: {
            format [(localize "STR_DOM_MISSIONSTRING_561"), _current_target_name]
        };
        case 6: {
            format [(localize "STR_DOM_MISSIONSTRING_562"), _current_target_name]
        };
        case 7: {
            format [(localize "STR_DOM_MISSIONSTRING_563"), _current_target_name]
        };
        case 8: {
            format [(localize "STR_DOM_MISSIONSTRING_564"), _current_target_name]
        };
        case 9: {
            format [(localize "STR_DOM_MISSIONSTRING_565"), _current_target_name]
        };
        case 10: {
            format [(localize "STR_DOM_MISSIONSTRING_566"), _current_target_name]
        };
        case 11: {
            format [(localize "STR_DOM_MISSIONSTRING_567"), _current_target_name]
        };
        default {
            (localize "STR_DOM_MISSIONSTRING_568")
        };
    };
} else {
    _s = (localize "STR_DOM_MISSIONSTRING_568");
};

__ctrl2(11007) ctrlSetText _s;

__ctrl2(12010) ctrlSetText ((rank player) call FUNC(GetRankPic));

__ctrl2(11014) ctrlSetText ((rank player) call FUNC(GetRankString));

0 spawn {
    scriptName "spawn_waitforstatusdialogclose";
    waitUntil {!GVAR(showstatus_dialog_open) || {!alive player} || {__pGetVar(xr_pluncon)}};
    if (GVAR(showstatus_dialog_open)) then {closeDialog 0};
};