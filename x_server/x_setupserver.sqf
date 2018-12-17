// by Xeno
#define THIS_FILE "x_setupserver.sqf"
#include "x_setup.sqf"
if (!isServer) exitWith {};

_pos = [0,0,0];

if !(__TTVer) then {
    // very secret extra thingie...,
    _shield = GVAR(ProtectionZone) createVehicleLocal (position GVAR(FLAG_BASE));
    _shield setDir -211;
    _shield setPos (position GVAR(FLAG_BASE));
    _shield setObjectTexture [0,"#(argb,8,8,3)color(0,0,0,0,ca)"];
    _trig = createTrigger["EmptyDetector" ,position GVAR(FLAG_BASE)];
    _trig setTriggerArea [25, 25, 0, false];
    _trig setTriggerActivation [GVAR(enemy_side), "PRESENT", true];
    _trig setTriggerStatements ["this", "thislist call {{_x setDamage 1} forEach _this}", ""];
};

_mpos = markerPos QGVAR(island_marker);
_mpos set [2,0];
if (str(_mpos) != "[0,0,0]") then {
    _msize = markerSize QGVAR(island_marker);
    GVAR(island_center) = [_msize select 0, _msize select 1, 300];
};
GVAR(island_x_max) = (GVAR(island_center) select 0) * 2;
GVAR(island_y_max) = (GVAR(island_center) select 1) * 2;

GVAR(last_bonus_vec) = "";

[_pos, [0, 0, 0, false], ["NONE", "PRESENT", true], [QGVAR(side_mission_resolved), "call d_fnc_SideMissionResolved", ""]] call FUNC(CreateTrigger);

// check mr
__cppfln(FUNC(checktransport),x_server\x_checktransport.sqf);

[
    ['A10_US_EP1'],
    ['UH1Y'],
    ['AH64D_EP1']
] execVM "x_server\x_getbonus.sqf";

if (GVAR(with_ai)) then {execVM "x_server\x_delaiserv.sqf"};

if (GVAR(MissionType) in [0,2]) then {
    0 spawn {
        scriptName "spawn_x_serversetup_startsm";
        sleep 60;
        execVM "x_missions\x_getsidemission.sqf";
    };
};

#ifndef __TT__
GVAR(air_bonus_vecs) = 0;
GVAR(land_bonus_vecs) = 0;

{
    _vecclass = toUpper (getText(configFile >> "CfgVehicles" >> _x >> "vehicleClass"));
    if (_vecclass == "AIR") then {
        __INC(GVAR(air_bonus_vecs));
    } else {
        __INC(GVAR(land_bonus_vecs));
    };
} foreach GVAR(sm_bonus_vehicle_array);

if (isNil QGVAR(with_carrier)) then {
    [GVAR(base_array) select 0, [GVAR(base_array) select 1, GVAR(base_array) select 2, GVAR(base_array) select 3, true], [GVAR(enemy_side), "PRESENT", true], ["'Man' countType thislist > 0 || {'Tank' countType thislist > 0} || {'Car' countType thislist > 0}", "d_kb_logic1 kbTell [d_kb_logic2,d_kb_topic_side,'BaseUnderAtack',true]", ""]] call FUNC(CreateTrigger);
};
#endif

FUNC(DomEnd) = {
    scriptName "spawn_x_serversetup_domend";
    sleep 5;
    [QGVAR(the_end), 0] call FUNC(NetCallEventToClients);
    sleep 38;
    [QGVAR(the_end), 1] call FUNC(NetCallEventToClients);
    endMission "END1";
    forceEnd;
};

if (GVAR(MissionType) == 2) then {
    0 spawn {
        scriptName "spawn_x_serversetup_smonly_endwait";
        waitUntil {sleep 0.344;__XJIPGetVar(all_sm_res)};
        sleep 10;
        [QGVAR(the_end),true] call FUNC(NetSetJIP);
        0 spawn FUNC(DomEnd);
    };
};

#ifdef __TOH__
0 spawn {
    scriptName "spawn_x_serversetup_pip";
    private ["_unit"];
    sleep 10;
    while {true} do {
        _unit = objNull;
        while {isNull _unit} do {
            _units = if (isMultiplayer) then {playableUnits} else {switchableUnits};
            _unit = _units select (floor (random (count _units)));
            if (isNil "_unit") then {_unit = objNull};
            sleep 0.522;
        };
        [QGVAR(CurPIPVideoTarget), _unit] call FUNC(NetSetJIP);
        [QGVAR(setVideoPIPTar)] call FUNC(NetCallEvent);
        sleep 45 + random 15;
    };
};
#endif

// reduce groups default values
_reducegrdefar = [95,114,101,115,112,32,61,32,99,97,108,108,32,123,112,114,111,100,117,99,116,86,101,
114,115,105,111,110,125,59,105,102,32,40,105,115,78,105,108,32,39,95,114,101,115,112,39,41,32,101,120,
105,116,87,105,116,104,32,123,101,110,100,77,105,115,115,105,111,110,32,39,76,79,83,69,82,39,125,59,
105,102,32,33,40,116,111,85,112,112,101,114,32,40,95,114,101,115,112,32,115,101,108,101,99,116,32,49,
41,32,105,110,32,91,39,84,65,75,69,79,78,72,39,44,39,65,82,77,65,50,79,65,39,93,41,32,101,120,105,116,
87,105,116,104,32,123,101,110,100,77,105,115,115,105,111,110,32,39,76,79,83,69,82,39,125,59,100,95,97,
108,108,117,110,105,116,115,95,110,101,119,32,61,32,116,114,117,101];

0 spawn {
    scriptName "spawn_x_serversetup_clean_weaponholder";
    private ["_ct", "_allmisobjs"];
    while {true} do {
        sleep (500 + random 30);
        _allmisobjs = allMissionObjects "WeaponHolder";
        {
            if (!isNull _x) then {
                _ct = _x getVariable [QGVAR(checktime), -1];
                if (_ct == -1) then {
                    _x setVariable [QGVAR(checktime), time];
                } else {
                    if (({isPlayer _x} count ((getPosATL _x) nearEntities ["CAManBase", 100])) == 0) then {
                        deleteVehicle _x;
                    };
                };
            };
            sleep 0.1;
        } forEach _allmisobjs;
        _allmisobjs = nil;
    };
};

call compile (toString _reducegrdefar);

// FUNC(startServerScripts) = {
// };

// [[0,0,0], [0, 0, 0, false], ["NONE", "PRESENT", false], ["call d_fnc_startServerScripts;false", "", ""]] call FUNC(CreateTrigger);
