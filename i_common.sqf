setViewDistance GVAR(InitialViewDistance);

// this will remove setVehicleInits in BIS effects and should fix sky in fire bug
// probably breaks addons like WarFX, dunno, I'm not using it
if (GVAR(OverrideBISEffects) == 0) then {
    0 spawn {
        scriptName "spawn_OverrideBISEffects";
        sleep 0.4;
        waitUntil {!isNil "BIS_Effects_Secondaries"};
        sleep 0.5;
        GVAR(BISsecondaries) = [];
        __cppfln(BIS_Effects_EH_Killed,BIS_Effects\killed.sqf);
        __cppfln(BIS_Effects_AirDestruction,BIS_Effects\airdestruction.sqf);
        __cppfln(BIS_Effects_AirDestructionStage2,BIS_Effects\airdestructionstage2.sqf);
        __cppfln(BIS_Effects_Burn,BIS_Effects\burn.sqf);
        __cppfln(BIS_Effects_Secondaries,BIS_Effects\secondaries.sqf);
        // one script handles secondary explosions of all vehicles now instead of one script per vehicle
        execVM "BIS_Effects\secondaryloop.sqf";
        sleep 0.5;
        if (!isNil "JSRS_Distance_Killed") then {
            JSRS_Distance_Killed = {};
            //JSRS_Distance_Fired = {};
        };
    };
};

GVAR(number_targets_h) = GVAR(MainTargets);

if (GVAR(MainTargets) >= 50) then {
    _h = switch (GVAR(MainTargets)) do {
        case 50: {7};
        case 60: {5};
        case 70: {8};
        case 90: {21};
    };
    GVAR(MainTargets) = _h;
};

if (GVAR(GrasAtStart) == 0) then {setTerrainGrid 50};

if (isServer) then {skiptime GVAR(TimeOfDay)};

GVAR(doRespawnGroups) =
#ifdef __RESPAWN_GROUPS__
    true;
#else
    false;
#endif

// WEST, EAST or GUER for own side, setup in x_setup.sqf
GVAR(own_side) = "WEST";
GVAR(enemy_side) = "EAST";

// setup in x_setup.sqf
GVAR(version) = [];
#define __adddv(dtype) GVAR(version) set [count GVAR(version), #dtype]
__adddv(OA);
GVAR(COVer) = false;
if (GVAR(WithRevive) == 0) then {__adddv(REVIVE)};

GVAR(last_target_idx) = -1;
GVAR(target_names) = [];

for "_i" from 0 to 100000 do {
    _ar = [];
    _mname = format [QGVAR(target_%1), _i];
    _dtar = __getMNsVar2(_mname);
    if (isNil "_dtar") exitWith {
        GVAR(last_target_idx) = _i - 1;
    };
    _dtar enableSimulation false;

    _name = GV(_dtar,GVAR(cityname));
    if (!isNil "_name") then {
        _pos = getPosASL _dtar;
        _pos set [2, 0];
        _ar set [count _ar, _pos]; // position CityCenter by logic
        if (isServer) then {
            _dtar setDir 0;
        };
        _ar set [count _ar, _name]; // name village/city
        _radius = GV(_dtar,GVAR(cityradius));
        _ar set [count _ar, if (isNil "_radius") then {300} else {_radius}];
    } else {
        _nlocs = nearestLocations [getPosASL _dtar, ["NameCityCapital","NameCity","NameVillage"], 1000];
        if (count _nlocs > 0) then {
            _nl = nearestLocations [locationPosition (_nlocs select 0), ["CityCenter"], 1000];
            _pos = if (count _nl > 0) then {
                locationPosition (_nl select 0)
            } else {
                locationPosition (_nlocs select 0)
            };
            _pos set [2, 0];
            _ar set [count _ar, _pos]; // position CityCenter
            if (isServer) then {
                _dtar setDir 0;
                _dtar setPos _pos;
            };
            _name = text (_nlocs select 0);
            _ar set [count _ar, _name]; // name village/city
            _radius = GV(_dtar,GVAR(cityradius));
            _ar set [count _ar, if (isNil "_radius") then {300} else {_radius}];
            _dtar setVariable [QGVAR(cityname), _name];
        } else {
            hint ("No city found near target location " + _mname);
        };
    };
    __TRACE_1("All targets found","_ar")
    GVAR(target_names) set [count GVAR(target_names), _ar];
};

