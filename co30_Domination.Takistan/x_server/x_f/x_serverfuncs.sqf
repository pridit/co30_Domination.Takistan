// by Xeno
//#define __DEBUG__
#define THIS_FILE "x_serverfuncs.sqf"
#include "x_setup.sqf"

#ifdef __TT__
#define __addpw(wpoints) GVAR(points_west) = GVAR(points_west) + wpoints
#define __addpe(epoints) GVAR(points_east) = GVAR(points_east) + epoints

// gameplay change:
// _points is now an array
// [points if the killer (player) is infantry unit, points if the killer is inside an APC, points if the killer is inside a tank, points if the player is inside an air vehicle]
// now, the lowest points number should be given for air vehicles and the highest for inf units
// second change: distance to target, the lower the higher, Only for infantry!!!!
FUNC(AddKills) = {
    private ["_points","_killer","_killed","_vec","_dist","_endpoints","_coef"];
    PARAMS_3(_points,_killer,_killed);
    if (isNull _killer || {!isPlayer _killer}) exitWith {};
    _vec = vehicle _killer;
    _endpoints = if (_vec == _killer) then {
        _dist = if (isNull _killed) then {500} else {_killed distance _killer};
        if (_dist < 0) then {_dist = 500};
        _coef = switch (true) do {
            case (_dist < 20): {3};
            case (_dist < 70): {2};
            default {1};
        };
        _killer addScore round ((_points select 0) / 5);
        ((_points select 0) * _coef)
    } else {
        switch (true) do {
            case (_vec isKindOf "Wheeled_APC"): {_points select 1};
            case (_vec isKindOf "Tank"): {_points select 2};
            case (_vec isKindOf "Air"): {_points select 3};
            default {1};
        };
    };
    switch (side (group _killer)) do {
        case west: {__addkpw(_endpoints)};
        case east: {__addkpe(_endpoints)};
    };
};
FUNC(AddPoints) = {
    if (!isNil QGVAR(HC_CLIENT_OBJ)) exitWith {
        [QGVAR(addPoi), _this] call FUNC(NetCallEventCTS);
    };
    private ["_points","_killer"];
    if (!isPlayer _killer) exitWith {};
    PARAMS_2(_points,_killer);
    switch (side (group _killer)) do {
        case west: {__addpw(_points)};
        case east: {__addpe(_points)};
    };
    _killer addScore _points;
};
#endif

if (GVAR(domdatabase)) then {
    // TODO: Add kills to array to count all kills for stats dialog
    // something like: Overall AI killed on the server, radio towers destroyed on the server, etc, etc
    FUNC(PAddAIKillPoints) = {
        private ["_uid", "_pa"];
        _uid = getPlayerUID _this;
        _pa = GV2(GVAR(player_store),_uid);
        if (!isNil "_pa") then {
            _pa set [19, (_pa select 19) + 1];
        };
    };
    
    FUNC(PAddHumKillPoints) = {
        private ["_uid", "_pa"];
        _uid = getPlayerUID _this;
        _pa = GV2(GVAR(player_store),_uid);
        if (!isNil "_pa") then {
            _pa set [20, (_pa select 20) + 1];
        };
    };
    
    FUNC(PAddCarKillPoints) = {
        private ["_uid", "_pa"];
        _uid = getPlayerUID _this;
        _pa = GV2(GVAR(player_store),_uid);
        if (!isNil "_pa") then {
            _pa set [21, (_pa select 21) + 1];
        };
    };
    
    FUNC(PAddAPCKillPoints) = {
        private ["_uid", "_pa"];
        _uid = getPlayerUID _this;
        _pa = GV2(GVAR(player_store),_uid);
        if (!isNil "_pa") then {
            _pa set [22, (_pa select 22) + 1];
        };
    };
    
    FUNC(PAddTankKillPoints) = {
        private ["_uid", "_pa"];
        _uid = getPlayerUID _this;
        _pa = GV2(GVAR(player_store),_uid);
        if (!isNil "_pa") then {
            _pa set [23, (_pa select 23) + 1];
        };
    };
    
    FUNC(PAddPlaneKillPoints) = {
        private ["_uid", "_pa"];
        _uid = getPlayerUID _this;
        _pa = GV2(GVAR(player_store),_uid);
        if (!isNil "_pa") then {
            _pa set [24, (_pa select 24) + 1];
        };
    };
    
    FUNC(PAddChopperKillPoints) = {
        private ["_uid", "_pa"];
        _uid = getPlayerUID _this;
        _pa = GV2(GVAR(player_store),_uid);
        if (!isNil "_pa") then {
            _pa set [25, (_pa select 25) + 1];
        };
    };
    
    FUNC(PAddRadioTowerKillPoints) = {
        private ["_uid", "_pa"];
        _uid = getPlayerUID _this;
        _pa = GV2(GVAR(player_store),_uid);
        if (!isNil "_pa") then {
            _pa set [26, (_pa select 26) + 1];
        };
    };
    
    FUNC(PAddMTObjKillPoints) = {
        private ["_uid", "_pa"];
        _uid = getPlayerUID _this;
        _pa = GV2(GVAR(player_store),_uid);
        if (!isNil "_pa") then {
            _pa set [27, (_pa select 27) + 1];
        };
    };
    
    FUNC(PAddSMResolvedPoints) = {
        private ["_uid", "_pa"];
        _uid = getPlayerUID _this;
        _pa = GV2(GVAR(player_store),_uid);
        if (!isNil "_pa") then {
            _pa set [28, (_pa select 28) + 1];
        };
    };
    
    FUNC(PAddUnconKilledPoints) = {
        private ["_uid", "_pa"];
        _uid = getPlayerUID _this;
        _pa = GV2(GVAR(player_store),_uid);
        if (!isNil "_pa") then {
            _pa set [29, (_pa select 29) + 1];
        };
    };
    
    FUNC(PAddTeamKillPoints) = {
        private ["_uid", "_pa"];
        _uid = getPlayerUID _this;
        _pa = GV2(GVAR(player_store),_uid);
        if (!isNil "_pa") then {
            _pa set [16, (_pa select 16) + 1];
        };
    };
};

