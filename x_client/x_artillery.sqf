// by Xeno
#define THIS_FILE "x_artillery.sqf"
#include "x_setup.sqf"
private ["_ok","_oldpos","_exitj"];

disableSerialization;

if (count _this > 2) then {
    _this = _this select 3;
};

PARAMS_2(_ari_num,_ari_target);

_ariavailstr = switch (_ari_num) do {
    case 1: {"ari_available"};
    case 2: {"ari2_available"};
};

_firstsecondstr = switch (_ari_num) do {
    case 1: {(localize "STR_DOM_MISSIONSTRING_143")};
    case 2: {(localize "STR_DOM_MISSIONSTRING_144")};
};

_arti_markername = switch (_ari_num) do {
    case 1: {QGVAR(arti_target)};
    case 2: {QGVAR(arti_target2)};
}; 

if !(X_JIPH getVariable _ariavailstr) exitWith {
    _str = _firstsecondstr + (localize "STR_DOM_MISSIONSTRING_145");
    _str call FUNC(HQChat);
};

["arti1_marker_1",getPosASL player,"ELLIPSE","ColorYellow",[GVAR(ArtiOperatorMaxDist),GVAR(ArtiOperatorMaxDist)],"",0,"","FDiagonal"] call FUNC(CreateMarkerLocal);

GVAR(ari_type) = "";
GVAR(ari_salvos) = 1;
GVAR(ARTI_HELPER) = switch (_ari_num) do {
    case 1: {GVAR(AriTarget)};
    case 2: {GVAR(AriTarget2)};
};
GVAR(ARTI_MARKER_HELPER) = _arti_markername;
_oldpos = getPosASL _ari_target;
createDialog "XD_ArtilleryDialog";

waitUntil {GVAR(ari_type) != "" || {!GVAR(arti_dialog_open)} || {!alive player} || {__pGetVar(xr_pluncon)}};

deleteMarkerLocal "arti1_marker_1";
if (!alive player || {__pGetVar(xr_pluncon)}) exitWith {
    if (GVAR(arti_dialog_open)) then {closeDialog 0};
};
if (GVAR(ari_type) != "") then {
    if !(X_JIPH getVariable _ariavailstr) exitWith {(localize "STR_DOM_MISSIONSTRING_149") call FUNC(HQChat)};
    _ppl = getPosASL player;
    _ppl set [2,0];
    if (_ppl distance [getPosASL _ari_target select 0,getPosASL _ari_target select 1,0] > GVAR(ArtiOperatorMaxDist)) exitWith {
        (format [(localize "STR_DOM_MISSIONSTRING_150"), GVAR(ArtiOperatorMaxDist)]) call FUNC(HQChat);
        _ari_target setPosASL _oldpos;
        _arti_markername setMarkerPos _oldpos;
    };
    
    _no = objNull;
    if (GVAR(arti_check_for_friendlies) == 0 && {GVAR(ari_type) == "he" || {GVAR(ari_type) == "dpicm"}}) then {
        _man_type = switch (GVAR(own_side)) do {
            case "WEST": {"SoldierWB"};
            case "EAST": {"SoldierEB"};
            case "GUER": {"SoldierGB"};
        };
        _pos_at = [getPosASL _ari_target select 0, getPosASL _ari_target select 1, 0];
        _no = nearestObject [_pos_at, _man_type];
    };
    
    if (!isNull _no) exitWith {
        (localize "STR_DOM_MISSIONSTRING_151") call FUNC(HQChat);
        _ari_target setPosASL _oldpos;
        _arti_markername setMarkerPos _oldpos;
    };

    [QGVAR(say), [player,"Funk"]] call FUNC(NetCallEvent);
    #ifndef __TT__
    player kbTell [GVAR(kb_logic1),GVAR(kb_topic_side_arti),"ArtilleryRequest",["1","",GVAR(ari_type),[]],["2","",str(GVAR(ari_salvos)),[]],["3","",mapGridPosition getPosASL _ari_target,[]],true];
    #else
    _topicside = switch (_ari_num) do {
        case 1: {"HQ_ART_W"};
        case 2: {"HQ_ART_E"};
    };
    _logic = switch (_ari_num) do {
        case 1: {GVAR(hq_logic_en1)};
        case 2: {GVAR(hq_logic_ru1)};
    };
    player kbTell [_logic,_topicside,"ArtilleryRequest",["1","",GVAR(ari_type),[]],["2","",str(GVAR(ari_salvos)),[]],["3","",mapGridPosition getPosASL _ari_target,[]],true];
    #endif
    [QGVAR(ari_type), [GVAR(ari_type),GVAR(ari_salvos),player,_ari_target,_ariavailstr,_ari_num]] call FUNC(NetCallEventCTS);
} else {
    (localize "STR_DOM_MISSIONSTRING_152") call FUNC(HQChat);
    _ari_target setpos _oldpos;
    _arti_markername setMarkerPos _oldpos;
};