#ifdef __DEBUG__
// only for debugging, creates markers at all main target positions
// {
    // _pos = _x select 0;
    // _name = _x select 1;
    // _size = _x select 2;
    // _marker= createMarkerLocal [_name, _pos];
    // _marker setMarkerShapeLocal "ELLIPSE";
    // _name setMarkerColorLocal "ColorGreen";
    // _name setMarkerSizeLocal [_size,_size];
    // _name = _name + "xx";
    // _marker= createMarkerLocal [_name, _pos];
    // _marker setMarkerTypeLocal "mil_dot";
    // _name setMarkerColorLocal "ColorBlack";
    // _name setMarkerSizeLocal [0.5,0.5];
    // _name setMarkerTextLocal _name;
// } forEach GVAR(target_names);
#endif

GVAR(side_enemy) = east;
GVAR(side_player) = west;
GVAR(ai_enemy_sides) = [east];

GVAR(side_player_str) = "west";
GVAR(own_side_trigger) = "WEST";

GVAR(rep_truck_west) = "MtvrRepair_DES_EP1";
GVAR(rep_truck_east) = "UralRepair_TK_EP1";

GVAR(rep_truck) = if (GVAR(enemy_side) == "EAST") then {GVAR(rep_truck_west)} else {GVAR(rep_truck_east)};

GVAR(version_string) = "West";

//default flag GUER
#ifdef __OWN_SIDE_WEST__
GVAR(FLAG_BASE) setflagtexture (if !(GVAR(COVer)) then {"\ca\Ca_E\data\flag_us_co.paa"} else {"\ca\data\flag_usa_co.paa"});
#endif
#ifdef __OWN_SIDE_EAST__
switch (true) do {
    case (__OAVer): {GVAR(FLAG_BASE) setflagtexture "\ca\Ca_E\data\flag_tka_co.paa"};
    case (__COVer): {GVAR(FLAG_BASE) setflagtexture "\ca\data\flag_rus_co.paa"};
};
#endif

if (GVAR(with_mgnest)) then {
    GVAR(mg_nest) = "WarfareBMGNest_M240_US_EP1";
};

GVAR(sm_bonus_vehicle_array) = [
    "A10_US_EP1",
    "AH64D_EP1",
    "AH6J_EP1",
    "M1A1_US_DES_EP1",
    "M1A2_US_TUSK_MG_EP1",
    "M6_EP1",
    "UH60M_EP1",
    "UH1Y",
    "Mi24_D_TK_EP1",
    "Su25_TK_EP1",
    "L39_TK_EP1"
];

GVAR(mt_bonus_vehicle_array) = [
    "M1126_ICV_M2_EP1",
    "M1126_ICV_mk19_EP1",
    "M1128_MGS_EP1",
    "M1129_MC_EP1",
    "M1135_ATGMV_EP1",
    "M2A2_EP1",
    "M2A3_EP1",
    "HMMWV_M1151_M2_DES_EP1",
    "HMMWV_M1151_M2_DES_EP1",
    "HMMWV_M998_crows_M2_DES_EP1",
    "HMMWV_M998_crows_MK19_DES_EP1",
    "HMMWV_M998A2_SOV_DES_EP1",
    "HMMWV_MK19_DES_EP1",
    "HMMWV_TOW_DES_EP1",
    "HMMWV_M1151_M2_CZ_DES_EP1",
    "LandRover_Special_CZ_EP1"
];

// positions for aircraft factories (if one get's destroyed you're not able to service jets/service choppers/repair wrecks)
// first jet service, second chopper service, third wreck repair

#ifndef __TT__
_mpos = markerPos QGVAR(base_jet_fac);
_mpos set [2,0];
if (str(_mpos) != "[0,0,0]") then {
    _mpos2 = markerPos QGVAR(base_chopper_fac);
    _mpos2 set [2,0];
    _mpos3 = markerPos QGVAR(base_wreck_fac);
    _mpos3 set [2,0];
    GVAR(aircraft_facs) = [[_mpos, markerDir QGVAR(base_jet_fac)],[_mpos2, markerDir QGVAR(base_chopper_fac)],[_mpos3, markerDir QGVAR(base_wreck_fac)]];
} else {
    GVAR(aircraft_facs) = [];
};
#else
GVAR(aircraft_facs) = [];
#endif