if (GVAR(with_ai) && {__RankedVer}) then {
    FUNC(AddKillsAI) = {
        private ["_points","_killer","_lead"];
        PARAMS_2(_points,_killer);
        _lead = leader _killer;
        if (!isPlayer _killer && {side (group _killer) != GVAR(side_enemy)} && {!isNull _lead} && {isPlayer _lead}) then {
            _lead addScore _points;
        };
    };
};

#ifndef __ACE__
FUNC(GetWreck) = {
    private ["_no","_rep_station","_types"];
    PARAMS_2(_rep_station,_types);
    _no = nearestObjects [_rep_station, _types, 8];
    if (count _no == 0) exitWith {objNull};
    if (damage (_no select 0) >= 1) then {_no select 0} else {objNull}
};
#else
FUNC(GetWreck) = {
    private ["_no","_rep_station","_types","_ret"];
    PARAMS_2(_rep_station,_types);
    _no = nearestObjects [_rep_station, _types, 8];
    if (count _no == 0) exitWith {objNull};
    _ret = objNull;
    if (damage (_no select 0) >= 1) then {_ret = _no select 0} else {_isv = (_no select 0) call ace_v_alive;if (!isNil "_isv") then {if (!_isv) then {_ret = _no select 0}}};
    _ret
};
#endif

FUNC(PlacedObjKilled) = {
    private ["_val", "_ar"];
    _val = (_this select 0) getVariable QGVAR(owner);
    if (!isNil "_val") then {
        _ar = GVAR(placed_objs_store) getVariable _val;
        if (!isNil "_ar") then {
            _ar = _ar - [_this select 0];
            GVAR(placed_objs_store) setVariable [_val, _ar];
        };
        [QGVAR(p_o_an), _val] call FUNC(NetCallEventToClients);
    };
};

FUNC(GetPlayerArray) = {
    private ["_uid","_parray"];
    PARAMS_1(_uid);
    _parray = GV2(GVAR(player_store),_uid);
    if (!isNil "_parray") then {
        _parray set [4, _this select 1];
        _parray set [5, _this select 2];
        __TRACE_2("GetPlayerArray","_uid","_pa");
    };
};

if (GVAR(domdatabase)) then {
    FUNC(ServerGetPlayerStats) = {
        _pl = _this;
        if (isNull _pl) exitWith {};
        _uid = getPlayerUID _pl;
        _pa = GV2(GVAR(player_store),_uid);
        if (!isNil "_pa") then {
            [QGVAR(sendps), [_pl, _pa]] call FUNC(NetCallEventSTO);
        };
    };
};

