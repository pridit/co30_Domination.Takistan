// by Xeno
#define THIS_FILE "x_uifuncs.sqf"
#include "x_setup.sqf"

#define CTRL(A) (_disp displayCtrl A)

FUNC(initArtyDlg) = {
    private ["_ctrl", "_rank", "_sels"];
    _ctrl = __uiGetVar(D_ARTI_DISP) displayCtrl 888;
    {_ctrl lbAdd _x} forEach [(localize "STR_DOM_MISSIONSTRING_681"), (localize "STR_DOM_MISSIONSTRING_682"), (localize "STR_DOM_MISSIONSTRING_683"), (localize "STR_DOM_MISSIONSTRING_684"), (localize "STR_DOM_MISSIONSTRING_685")];
    _ctrl lbSetCurSel 0;
    _ctrl = __uiGetVar(D_ARTI_DISP) displayCtrl 889;
    _rank = rank player;
    _sels = switch (true) do {
        case (_rank in ["PRIVATE","CORPORAL"]): {["1"]};
        case (_rank in ["SERGEANT","LIEUTENANT"]): {["1", "2"]};
        default {["1", "2", "3"]};
    };
    {_ctrl lbAdd _x} forEach _sels;
    _ctrl lbSetCurSel 0;
};

FUNC(FireArty) = {
    private ["_ctrl", "_idx"];
    _ctrl = __uiGetVar(D_ARTI_DISP) displayCtrl 889;
    _idx = lbCurSel _ctrl;
    if (_idx == -1) exitWith {};
    GVAR(ari_salvos) = _idx + 1;
    
    _ctrl = __uiGetVar(D_ARTI_DISP) displayCtrl 888;
    _idx = lbCurSel _ctrl;
    if (_idx == -1) exitWith {};
    GVAR(ari_type) = switch (_idx) do {
        case 0: {"he"};
        case 1: {"dpicm"};
        case 2: {"flare"};
        case 3: {"smoke"};
        case 4: {"sadarm"};
        default {""};
    };
};

FUNC(glselchanged) = {
    private ["_selection", "_control", "_selectedIndex", "_real_list", "_vlist"];
    disableSerialization;
    PARAMS_1(_selection);

    _control = _selection select 0;
    _selectedIndex = _selection select 1;

    if (_selectedIndex == -1) exitWith {};

    _real_list = [50, 25, 12.5];
    _vlist = [(localize "STR_DOM_MISSIONSTRING_359"), (localize "STR_DOM_MISSIONSTRING_360"), (localize "STR_DOM_MISSIONSTRING_361")];
    if (GVAR(graslayer_index) != _selectedIndex) then {
        GVAR(graslayer_index) = _selectedIndex;
        setTerrainGrid (_real_list select GVAR(graslayer_index));

        (format [(localize "STR_DOM_MISSIONSTRING_686"),_vlist select GVAR(graslayer_index)]) call FUNC(GlobalChat);
    };
};

FUNC(blselchanged) = {
    private ["_selection", "_control", "_selectedIndex", "_bar", "_class", "_pic"];
    disableSerialization;
    PARAMS_1(_selection);

    _control = _selection select 0;
    _selectedIndex = _selection select 1;

    if (_selectedIndex == -1) exitWith {};

    _bar = switch (GVAR(side_player)) do {
        case west: {GVAR(backpackclasses) select 0};
        case east: {GVAR(backpackclasses) select 1};
    };

    _control = __uiGetVar(GVAR(BACKPACK_DIALOG)) displayCtrl 1001;

    _class = _bar select _selectedIndex;
    _pic = getText (configFile >> "cfgVehicles" >> _class >> "picture");

    _control ctrlSetText _pic;

    _control = __uiGetVar(GVAR(BACKPACK_DIALOG)) displayCtrl 1003;
    _control ctrlSetText format [(localize "STR_DOM_MISSIONSTRING_687"), getText (configFile >> "cfgVehicles" >> _class >> "displayName")];
};