GVAR(x_drop_array) =
#ifdef __OWN_SIDE_GUER__
    switch (true) do {
        case (__OAVer): {
            [[(localize "STR_DOM_MISSIONSTRING_18"), "D30_TK_GUE_EP1"], [(localize "STR_DOM_MISSIONSTRING_21"),"Pickup_PK_TK_GUE_EP1"], [(localize "STR_DOM_MISSIONSTRING_20"), "USBasicAmmunitionBox"]]
        };
        case (__COVer): {
            [[(localize "STR_DOM_MISSIONSTRING_18"), "M119"], [(localize "STR_DOM_MISSIONSTRING_19"),"HMMWV"], [(localize "STR_DOM_MISSIONSTRING_20"), "USBasicAmmunitionBox"]]
        };
    };
#endif
#ifdef __OWN_SIDE_WEST__
    switch (true) do {
        case (__OAVer): {
            [[(localize "STR_DOM_MISSIONSTRING_18"), "M119_US_EP1"], [(localize "STR_DOM_MISSIONSTRING_19"),"HMMWV_M1035_DES_EP1"], [(localize "STR_DOM_MISSIONSTRING_20"), "USBasicAmmunitionBox_EP1"]]
        };
        case (__COVer): {
            [[(localize "STR_DOM_MISSIONSTRING_18"), "M119"], [(localize "STR_DOM_MISSIONSTRING_19"),"HMMWV"], [(localize "STR_DOM_MISSIONSTRING_20"), "USBasicAmmunitionBox"]]
        };
    };
#endif
#ifdef __OWN_SIDE_EAST__
    switch (true) do {
        case (__OAVer): {
            [[(localize "STR_DOM_MISSIONSTRING_18"), "D30_TK_EP1"], [(localize "STR_DOM_MISSIONSTRING_22"),"UAZ_Unarmed_TK_EP1"], [(localize "STR_DOM_MISSIONSTRING_20"), "TKBasicAmmunitionBox_EP1"]]
        };
        case (__COVer): {
            [[(localize "STR_DOM_MISSIONSTRING_18"), "D30_RU"], [(localize "STR_DOM_MISSIONSTRING_22"),"UAZ_RU"], [(localize "STR_DOM_MISSIONSTRING_20"), "RUBasicAmmunitionBox"]]
        };
    };
#endif

// side of the pilot that will fly the drop air vehicle
GVAR(drop_side) = GVAR(own_side);

#ifndef __TT__
for "_i" from 0 to (count GVAR(sm_bonus_vehicle_array) - 1) do {
    GVAR(sm_bonus_vehicle_array) set [_i, toUpper(GVAR(sm_bonus_vehicle_array) select _i)];
};
for "_i" from 0 to (count GVAR(mt_bonus_vehicle_array) - 1) do {
    GVAR(mt_bonus_vehicle_array) set [_i, toUpper(GVAR(mt_bonus_vehicle_array) select _i)];
};
#else
for "_i" from 0 to (count (GVAR(sm_bonus_vehicle_array) select 0) - 1) do {
    (GVAR(sm_bonus_vehicle_array) select 0) set [_i, toUpper((GVAR(sm_bonus_vehicle_array) select 0) select _i)];
};
for "_i" from 0 to (count (GVAR(sm_bonus_vehicle_array) select 1) - 1) do {
    (GVAR(sm_bonus_vehicle_array) select 1) set [_i, toUpper((GVAR(sm_bonus_vehicle_array) select 1) select _i)];
};
for "_i" from 0 to (count (GVAR(mt_bonus_vehicle_array) select 0) - 1) do {
    (GVAR(mt_bonus_vehicle_array) select 0) set [_i, toUpper((GVAR(mt_bonus_vehicle_array) select 0) select _i)];
};
for "_i" from 0 to (count (GVAR(mt_bonus_vehicle_array) select 1) - 1) do {
    (GVAR(mt_bonus_vehicle_array) select 1) set [_i, toUpper((GVAR(mt_bonus_vehicle_array) select 1) select _i)];
};
#endif

// these vehicles can be lifted by the wreck lift chopper (previous chopper 4), but only, if they are completely destroyed
GVAR(heli_wreck_lift_types) = GVAR(sm_bonus_vehicle_array) + GVAR(mt_bonus_vehicle_array) + ["Su25_TK_EP1","L39_TK_EP1","Mi24_D_TK_EP1","Mi17_TK_EP1","UH1H_TK_EP1"];
{GVAR(heli_wreck_lift_types) set [_forEachIndex, toUpper _x]} forEach GVAR(heli_wreck_lift_types);

