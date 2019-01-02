// init include client
private ["_standard_weap","_silenced","_glweaps","_basic","_machineg","_sniper","_atweap","_elem","_i","_armor","_car"];

// GVAR(reserved_slot) gives you the ability to add a reserved slot for admins
// if you don't log in when you've chosen the slot, you'll get kicked after ~20 once the intro ended
// default is no check, example: GVAR(reserved_slot) = "RESCUE";
GVAR(reserved_slot) = "";

// GVAR(uid_reserved_slots) and GVAR(uids_for_reserved_slots) gives you the possibility to limit a slot
// you have to add the var names of the units to GVAR(uid_reserved_slots) and in GVAR(uids_for_reserved_slots) the UIDs of valid players
// GVAR(uid_reserved_slots) = ["alpha_1", "bravo_3"];
// GVAR(uids_for_reserved_slots) = ["1234567", "7654321"];
GVAR(uid_reserved_slots) = [];
GVAR(uids_for_reserved_slots) = [];

// marker type used for players
GVAR(p_marker) = (getArray (missionConfigFile >> "Params" >> QGVAR(MarkerTypeL) >> "texts")) select GVAR(MarkerTypeL);

// position of the player ammobox at base (created only on the players computer, refilled every 20 minutes)
_mpos = markerPos QGVAR(player_ammobox_pos);
_mpos set [2,0];
GVAR(player_ammobox_pos) = [_mpos, markerDir QGVAR(player_ammobox_pos)];

// position of the backpack heap
_bpos = markerPos QGVAR(player_backpacks_pos);
_bpos set [2,0];
GVAR(player_backpacks_pos) = [_bpos, markerDir QGVAR(player_backpacks_pos)];

// this vehicle will be created if you use the "Create XXX" at a mobile respawn (old "Create Motorcycle") or at a jump flag
// IMPORTANT !!!! for ranked version !!!!
// if there is more than one vehicle defined in the array the vehicle will be selected by player rank
// one vehicle only, vehicle is only available when the player is at least lieutenant
GVAR(create_bike) =
#ifdef __OWN_SIDE_GUER__
["M1030"];
#endif
#ifdef __OWN_SIDE_WEST__
switch (true) do {
    case (__OAVer): {
        ["ATV_US_EP1","M1030_US_DES_EP1"]
    };
    case (__COVer): {
        ["MMT_USMC","M1030"]
    };
};
#endif
#ifdef __OWN_SIDE_EAST__
switch (true) do {
    case (__OAVer): {
        ["TT650_TK_EP1","Old_bike_TK_INS_EP1"]
    };
    case (__COVer): {
        ["MMT_Civ","TT650_Civ"]
    };
};
#endif

// if the array is empty, anybody can fly,
// just add the string name (var name in the editor) of the playable units that can fly, for example:
// for example: ["pilot_1","pilot_2"];, case sensitiv
// this includes bonus aircrafts too
GVAR(only_pilots_can_fly) = [];

GVAR(current_mission_text) = "";
GVAR(current_mission_resolved_text) = "";

// time player has to wait until he can drop the next ammobox (old ammobox handling)
// in the new ammobox handling (default, loading and dropping boxes) it means the time dif in seconds before a box can be loaded or dropped again in a vehicle
GVAR(drop_ammobox_time) = 60;
GVAR(current_truck_cargo_array) = 0;
// GVAR(check_ammo_load_vecs)
// the only vehicles that can load an ammo box are the transport choppers and MHQs__
#ifdef __OWN_SIDE_WEST__
GVAR(check_ammo_load_vecs) = switch (true) do {
    case (__OAVer): {["M1133_MEV_EP1","UH60M_EP1","UH1H_TK_GUE_EP1","BMP2_HQ_TK_EP1","Mi17_TK_EP1"]};
    case (__COVer): {["LAV25_HQ","MH60S"]};
};
#endif
#ifdef __OWN_SIDE_EAST__
GVAR(check_ammo_load_vecs) = switch (true) do {
    case (__OAVer): {["BMP2_HQ_TK_EP1","Mi17_TK_EP1"]};
    case (__COVer): {["BTR90_HQ","Mi17_Ins"]};
};
#endif

GVAR(weapon_respawn) = true;

// points needed to get a specific rank
// gets even used in the unranked versions, though it's just cosmetic there
GVAR(points_needed) = [
    20, // Corporal
    50, // Sergeant
    80, // Lieutenant
    130, // Captain
    180, // Major
    250 // Colonel
];

GVAR(graslayer_index) = if (GVAR(GrasAtStart) == 1) then {0} else {1};

GVAR(custom_layout) = [];

GVAR(disable_viewdistance) = (GVAR(ViewdistanceChange) == 1);