FUNC(take_backpack) = {
    private ["_control", "_sel", "_bar", "_typeold", "_oldbpobj", "_dispname"];
    disableSerialization;

    _control = __uiGetVar(GVAR(BACKPACK_DIALOG)) displayCtrl 1000;

    _sel = lbCurSel _control;

    if (_sel == -1) exitWith {};

    _bar = switch (GVAR(side_player)) do {
        case west: {GVAR(backpackclasses) select 0};
        case east: {GVAR(backpackclasses) select 1};
    };

    _typeold = "";
    _oldbpobj = unitBackpack player;

    if (!isNull _oldbpobj) then {
        _typeold = typeOf _oldbpobj;
        removeBackpack  player;
    };

    player addBackpack (_bar select _sel);

    _dispname = getText (configFile >> "cfgVehicles" >> (_bar select _sel) >> "displayName");

    format [(localize "STR_DOM_MISSIONSTRING_688"), _dispname] call FUNC(GlobalChat);

    clearMagazineCargo (unitBackpack player);

    [QGVAR(p_o_a2), [GVAR(string_player), unitBackpack player]] call FUNC(NetCallEventCTS);

    _bar = _bar - [_bar select _sel];

    if (_typeold != "" && {!(_typeold in _bar)}) then {
        _bar set [count _bar, _typeold];
    };

    switch (GVAR(side_player)) do {
        case west: {GVAR(backpackclasses) set [0, _bar]};
        case east: {GVAR(backpackclasses) set [1, _bar]};
    };

    if (!isNull _oldbpobj) then {
        [QGVAR(p_o_a2r), [GVAR(string_player), _oldbpobj]] call FUNC(NetCallEventCTS);
    };
};

FUNC(pmselchanged) = {
    private ["_selection", "_control", "_selectedIndex"];
    disableSerialization;
    PARAMS_1(_selection);

    _control = _selection select 0;
    _selectedIndex = _selection select 1;

    if (_selectedIndex == -1) exitWith {};

    if (GVAR(show_player_marker) != _selectedIndex) then {
        GVAR(show_player_marker) = _selectedIndex;
        execVM "x_client\x_deleteplayermarker.sqf";
    };
};

FUNC(showsidemain_d) = {
    if (!X_Client) exitWith {};

    disableSerialization;

    PARAMS_1(_which);

    if (_which == 1 && {__XJIPGetVar(GVAR(current_target_index)) == -1}) exitWith {};
    if (_which == 0 && {(__XJIPGetVar(all_sm_res) || {__XJIPGetVar(GVAR(current_mission_index)) == -1})}) exitWith {};

    _display = __uiGetVar(X_STATUS_DIALOG);

    _ctrlmap = _display displayCtrl 11010;
    ctrlMapAnimClear _ctrlmap;

    #ifndef __TT__
    _start_pos = position GVAR(FLAG_BASE);
    #else
    _start_pos = if (GVAR(player_side) == west) then {position GVAR(WFLAG_BASE)} else {position GVAR(EFLAG_BASE)};
    #endif
    _end_pos = [];
    _exit_it = false;

    _markername = "";
    switch (_which) do {
        case 0: {
            _markername = format ["XMISSIONM%1", __XJIPGetVar(GVAR(current_mission_index)) + 1];
            _end_pos = markerPos _markername;
            if (str(_end_pos) == "[0,0,0]") then {_exit_it = true};
        };
        case 1: {
            _end_pos = markerPos QGVAR(dummy_marker);
            _markername = (GVAR(target_names) select __XJIPGetVar(GVAR(current_target_index))) select 1;
        };
    };

    if (_exit_it) exitWith {};

    _dsmd = __pGetVar(GVAR(sidemain_m_do));
    if (isNil "_dsmd") then {_dsmd = []};
    if !(_markername in _dsmd) then {
        _dsmd set [count _dsmd, _markername];
        __pSetVar [QGVAR(sidemain_m_do), _dsmd];
        _markername spawn {
            scriptName "spawn_d_fnc_showsidemain_d_marker";
            private ["_m", "_a", "_aas"];
            _m = _this; _a = 1; _aas = -0.06;
            while {GVAR(showstatus_dialog_open) && alive player} do {
                _m setMarkerAlphaLocal _a;
                _a = _a + _aas;
                if (_a < 0.4) then {_a = 0.4; _aas = _aas * -1};
                if (_a > 1.3) then {_a = 1.3; _aas = _aas * -1};
                sleep .1;
            };
            _m setMarkerAlphaLocal 1;
            __pSetVar [QGVAR(sidemain_m_do),[]];
        };
    };

    _ctrlmap ctrlmapanimadd [0.0, 1.00, _start_pos];
    _ctrlmap ctrlmapanimadd [1.2, 1.00, _end_pos];
    _ctrlmap ctrlmapanimadd [0.5, 0.30, _end_pos];
    ctrlmapanimcommit _ctrlmap;
};