GVAR(lift_types_custom) = [
    "A10_US_EP1",
    "C130J_US_EP1",
    "Su25_TK_EP1",
    "L39_TK_EP1"
];

// internal
GVAR(next_jump_time) = -1;

// d_jumpflag_vec = empty ("") means normal jump flags for HALO jump get created
// if you add a vehicle typename to d_jumpflag_vec (d_jumpflag_vec = "UAZ"; for example) only a vehicle gets created and no HALO jump is available
GVAR(jumpflag_vec) = "";

// internal
GVAR(side_mission_winner) = 0;
GVAR(objectID1) = objNull;
GVAR(objectID2) = objNull;

if (isServer) then {
    MEDIC_TENT1 addEventHandler ["handleDamage", {0}];
    MEDIC_TENT2 addEventHandler ["handleDamage", {0}];
    WALL1 addEventHandler ["handleDamage", {0}];
    WALL2 addEventHandler ["handleDamage", {0}];
    WALL3 addEventHandler ["handleDamage", {0}];
};

GVAR(artillery) = [];
GVAR(engineers) = [];
GVAR(machine_gunners) = [];
GVAR(marksmen) = [];
GVAR(medics) = [];
GVAR(pilots) = [];

for "_i" from 1 to 2 do {
    GVAR(artillery) = GVAR(artillery) + ["ARTY" + str _i];
};

for "_i" from 1 to 8 do {
    GVAR(engineers) = GVAR(engineers) + ["ENGINEER" + str _i];
};

for "_i" from 1 to 8 do {
    GVAR(machine_gunners) = GVAR(machine_gunners) + ["MGUNNER" + str _i];
};

for "_i" from 1 to 8 do {
    GVAR(marksmen) = GVAR(marksmen) + ["MARKSMAN" + str _i];
};

for "_i" from 1 to 8 do {
    GVAR(medics) = GVAR(medics) + ["MEDIC" + str _i];
};

for "_i" from 1 to 6 do {
    GVAR(pilots) = GVAR(pilots) + ["PILOT" + str _i];
};

GVAR(player_entities) = GVAR(artillery) + GVAR(engineers) + GVAR(machine_gunners) + GVAR(marksmen) + GVAR(medics) + GVAR(pilots);

if (!isDedicated) then {
    GVAR(player_roles) = ["PLT LD","PLT SGT","SL","SN","MG","AT","GL","CM","AR","AM","TL","OP","GL","MG","MM","CM","GL","DS","SL","SN","AR","AT","RM","CM","MG","AT","EN","EN","EN","EN","EN","EN","SL","SN","AR","AT","RM","CM","MG","AT"];
};

// position base, a,b, for the enemy at base trigger and marker
#ifdef __DEFAULT__
_mpos = markerPos QGVAR(base_marker);
_mpos set [2,0];
_hasbasemarker = str(_mpos) != "[0,0,0]";
QGVAR(base_marker) setMarkerAlphaLocal 0;
_msize = markerSize QGVAR(base_marker);
GVAR(base_array) =[_mpos, _msize select 0, _msize select 1, markerDir QGVAR(base_marker)];
#endif

// position of radar and anti air at own base
#ifdef __DEFAULT__
_mpos = markerPos QGVAR(base_radar_pos);
_mpos set [2,0];
GVAR(base_radar_pos) = _mpos;
_mpos = markerPos QGVAR(base_anti_air1);
_mpos set [2,0];
GVAR(base_anti_air1) = _mpos;
_mpos = markerPos QGVAR(base_anti_air2);
_mpos set [2,0];
GVAR(base_anti_air2) = _mpos;
#endif

QGVAR(isledefense_marker) setMarkerAlphaLocal 0;

if (GVAR(sub_kill_points) != 0) then {
    GVAR(sub_kill_points) = GVAR(sub_kill_points) * -1;
};

GVAR(WarfareAircraftFactory_East) = "TK_WarfareBAircraftFactory_EP1";
GVAR(WarfareAircraftFactory_West) = "US_WarfareBAircraftFactory_EP1";
GVAR(WarfareAircraftFactory_Guer) = "TK_GUE_WarfareBAircraftFactory_EP1";

GVAR(illum_tower) = "Land_Ind_IlluminantTower";
GVAR(wcamp) = "Land_fortified_nest_big_EP1";

GVAR(ProtectionZone) = "ProtectionZone_Ep1";

GVAR(mash) = "MASH_EP1";

GVAR(dropped_box_marker) = "mil_marker";