if (GVAR(LimitedWeapons)) then {
_standard_weap = ["M16A2","M4A1","G36A_camo","G36C_camo","G36K_camo","LeeEnfield","M14_EP1","AKS_74_kobra","AK_47_M","AK_47_S","AK_74","AKS_74","AKS_74_kobra","AKS_74_U","FN_FAL","Sa58P_EP1","Sa58V_EP1","SCAR_L_CQC","SCAR_L_CQC_Holo","SCAR_L_STD_HOLO"];
_silenced = ["SCAR_H_CQC_CCO_SD","SCAR_H_STD_TWS_SD"];
_glweaps = ["AK_74_GL","AK_74_GL_kobra","M16A2GL","M4A3_RCO_GL_EP1","SCAR_H_STD_EGLM_Spect","SCAR_L_CQC_EGLM_Holo","SCAR_L_STD_EGLM_RCO","SCAR_L_STD_EGLM_TWS","M32_EP1","M79_EP1","Mk13_EP1"];
_basic = ["M16A2","M4A1","AK_47_M","AK_47_S","AK_74","M14_EP1","LeeEnfield","AKS_74","FN_FAL","Sa58P_EP1","Sa58V_EP1"];
_machineg = ["m240_scoped_EP1","M249_EP1","M249_m145_EP1","M249_TWS_EP1","M60A4_EP1","MG36_camo","Mk_48_DES_EP1","PK","RPK_74"];
_sniper = ["KSVK","M107","M107 TWS","M110_NVG_EP1","M110_TWS_EP1","M24_des_EP1","SCAR_H_LNG_Sniper","SCAR_H_LNG_Sniper_SD","SVD","SVD_des_EP1","SVD_NSPU_EP1"];
_atweap = ["Javelin","M136","M47Launcher_EP1","MAAWS","MetisLauncher","RPG18","RPG7V"];
GVAR(limited_weapons_ar) = [
    [["delta_1","delta_2","delta_3","delta_4","delta_5","delta_6"], _standard_weap],
    [["RESCUE","RESCUE2"], _standard_weap],
    [["bravo_1","alpha_1","charlie_1","echo_1"], _standard_weap + _silenced],
    [["alpha_5","bravo_3","bravo_7"], _standard_weap + _glweaps],
    [["alpha_3","alpha_7","charlie_7","charlie_3","bravo_4"], _basic + _machineg],
    [["alpha_2","bravo_5","charlie_2"], _basic + _sniper],
    [["alpha_6","bravo_6","charlie_6"], _basic],
    [["alpha_4","alpha_8","charlie_4","charlie_8"], _standard_weap + _atweap],
    [[], _standard_weap]
];
};

GVAR(marker_vecs) = [];

// chopper varname, type (0 = lift chopper, 1 = wreck lift chopper, 2 = normal chopper), marker name, unique number (same as in init.sqf), marker type, marker color, marker text, chopper string name
GVAR(choppers) = [
    ["LIFT1",0,"lift1",301,"n_air","ColorWhite","CH1",(localize "STR_DOM_MISSIONSTRING_7")],
    ["LIFT2",0,"lift2",302,"n_air","ColorWhite","CH2",(localize "STR_DOM_MISSIONSTRING_8")],
    ["LIFT3",0,"lift3",303,"n_air","ColorWhite","HC3",(localize "STR_DOM_MISSIONSTRING_9")],
    ["TRANSPORT1",2,"transport1",304,"n_air","ColorWhite","UH1",""],
    ["TRANSPORT2",2,"transport2",305,"n_air","ColorWhite","UH2",""],
    ["TRANSPORT3",0,"transport3",306,"n_air","ColorWhite","MV22",""],
    ["TRANSPORT4",2,"transport4",307,"n_air","ColorWhite","C130J",""],
    ["LIGHT1",2,"light1",308,"n_air","ColorWhite","LB1",""],
    ["LIGHT2",2,"light2",309,"n_air","ColorWhite","LB2",""],
    ["WRECK1",1,"wreck1",310,"n_air","ColorWhite","WRK1",(localize "STR_DOM_MISSIONSTRING_10")],
    ["WRECK2",1,"wreck2",311,"n_air","ColorWhite","WRK2",(localize "STR_DOM_MISSIONSTRING_10")],
    ["A10",2,"attack1",350,"n_air","ColorWhite","A10",""],
    ["UH1Y",2,"attack2",351,"n_air","ColorWhite","UH1Y",""],
    ["AH64",2,"attack3",352,"n_air","ColorWhite","AH64",""]
];

