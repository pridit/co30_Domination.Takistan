// by Xeno
#define THIS_FILE "x_settingsdialog.sqf"
#include "x_setup.sqf"
#define __ctrl(numcontrol) (_XD_display displayCtrl numcontrol)
private ["_XD_display","_ctrl","_index","_glindex","_str","_ar","_hstr","_med","_art","_eng"];

disableSerialization;

createDialog "XD_SettingsDialog";

_XD_display = __uiGetVar(X_SETTINGS_DIALOG);

if (GVAR(disable_viewdistance)) then {
    __ctrl(1000) ctrlEnable false;
    __ctrl(1999) ctrlSetText (localize "STR_DOM_MISSIONSTRING_357");
    __ctrl(1997) ctrlSetText "";
} else {
    sliderSetRange [1000, 200, GVAR(MaxViewDistance)];
    sliderSetPosition [1000, viewDistance];
    __ctrl(1999) ctrlSetText format [(localize "STR_DOM_MISSIONSTRING_358"), round viewDistance];
};

_ctrl = __ctrl(1001);

_glindex = -1;
{
    _index = _ctrl lbAdd _x;
    if (GVAR(graslayer_index) == _index) then {_glindex = _index};
} forEach [(localize "STR_DOM_MISSIONSTRING_359"), (localize "STR_DOM_MISSIONSTRING_360"), (localize "STR_DOM_MISSIONSTRING_361")];

_ctrl lbSetCurSel _glindex;
if (GVAR(Terraindetail) == 1) then {
    _ctrl ctrlEnable false;
    __ctrl(1998) ctrlSetText (localize "STR_DOM_MISSIONSTRING_362");
    __ctrl(1996) ctrlSetText "";
};

_ctrl = __ctrl(1002);
if (GVAR(dont_show_player_markers_at_all) == 1) then {
    {_ctrl lbAdd _x} forEach [(localize "STR_DOM_MISSIONSTRING_363"), (localize "STR_DOM_MISSIONSTRING_364"), (localize "STR_DOM_MISSIONSTRING_365"), (localize "STR_DOM_MISSIONSTRING_366"), (localize "STR_DOM_MISSIONSTRING_367")];
    _ctrl lbSetCurSel GVAR(show_player_marker);
} else {
    _ctrl ctrlShow false;
    __ctrl(1500) ctrlShow false;
    __ctrl(1501) ctrlShow false;
};

_ctrl = __ctrl(1602);
{_ctrl lbAdd _x} forEach [(localize "STR_DOM_MISSIONSTRING_363"), (localize "STR_DOM_MISSIONSTRING_364"), (localize "STR_DOM_MISSIONSTRING_366"), (localize "STR_DOM_MISSIONSTRING_367")];
_ctrl lbSetCurSel GVAR(show_player_namesx);

__ctrl(2001) ctrlSetText str(GVAR(points_needed) select 0);
__ctrl(2002) ctrlSetText str(GVAR(points_needed) select 1);
__ctrl(2003) ctrlSetText str(GVAR(points_needed) select 2);
__ctrl(2004) ctrlSetText str(GVAR(points_needed) select 3);
__ctrl(2005) ctrlSetText str(GVAR(points_needed) select 4);
__ctrl(2006) ctrlSetText str(GVAR(points_needed) select 5);

#define __str _str = _str + 

_str = (localize "STR_DOM_MISSIONSTRING_368") + GVAR(own_side) + "\n";
#ifndef __TT__
__str (localize "STR_DOM_MISSIONSTRING_369") + GVAR(enemy_side);
#else
__str (switch (GVAR(player_side)) do {case east: {", WEST"};case west: {", EAST"};});
#endif
__str "\n";
__str (localize "STR_DOM_MISSIONSTRING_370") + GVAR(player_faction) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_371") + str(GVAR(MainTargets)) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_372") + (getText (configFile >> "CfgWorlds" >> worldName >> "description")) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_373") + (if (GVAR(WithRevive) == 0) then {(localize "STR_DOM_MISSIONSTRING_374")} else {(localize "STR_DOM_MISSIONSTRING_375")});
__str (localize "STR_DOM_MISSIONSTRING_376") + str(GVAR(maxnum_tks_forkick)) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_377") + str(GVAR(player_kick_shootingbase)) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_378") + (if (GVAR(kick_base_satchel) == 0) then {(localize "STR_DOM_MISSIONSTRING_374")} else {(localize "STR_DOM_MISSIONSTRING_375")});
__str (localize "STR_DOM_MISSIONSTRING_379") + str(GVAR(InitialViewDistance)) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_380") + str(GVAR(MaxViewDistance)) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_381");

