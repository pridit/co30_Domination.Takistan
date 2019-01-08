#define THIS_FILE "x_playerfuncs.sqf"
#include "x_setup.sqf"


FUNC(sfunc) = {
    private "_objs";
    if (vehicle player == player) then {
        _objs = (position player) nearEntities [["LandVehicle","Air"], 7];
        if (count _objs > 0) then {
            GVAR(objectID2) = _objs select 0;
            if (alive GVAR(objectID2)) then {
                (damage GVAR(objectID2) > 0.05 || fuel GVAR(objectID2) < 1)
            } else {
                false
            }
        }
    } else {
        false
    }
};

FUNC(ffunc) = {
    private ["_l","_vUp","_winkel"];
    if (vehicle player == player) then {
        GVAR(objectID1) = position player nearestObject "LandVehicle";
        if (!alive GVAR(objectID1) || {player distance GVAR(objectID1) > 8}) then {
            false
        } else {
            _vUp = vectorUp GVAR(objectID1);
            if ((_vUp select 2) < 0 && {player distance (position player nearestObject GVAR(rep_truck)) < 20}) then {
                true
            } else {
                _l=sqrt((_vUp select 0)^2+(_vUp select 1)^2);
                if (_l != 0) then {
                    _winkel = (_vUp select 2) atan2 _l;
                    (_winkel < 30 && {player distance (position player nearestObject GVAR(rep_truck)) < 20})
                }
            }
        }
    } else {
        false
    }
};

