// by Xeno
#define THIS_FILE "x_marker.sqf"
#include "x_setup.sqf"

FUNC(X_XMarkerVehicles) = {
    private "_rem";
    _rem = [];
    {
        if (!isNull _x && {alive _x}) then {
            _m = GV(_x,GVAR(marker));_m setMarkerPosLocal (getPosASL _x);if (GVAR(v_marker_dirs)) then {_m setMarkerDirLocal (direction _x)};
            _m setMarkerAlphaLocal (if (!canMove _x) then {0.5} else {1.0});
        } else {
            _rem set [count _rem, _x]
        };
    } forEach GVAR(marker_vecs);
    if (count _rem > 0) then {GVAR(marker_vecs) = GVAR(marker_vecs) - _rem};
};

GVAR(mark_loc280) = localize "STR_DOM_MISSIONSTRING_280";

FUNC(X_XMarkerPlayers) = {
    private ["_ap","_as","_isu"];
    {
        _ap = __getMNsVar2(_x);
        _as = _x;
        _isu = GV(_ap,xr_pluncon);
        if ((isNil "_isu" || {!_isu}) && {!isNil "_ap"} && {alive _ap} && {isPlayer _ap}) then {
            _as setMarkerAlphaLocal 1;
            _as setMarkerPosLocal getPosASL _ap;
            _as setMarkerTextLocal (switch (GVAR(show_player_marker)) do {
                case 1: {name _ap};
                case 2: {""};
                case 3: {GVAR(player_roles) select _forEachIndex};
                case 4: {GVAR(mark_loc280) + str(9 - round(9 * damage _ap))};
                default {""};
            });
            if (GVAR(p_marker_dirs)) then {_as setMarkerDirLocal (direction (vehicle _ap))};
        } else {
            _as setMarkerPosLocal [0,0];
            _as setMarkerTextLocal "";
            _as setMarkerAlphaLocal 0;
        };
    } forEach GVAR(player_entities);
};

if (GVAR(dont_show_player_markers_at_all) == 1) then {
    {[_x, [0,0],"ICON","ColorGreen",[0.4,0.4],"",0,GVAR(p_marker)] call FUNC(CreateMarkerLocal)} forEach GVAR(player_entities);
};

_ncpr = count GVAR(player_roles);
_ncpe = count GVAR(player_entities);
if (_ncpr != _ncpe && {_ncpe > _ncpr}) then {
    for "_e" from 1 to (_ncpe - _ncpr) do {
        GVAR(player_roles) set [count GVAR(player_roles), "AR"];
    };
};

{
    GVAR(misc_store) setVariable [_x, [_forEachIndex, GVAR(player_roles) select _forEachIndex]];
} forEach GVAR(player_entities);

0 spawn {
    scriptName "spawn_start_marker";
    sleep 10;
    ["marker_vecs", {if (visibleMap || {GVAR(do_ma_update_n)} || {!isNil {uiNamespace getVariable "BIS_RscMiniMap"}} || {!isNil {uiNamespace getVariable "RscMiniMapSmall"}}) then {call FUNC(X_XMarkerVehicles)}}, 1.98] call FUNC(addPerFrame);
    ["marker_units", {
        if (GVAR(show_player_marker) > 0 && {visibleMap || {GVAR(do_ma_update_n)} || {!isNil {uiNamespace getVariable "BIS_RscMiniMap"}} || {!isNil {uiNamespace getVariable "RscMiniMapSmall"}}}) then {
            call FUNC(X_XMarkerPlayers);
        };
    }, 2.02] call FUNC(addPerFrame);
};