// vehicle varname, unique number (same as in init.sqf), marker name, marker type, marker color, marker text, vehicle string name
GVAR(p_vecs) = [
    ["MRR1",0,"mobilerespawn1","HQ","ColorYellow","MHQ 1",(localize "STR_DOM_MISSIONSTRING_12")],
    ["MRR2",1,"mobilerespawn2","HQ","ColorYellow","MHQ 2",(localize "STR_DOM_MISSIONSTRING_13")],
    ["MEDVEC",10,"medvec","n_med","ColorGreen","M",""],["TR1",20,"truck1","n_maint","ColorGreen","R1",""],
    ["TR2",21,"truck2","n_support","ColorGreen","F1",""],["TR3",22,"truck3","n_support","ColorGreen","A1",""],
    ["TR6",23,"truck4","n_maint","ColorGreen","R2",""],["TR5",24,"truck5","n_support","ColorGreen","F2",""],
    ["TR4",25,"truck6","n_support","ColorGreen","A2",""],["TR7",30,"truck7","n_service","ColorGreen","E1",""],
    ["TR8",31,"truck8","n_service","ColorGreen","E2",""],["TR9",40,"truck9","n_support","ColorGreen","T2",""],
    ["TR10",41,"truck10","n_support","ColorGreen","T1",""]
];

// All available player roles and subsequent classes
// We use this to determine perk availability
GVAR(roles) = [
    "artillery", "engineers", "machine_gunners", "marksmen", "medics", "pilots"
];

// is engineer
GVAR(is_engineer) = ["delta_1","delta_2","delta_3","delta_4","delta_5","delta_6"];

//hint format ["%1 | %2", GVAR(pilots), GVAR(is_engineer)];

// is artillery operator
// please be aware that Dom 2 only supports two artillery operators in the non AI versions
// in the AI version everybody can call in artillery though only one arty is used
GVAR(can_use_artillery) = ["RESCUE","RESCUE2"];

// can build mash
GVAR(is_medic) = ["alpha_6","bravo_6","charlie_6","echo_6"];

// can build mg nest
GVAR(can_use_mgnests) =  ["alpha_3","alpha_7","charlie_3","charlie_7","bravo_4","echo_3","echo_7"];

#ifdef __OWN_SIDE_EAST__
_armor = if (GVAR(LockArmored) == 1) then {
    switch (true) do {
        case (__OAVer): {["M1A2_US_TUSK_MG_EP1","M1A1_US_DES_EP1","M1126_ICV_M2_EP1","M1126_ICV_mk19_EP1","M1128_MGS_EP1","M1135_ATGMV_EP1","M2A2_EP1","M2A3_EP1","M6_EP1"]};
        case (__COVer): {["AAV","LAV25","MLRS"]};
    };
} else {[]};
_car = if (GVAR(LockCars) == 1) then {
    switch (true) do {
        case (__OAVer): {["HMMWV_Avenger_DES_EP1","HMMWV_M1151_M2_DES_EP1","HMMWV_M998_crows_M2_DES_EP1","HMMWV_M1151_M2_CZ_DES_EP1","LandRover_Special_CZ_EP1","HMMWV_M998_crows_MK19_DES_EP1","HMMWV_MK19_DES_EP1","HMMWV_TOW_DES_EP1","M119_US_EP1"]};
        case (__COVer): {["HMMWV_Avenger","HMMWV_M2","HMMWV_Armored","HMMWV_MK19","HMMWV_TOW","M119"]};
    };
} else {[]};
#endif
#ifdef __OWN_SIDE_WEST__
_armor = if (GVAR(LockArmored) == 1) then {
    switch (true) do {
        case (__OAVer): {["T72_TK_EP1","T55_TK_EP1","T34_TK_EP1","BMP2_HQ_TK_EP1","BMP2_TK_EP1","M113_TK_EP1","BRDM2_ATGM_TK_EP1","BRDM2_TK_EP1","BTR60_TK_EP1","ZSU_TK_EP1","Ural_ZU23_TK_EP1","GRAD_TK_EP1"]};
        case (__COVer): {["BMP3","BTR90","BTR90_HQ","GAZ_Vodnik","GAZ_Vodnik_HMG"]};
    };
} else {[]};
_car = if (GVAR(LockCars) == 1) then {
    switch (true) do {
        case (__OAVer): {["UAZ_MG_TK_EP1","BTR40_MG_TK_INS_EP1","LandRover_MG_TK_INS_EP1","LandRover_MG_TK_EP1","UAZ_AGS30_TK_EP1","LandRover_SPG9_TK_INS_EP1","LandRover_SPG9_TK_EP1","D30_TK_EP1","D30_TK_INS_EP1"]};
        case (__COVer): {["UAZ_RU","UAZ_AGS30_RU","D30_RU"]};
    };
} else {[]};
#endif
#ifdef __OWN_SIDE_GUER__
_armor = if (GVAR(LockArmored) == 1) then {["BMP3","BTR90","BTR90_HQ","GAZ_Vodnik","GAZ_Vodnik_HMG"]} else {[]};
_car = if (GVAR(LockCars) == 1) then {["UAZ_RU","UAZ_AGS30_RU","D30_RU"]} else {[]};
#endif