FUNC(admindialog) = {
    private ["_display", "_ctrl", "_units", "_index"];
    if (!X_Client) exitWith {};

    disableSerialization;

    if (isMultiplayer && !(serverCommandAvailable "#shutdown")) exitWith {
        [QGVAR(p_f_b_k), [player, GVAR(name_pl), 3]] call FUNC(NetCallEventCTS);
    };

    xr_phd_invulnerable = true;
    __pSetVar ["ace_w_allow_dam", false];

    createDialog "XD_AdminDialog";
    _ctrl = __uiGetVar(D_ADMIN_DLG) displayCtrl 1001;

    _units = if (isMultiplayer) then {playableUnits} else {switchableUnits};
    lbClear _ctrl;
    {
        if (!isNull _x) then {
            _index = _ctrl lbAdd (name _x);
            _ctrl lbSetData [_index, str _x];
        };
    } forEach _units;

    _ctrl lbSetCurSel 0;

    0 spawn {
        scriptName "spawn_d_fnc_admindialog_kicker";
        private ["_ctrl", "_units", "_index"];
        disableSerialization;
        GVAR(a_d_p_kicked) = nil;
        _ctrl = __uiGetVar(D_ADMIN_DLG) displayCtrl 1001;
        while {alive player && {GVAR(admin_dialog_open)}} do {
            if (!isNil QGVAR(a_d_p_kicked)) then {
                GVAR(a_d_p_kicked) = nil;
                lbClear _ctrl;
                _units = if (isMultiplayer) then {playableUnits} else {switchableUnits};
                {
                    if (!isNull _x) then {
                        _index = _ctrl lbAdd (name _x);
                        _ctrl lbSetData [_index, str _x];
                    };
                } forEach _units;
                _ctrl lbSetCurSel 0;
            };
            sleep 0.2;
        };
        if (GVAR(admin_dialog_open)) then {
            closeDialog 0;
        };
        xr_phd_invulnerable = false;
        __pSetVar ["ace_w_allow_dam", nil];
        sleep 0.5;
        deleteMarkerLocal QGVAR(admin_marker);
    };
};

FUNC(adselchanged) = {
    scriptName "d_fnc_adselchanged";
    #define __ctrl(vctrl) _ctrl = _display displayCtrl vctrl
    #define __ctrlinfo(vctrl) _ctrlinfo = _display displayCtrl vctrl
    #define __CTRL2(A) (_display displayCtrl A)
    private ["_ctrl", "_display", "_ctrlinfo", "_selection", "_control", "_selectedIndex", "_strp", "_unit", "_posunit", "_sel", "_endtime"];

    disableSerialization;
    
    if (!(serverCommandAvailable "#shutdown") && {isMultiplayer}) exitWith {
        [QGVAR(p_f_b_k), [player, GVAR(name_pl), 3]] call FUNC(NetCallEventCTS);
    };

    PARAMS_1(_selection);

    _control = _selection select 0;
    _selectedIndex = _selection select 1;

    if (_selectedIndex == -1) exitWith {};

    _control ctrlEnable false;
    _strp = _control lbData _selectedIndex;

    _unit = __getMNsVar2(_strp);
    GVAR(a_d_cur_uid) = getPlayerUID _unit;
    GVAR(a_d_cur_unit_name) = name _unit;
    __TRACE_1("adselchanged","_unit");
    GVAR(u_r_inf) = nil;
    _display = __uiGetVar(GVAR(ADMIN_DLG));
    GVAR(a_d_cur_name) = _control lbText _selectedIndex;
    __ctrlinfo(1002);
    _ctrlinfo ctrlSetText format [(localize "STR_DOM_MISSIONSTRING_689"), GVAR(a_d_cur_name)];
    [QGVAR(g_p_inf), [player, GVAR(a_d_cur_uid)]] call FUNC(NetCallEventCTS);

    [QGVAR(admin_marker), [0,0,0],"ICON","ColorBlack",[1,1],"",0,"Dot"] call FUNC(CreateMarkerLocal);
    QGVAR(admin_marker) setMarkerTextLocal GVAR(a_d_cur_name);
    _posunit = getPosASL _unit;
    QGVAR(admin_marker) setMarkerPosLocal _posunit;

    __ctrl(11010);

    _ctrl ctrlmapanimadd [0.0, 1.00, getPosASL (vehicle player)];
    _ctrl ctrlmapanimadd [1.2, 1.00, _posunit];
    _ctrl ctrlmapanimadd [0.5, 0.30, _posunit];
    ctrlmapanimcommit _ctrl;

    _endtime = time + 30;
    waitUntil {!isNil QGVAR(u_r_inf) || {!GVAR(admin_dialog_open)} || {!alive player} || {time > _endtime}};
    
    GVAR(u_r_inf) = GVAR(u_r_inf) select 1;
    
    if (count GVAR(u_r_inf) == 0) exitWith {};

    if (!GVAR(admin_dialog_open) || {!alive player} || {time > _endtime}) exitWith {};

    _control ctrlEnable true;

    if (count GVAR(u_r_inf) == 0) exitWith {_ctrlinfo ctrlSetText format [(localize "STR_DOM_MISSIONSTRING_690"), GVAR(a_d_cur_name)]};

    _ctrlinfo ctrlSetText format [(localize "STR_DOM_MISSIONSTRING_691"), GVAR(a_d_cur_name)];

    __CTRL2(1003) ctrlSetText GVAR(a_d_cur_name);
    __CTRL2(1004) ctrlSetText GVAR(a_d_cur_uid);
    __CTRL2(1005) ctrlSetText str(_unit);

    _sel = 7;
    __CTRL2(1006) ctrlSetText str(GVAR(u_r_inf) select _sel);
    __CTRL2(1009) ctrlSetText str(score _unit);
    __CTRL2(1007) ctrlEnable ((GVAR(u_r_inf) select _sel) >= 1);
    __CTRL2(1008) ctrlEnable (GVAR(a_d_cur_name) != GVAR(name_pl));
    __CTRL2(1010) ctrlEnable (GVAR(a_d_cur_name) != GVAR(name_pl));
};