FUNC(PlacedObjAn) = {
    if (GVAR(string_player) == _this) then {
        if (GVAR(player_is_medic)) then {
            _m_name = "Mash " + _this;
            [QGVAR(w_ma),_m_name] call FUNC(NetCallEventToClients);
            __pSetVar [QGVAR(medtent), []];
            _medic_tent = __pGetVar(medic_tent);
            if (!isNil "_medic_tent") then {if (!isNull _medic_tent) then {deleteVehicle _medic_tent}};
            __pSetVar ["medic_tent", objNull];
            (localize "STR_DOM_MISSIONSTRING_656") call FUNC(GlobalChat);
        };
        if (GVAR(player_can_build_mgnest)) then {
            _m_name = "MG Nest " + _this;
            [QGVAR(w_ma),_m_name] call FUNC(NetCallEventToClients);
            __pSetVar [QGVAR(mgnest_pos), []];
            _mg_nest = __pGetVar(mg_nest);
            if (!isNil "_mg_nest") then {if (!isNull _mg_nest) then {deleteVehicle _mg_nest}};
            __pSetVar ["mg_nest", objNull];
            (localize "STR_DOM_MISSIONSTRING_657") call FUNC(GlobalChat);
        };
        if (__pGetVar(GVAR(eng_can_repfuel))) then {
            _m_name = "FARP " + _this;
            [QGVAR(w_ma),_m_name] call FUNC(NetCallEventToClients);
            __pSetVar [QGVAR(farp_pos), []];
            _farp = __pGetVar(GVAR(farp_obj));
            if (!isNil "_farp") then {if (!isNull _farp) then {deleteVehicle _farp}};
            __pSetVar [QGVAR(farp_obj), objNull];
            (localize "STR_DOM_MISSIONSTRING_658") call FUNC(GlobalChat);
        };
    };
};
#ifndef __TT__
FUNC(RecapturedUpdate) = {
    private ["_index","_target_array", "_target_name", "_targetName","_state"];
    PARAMS_2(_index,_state);
    _target_array = GVAR(target_names) select _index;
    _target_name = _target_array select 1;
    switch (_state) do {
        case 0: {
            _target_name setMarkerColorLocal "ColorRed";
            _target_name setMarkerBrushLocal "FDiagonal";
            hint composeText[
                parseText("<t color='#f0ff0000' size='2'>" + (localize "STR_DOM_MISSIONSTRING_659") + "</t>"), lineBreak,
                parseText("<t size='1'>" + format [(localize "STR_DOM_MISSIONSTRING_660"), _target_name] + "</t>")
            ];
            format [(localize "STR_DOM_MISSIONSTRING_661"), _target_name] call FUNC(HQChat);
        };
        case 1: {
            _target_name setMarkerColorLocal "ColorGreen";
            _target_name setMarkerBrushLocal "Solid";
            hint composeText[
                parseText("<t color='#f00000ff' size='2'>" + (localize "STR_DOM_MISSIONSTRING_662") + "</t>"), lineBreak,
                parseText("<t size='1'>" + format [(localize "STR_DOM_MISSIONSTRING_663"), _target_name] + "</t>")
            ];
        };
    };
};
#endif
FUNC(PlayerRank) = {
    private ["_score","_d_player_old_score","_d_player_old_rank","_perks_unlocked","_points_available"];
    _score = score player;
    _d_player_old_score = __pGetVar(GVAR(player_old_score));
    if (isNil "_d_player_old_score") then {_d_player_old_score = 0};
    _d_player_old_rank = __pGetVar(GVAR(player_old_rank));
    if (isNil "_d_player_old_rank") then {_d_player_old_rank = 0};
    
    [false] call FUNC(calculatePerks);
    
    if (_score < (GVAR(points_needed) select 0) && {_d_player_old_rank != 0}) exitWith {
        if (_d_player_old_score >= (GVAR(points_needed) select 0)) then {(format [(localize "STR_DOM_MISSIONSTRING_664"),_d_player_old_rank call FUNC(GetRankIndex2)]) call FUNC(HQChat)};
        _d_player_old_rank = 0;
        player setRank (_d_player_old_rank call FUNC(GetRankIndex2));
        __pSetVar [QGVAR(player_old_rank), _d_player_old_rank];
        __pSetVar [QGVAR(player_old_score), _score];
    };
    if (_score < (GVAR(points_needed) select 1) && {_score >= (GVAR(points_needed) select 0)} && {_d_player_old_rank != 1}) exitWith {
        if (_d_player_old_score < (GVAR(points_needed) select 1)) then {
            (localize "STR_DOM_MISSIONSTRING_665") call FUNC(HQChat);
            playSound "Impressive";
        } else {
            (format [(localize "STR_DOM_MISSIONSTRING_666"),_d_player_old_rank call FUNC(GetRankIndex2)]) call FUNC(HQChat);
        };
        _d_player_old_rank = 1;
        player setRank (_d_player_old_rank  call FUNC(GetRankIndex2));
        __pSetVar [QGVAR(player_old_score), _score];
        __pSetVar [QGVAR(player_old_rank), _d_player_old_rank];
    };
    if (_score < (GVAR(points_needed) select 2) && {_score >= (GVAR(points_needed) select 1)} && {_d_player_old_rank != 2}) exitWith {
        if (_d_player_old_score < (GVAR(points_needed) select 2)) then {
            (localize "STR_DOM_MISSIONSTRING_667") call FUNC(HQChat);
            playSound "Impressive";
        } else {
            (format [(localize "STR_DOM_MISSIONSTRING_668"),_d_player_old_rank call FUNC(GetRankIndex2)]) call FUNC(HQChat);
        };
        _d_player_old_rank = 2;
        player setRank (_d_player_old_rank call FUNC(GetRankIndex2));
        __pSetVar [QGVAR(player_old_score), _score];
        __pSetVar [QGVAR(player_old_rank), _d_player_old_rank];
    };
    if (_score < (GVAR(points_needed) select 3) && {_score >= (GVAR(points_needed) select 2)} && {_d_player_old_rank != 3}) exitWith {
        if (_d_player_old_score < (GVAR(points_needed) select 3)) then {
            (localize "STR_DOM_MISSIONSTRING_669") call FUNC(HQChat);
            playSound "Impressive";
        } else {
            (format [(localize "STR_DOM_MISSIONSTRING_670"),_d_player_old_rank call FUNC(GetRankIndex2)]) call FUNC(HQChat);
        };
        _d_player_old_rank = 3;
        player setRank (_d_player_old_rank call FUNC(GetRankIndex2));
        __pSetVar [QGVAR(player_old_score), _score];
        __pSetVar [QGVAR(player_old_rank), _d_player_old_rank];
    };
    if (_score < (GVAR(points_needed) select 4) && {_score >= (GVAR(points_needed) select 3)} && {_d_player_old_rank != 4}) exitWith {
        if (_d_player_old_score < (GVAR(points_needed) select 4)) then {
            (localize "STR_DOM_MISSIONSTRING_671") call FUNC(HQChat);
            playSound "Impressive";
        } else {
            (format [(localize "STR_DOM_MISSIONSTRING_672"),_d_player_old_rank call FUNC(GetRankIndex2)]) call FUNC(HQChat);
        };
        _d_player_old_rank = 4;
        player setRank (_d_player_old_rank call FUNC(GetRankIndex2));
        __pSetVar [QGVAR(player_old_score), _score];
        __pSetVar [QGVAR(player_old_rank), _d_player_old_rank];
    };
    if (_score < (GVAR(points_needed) select 5) && {_score >= (GVAR(points_needed) select 4)} && {_d_player_old_rank != 5}) exitWith {		
        if (_d_player_old_score < (GVAR(points_needed) select 4)) then {
            (localize "STR_DOM_MISSIONSTRING_673") call FUNC(HQChat);
            playSound "Impressive";
        } else {
            (format [(localize "STR_DOM_MISSIONSTRING_674"),_d_player_old_rank call FUNC(GetRankIndex2)]) call FUNC(HQChat);
        };
        _d_player_old_rank = 5;
        player setRank (_d_player_old_rank call FUNC(GetRankIndex2));
        __pSetVar [QGVAR(player_old_score), _score];
        __pSetVar [QGVAR(player_old_rank), _d_player_old_rank];
    };
    if (_score >= (GVAR(points_needed) select 5) && {_d_player_old_rank != 6}) exitWith {
        _d_player_old_rank = 6;
        player setRank (_d_player_old_rank call FUNC(GetRankIndex2));
        (localize "STR_DOM_MISSIONSTRING_675") call FUNC(HQChat);
        playSound "Impressive";
        __pSetVar [QGVAR(player_old_score), _score];
        __pSetVar [QGVAR(player_old_rank), _d_player_old_rank];
    };
};

