//#define __DEBUG__
#define THIS_FILE "x_netinitclient.sqf"
#include "x_setup.sqf"

FUNC(create_boxNet) = {
    private "_box";
    _box = objNull;
    _box = GVAR(the_box) createVehicleLocal (_this select 0);
    _box setDir (getDir (_this select 2));
    _box setPos (_this select 0);
    player reveal _box;
    _box allowDamage false;
    {
        if (_x == 5) exitWith {
            _box addAction [(localize "STR_DOM_MISSIONSTRING_300") call FUNC(BlueText), "x_client\x_savelayout.sqf"];
            _box addAction [(localize "STR_DOM_MISSIONSTRING_301") call FUNC(BlueText), "x_client\x_clearlayout.sqf"];
        };
    } forEach __pGetVar(GVAR(perks_unlocked));
    [_box] call FUNC(weaponcargo);
};

#ifndef __TT__
FUNC(jet_service_facNet) = {
    if (__XJIPGetVar(GVAR(jet_serviceH))) then {
        private ["_element", "_pos", "_dir", "_fac"];
        _element = GVAR(aircraft_facs) select 0;
        _pos = _element select 0;
        _dir = _element select 1;
        _fclass = switch (true) do {
            case (__OAVer): {"Land_vez_ruins"};
            case (__COVer): {"Land_budova2_ruins"};
        };
        _fac = _fclass createVehicleLocal _pos;
        _fac setDir _dir;
        _fac setPos _pos;
    };
};

FUNC(chopper_service_facNet) = {
    if (__XJIPGetVar(GVAR(chopper_serviceH))) then {
        private ["_element", "_pos", "_dir", "_fac"];
        _element = GVAR(aircraft_facs) select 1;
        _pos = _element select 0;
        _dir = _element select 1;
        _fclass = switch (true) do {
            case (__OAVer): {"Land_vez_ruins"};
            case (__COVer): {"Land_budova2_ruins"};
        };
        _fac = _fclass createVehicleLocal _pos;
        _fac setDir _dir;
        _fac setPos _pos;
    };
};

FUNC(wreck_repair_facNet) = {
    if (__XJIPGetVar(GVAR(wreck_repairH))) then {
        private ["_element", "_pos", "_dir", "_fac"];
        _element = GVAR(aircraft_facs) select 2;
        _pos = _element select 0;
        _dir = _element select 1;
        _fclass = switch (true) do {
            case (__OAVer): {"Land_vez_ruins"};
            case (__COVer): {"Land_budova2_ruins"};
        };
        _fac = _fclass createVehicleLocal _pos;
        _fac setDir _dir;
        _fac setPos _pos;
    };
};
#endif

FUNC(ataxiNet) = {
    switch (_this select 1) do {
        case 0: {(localize "STR_DOM_MISSIONSTRING_634") call FUNC(HQChat)};
        case 1: {(localize "STR_DOM_MISSIONSTRING_635") call FUNC(HQChat);GVAR(heli_taxi_available) = true};
        case 2: {(localize "STR_DOM_MISSIONSTRING_636") call FUNC(HQChat);GVAR(heli_taxi_available) = true};
        case 3: {(localize "STR_DOM_MISSIONSTRING_637") call FUNC(HQChat)};
        case 4: {(localize "STR_DOM_MISSIONSTRING_638") call FUNC(HQChat);GVAR(heli_taxi_available) = true};
        case 5: {(localize "STR_DOM_MISSIONSTRING_639") call FUNC(HQChat)};
        case 6: {(localize "STR_DOM_MISSIONSTRING_640") call FUNC(HQChat)};
    };
};

FUNC(player_stuff) = {
    __TRACE_1("player_stuff","_this");
    _this = _this select 1;
    __TRACE_1("player_stuff new _this","_this");
    GVAR(player_autokick_time) = _this select 0;
    private "_can_select";
    _can_select = true;
    if (GVAR(WithRevive) == 0 && {(_this select 8) == -1} && {xr_max_lives != -1}) then {
        _can_select = false;
        0 spawn {
            scriptName "spawn_playerstuffparking";
            waitUntil {!GVAR(still_in_intro)};
            __TRACE("player_stuff, calling park_player");
            [false] spawn xr_fnc_park_player;
        };
    };
    if (_can_select) then {
        // TODO: if player wasn't in a vehicle, ask him if he wants to spawn at the position where he left the server, add dialog ? Do it all ? Aka, does it make sense ?
        // _this select 10 = weapons player
        // _this select 11 = magazines player
        // _this select 12 = position player
        // _this select 13 = true = player wasn not in vehicle, false = player was in vehicle
        if (!GVAR(LimitedWeapons) && {count (_this select 10) > 0}) then {
            private "_p";
            _p = player;
            removeAllWeapons _p;
            removeAllItems _p;
            {_p addMagazine _x} forEach (_this select 11);
            {_p addWeapon _x} forEach (_this select 10);
            _primw = primaryWeapon _p;
            if (_primw != "") then {
                _p selectWeapon _primw;
                _muzzles = getArray(configFile>>"cfgWeapons" >> _primw >> "muzzles");
                _p selectWeapon (_muzzles select 0);
            };
        };
    };
};

FUNC(dropansw) = {
    switch (_this select 1) do {
        case 0: {(localize "STR_DOM_MISSIONSTRING_642") call FUNC(HQChat)};
        case 1: {(localize "STR_DOM_MISSIONSTRING_643") call FUNC(HQChat)};
        case 2: {(localize "STR_DOM_MISSIONSTRING_644") call FUNC(HQChat)};
        case 3: {(localize "STR_DOM_MISSIONSTRING_645") call FUNC(HQChat)};
        case 4: {(localize "STR_DOM_MISSIONSTRING_646") call FUNC(HQChat)};
    };
};

FUNC(mhqdeplNet) = {
    private ["_mhq", "_isdeployed", "_name", "_vside"];
    PARAMS_2(_mhq,_isdeployed);
    _name = GV(_mhq,GVAR(vec_name));
    if (isNil "_name") exitWith {};
    _m = GV(_mhq,GVAR(marker));
    if (_isdeployed) then {
        (format [(localize "STR_DOM_MISSIONSTRING_647"), _name]) call FUNC(HQChat);
        if (!isNil "_m") then {_m setMarkerTextLocal format [(localize "STR_DOM_MISSIONSTRING_261"), GV(_mhq,GVAR(marker_text))]};
    } else {
        (format [(localize "STR_DOM_MISSIONSTRING_648"), _name]) call FUNC(HQChat);
        if (!isNil "_m") then {_m setMarkerTextLocal (GV(_mhq,GVAR(marker_text)))};
    };
};