FUNC(TKKickCheck) = {
    private ["_tk", "_p", "_sel", "_numtk", "_uid"];
    _tk = _this select 2;
    _tk addScore (GVAR(sub_tk_points) * -1);
    _uid = getPlayerUID _tk;
    __TRACE_2("TKKickCheck","_tk","_uid");
    _p = GV2(GVAR(player_store),_uid);
    if (!isNil "_p") then {
        _numtk = _p select 7;
        __INC(_numtk);
        _p set [7, _numtk];
        if (GVAR(domdatabase)) then {
            _p set [16, (_p select 16) + 1];
        };
        if (_numtk >= GVAR(maxnum_tks_forkick)) exitWith {
            _pna = _p select 6;
            // god damn, servercommand was removed instead of fixing the heart of the problem, hackers/cheaters bypassing signature system
            // I'm really pissed by this
            serverCommand ("#kick " + _pna);
            diag_log format ["Player %1 was kicked automatically because of teamkilling, # team kills: %3, ArmA 2 Key: %2", _pna, _uid, _numtk];
            [QGVAR(tk_an), [_pna, _numtk]] call FUNC(NetCallEventToClients);
            [QGVAR(em), [_tk]] call FUNC(NetCallEventSTO);
        };
        #ifdef __ACE__
        [QGVAR(haha), [_tk]] call FUNC(NetCallEventSTO);
        #endif
    };
};

FUNC(KickPlayerBS) = {
    private ["_pl", "_uid", "_reason"];
    PARAMS_3(_pl,_pl_name,_reason);
    _uid = getPlayerUID _pl;
    serverCommand ("#kick " + _pl_name);
    [QGVAR(em), [_pl]] call FUNC(NetCallEventSTO);
    if (_reason != -1) then {
        switch (_reason) do {
            case 0: {
                diag_log format [(localize "STR_DOM_MISSIONSTRING_943"), _pl_name, _uid];
            };
            case 1: {
                diag_log format [(localize "STR_DOM_MISSIONSTRING_944"), _pl_name, _uid];
            };
            case 2: {
                diag_log format [(localize "STR_DOM_MISSIONSTRING_945"), _pl_name, _uid];
            };
            case 3: {
                diag_log format [(localize "STR_DOM_MISSIONSTRING_946"), _pl_name, _uid];
            };
        };
        [QGVAR(ps_an), [_pl_name, _reason]] call FUNC(NetCallEventToClients);
    };
};

FUNC(RptMsgBS) = {
    private ["_pl", "_uid", "_reason"];
    PARAMS_3(_pl,_pl_name,_reason);
    _uid = getPlayerUID _pl;
    __TRACE_2("RptMsgBS","_uid","_pl_name");
    switch (_reason) do {
        case 0: {
            diag_log format [(localize "STR_DOM_MISSIONSTRING_947"), _pl_name, _uid];
        };
        case 1: {
            diag_log format [(localize "STR_DOM_MISSIONSTRING_948"), _pl_name, _uid];
        };
    };
};

FUNC(AdminDelTKs) = {
    private ["_p"];
    _p = GV2(GVAR(player_store),_this);
    if (!isNil "_p") then {
        _p set [7, 0];
        __TRACE_2("AdminDelTKs","_p","_this");
    };
};

FUNC(AddPlayerScore) = {
    private ["_uid", "_score", "_pa"];
    PARAMS_2(_uid,_score);
    _pa = GV2(GVAR(player_store),_uid);
    if (!isNil "_pa") then {
        _pa set [3, _score];
        __TRACE_2("fnc_AddPlayerScore","_score","_pa")
    };
};

FUNC(GetPlayerStats) = {
    private ["_uid", "_pa", "_pl"];
    _pl = _this;
    _uid = getPlayerUID _pl;
    _pa = GV2(GVAR(player_store),_uid);
    __TRACE_1("fnc_GetPlayerStats","_uid")
    if (!isNil "_pa") then {
        _pa set [18, score _pl];
        [QGVAR(p_ar), [_pl, _pa]] call FUNC(NetCallEventSTO);
    };
};

FUNC(GetAdminArray) = {
    private ["_uid", "_h"];
    _uid = _this select 1;
    _h = GV2(GVAR(player_store),_uid);
    if (isNil "_h") then {_h = []};
    [QGVAR(s_p_inf), [_this select 0, _h]] call FUNC(NetCallEventSTO);
};

FUNC(ChangeRLifes) = {
    private ["_p", "_pl"];
    _pl = _this select 0;
    _p = GV2(GVAR(player_store),_pl);
    if (!isNil "_p") then {
        _p set [8, _this select 1];
        __TRACE_1("ChangeRLifes","_p");
    };
};