if (!GVAR(LimitedWeapons)) then {
    __str (localize "STR_DOM_MISSIONSTRING_382");
} else {
    if (count GVAR(poss_weapons) > 0) then {
        {
            __str ([_x, 1] call FUNC(GetDisplayName));
            if (_forEachIndex != (count GVAR(poss_weapons)- 1)) then {__str ", "};
        } forEach GVAR(poss_weapons);
        __str "\n";
    } else {
        __str (localize "STR_DOM_MISSIONSTRING_383");
    };
};

#define __tyn then {(localize "STR_DOM_MISSIONSTRING_374")} else {(localize "STR_DOM_MISSIONSTRING_375")}

__str (localize "STR_DOM_MISSIONSTRING_387") + GVAR(version_string) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_388") + (if (GVAR(TimeOfDay) < 10) then {"0"} else {""}) + str(GVAR(TimeOfDay)) + ":00\n";
__str (localize "STR_DOM_MISSIONSTRING_389") + (if (GVAR(WithBackpack)) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_390") + (if (GVAR(MissionType) == 2) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_391") + (if (GVAR(MissionType) == 1) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_392") + (if (GVAR(p_marker_dirs)) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_393") + (if (GVAR(v_marker_dirs)) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_394") + GVAR(p_marker) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_398") + (switch (GVAR(EnemySkill)) do {case 1: {(localize "STR_DOM_MISSIONSTRING_399")};case 2: {(localize "STR_DOM_MISSIONSTRING_11")};case 3: {(localize "STR_DOM_MISSIONSTRING_400")};}) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_401") + (if (GVAR(WithIsleDefense) == 0) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_402") + (if (GVAR(WithRecapture) == 0) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_401") + (if (GVAR(WithIsleDefense) == 0) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_403") + (switch (GVAR(WithLessArmor)) do {case 0: {(localize "STR_DOM_MISSIONSTRING_11")};case 1: {(localize "STR_DOM_MISSIONSTRING_404")};case 2: {(localize "STR_DOM_MISSIONSTRING_405")};}) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_406") + (if (GVAR(WithTeleToBase) == 0) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_407") + (if (GVAR(IllumMainTarget) == 0) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_408") + (if (GVAR(WithEnemyArtySpotters) == 0) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_409") + (if (GVAR(WithBaseAttack) == 0) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_411") + (if (GVAR(OverrideBISEffects) == 0) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_412") + (if (GVAR(BloodDirtScreen) == 0) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_413") + (if (GVAR(BlockSpacebarScanning) == 0) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_394") + str GVAR(playernames_state) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_415") + str GVAR(GrasAtStart) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_416") + (if (GVAR(Terraindetail) == 0) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_417") + (if (GVAR(WreckDeleteTime) == -1) then {(localize "STR_DOM_MISSIONSTRING_418")} else {(str(GVAR(WreckDeleteTime) / 60) + (localize "STR_DOM_MISSIONSTRING_419"))});
__str (localize "STR_DOM_MISSIONSTRING_420") + (if (GVAR(ViewdistanceChange) == 0) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_421");
{
    __str ([_x, 0] call FUNC(GetDisplayName));
    if (_forEachIndex < (count GVAR(create_bike) - 1)) then {__str ", "};
} forEach GVAR(create_bike);
__str "\n";

__str (localize "STR_DOM_MISSIONSTRING_422") + str(GVAR(VecCreateWaitTime)) + "\n";

__str (localize "STR_DOM_MISSIONSTRING_424") + str(GVAR(MaxNumAmmoboxes)) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_425") + str(__XJIPGetVar(GVAR(num_ammo_boxes))) + "\n";

__str (localize "STR_DOM_MISSIONSTRING_426") + str(GVAR(drop_ammobox_time)) + "\n";

__str (localize "STR_DOM_MISSIONSTRING_427") + str(GVAR(max_truck_cargo)) + "\n";

__str (localize "STR_DOM_MISSIONSTRING_428");
{
    __str ([_x, 0] call FUNC(GetDisplayName));
    if (_forEachIndex < (count GVAR(check_ammo_load_vecs) - 1)) then {__str ", "};
} forEach GVAR(check_ammo_load_vecs);
__str "\n";
__str (localize "STR_DOM_MISSIONSTRING_430") + (if (GVAR(with_mgnest)) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_431") + (if (GVAR(with_medtent)) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_432") + (if (GVAR(weapon_respawn)) __tyn);
__str (localize "STR_DOM_MISSIONSTRING_437") + str(GVAR(sub_tk_points)) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_464") + str(GVAR(drop_radius)) + "\n";

__str (localize "STR_DOM_MISSIONSTRING_465") + str(GVAR(reload_time_factor)) + "\n";

__str (localize "STR_DOM_MISSIONSTRING_466") + (if (GVAR(reload_engineoff)) __tyn);

#ifndef __TT__
__str (localize "STR_DOM_MISSIONSTRING_467") + (if (GVAR(WithJumpFlags) == 1) __tyn);
#endif

if (GVAR(WithJumpFlags) == 1) then {
    __str (localize "STR_DOM_MISSIONSTRING_468") + (if (GVAR(ParaAtBase) == 0) then {(localize "STR_DOM_MISSIONSTRING_374")} else {(localize "STR_DOM_MISSIONSTRING_375")});
    if (GVAR(ParaAtBase) == 0) then {__str (localize "STR_DOM_MISSIONSTRING_469") + str(GVAR(HALOWaitTime)/60) + "\n"};
    __str (localize "STR_DOM_MISSIONSTRING_470") + str(GVAR(HALOJumpHeight)) + "\n";
    if (GVAR(jumpflag_vec) != "") then {__str (localize "STR_DOM_MISSIONSTRING_471") + GVAR(jumpflag_vec) + "\n"};
};

__str (localize "STR_DOM_MISSIONSTRING_472") + str(GVAR(ArtiOperatorMaxDist)) + "\n";
__str (localize "STR_DOM_MISSIONSTRING_473") + str(GVAR(arti_reload_time)) + "\n";
__str format [(localize "STR_DOM_MISSIONSTRING_474"), GVAR(arti_available_time), GVAR(arti_available_time) + 200, GVAR(arti_available_time) + 400] + "\n";
__str (localize "STR_DOM_MISSIONSTRING_475") + (if (GVAR(arti_check_for_friendlies) == 0) then {(localize "STR_DOM_MISSIONSTRING_374")} else {(localize "STR_DOM_MISSIONSTRING_375")});
__str "Maximum distance player to airdrop point to call in an airdrop: " + str(GVAR(drop_max_dist)) + "\n";

__str (localize "STR_DOM_MISSIONSTRING_476") + str(GVAR(AutoKickTime)) + "\n";

if (GVAR(WithChopHud)) then {
    __str (localize "STR_DOM_MISSIONSTRING_480") + (if (GVAR(chophud_on)) __tyn);
};

__str (localize "STR_DOM_MISSIONSTRING_481") + (if (GVAR(show_chopper_welcome)) __tyn);

__str (localize "STR_DOM_MISSIONSTRING_482") + (if (GVAR(show_vehicle_welcome) == 0) __tyn);

__str (localize "STR_DOM_MISSIONSTRING_483") + (if (GVAR(WithRepStations) == 0) __tyn);

// don't forget to add \n, but not when adding the last string part
__ctrl(2007) ctrlSetText _str;
__ctrl(2007) ctrlCommit 0;

_str = "";
{
    _med = __getMNsVar2(_x);
    if (!isNull _med && {isPlayer _med}) then {
        if (_str != "") then {__str ", "};
        __str (if (alive _med) then {name _med} else {(localize "STR_DOM_MISSIONSTRING_493")});
    };
} forEach GVAR(medics);

if (_str == "") then {_str = (localize "STR_DOM_MISSIONSTRING_494")};
__ctrl(2008) ctrlSetText _str;

_str = "";
{
    _art = __getMNsVar2(_x);
    if (!isNull _art && {isPlayer _art}) then {
        if (_str != "") then {__str ", "};
        __str (if (alive _art) then {name _art} else {(localize "STR_DOM_MISSIONSTRING_493")});
    };
} forEach GVAR(artillery);

if (_str == "") then {_str = (localize "STR_DOM_MISSIONSTRING_495")};
__ctrl(2009) ctrlSetText _str;

_str = "";
{
    _eng = __getMNsVar2(_x);
    if (!isNull _eng && {isPlayer _eng}) then {
        if (_str != "") then {__str ", "};
        __str (if (alive _eng) then {name _eng} else {(localize "STR_DOM_MISSIONSTRING_493")});
    };
} forEach GVAR(engineers);

if (_str == "") then {_str = (localize "STR_DOM_MISSIONSTRING_496")};
__ctrl(2010) ctrlSetText _str;

0 spawn {
    scriptName "spawn_settingsdialog_dialogclose";
    waitUntil {!GVAR(settings_dialog_open) || {!alive player} || {__pGetVar(xr_pluncon)}};
    if (GVAR(settings_dialog_open)) then {closeDialog 0};
};