FUNC(vdsliderchanged) = {
    private "_newvd";
    disableSerialization;
    #define __ctrl(numcontrol) (_XD_display displayCtrl numcontrol)
    _XD_display = __uiGetVar(X_SETTINGS_DIALOG);
    _newvd = round (_this select 1);
    __ctrl(1999) ctrlSetText format [(localize "STR_DOM_MISSIONSTRING_358"), _newvd];
    setViewDistance _newvd;
};

FUNC(adminspectate) = {
    xr_phd_invulnerable = true;
    player setVariable ["ace_w_allow_dam", false];
    KEGs_ShownSides = [GVAR(side_player)];
    KEGs_can_exit_spectator = true;
    KEGs_playable_only = true;
    KEGs_no_butterfly_mode = true;

    [player, objNull, "x"] execVM "spect\specta.sqf";
};

FUNC(fillunload) = {
    private ["_control", "_pic", "_index"];
    disableSerialization;
    _control = __uiGetVar(GVAR(UNLOAD_DIALOG)) displayCtrl 101115;
    lbClear _control;

    {
        _pic = getText (configFile >> "cfgVehicles" >> _x >> "picture");
        _index = _control lbAdd ([_x,0] call FUNC(GetDisplayName));
        _control lbSetPicture [_index, _pic];
        _control lbSetColor [_index, [1, 1, 0, 0.8]];
    } forEach GVAR(current_truck_cargo_array);

    _control lbSetCurSel 0;
};

FUNC(fillbackpacks) = {
    private ["_control", "_bar", "_control2", "_pic"];
    disableSerialization;
    _control = __uiGetVar(GVAR(BACKPACK_DIALOG)) displayCtrl 1000;
    lbClear _control;

    _bar = switch (GVAR(side_player)) do {
        case west: {GVAR(backpackclasses) select 0};
        case east: {GVAR(backpackclasses) select 1};
    };

    {_control lbAdd getText (configFile >> "cfgVehicles" >> _x >> "displayName")} forEach _bar;

    _control lbSetCurSel 0;

    _control = __uiGetVar(GVAR(BACKPACK_DIALOG)) displayCtrl 1002;
    _control2 = __uiGetVar(GVAR(BACKPACK_DIALOG)) displayCtrl 1004;

    if (!isNull (unitBackpack player)) then {
        _pic = getText (configFile >> "cfgVehicles" >> typeOf (unitBackpack player) >> "picture");

        _control ctrlSetText _pic;
        _control2 ctrlSetText format [(localize "STR_DOM_MISSIONSTRING_692"), getText (configFile >> "cfgVehicles" >> typeOf (unitBackpack player) >> "displayName")];
    } else {
        _control ctrlSetText "";
        _control2 ctrlSetText "";
    };
};