FUNC(GetRankIndex) = {["PRIVATE","CORPORAL","SERGEANT","LIEUTENANT","CAPTAIN","MAJOR","COLONEL"] find (toUpper (_this))};
FUNC(GetRankIndex2) = {["PRIVATE","CORPORAL","SERGEANT","LIEUTENANT","CAPTAIN","MAJOR","COLONEL"] select _this};

FUNC(GetRankString) = {
    scriptName "d_fnc_GetRankString";
    switch (toUpper(_this)) do {
        case "PRIVATE": {"Private"};
        case "CORPORAL": {"Corporal"};
        case "SERGEANT": {"Sergeant"};
        case "LIEUTENANT": {"Lieutenant"};
        case "CAPTAIN": {"Captain"};
        case "MAJOR": {"Major"};
        case "COLONEL": {"Colonel"};
    }
};

FUNC(GetRankFromScore) = {
    scriptName "d_fnc_GetRankFromScore";
    if (_this < (GVAR(points_needed) select 0)) exitWith {"Private"};
    if (_this < (GVAR(points_needed) select 1)) exitWith {"Corporal"};
    if (_this < (GVAR(points_needed) select 2)) exitWith {"Sergeant"};
    if (_this < (GVAR(points_needed) select 3)) exitWith {"Lieutenant"};
    if (_this < (GVAR(points_needed) select 4)) exitWith {"Captain"};
    if (_this < (GVAR(points_needed) select 5)) then {"Major"} else {"Colonel"}
};

FUNC(GetRankPic) = {
    scriptName "d_fnc_GetRankPic";
    switch (toUpper(_this)) do {
        case "PRIVATE": {"pics\rank_private.paa"};
        case "CORPORAL": {"pics\rank_corporal.paa"};
        case "SERGEANT": {"pics\rank_sergeant.paa"};
        case "LIEUTENANT": {"pics\rank_lieutenant.paa"};
        case "CAPTAIN": {"pics\rank_captain.paa"};
        case "MAJOR": {"pics\rank_major.paa"};
        case "COLONEL": {"pics\rank_colonel.paa"};
    }
};

