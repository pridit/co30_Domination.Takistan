// by Xeno
#define THIS_FILE "x_sidemissionwinner.sqf"
#include "x_setup.sqf"
private ["_bonus_string","_s"];

if (!X_Client || {GVAR(IS_HC_CLIENT)}) exitWith {};

sleep 1;

deleteMarkerLocal (format ["XMISSIONM%1", GVAR(x_sm_oldmission_index) + 1]);
if (GVAR(x_sm_type) == "convoy") then {deleteMarkerLocal (format ["XMISSIONM2%1", GVAR(x_sm_oldmission_index) + 1])};

GVAR(current_mission_text) = (localize "STR_DOM_MISSIONSTRING_712");

if (GVAR(side_mission_winner) > 0) then {
    hint composeText[
        parseText("<t color='#f0ffff00' size='1'>Sidemission resolved</t>"), lineBreak,lineBreak,
        (localize "STR_DOM_MISSIONSTRING_572"), lineBreak,lineBreak,
        GVAR(current_mission_resolved_text)
    ];
    GVAR(current_side_task) setTaskState "Succeeded";
    [GVAR(current_side_task), "SUCCEEDED"] call FUNC(TaskHint);
    playSound "AhRosie";
} else {
    _s = switch (GVAR(side_mission_winner)) do {
        case -1: {(localize "STR_DOM_MISSIONSTRING_716")};
        case -2: {(localize "STR_DOM_MISSIONSTRING_717")};
        case -300: {(localize "STR_DOM_MISSIONSTRING_718")};
        case -400: {(localize "STR_DOM_MISSIONSTRING_719")};
        case -500: {(localize "STR_DOM_MISSIONSTRING_720")};
        case -600: {(localize "STR_DOM_MISSIONSTRING_721")};
        case -700: {(localize "STR_DOM_MISSIONSTRING_722")};
        case -878: {(localize "STR_DOM_MISSIONSTRING_723")};
        case -879: {(localize "STR_DOM_MISSIONSTRING_724")};
        default {""};
    };
    if (_s != "") then {
        hint composeText[
            parseText("<t color='#f0ff00ff' size='1'>" + (localize "STR_DOM_MISSIONSTRING_725") + "</t>"), lineBreak,lineBreak,
            _s
        ];
    };
    GVAR(current_side_task) setTaskState "Failed";
    [GVAR(current_side_task), "FAILED"] call FUNC(TaskHint);
};

sleep 1;
GVAR(side_mission_winner) = 0;