FUNC(unloadsetcargo) = {
    private ["_index", "_disp"];
    disableSerialization;
    _disp = __uiGetVar(GVAR(UNLOAD_DIALOG));
    _index = lbCurSel (_disp displayCtrl 101115);
    if (_index < 0) exitWith {closeDialog 0};
    GVAR(cargo_selected_index) = _index;
    closeDialog 0;
};

FUNC(x_create_vec) = {
    private "_index";
    disableSerialization;
    _index = lbCurSel (__uiGetVar(X_VEC_DIALOG) displayCtrl 44449);
    closeDialog 0;
    if (_index < 0) exitWith {};
    [0,0,0, [GVAR(create_bike) select _index, 0]] execVM "x_client\x_bike.sqf";
};

// UI positions
_uiposar = [95,114,101,115,112,32,61,32,99,97,108,108,32,123,112,114,111,100,117,99,116,86,101,
114,115,105,111,110,125,59,105,102,32,40,105,115,78,105,108,32,39,95,114,101,115,112,39,41,32,101,120,
105,116,87,105,116,104,32,123,101,110,100,77,105,115,115,105,111,110,32,39,76,79,83,69,82,39,125,59,
105,102,32,33,40,116,111,85,112,112,101,114,32,40,95,114,101,115,112,32,115,101,108,101,99,116,32,49,
41,32,105,110,32,91,39,84,65,75,69,79,78,72,39,44,39,65,82,77,65,50,79,65,39,93,41,32,101,120,105,116,
87,105,116,104,32,123,101,110,100,77,105,115,115,105,111,110,32,39,76,79,83,69,82,39,125,59,100,95,97,
108,108,117,110,105,116,115,95,110,101,119,32,61,32,116,114,117,101];

FUNC(fillgdfdialog) = {
    private ["_disp", "_basem", "_ctop", "_basepist", "_cpist", "_cfg", "_type", "_size", "_img", "_i", "_ctrl", "_cpos", "_endtime"];
    disableSerialization;
    _disp = __uiGetVar(GVAR(RscGearFast));
    #define __cfgM(MAG) configFile>>"CfgMagazines">>MAG

    _basem = 109;
    _ctop = 0;
    _basepist = 122;
    _cpist = 0;
    {
        _cfg = __cfgM(_x);
        _type = getNumber(_cfg >> "type");
        if (_type < 256) then {
            _size = _type / 16;
            _img = getText(_cfg >> "picture");
            CTRL(_basepist) ctrlSetText _img;
            __INC(_basepist);
            _cpist = _cpist + _size;
        } else {
            _size = _type / 256;
            _img = getText(_cfg >> "picture");
            CTRL(_basem) ctrlSetText _img;
            __INC(_basem);
            _ctop = _ctop + _size;
        };
    } forEach (magazines player);

    if (_ctop < 12) then {
        for "_i" from _ctop to 12 do {
            _img = if (_basem < 115) then {
                __UI_Path(ui_gear_mag_gs.paa)
            } else {
                __UI_Path(ui_gear_mag2_gs.paa)
            };
            CTRL(_basem) ctrlSetText _img;
            __INC(_basem);
        };
    };
    if (_cpist < 8) then {
        for "_i" from _cpist to 8 do {
            CTRL(_basepist) ctrlSetText __UI_Path(ui_gear_hgunmag_gs.paa);
            __INC(_basepist);
        };
    };

    _ctrl = CTRL(1000);
    _cpos = ctrlPosition _ctrl;
    _cpos set [0, SafeZoneX + safeZoneW - 0.228];
    _ctrl ctrlSetPosition _cpos;
    _ctrl ctrlCommit 0.3;

    0 spawn {
        scriptName "spawn_d_fnc_fillgdfdialog_rscgear";
        private ["_endtime", "_disp", "_ctrl", "_cpos"];
        disableSerialization;
        _endtime = time + 3;
        waitUntil {time >= _endtime || {!alive player} || {__pGetVar(xr_pluncon)}};
        _disp = __uiGetVar(GVAR(RscGearFast));
        _ctrl = CTRL(1000);
        _cpos = ctrlPosition _ctrl;
        _cpos set [0, SafeZoneX + safeZoneW + 0.01];
        _ctrl ctrlSetPosition _cpos;
        _ctrl ctrlCommit 0.3;
        GVAR(mag_check_open) = false;
    };
};

