#define THIS_FILE "x_newtask.sqf"
#include "x_setup.sqf"
private ["_text", "_type", "_target_pos", "_dtnum", "_dtform", "_dtask"];
PARAMS_3(_text,_type,_target_pos);
_dtnum = __XJIPGetVar(GVAR(current_mission_index)) + 100;
_dtform = format ["d_task%1", _dtnum];
sleep 7.012;
__mNsSetVar [_dtform, player createSimpleTask [format ["obj%1", _dtnum]]];
_dtask = __getMNsVar2(_dtform);

_dtask setSimpleTaskDescription [_text, format [(localize "STR_DOM_MISSIONSTRING_1449"), _type], format [(localize "STR_DOM_MISSIONSTRING_1449"), _type]];
_dtask setTaskState "Created";
_dtask setSimpleTaskDestination _target_pos;
GVAR(current_side_task) = _dtask;

[GVAR(current_side_task), "CREATED"] call FUNC(TaskHint);