GVAR(helilift1_types) =
#ifdef __OWN_SIDE_EAST__
switch (true) do {
    case (__OAVer): {
        ["BMP2_HQ_TK_EP1","M113Ambul_TK_EP1","UralSupply_TK_EP1","UralRepair_TK_EP1","UralRefuel_TK_EP1","UralReammo_TK_EP1","V3S_Open_TK_EP1","V3S_TK_EP1","UAZ_Unarmed_TK_EP1","D30_TK_EP1"]
    };
    case (__COVer): {
        ["BTR90_HQ","GAZ_Vodnik_MedEvac","WarfareSalvageTruck_RU","KamazRepair","KamazRefuel","KamazReammo","Kamaz","KamazOpen","UAZ_RU"]
    };
};
#endif
#ifdef __OWN_SIDE_WEST__
switch (true) do {
    case (__OAVer): {
        ["M1133_MEV_EP1","HMMWV_DES_EP1","HMMWV_M1035_DES_EP1","MTVR_DES_EP1","HMMWV_Ambulance_DES_EP1","MtvrReammo_DES_EP1","MtvrRefuel_DES_EP1","MtvrRepair_DES_EP1","LandRover_CZ_EP1","HMMWV_Ambulance_CZ_DES_EP1","MtvrSupply_DES_EP1","M119_US_EP1"]
    };
    case (__COVer): {
        ["LAV25_HQ","HMMWV","HMMWV_Armored","MTVR","HMMWV_Ambulance","MtvrReammo","MtvrRefuel","MtvrRepair"]
    };
};
#endif
#ifdef __OWN_SIDE_GUER__
    [];
#endif

if (count _armor > 0) then {GVAR(helilift1_types) = [GVAR(helilift1_types), _armor] call FUNC(arrayPushStack2)};
if (count _car > 0) then {GVAR(helilift1_types) = [GVAR(helilift1_types), _car] call FUNC(arrayPushStack2)};

{GVAR(helilift1_types) set [_forEachIndex, toUpper _x]} forEach GVAR(helilift1_types);

{
    switch (_x select 1) do {
        case 0: {_x set [count _x, GVAR(helilift1_types)]};
        case 1: {_x set [count _x, GVAR(heli_wreck_lift_types)]};
    };
} forEach GVAR(choppers);

GVAR(prim_weap_player) = "";
GVAR(last_telepoint) = 0;
GVAR(chophud_on) = true;

// show a welcome message in a chopper (mainly used to tell the player if it is a lift or wreck lift chopper).
// false = disable it
GVAR(show_chopper_welcome) = GVAR(WithChopHud);

GVAR(backpackclasses) = [
    [ // US
        "TK_ALICE_Pack_EP1",
        "US_Assault_Pack_EP1",
        "TK_Assault_Pack_EP1",
        "US_Backpack_EP1",
        "BAF_AssaultPack_special",
        "DE_Backpack_Specops_EP1",
        "US_Patrol_Pack_EP1",
        "TK_RPG_Backpack_EP1",
        "Tripod_Bag",
        "US_UAV_Pack_EP1"
    ],
    [ // East
        "Tripod_Bag", "DSHKM_TK_GUE_Bag_EP1", "KORD_high_TK_Bag_EP1", "KORD_TK_Bag_EP1", "AGS_TK_Bag_EP1", "2b14_82mm_TK_Bag_EP1", "Metis_TK_Bag_EP1", "TK_RPG_Backpack_EP1",
        "TK_ALICE_Pack_EP1", "TK_Assault_Pack_EP1"
        
        // "Tripod_Bag", "DSHKM_TK_GUE_Bag_EP1", "DSHKM_TK_INS_Bag_EP1", "KORD_high_TK_Bag_EP1", "KORD_TK_Bag_EP1", "AGS_TK_Bag_EP1", "2b14_82mm_TK_Bag_EP1", "Metis_TK_Bag_EP1", "TK_RPG_Backpack_EP1",
        // "TK_ALICE_Pack_EP1", "TK_ALICE_Pack_Explosives_EP1", "TK_ALICE_Pack_AmmoMG_EP1", "TKA_ALICE_Pack_Ammo_EP1", "TKG_ALICE_Pack_AmmoAK47_EP1", "TKG_ALICE_Pack_AmmoAK74_EP1", "TK_Assault_Pack_EP1",
        // "TK_Assault_Pack_RPK_EP1", "TKA_Assault_Pack_Ammo_EP1"
    ]
];

GVAR(jump_helo) = ["Mi17_TK_EP1", "UH60M_EP1", "UH1H_TK_GUE_EP1"];
GVAR(headbug_vehicle) = "UAZ_Unarmed_TK_EP1";

GVAR(do_ma_update_n) = false;