FUNC(BaseEnemies) = {
    scriptName "d_fnc_BaseEnemies";
    private "_status";
    _status = _this select 0;
    switch (_status) do {
        case 0: {
            hint composeText[
                parseText("<t color='#f0ff0000' size='2'>" + (localize "STR_DOM_MISSIONSTRING_676") + "</t>"), lineBreak,
                parseText("<t size='1'>" + (localize "STR_DOM_MISSIONSTRING_677") + "</t>")
            ];
        };
        case 1: {
            hint composeText[
                parseText("<t color='#f00000ff' size='2'>" + (localize "STR_DOM_MISSIONSTRING_678") + "</t>"), lineBreak,
                parseText("<t size='1'>" + (localize "STR_DOM_MISSIONSTRING_679") + "</t>")
            ];
        };
    };
};

FUNC(ProgBarCall) = {
    scriptName "d_fnc_ProgBarCall";
    private ["_captime", "_wf", "_curcaptime", "_disp", "_control", "_backgroundControl", "_maxWidth", "_position", "_newval"];
    PARAMS_1(_wf);
    disableSerialization;
    _captime = _wf getVariable QGVAR(CAPTIME);
    _curcaptime = _wf getVariable QGVAR(CURCAPTIME);
    _curside = _wf getVariable QGVAR(SIDE);
    _disp = __uiGetVar(DPROGBAR);
    _control = _disp displayCtrl 3800;
    _backgroundControl = _disp displayCtrl 3600;
    _maxWidth = (ctrlPosition _backgroundControl select 2) - 0.01;
    _position = ctrlPosition _control;
    _newval = if (_curside != GVAR(own_side_trigger)) then {(_maxWidth * _curcaptime / _captime) max 0.02} else {_maxWidth};
    _position set [2, _newval];
    _r = 1 - (_newval * 2.777777);
    _g = _newval * 2.777777;
    _control ctrlSetPosition _position;
    //_control ctrlSetBackgroundColor (if !(_wf getVariable QGVAR(STALL)) then {[0.543, 0.5742, 0.4102, 0.8]} else {[1, 1, 0, 0.8]});
    _control ctrlSetBackgroundColor (if !(_wf getVariable QGVAR(STALL)) then {[_r, _g, 0, 0.8]} else {[1, 1, 0, 0.8]});
    _control ctrlCommit 3;
};

FUNC(ArtyShellTrail) = {
    scriptName "d_fnc_ArtyShellTrail";
    private ["_shpos", "_type", "_trails", "_ns", "_sh", "_trail"];
    PARAMS_2(_shpos,_type);
    if (_type != "") then {
        _trails = getText (configFile >> "CfgAmmo" >> _type >> "ARTY_TrailFX"); // TODO: No idea if the arty module still exists in A3
        _ns = getText (configFile >> "CfgAmmo" >> _type >> "ARTY_NetShell");
        _sh = _ns createVehicleLocal [_shpos select 0, _shpos select 1, 150];
        _sh setPosASL _shpos;
        _sh setVelocity [0,0,-150];
        _trail = [_sh] call compile preprocessFile _trails;
        waitUntil {isNull _sh};
        sleep 1;
        deleteVehicle _trail;
    };
};

FUNC(ParaExploitHandler) = {
    if (animationState player == "halofreefall_non" && {(_this select 4) isKindOf "TimeBombCore"}) then {
        deleteVehicle (_this select 6);
        player addMagazine (_this select 5);
    };
};

FUNC(LightObj) = {
    private "_light";
    _light = "#lightpoint" createVehicleLocal [0,0,0];
    _light setLightBrightness 1;
    _light setLightAmbient[0.2, 0.2, 0.2];
    _light setLightColor[0.01, 0.01, 0.01];
    _light lightAttachObject [_this, [0,0,0]];
};