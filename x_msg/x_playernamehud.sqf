// by Xeno
#define THIS_FILE "x_playernamehud.sqf"
#include "x_setup.sqf"
private "_xctrl";
if (!local player) exitwith {};

#define IDCPLAYER 5200

disableSerialization;

if (isNil "d_blockspacebarscanning") then {GVAR(blockspacebarscanning) = 1};
if (GVAR(BlockSpacebarScanning) == 0) then {
    X_KeyboardHandlerKeyDown = {((_this select 1) == 57)};
    waitUntil {sleep 0.412;!isNull (findDisplay 46)};
    (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call X_KeyboardHandlerKeyDown"];
};

// 0 = over head, 1 = cursor target
x_show_pname_hud = false;

GVAR(show_player_namesx) = GVAR(playernames_state);

GVAR(dist_pname_hud) = 100;

sleep 10;

#ifndef __TT__
waitUntil {sleep 0.232;!isNil QGVAR(player_entities)};
GVAR(phud_units) = GVAR(player_entities);
waitUntil {sleep 0.232;!isNil {GVAR(misc_store) getVariable (GVAR(player_entities) select ((count GVAR(player_entities)) - 1))}};
#else
waitUntil {sleep 0.232;!isNil QGVAR(entities_tt)};
GVAR(phud_units) = GVAR(entities_tt);
waitUntil {sleep 0.232;!isNil {GVAR(misc_store) getVariable (GVAR(entities_tt) select ((count GVAR(entities_tt)) - 1))}};
#endif
waitUntil {sleep 0.232;!isNil {GV(player,xr_pluncon)}};
waitUntil {sleep 0.232;!GVAR(still_in_intro)};

74193 cutrsc["PlayerNameHud","PLAIN"];

GVAR(phud_deleted) = false;
GVAR(pnhudgroupcolor) = [0.7,0.7,0,0.6];
GVAR(pnhudothercolor) = [0.72,0.72,0.72,0.6];
GVAR(pnhuddeadcolor) = [0,0,0,0];
//GVAR(pnhudptext) = "<img image='%1' /> %2";
GVAR(pnhudptext) = "%2";
GVAR(phud_loc883) = localize "STR_DOM_MISSIONSTRING_883";
GVAR(phud_loc884) = localize "STR_DOM_MISSIONSTRING_884";
GVAR(phud_loc885) = localize "STR_DOM_MISSIONSTRING_885";
GVAR(phud_loc886) = localize "STR_DOM_MISSIONSTRING_886";
FUNC(player_name_huddo) = {
    private ["_u", "_ua", "_index", "_control", "_ali", "_targetPos", "_position", "_vehu", "_tex", "_col", "_o", "_distu", "_do_del_u", "_pheight", "_eyepos_u"];
    disableSerialization;
    if (x_show_pname_hud && {!visibleMap}) then {
        GVAR(phud_deleted) = false;
        _pheight = switch (player call FUNC(getUnitStance)) do {
            case "prone": {0.2};
            case "kneel": {0.9};
            case "stand": {1.7};
            default {0.9};
        };
        {
            _u = __getMNsVar2(_x);
            if (!isNil "_u" && {!isNull _u}) then {
                _distu = (positionCameraToWorld [0,0,0]) distance _u;
                _do_del_u = false;
                if (_u != player && {_distu <= GVAR(dist_pname_hud)} && {alive player} && {alive _u}) then {
                    _epp = eyePos player;
                    _epu = eyePos _u;
                    if (terrainIntersectASL [_epp, _epu] || {lineIntersects [_epp, _epu]}) exitWith {
                        _do_del_u = true;
                    };
                    _ua = GV2(GVAR(misc_store),_x);
                    _index = _ua select 0;
                    _control = __uiGetVar(X_PHUD) displayCtrl (IDCPLAYER + _index);
                    if (isNil "_control") exitWith {};
                    _ali = alive _u;
                    _vehu = vehicle _u;
                    
                    _targetPos = if (!surfaceIsWater (getPosASL _u)) then {
                        ASLToATL (visiblePositionASL _u)
                    } else {
                        visiblePosition _u
                    };
                    _targetPos set [2 , (_targetPos select 2) + (if (_ali) then {2} else {1})];
                    _position = worldToScreen _targetPos;

                    if (count _position != 0 && {(_vehu == _u || {(_vehu != _u && {_u == driver _vehu})})}) then {
                        _control ctrlShow true;
                        _control ctrlSetPosition _position;
                        private "_tex";
                        
                        if (_distu <= 50) then {
                            _tex = switch (GVAR(show_player_namesx)) do {
                                case 1: {
                                    if (_ali) then {
                                        private "_unc";
                                        _unc = GV(_u,xr_pluncon);
                                        if (isNil "_unc") then {_unc = false};
                                        if (_unc) then {GVAR(phud_loc883)} else {(name _u) + (if (getNumber (configFile >> "CfgVehicles" >> typeOf _u >> "attendant") == 1) then {GVAR(phud_loc884)} else {""})}
                                    } else {GVAR(phud_loc885)}
                                };
                                case 2: {_ua select 1};
                                case 3: {str(9 - round(9 * damage _u))};
                                default {GVAR(phud_loc886)};
                            };
                            if (isNil "_tex") then {_tex = GVAR(phud_loc886)};
                            _scale = if (_distu == 0) then {
                                1.2
                            } else {
                                (1.2 - ((_distu / 50) * .65)) max 0.8;
                            };
                            _control ctrlSetScale _scale;
                        } else {
                            _tex = "*";
                            _control ctrlSetScale 0.4;
                        };

                        _control ctrlSetText _tex;
                        _col = if (!_ali) then {
                            GVAR(pnhuddeadcolor)
                        } else {
                            if (group _u == group player) then {GVAR(pnhudgroupcolor)} else {GVAR(pnhudothercolor)}
                        };
                        _control ctrlSetTextColor _col;
                    } else {
                        _control ctrlShow false;
                    };
                    _control ctrlCommit 0;
                } else {
                    _do_del_u = true;
                };
                if (_do_del_u) then {
                    _ua = GV2(GVAR(misc_store),_x);
                    if (!isNil "_ua") then {
                        _index = _ua select 0;
                        _control = __uiGetVar(X_PHUD) displayCtrl (IDCPLAYER + _index);
                        if (isNil "_control") exitWith {};
                        _control ctrlShow false;
                        _control ctrlCommit 0;
                    };
                };
            } else {
                _ua = GV2(GVAR(misc_store),_x);
                if (!isNil "_ua") then {
                    _index = _ua select 0;
                    _control = __uiGetVar(X_PHUD) displayCtrl (IDCPLAYER + _index);
                    if (isNil "_control") exitWith {};
                    _control ctrlShow false;
                    _control ctrlCommit 0;
                };
            };
        } foreach GVAR(phud_units);
    } else {
        if (!GVAR(phud_deleted)) then {
            GVAR(phud_deleted) = true;
            for "_o" from 5200 to 5249 do {
                _control = __uiGetVar(X_PHUD) displayCtrl _o;
                _control ctrlShow false;
                _control ctrlCommit 0;
            };
        };
        if (!x_show_pname_hud) then {
            ["player_hud"] call FUNC(removePerFrame);
        };
    };
};

GVAR(showPlayerNameRSC_shown) = false;

if (x_show_pname_hud) then {
    ["player_hud", {call FUNC(player_name_huddo)},0] call FUNC(addPerFrame);
};