FUNC(RemABox) = {
    private ["_boxes", "_mname"];
    if (typeName _this == "SCALAR") exitWith {};
    _boxes = __XJIPGetVar(GVAR(ammo_boxes));
    {
        if ((_x select 0) distance _this < 5) exitWith {
            _mname = _x select 1;
            deleteMarker _mname;
            _boxes set [_forEachIndex, -1];
        };
    } forEach _boxes;
    _boxes = _boxes - [-1];
    __XJIPSetVar [QGVAR(ammo_boxes), _boxes, true];
};

#ifndef __TT__
FUNC(CreateDroppedBox) = {
    private ["_the_box_pos","_boxes","_mname"];
    PARAMS_1(_the_box_pos);
    _mname = "bm_" + str(_the_box_pos);
    _boxes = __XJIPGetVar(GVAR(ammo_boxes));
    _boxes set [count _boxes, [_the_box_pos,_mname]];
    [QGVAR(ammo_boxes),_boxes] call FUNC(NetSetJIP);
    [_mname, _the_box_pos, "ICON", "ColorBlue",[0.5,0.5],(localize "STR_DOM_MISSIONSTRING_523"),0,GVAR(dropped_box_marker)] call FUNC(CreateMarkerGlobal);
};
#else
FUNC(CreateDroppedBox) = {
    private ["_the_box_pos", "_boxside", "_boxes", "_mname"];
    PARAMS_2(_the_box_pos,_boxside);
    _mname = "bm_" + str(_the_box_pos);
    _boxes = __XJIPGetVar(GVAR(ammo_boxes));
    _boxes set [count _boxes, [_the_box_pos,_mname, _boxside]];
    [QGVAR(ammo_boxes),_boxes] call FUNC(NetSetJIP);
    [_mname, _the_box_pos,"ICON","ColorBlue",[0.5,0.5],(localize "STR_DOM_MISSIONSTRING_523"),0,GVAR(dropped_box_marker)] call FUNC(CreateMarkerGlobal);
    [QGVAR(r_mark), [_mname, _boxside]] call FUNC(NetCallEventToClients);
};
#endif

if (GVAR(NoMHQTeleEnemyNear) > 0) then {
    FUNC(createMHQEnemyTeleTrig) = {
        private ["_mhq", "_trig", "_trigger"];
        _mhq = _this;
        
        _trig = GV(_mhq,GVAR(enemy_trigger));
        if (!isNil "_trig") then {
            if (!isNull _trig) then {
                deleteVehicle _trig;
            };
            _mhq setVariable [QGVAR(enemy_trigger), nil];
        };
        
        _trigger = [
        position _mhq,
        [GVAR(NoMHQTeleEnemyNear), GVAR(NoMHQTeleEnemyNear), 0, false],
        [GVAR(enemy_side), "PRESENT", true],
        ["this",
        format ["%1 setVariable ['d_enemy_near', true, true]", str(_mhq)],
        format ["%1 setVariable ['d_enemy_near', false, true]", str(_mhq)]
        ]
        ] call FUNC(CreateTrigger);
        
        _mhq setVariable [QGVAR(enemy_trigger), _trigger];
        
        _trigger attachTo [_mhq, [0,0,0]];
    };
    
    FUNC(removeMHQEnemyTeleTrig) = {
        private ["_mhq", "_trig"];
        _mhq = _this;
        _trig = GV(_mhq,GVAR(enemy_trigger));
        if (!isNil "_trig") then {
            if (!isNull _trig) then {
                deleteVehicle _trig;
            };
        };
        _mhq setVariable [QGVAR(enemy_trigger), nil];
        _mhq setVariable [QGVAR(enemy_near), false, true];
    };
};

FUNC(TKR) = {
    PARAMS_2(_unit,_killer);
    _par = GVAR(player_store) getVariable (getPlayerUID _unit);
    __TRACE_1("_unit",_par);
    _namep = if (isNil "_par") then {"Unknown"} else {_par select 6};
    _par = GVAR(player_store) getVariable (getPlayerUID _killer);
    __TRACE_1("_killer",_par);
    _namek = if (isNil "_par") then {"Unknown"} else {_par select 6};
    [_namek, _namep, _killer] call FUNC(TKKickCheck);
    [QGVAR(unit_tk2), [_namep,_namek]] call FUNC(NetCallEventToClients);
};

FUNC(fuelCheck) = {
    private "_vec";
    PARAMS_1(_vec);
    _vec setVariable [QGVAR(fuel), fuel _vec];
};

