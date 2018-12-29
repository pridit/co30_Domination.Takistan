// by Xeno
#define THIS_FILE "x_target_clear_client.sqf"
#include "x_setup.sqf"
private ["_current_target_name","_target_array2","_extra_bonusn"];

if (!X_Client) exitWith {};

_extra_bonusn = _this;

__TargetInfo

_current_target_name setMarkerColorLocal "ColorGreen";

if (!isNil QGVAR(task1)) then {GVAR(task1) setTaskState "Succeeded"};

if (!isNil QGVAR(current_task)) then {
    GVAR(current_task) setTaskState "Succeeded";
    [GVAR(current_task), "SUCCEEDED"] call FUNC(TaskHint);
    sleep 3;
    playSound "PizzaTime";
};

if (count __XJIPGetVar(resolved_targets) < GVAR(MainTargets)) then {
    _bonus_pos = (localize "STR_DOM_MISSIONSTRING_569");
    
    _mt_str = format [(localize "STR_DOM_MISSIONSTRING_570"), _current_target_name];
    if (_extra_bonusn != "") then {
        _bonus_string = format[(localize "STR_DOM_MISSIONSTRING_571"), [_extra_bonusn, 0] call FUNC(GetDisplayName), _bonus_pos];
        
        hint composeText[
            parseText("<t color='#f02b11ed' size='1'>" + _mt_str + "</t>"), lineBreak,lineBreak,
            (localize "STR_DOM_MISSIONSTRING_572"), lineBreak,lineBreak,
            _bonus_string, lineBreak,lineBreak,
            (localize "STR_DOM_MISSIONSTRING_573")
        ];
    } else {
        hint composeText[
            parseText("<t color='#f02b11ed' size='1'>" + _mt_str + "</t>"), lineBreak,lineBreak,
            (localize "STR_DOM_MISSIONSTRING_572"), lineBreak,lineBreak,
            (localize "STR_DOM_MISSIONSTRING_573")
        ];
    };
} else {
    _mt_str = format [(localize "STR_DOM_MISSIONSTRING_570"), _current_target_name];
    hint  composeText[
        parseText("<t color='#f02b11ed' size='1'>" + _mt_str + "</t>"), lineBreak,lineBreak,
        (localize "STR_DOM_MISSIONSTRING_572")
    ];
};

sleep 2;

if (!X_SPE) then {__XJIPSetVar [QGVAR(current_target_index), -1]};