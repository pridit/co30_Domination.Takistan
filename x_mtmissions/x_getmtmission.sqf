// by Xeno
#define THIS_FILE "x_getmtmission.sqf"
#include "x_setup.sqf"

#define __getPos \
_poss = [_target_array2 select 0, _target_array2 select 2] call FUNC(GetRanPointCircleBig);\
if (isOnRoad _poss) then {_poss = []};\
while {count _poss == 0} do {\
    _poss = [_target_array2 select 0, _target_array2 select 2] call FUNC(GetRanPointCircleBig);\
    if (isOnRoad _poss) then {_poss = []};\
    sleep 0.01;\
}

#define __specops \
__GetEGrp(_newgroup)\
_unit_array = [#specops, GVAR(enemy_side)] call FUNC(getunitliste);\
[_poss, _unit_array select 0, _newgroup,true] spawn FUNC(makemgroup);\
sleep 1.0112;\
_newgroup allowFleeing 0;\
_newgroup setVariable [QGVAR(defend), true]; \
[_newgroup, _poss] spawn FUNC(taskDefend); \
_newgroup setVariable [QGVAR(gstate), 1]; \
if (GVAR(doRespawnGroups)) then { \
    GVAR(reduce_groups) set [count GVAR(reduce_groups), _newgroup]; \
};


#define __vkilled(ktype) _vehicle addEventHandler [#killed, {_this set [count _this, #ktype]; _this call FUNC(MTSMTargetKilled)}]

private ["_man","_newgroup","_poss","_unit_array","_vehicle","_wp_array","_truck","_the_officer","_sec_kind","_fixor"];
if !(call FUNC(checkSHC)) exitWith {};

_fixor = {
    scriptName "spawn_x_getmtmission_fixor";
    private ["_unit", "_list","_curidx"];
    PARAMS_2(_unit,_curidx);
    while {true} do {
        if (!alive _unit || {isNull _unit}) exitWith {};
        sleep 0.01;
        _list = list GVAR(current_trigger);
        if (!isNil QGVAR(sum_camps)) then {
            if ((X_JIPH getVariable QGVAR(campscaptured)) == GVAR(sum_camps) && {("Car" countType _list <= GVAR(car_count_for_target_clear))} && {("Tank" countType _list <= GVAR(tank_count_for_target_clear))} && {("CAManBase" countType _list <= GVAR(man_count_for_target_clear))}) exitWith {};
        };
        
        sleep 3.219;
    };
    if (alive _unit) then {
        sleep 240 + random 60;
        if (alive _unit && _curidx == __XJIPGetVar(GVAR(current_target_index))) then {
            _unit setDamage 1;
            GVAR(side_main_done) = true;
            if (!isServer) then {
                [QGVAR(sSetVar), [QGVAR(side_main_done), true]] call FUNC(NetCallEventCTS);
            };
        } else {
            if (isNull _unit && {!GVAR(side_main_done)} && {_curidx == __XJIPGetVar(GVAR(current_target_index))}) then {
                GVAR(side_main_done) = true;
                if (!isServer) then {
                    [QGVAR(sSetVar), [QGVAR(side_main_done), true]] call FUNC(NetCallEventCTS);
                };
            };
        };
    } else {
        if (isNull _unit && {!GVAR(side_main_done)} && {_curidx == __XJIPGetVar(GVAR(current_target_index))}) then {
            GVAR(side_main_done) = true;
            if (!isServer) then {
                [QGVAR(sSetVar), [QGVAR(side_main_done), true]] call FUNC(NetCallEventCTS);
            };
        };
    };
};

_wp_array = _this;

sleep 3.120;
_xx_ran = (count _wp_array) call FUNC(RandomFloor);
_poss = _wp_array select _xx_ran;

_sec_kind = (floor (random 11)) + 1;

__TargetInfo

switch (_sec_kind) do {
    case 1: {
        __GetEGrp(_newgroup)
        _the_officer = switch (GVAR(enemy_side)) do {
            case "EAST": {"TK_Soldier_Officer_EP1"};
            case "WEST": {"US_Soldier_Officer_EP1"};
            case "GUER": {"TK_GUE_Warlord_EP1"};
        };
        _vehicle = _newgroup createUnit [_the_officer, _poss, [], 0, "FORM"];
        if (GVAR(without_nvg) == 0) then {
            if (_vehicle hasWeapon "NVGoggles") then {_vehicle removeWeapon "NVGoggles"};
        };
        _svec = sizeOf _the_officer;
        _isFlat = (position _vehicle) isFlatEmpty [_svec / 2, 150, 0.7, _svec, 0, false, _vehicle];
        if (count _isFlat > 1) then {
            _isFlat set [2,0];
            if (_poss distance _isFlat < 100) then {
                _poss = _isFlat;
            };
        };
        _vehicle setPos _poss;
        _vehicle setVariable ["BIS_noCoreConversations", true];
        _vehicle setRank "COLONEL";
        _vehicle setSkill 0.3;
        _vehicle disableAI "MOVE";
        [_vehicle, __XJIPGetVar(GVAR(current_target_index))] spawn _fixor;
        _iar = __XJIPGetVar(GVAR(searchintel));
        _sum = 0;
        {if (_x == 1) then {__INC(_sum)}} forEach _iar;
        if (_sum < count _iar) then {
            GVAR(intel_unit) = _vehicle;
            [QGVAR(searchbody), _vehicle] call FUNC(NetSetJIP);
            [QGVAR(s_b_client)] call FUNC(NetCallEventToClients);
        } else {
            if (!isNull __XJIPGetVar(GVAR(searchbody))) then {[QGVAR(searchbody), objNull] call FUNC(NetSetJIP)};
            __addDead(_vehicle)
        };
        sleep 0.1;
        __vkilled(gov_dead);
        sleep 1.0112;
        __specops;
    };
    case 2: {
        __getPos;
        _ctype = "Land_Fort_Watchtower_EP1";
        _vehicle = createVehicle [_ctype, _poss, [], 0, "NONE"];
        _svec = sizeOf _ctype;
        _isFlat = (position _vehicle) isFlatEmpty [_svec / 2, 150, 0.7, _svec, 0, false, _vehicle];
        if (count _isFlat > 1) then {
            _isFlat set [2,0];
            if (_poss distance _isFlat < 100) then {
                _poss = _isFlat;
            };
        };
        _vehicle setPos _poss;
        [_vehicle] execFSM "fsms\XRemoveVehiExtra.fsm";
        __vkilled(radar_down);
        [_vehicle, __XJIPGetVar(GVAR(current_target_index))] spawn _fixor;
        sleep 1.0112;
        __specops;
    };
    case 3: {
        __getPos;
        _truck = switch (GVAR(enemy_side)) do {
            case "EAST": {"UralReammo_TK_EP1"};
            case "WEST": {"MtvrReammo_DES_EP1"};
            case "GUER": {"V3S_Reammo_TK_GUE_EP1"};
        };
        _vehicle = createVehicle [_truck, _poss, [], 0, "NONE"];
        _svec = sizeOf _truck;
        _isFlat = (position _vehicle) isFlatEmpty [_svec / 2, 150, 0.7, _svec, 0, false, _vehicle];
        if (count _isFlat > 1) then {
            _isFlat set [2,0];
            if (_poss distance _isFlat < 100) then {
                _poss = _isFlat;
            };
        };
        _vehicle setDir (floor random 360);
        _vehicle setPos _poss;
        _vehicle lock true;
        _vehicle addEventHandler ["killed", {
            _this set [count _this, "ammo_down"];
            _this call FUNC(MTSMTargetKilled);
            _this call FUNC(handleDeadVec);
        }];
        [_vehicle, __XJIPGetVar(GVAR(current_target_index))] spawn _fixor;
        sleep 1.0112;
        __specops;
    };
    case 4: {
        _truck = switch (GVAR(enemy_side)) do {
            case "EAST": {"M113Ambul_TK_EP1"};
            case "WEST": {"HMMWV_Ambulance_DES_EP1"};
            case "GUER": {"M113Ambul_UN_EP1"};
        };
        _vehicle = createVehicle [_truck, _poss, [], 0, "NONE"];
        _svec = sizeOf _truck;
        _isFlat = (position _vehicle) isFlatEmpty [_svec / 2, 150, 0.7, _svec, 0, false, _vehicle];
        if (count _isFlat > 1) then {
            _isFlat set [2,0];
            if (_poss distance _isFlat < 100) then {
                _poss = _isFlat;
            };
        };
        _vehicle setDir (floor random 360);
        _vehicle setPos _poss;
        _vehicle lock true;
        _vehicle addEventHandler ["killed", {
            _this set [count _this, "apc_down"];
            _this call FUNC(MTSMTargetKilled);
            _this call FUNC(handleDeadVec);
        }];
        [_vehicle, __XJIPGetVar(GVAR(current_target_index))] spawn _fixor;
        sleep 1.0112;
        __specops;
    };
    case 5: {
        __getPos;
        _vehicle = createVehicle [GVAR(enemy_hq), _poss, [], 0, "NONE"];
        _svec = sizeOf GVAR(enemy_hq);
        _isFlat = (position _vehicle) isFlatEmpty [_svec / 2, 150, 0.7, _svec, 0, false, _vehicle];
        if (count _isFlat > 1) then {
            _isFlat set [2,0];
            if (_poss distance _isFlat < 100) then {
                _poss = _isFlat;
            };
        };
        _vehicle setDir (floor random 360);
        _vehicle setPos _poss;
        _vehicle lock true;
        [_vehicle] execFSM "fsms\XRemoveVehiExtra.fsm";
        __vkilled(hq_down);
        [_vehicle, __XJIPGetVar(GVAR(current_target_index))] spawn _fixor;
        sleep 1.0112;
        __specops;
    };
    case 6: {
        __getPos;
        _fact = switch (GVAR(enemy_side)) do {
            case "EAST": {"TK_WarfareBLightFactory_EP1"};
            case "WEST": {"US_WarfareBLightFactory_EP1"};
            case "GUER": {"TK_GUE_WarfareBLightFactory_EP1"};
        };
        _vehicle = createVehicle [_fact, _poss, [], 0, "NONE"];
        _svec = sizeOf _fact;
        _isFlat = (position _vehicle) isFlatEmpty [_svec / 2, 150, 0.7, _svec, 0, false, _vehicle];
        if (count _isFlat > 1) then {
            _isFlat set [2,0];
            if (_poss distance _isFlat < 100) then {
                _poss = _isFlat;
            };
        };
        _vehicle setDir (floor random 360);
        _vehicle setPos _poss;
        [_vehicle] execFSM "fsms\XRemoveVehiExtra.fsm";
        __vkilled(light_down);
        [_vehicle, __XJIPGetVar(GVAR(current_target_index))] spawn _fixor;
        sleep 1.0112;
        __specops;
    };
    case 7: {
        __getPos;
        _fact = switch (GVAR(enemy_side)) do {
            case "EAST": {"TK_WarfareBHeavyFactory_EP1"};
            case "WEST": {"US_WarfareBHeavyFactory_EP1"};
            case "GUER": {"TK_GUE_WarfareBHeavyFactory_EP1"};
        };
        _vehicle = createVehicle [_fact, _poss, [], 0, "NONE"];
        _svec = sizeOf _fact;
        _isFlat = (position _vehicle) isFlatEmpty [_svec / 2, 150, 0.7, _svec, 0, false, _vehicle];
        if (count _isFlat > 1) then {
            _isFlat set [2,0];
            if (_poss distance _isFlat < 100) then {
                _poss = _isFlat;
            };
        };
        _vehicle setDir (floor random 360);
        _vehicle setPos _poss;
        [_vehicle] execFSM "fsms\XRemoveVehiExtra.fsm";
        __vkilled(heavy_down);
        [_vehicle, __XJIPGetVar(GVAR(current_target_index))] spawn _fixor;
        sleep 1.0112;
        __GetEGrp(_newgroup)
        __specops;
    };
    case 8: {
        __getPos;
        _vehicle = createVehicle [GVAR(artillery_radar), _poss, [], 0, "NONE"];
        _svec = sizeOf GVAR(artillery_radar);
        _isFlat = (position _vehicle) isFlatEmpty [_svec / 2, 150, 0.7, _svec, 0, false, _vehicle];
        if (count _isFlat > 1) then {
            _isFlat set [2,0];
            if (_poss distance _isFlat < 100) then {
                _poss = _isFlat;
            };
        };
        _vehicle setDir (floor random 360);
        _vehicle setPos _poss;
        [_vehicle] execFSM "fsms\XRemoveVehiExtra.fsm";
        __vkilled(artrad_down);
        [_vehicle, __XJIPGetVar(GVAR(current_target_index))] spawn _fixor;
        sleep 1.0112;
        __specops;
    };
    case 9: {
        __getPos;
        _vehicle = createVehicle [GVAR(air_radar), _poss, [], 0, "NONE"];
        _svec = sizeOf GVAR(air_radar);
        _isFlat = (position _vehicle) isFlatEmpty [_svec / 2, 150, 0.7, _svec, 0, false, _vehicle];
        if (count _isFlat > 1) then {
            _isFlat set [2,0];
            if (_poss distance _isFlat < 100) then {
                _poss = _isFlat;
            };
        };
        _vehicle setDir (floor random 360);
        _vehicle setPos _poss;
        [_vehicle] execFSM "fsms\XRemoveVehiExtra.fsm";
        __vkilled(airrad_down);
        [_vehicle, __XJIPGetVar(GVAR(current_target_index))] spawn _fixor;
        sleep 1.0112;
        __specops;
    };
    case 10: {
        __GetEGrp(_newgroup)
        _ctype = "Dr_Hladik_EP1";
        _vehicle = _newgroup createUnit [_ctype, _poss, [], 0, "FORM"];
        if (GVAR(without_nvg) == 0) then {
            if (_vehicle hasWeapon "NVGoggles") then {_vehicle removeWeapon "NVGoggles"};
        };
        _svec = sizeOf _ctype;
        _isFlat = (position _vehicle) isFlatEmpty [_svec / 2, 150, 0.7, _svec, 0, false, _vehicle];
        if (count _isFlat > 1) then {
            _isFlat set [2,0];
            if (_poss distance _isFlat < 100) then {
                _poss = _isFlat;
            };
        };
        _vehicle setPos _poss;
        _vehicle setVariable ["BIS_noCoreConversations", true];
        _vehicle setRank "COLONEL";
        _vehicle setSkill 0.3;
        _vehicle disableAI "MOVE";
        [_vehicle, __XJIPGetVar(GVAR(current_target_index))] spawn _fixor;
        for "_i" from 1 to 4 do {_vehicle addMagazine "15Rnd_9x19_M9"};
        _vehicle addWeapon "M9";
        _iar = __XJIPGetVar(GVAR(searchintel));
        _sum = 0;
        {if (_x == 1) then {__INC(_sum)}} forEach _iar;
        if (_sum < count _iar) then {
            GVAR(intel_unit) = _vehicle;
            [QGVAR(searchbody), _vehicle] call FUNC(NetSetJIP);
            [QGVAR(s_b_client)] call FUNC(NetCallEventToClients);
        } else {
            if (!isNull __XJIPGetVar(GVAR(searchbody))) then {[QGVAR(searchbody), objNull] call FUNC(NetSetJIP)};
            __addDead(_vehicle)
        };
        sleep 0.1;
        __vkilled(lopo_dead);
        sleep 1.0112;
        __specops;
    };
    case 11: {
        __GetEGrp(_newgroup)
        _ctype = "TK_Aziz_EP1";
        _vehicle = _newgroup createUnit [_ctype, _poss, [], 0, "FORM"];
        if (GVAR(without_nvg) == 0) then {
            if (_vehicle hasWeapon "NVGoggles") then {_vehicle removeWeapon "NVGoggles"};
        };
        _svec = sizeOf _ctype;
        _isFlat = (position _vehicle) isFlatEmpty [_svec / 2, 150, 0.7, _svec, 0, false, _vehicle];
        if (count _isFlat > 1) then {
            _isFlat set [2,0];
            if (_poss distance _isFlat < 100) then {
                _poss = _isFlat;
            };
        };
        _vehicle setPos _poss;
        _vehicle setVariable ["BIS_noCoreConversations", true];
        _vehicle setRank "COLONEL";
        _vehicle setSkill 0.3;
        [_vehicle, __XJIPGetVar(GVAR(current_target_index))] spawn _fixor;
        _vehicle disableAI "MOVE";
        for "_i" from 1 to 4 do {_vehicle addMagazine "15Rnd_9x19_M9"};
        _vehicle addWeapon "M9";
        _iar = __XJIPGetVar(GVAR(searchintel));
        _sum = 0;
        {if (_x == 1) then {__INC(_sum)}} forEach _iar;
        if (_sum < count _iar) then {
            GVAR(intel_unit) = _vehicle;
            [QGVAR(searchbody), _vehicle] call FUNC(NetSetJIP);
            [QGVAR(s_b_client)] call FUNC(NetCallEventToClients);
        } else {
            if (!isNull __XJIPGetVar(GVAR(searchbody))) then {[QGVAR(searchbody), objNull] call FUNC(NetSetJIP)};
            __addDead(_vehicle)
        };
        sleep 0.1;
        __vkilled(dealer_dead);
        sleep 1.0112;
        __specops;
    };
};

["sec_kind",_sec_kind] call FUNC(NetSetJIP);
_s = "";
if (__XJIPGetVar(GVAR(current_target_index)) != -1) then {
    _s = (switch (_sec_kind) do {
        case 1: {
            format [(localize "STR_DOM_MISSIONSTRING_891"), _current_target_name]
        };
        case 2: {
#ifdef __CO__
            format [(localize "STR_DOM_MISSIONSTRING_892"), _current_target_name]
#endif
#ifdef __OA__
            format [(localize "STR_DOM_MISSIONSTRING_893"), _current_target_name]
#endif
        };
        case 3: {
            #ifndef __TT__
            format [(localize "STR_DOM_MISSIONSTRING_894"), _current_target_name]
            #else
            format [(localize "STR_DOM_MISSIONSTRING_895"), _current_target_name]
            #endif
        };
        case 4: {
            #ifndef __TT__
            format [(localize "STR_DOM_MISSIONSTRING_896"), _current_target_name]
            #else
            format [(localize "STR_DOM_MISSIONSTRING_897"), _current_target_name]
            #endif
        };
        case 5: {
            format [(localize "STR_DOM_MISSIONSTRING_898"), _current_target_name]
        };
        case 6: {
            format [(localize "STR_DOM_MISSIONSTRING_899"), _current_target_name]
        };
        case 7: {
            format [(localize "STR_DOM_MISSIONSTRING_900"), _current_target_name]
        };
        case 8: {
            format [(localize "STR_DOM_MISSIONSTRING_901"), _current_target_name]
        };
        case 9: {
            format [(localize "STR_DOM_MISSIONSTRING_902"), _current_target_name]
        };
        case 10: {
            format [(localize "STR_DOM_MISSIONSTRING_903"), _current_target_name]
        };
        case 11: {
            format [(localize "STR_DOM_MISSIONSTRING_904"), _current_target_name]
        };
    });
} else {
    _s = (localize "STR_DOM_MISSIONSTRING_905");
};
#ifndef __TT__
[QGVAR(kbmsg), [18, _s]] call FUNC(NetCallEventCTS);
#else
[QGVAR(kbmsg), [19, _s]] call FUNC(NetCallEventCTS);
#endif