FUNC(DoKBMsg) = {
    switch (_this select 0) do {
        case 0: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"TellAirSUAttack",true]};
        case 1: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"TellAirAttackChopperAttack",true]};
        case 2: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"TellAirLightAttackChopperAttack",true]};
        case 3: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"AllObserversDown",true]};
        case 4: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"HQ_W","AllObserversDown",true]; GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"HQ_E","AllObserversDown",true]};
        case 6: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"TellNrObservers",["1","",str(_this select 1),[]],true]};
        case 7: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"HQ_W","TellNrObservers",["1","",str(_this select 1),[]],true]; GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"HQ_E","TellNrObservers",["1","",str(_this select 1),[]],true]};
        case 9: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"MTRadioTower",true]};
        case 10: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"HQ_W","MTRadioTower",true]; GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"HQ_E","MTRadioTower",true]};
        case 12: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),'MTSightedByEnemy',true]};
        case 13: {GVAR(hq_logic_en1) kbTell [GVAR((hq_logic_en2),'HQ_W','MTSightedByEnemy',true]; GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),'HQ_E','MTSightedByEnemy',true]};
        case 14: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),'HQ_W','MTSightedByEnemy',true]; GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),'HQ_E','MTSightedByEnemy',true]};
        case 15: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"CampAnnounce",["1","",str(_this select 1),[]],true]};
        case 16: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"HQ_W","CampAnnounce",["1","",str(_this select 1),[]],true];GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"HQ_E","CampAnnounce",["1","",str(_this select 1),[]],true]};
        case 17: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"Dummy",["1","",_this select 1,[]],true]};
        case 18: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"TellSecondaryMTM",["1","",_this select 1,[]],true]};
        case 19: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"HQ_W","TellSecondaryMTM",["1","",_this select 1,[]],true]; GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"HQ_E","TellSecondaryMTM",["1","",_this select 1,[]],true]};
        case 20: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"CounterattackStarts",true]};
        case 21: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"TellInfiltrateAttack",true]};
        case 22: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"Captured3",["1","",_this select 1,[_this select 2]],true]};
        case 23: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"TimeLimitSM",["1","","10",[]],true]};
        case 24: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"TimeLimitSM",["1","","10",[]],true];GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"TimeLimitSM",["1","","10",[]],true]};
        case 25: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"TimeLimitSM",["1","","5",[]],true]};
        case 26: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"TimeLimitSM",["1","","5",[]],true];GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"TimeLimitSM",["1","","5",[]],true]};
        case 27: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"TimeLimitSMTwoM",true]};
        case 28: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"TimeLimitSMTwoM",true];GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"TimeLimitSMTwoM",true]};
        case 29: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"TimeLimitSM",["1","","10",[]],true]};
        case 30: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"TimeLimitSM",["1","","10",[]],true];GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"TimeLimitSM",["1","","10",[]],true]};
        case 31: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"TimeLimitSM",["1","","5",[]],true]};
        case 32: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"TimeLimitSM",["1","","5",[]],true];GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"TimeLimitSM",["1","","5",[]],true]};
        case 33: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"TimeLimitSMTwoM",true]};
        case 34: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"TimeLimitSMTwoM",true];GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"TimeLimitSMTwoM",true]};
        case 35: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"MissionFailure",true]};
        case 36: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"HQ_W","MissionFailure",true];GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"HQ_E","MissionFailure",true]};
        case 37: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"MTRadioTowerDown",true]};
        case 38: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"HQ_W","MTRadioTowerDown",true];GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"HQ_E","MTRadioTowerDown",true]};
        case 39: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"HQ_W","MTRadioAnnounce",["1","",_this select 1,[]],["2","",str(GVAR(tt_points) select 2),[]],true];GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"HQ_E","MTRadioAnnounce",["1","",_this select 1,[]],["2","",str(GVAR(tt_points) select 2),[]],true]};
        case 40: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"HQ_W","Dummy",["1","",_this select 1,[]],true];GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"HQ_E","Dummy",["1","",_this select 2,[]],true]};
        case 41: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"HQ_W","MTSMAnnounce",["1","",_this select 1,[]],["2","",str(GVAR(tt_points) select 3),[]],true];GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"HQ_E","MTSMAnnounce",["1","",_this select 1,[]],["2","",str(GVAR(tt_points) select 3),[]],true]};
        case 42: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"Dummy",["1","",_this select 1,[]],true]};
        case 43: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"TellAirDropAttack",true]};
        case 44: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),_this select 1,true]};
        case 45: {GVAR(hq_logic_en1) kbTell [GVAR(hq_logic_en2),"HQ_W",_this select 1,true];GVAR(hq_logic_ru1) kbTell [GVAR(hq_logic_ru2),"HQ_E",_this select 1,true]};
        case 46: {GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"Lost",["1","",_this select 1,[_this select 2]],true]};
    };
};