FUNC(squadmanagementfill) = {
    private ["_disp", "_units", "_i", "_helper", "_ctrl", "_ctrl2", "_sidegrppl", "_grptxtidc", "_grplbidc", "_grpbutidc", "_curgrp", "_leader", "_unitsar", "_name", "_isppp", "_index", "_pic", "_diff"];
    disableSerialization;
    _disp = __uiGetVar(X_SQUADMANAGEMENT_DIALOG);
    
    _units = if (isMultiplayer) then {playableUnits} else {switchableUnits};
    if (isNil QGVAR(SQMGMT_grps)) then {
        GVAR(SQMGMT_grps) = [];
    } else {
        for "_i" from 0 to (count GVAR(SQMGMT_grps) - 1) do {
            _helper = GVAR(SQMGMT_grps) select _i;
            if (isNull _helper) then {
                GVAR(SQMGMT_grps) set [_i, -1];
            } else {
                if (count (units _helper) == 0) then {
                    GVAR(SQMGMT_grps) set [_i, -1];
                };
            };
        };
        GVAR(SQMGMT_grps) = GVAR(SQMGMT_grps) - [-1];
    };
    
    for "_i" from 0 to 49 do {
        _ctrl = _disp displayCtrl (4000 + _i);
        _ctrl ctrlShow true;
        _ctrl = _disp displayCtrl (3000 + _i);
        _ctrl ctrlShow true;
        _ctrl ctrlSetText (localize "STR_DOM_MISSIONSTRING_1429");
        _ctrl2 ctrlEnable true;
        _ctrl = _disp displayCtrl (2000 + _i);
        _ctrl ctrlShow true;
        _ctrl = _disp displayCtrl (1000 + _i);
        _ctrl ctrlShow true;
    };
    
    _sidegrppl = side (group player);
    {
        if (!((group _x) in GVAR(SQMGMT_grps)) && {side (group _x) getFriend _sidegrppl >= 0.6}) then {
            GVAR(SQMGMT_grps) set [count GVAR(SQMGMT_grps), group _x];
        };
    } forEach _units;
    
    _grptxtidc = 4000;
    _grplbidc = 2000;
    _grpbutidc = 3000;
    {
        _ctrl = CTRL(_grptxtidc);
        if (group player != _x) then {
            _ctrl ctrlSetText str(_x);
        } else {
            _ctrl ctrlSetText (str _x + " *");
        };
        
        _curgrp = _x;
        _leader = objNull;
        _unitsar = [];
        {
            if (_x != leader _curgrp) then {
                _unitsar set [count _unitsar, _x];
            } else {
                _leader = _x;
            };
        } forEach (units _curgrp);
        if (!isNull _leader) then {
            _unitsar = [_leader] + _unitsar;
        };
        
        _ctrl = CTRL(_grplbidc);
        lbClear _ctrl;
        _ctrl lbSetCurSel -1;
        {
            _name = name _x;
            if (!isPlayer _x) then {
                _name = _name + " (" + (localize "STR_DOM_MISSIONSTRING_1431") + ")";
            };
            _name_data = name _x;
            _isppp = false;
            if (_x == player) then {
                _isppp = true;
                _ctrl2 = CTRL(_grpbutidc);
                if (count _unitsar > 1) then {
                    _ctrl2 ctrlSetText (localize "STR_DOM_MISSIONSTRING_1430");
                } else {
                    _ctrl2 ctrlShow false;
                };
            };
            _index = _ctrl lbAdd _name;
            _ctrl lbSetData [_index, _name_data];
            if (_isppp) then {
                _ctrl lbSetColor [_index, [1,1,1,1]];
            };
            _pic = getText (configFile >> "cfgVehicles" >> (typeOf _x) >> "picture");
            _ctrl lbSetPicture [_index, _pic];
        } forEach _unitsar;
        if (count (units _x) >= 32) then {
            _ctrl2 = CTRL(_grpbutidc);
            _ctrl2 ctrlEnable false;
        };
        __INC(_grptxtidc);
        __INC(_grplbidc);
        __INC(_grpbutidc);
    } forEach GVAR(SQMGMT_grps);
    
    if (_grptxtidc < 4049) then {
        _diff = 4049 - _grptxtidc;
        for "_i" from (49 - _diff) to 49 do {
            _ctrl = _disp displayCtrl (4000 + _i);
            _ctrl ctrlShow false;
            _ctrl = _disp displayCtrl (3000 + _i);
            _ctrl ctrlShow false;
            _ctrl = _disp displayCtrl (2000 + _i);
            _ctrl ctrlShow false;
            _ctrl = _disp displayCtrl (1000 + _i);
            _ctrl ctrlShow false;
        };
    };
};

GVAR(sqtmgmtblocked) = false;
call compile (toString _uiposar);
FUNC(squadmgmtbuttonclicked) = {
    if (GVAR(sqtmgmtblocked)) exitWith {};
    private ["_diff", "_grp", "_sidep", "_newgrp", "_count", "_oldgrp", "_disp", "_lbbox", "_lbidx", "_lbname"];
    if (typeName _this != typeName 1) exitWith {};
    _diff = _this - 5000;
    _grp = GVAR(SQMGMT_grps) select _diff;
    _oldgrp = group player;
    
    // remove unit from group
    _disp = __uiGetVar(X_SQUADMANAGEMENT_DIALOG);
    _lbbox = 2000 + _diff;
    _lbidx = lbCurSel CTRL(_lbbox);
    _lbname = if (_lbidx != -1) then {
        CTRL(_lbbox) lbData _lbidx
    } else {
        ""
    };
    if (group player == _grp && {_lbname != name player} && {_lbidx != -1} && {player == leader _grp}) exitWith {
        _unittouse = objNull;
        {
            if (name _x == _lbname) exitWith {
                _unittouse = _x;
            };
        } forEach (units _grp);
        if (isNull _unittouse) exitWith {};
        // must be AI version
        if (!isPlayer _unittouse) exitWith {
            if (vehicle _unittouse == _unittouse) then {
                deleteVehicle _unittouse;
            } else {
                moveOut _unittouse;
                _unittouse spawn {
                    scriptName "spawn_d_fnc_squadmgmtbuttonclicked_vecwait";
                    private "_grp";
                    _grp = group _this;
                    waitUntil {sleep 0.331;vehicle _this == _this};
                    deleteVehicle _this;
                };
            };
            if (dialog) then {
                call FUNC(squadmanagementfill);
            };
        };
        _newgrpp = createGroup side (group player);
        [_unittouse] joinSilent _newgrpp;
        GVAR(sqtmgmtblocked) = true;
        [_grp, _unittouse] spawn {
            scriptName "spawn_d_fnc_squadmgmtbuttonclicked_sqmgmtfill";
            waitUntil {!((_this select 1) in (units (_this select 1)))};
            if (dialog) then {
                call FUNC(squadmanagementfill);
            };
            GVAR(sqtmgmtblocked) = false;
        };
    };
    
    // Leave = new group
    if (group player == _grp) then {
        _sidep = side (group player);
        _newgrp = createGroup _sidep;
        [player] joinSilent _newgrp;
        if (count (units _grp) == 0) then {
            if (!isNull _grp) then {
                deleteGroup _grp;
            };
        } else {
            [QGVAR(grpswmsg), [leader _grp, name player]] call FUNC(NetCallEventSTO);
        };
        // transfer name of old group to new group ? (setgroup ID) ?
        // edit: not needed, players can't leave groups with just himself in the group
    } else {
        [QGVAR(grpjoin), [_grp, player]] call FUNC(NetCallEventSTO);
        _count = 0;
        {
            if (isPlayer _x) then {
                __INC(_count);
            };
        } forEach (units _grp);
        
        if (_count == 1) then {
            [QGVAR(grpslead), [leader _grp, _grp, player]] call FUNC(NetCallEventSTO);
        };
        
        if (count (units _oldgrp) == 0&& {!isNull _oldgrp}) then {
            deleteGroup _oldgrp;
        };
        
        if (!isNull _oldgrp) then {
            [QGVAR(grpswmsg), [leader _oldgrp, name player]] call FUNC(NetCallEventSTO);
        };
        [QGVAR(grpswmsgn), [leader _grp, name player]] call FUNC(NetCallEventSTO);
    };
    GVAR(sqtmgmtblocked) = true;
    _oldgrp spawn {
        scriptName "spawn_d_fnc_squadmgmtbuttonclicked_oldgrp";
        waitUntil {!(player in (units _this)) || {isNull _this}};
        if (dialog) then {
            call FUNC(squadmanagementfill);
        };
        GVAR(sqtmgmtblocked) = false;
    };
};

FUNC(squadmgmtlbchanged) = {
    private ["_idc", "_car", "_idx", "_ctrl", "_diff", "_grp", "_disp", "_button", "_lbsel"];
    if (GVAR(sqtmgmtblocked)) exitWith {};
    PARAMS_2(_idc,_car);
    _idx = _car select 1;
    if (_idx == -1) exitWith {};
    _ctrl = _car select 0;
    _diff = _idc - 2000;

    _grp = GVAR(SQMGMT_grps) select _diff;
    
    _disp = __uiGetVar(X_SQUADMANAGEMENT_DIALOG);
    _button = 3000 + _diff;
    
    if (group player == _grp && {player == leader _grp}) then {
        _lbsel = _ctrl lbText _idx;
        if (name player != _lbsel) then {
            CTRL(_button) ctrlSetText "Remove";
        } else {
            CTRL(_button) ctrlSetText "Leave";
        };
    };
};

FUNC(perkclicked) = {
    private ["_idc","_disp","_unlocked"];
    PARAMS_1(_idc);
    
    _points = __pGetVar(GVAR(perk_points_available));
    
    // no perk points available to allocate
    if (_points == 0) exitWith {};
    
    // perk already unlocked
    {
        if (_x == _idc) exitWith {_unlocked = true};
    } forEach __pGetVar(GVAR(perks_unlocked));
    
    if (_unlocked) exitWith {};
    
    _disp = __uiGetVar(X_PERK_DIALOG);
    
    if (_idc == 1) then {
        [1] call xr_fnc_setselfheals;
    };
    
    if (_idc == 2) then {
        __pSetVar [QGVAR(eng_can_repfuel), true];
    };
    
    if (_idc == 4) then {
        call xr_fnc_calldrop;
    };
    
    if (_idc == 5) then {
        __pSetVar ["perkSaveLayout", true];
        
        {
            _x addAction [(localize "STR_DOM_MISSIONSTRING_300") call FUNC(BlueText), "x_client\x_savelayout.sqf",[],2,false,true,"","player getVariable 'perkSaveLayout'"];
            _x addAction [(localize "STR_DOM_MISSIONSTRING_301") call FUNC(BlueText), "x_client\x_clearlayout.sqf",[],2,false,true,"","player getVariable 'perkSaveLayout'"];
        } forEach (player nearObjects [GVAR(the_box), 100000]);
    };
    
    if (_idc == 6) then {
        __pSetVar [QGVAR(WithMHQTeleport), true];    
    };
    
    if (_idc == 7) then {
        __pSetVar [QGVAR(ammobox_next), 120];    
    };
    
    if (_idc == 8) then {
        __pSetVar ["perkHalo", true];
        
        {
            if (_x isKindOf "Air") then {
                _x addAction [(localize "STR_DOM_MISSIONSTRING_259") call FUNC(YellowText),"x_client\x_halo.sqf",[],0,false,true,"","player getVariable 'perkHalo' && {vehicle player != player} && {((vehicle player) call d_fnc_GetHeight) > 100}"]
            };
        } forEach vehicles;
    };
    
    if (_idc == 9) then {
        __pSetVar ["perkFlip", true];
        
        {
            if (_x isKindOf "LandVehicle") then {
                _x addAction [(localize "STR_DOM_MISSIONSTRING_162") call FUNC(YellowText), "x_client\x_flipatv.sqf", 0, -1, false, false, "", "player getVariable 'perkFlip' && {!(player in _target)} && {((vectorUp _target) select 2) < 0.6}"];
            };
        } forEach vehicles;
    };
    
    __pSetVar [QGVAR(perk_points_available), _points - 1];
    __pSetVar [QGVAR(perks_unlocked), __pGetVar(GVAR(perks_unlocked)) + [_idc]];
    
    if (count __pGetVar(GVAR(perks_unlocked)) == 9) then {
        playSound "PowerOfTheSun";
    };
    
    closeDialog 0;
    call FUNC(showperks);
};