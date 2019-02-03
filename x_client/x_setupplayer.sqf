// by Xeno
//#define __DEBUG__
#define THIS_FILE "x_setupplayer.sqf"
#include "x_setup.sqf"
private ["_p", "_pos", "_type", "_weapp", "_magp", "_res", "_taskstr", "_color", "_counterxx", "_text", "_mcol", "_s", "_trigger", "_types", "_action", "_ar", "_tactionar", "_primw", "_muzzles"];

diag_log [diag_frameno, diag_ticktime, time, "Executing Dom x_setupplayer.sqf"];

GVAR(still_in_intro) = true;

_shield = GVAR(ProtectionZone) createVehicleLocal (position GVAR(FLAG_BASE));
_shield setDir -211;
_shield setPos (position GVAR(FLAG_BASE));
_shield setObjectTexture [0,"#(argb,8,8,3)color(0,0,0,0,ca)"];
if (GVAR(ShowBaseSafeZone) == 0) then {
    _shield = GVAR(ProtectionZone) createVehicleLocal (position GVAR(FLAG_BASE));
    _shield setDir -211;
    _shield setPos [getPosASL GVAR(FLAG_BASE) select 0, getPosASL GVAR(FLAG_BASE) select 1, -28.48];
    _shield setObjectTexture [0,"#(argb,8,8,3)color(0,0,0,0.7,ca)"];
};

GVAR(current_defend_target) = "";
GVAR(current_defend_idx) = -1;
GVAR(current_attack_target) = "";
GVAR(current_attack_idx) = -1;

__pSetVar [QGVAR(perk_points_available), 0];
__pSetVar [QGVAR(perks_unlocked), []];

__ccppfln(x_client\x_f\x_perframe.sqf);

GVAR(name_pl) = name player;
GVAR(player_faction) = faction player;

GVAR(misc_store) = GVAR(HeliHEmpty) createVehicleLocal [0,0,0];

FUNC(GreyText) = {"<t color='#f0bfbfbf'>" + _this + "</t>"};
FUNC(RedText) = {"<t color='#f0ff0000'>" + _this + "</t>"};
FUNC(BlueText) = {"<t color='#f07f7f00'>" + _this + "</t>"}; //olive
FUNC(YellowText) = {"<t color='#e7e700'>" + _this + "</t>"};

__pSetVar ["BIS_noCoreConversations", true];

_p = player;
__pSetVar [QGVAR(alivetimestart), time];
_pos = position _p;
_type = typeOf _p;
GVAR(string_player) = str(player);
GVAR(player_side) = playerSide;
GVAR(player_str_group) = str(group player);
if (GVAR(player_str_group) != "") then {
    _ar = toArray GVAR(player_str_group);
    _ar set [0,-99]; _ar set [1,-99];
    _ar = _ar - [-99];
    GVAR(player_str_group) = toString _ar;
};
// no idea if the following really works and it should never happen!
if (isNull (group player)) then {
    _gside = if ((faction player) in ["USMC","CDF","BIS_US","BIS_CZ","BIS_GER","BIS_BAF","ACE_USAF","ACE_USNAVY"]) then {west} else {east};
    _grpp = createGroup west;
    [player] joinSilent _grpp;
};
if (side (group player) != GVAR(player_side)) then {
    GVAR(player_side) = side (group player);
};

if (GVAR(WithRevive) == 1) then {
    __pSetVar ["xr_pluncon", false];
    
    #define __shots ["shotBullet","shotShell","shotRocket","shotMissile","shotTimeBomb","shotMine"]
    xr_bscreens = ["xr_ScreenBlood1", "xr_ScreenBlood2","xr_ScreenBlood3"];
    xr_blurr = ppEffectCreate ["dynamicBlur", -12521];
    FUNC(blurr) = {
        scriptName "func_blurr";
        xr_blurr ppEffectEnable true;
        xr_blurr ppEffectAdjust [1];
        xr_blurr ppEffectCommit 1;
        sleep 1;
        xr_blurr ppEffectAdjust [0];
        xr_blurr ppEffectCommit 1;
        sleep 1;
        xr_blurr ppEffectEnable false;
    };
    FUNC(playerHD) = {
        private ["_unit", "_part", "_dam", "_injurer", "_ammo", "_ddexit"];
        PARAMS_5(_unit,_part,_dam,_injurer,_ammo);
        if (!alive _unit) exitWith {_dam};
        if (xr_phd_invulnerable || {GV(_unit,xr_pluncon)}) exitWith {0};
        if (GVAR(no_teamkill) == 0 && {isPlayer _injurer} && {_injurer != _unit} && {_part == ""} && {_dam >= 0.5} && {side (group _injurer) == side (group _unit)} && {getText (configFile >> "CfgAmmo" >> _ammo >> "simulation") in __shots}) exitWith {
            hint format [(localize "STR_DOM_MISSIONSTRING_497"), name _injurer];
            [QGVAR(unit_tkr), [_unit,_injurer]] call FUNC(NetCallEventCTS);
            0
        };
        _dam = _dam * 0.8;
        if (_dam > 0.15 && {_part == ""} && {vehicle _unit == _unit} && {getText (configFile >> "CfgAmmo" >> _ammo >> "simulation") in __shots} && {!surfaceIsWater (getPosASL _unit)}) then {
            39672 cutRsc ["xr_ScreenDirt","PLAIN"];
        };
        0 spawn FUNC(blurr);
        39671 cutRsc[xr_bscreens select (floor (random 3)),"PLAIN"];
        _dam
    };
    player removeAllEventHandlers "handleDamage";
    player addEventHandler ["handleDamage", {_this call FUNC(playerHD)}];
};

GVAR(name_flag_base) = GVAR(FLAG_BASE);
GVAR(the_box) = "USVehicleBox_EP1";
GVAR(the_base_box) = "USVehicleBox_EP1";
GVAR(backpacks) = "Misc_Backpackheap_EP1";
GVAR(flag_vec) = objNull;

__ccppfln(x_client\x_f\x_playerfuncs.sqf);

if (!isServer) then {execVM "x_bikb\kbinit.sqf"};

if (!X_SPE) then {
    GVAR(X_DropZone) = __XJIPGetVar(X_DropZone);
};

[QGVAR(dummy_marker), [0,0,0],"ICON","ColorBlack",[1,1],"",0,"Empty"] call FUNC(CreateMarkerLocal);
[QGVAR(arti_target2), [0,0,0],"ICON","ColorBlue",[1,1],(localize "STR_DOM_MISSIONSTRING_498"),0,"mil_destroy"] call FUNC(CreateMarkerLocal);
QGVAR(arti_target2) setMarkerPosLocal getPosASL GVAR(AriTarget2);
[QGVAR(arti_target), [0,0,0],"ICON","ColorBlue",[1,1],(localize "STR_DOM_MISSIONSTRING_499"),0,"mil_destroy"] call FUNC(CreateMarkerLocal);
QGVAR(arti_target) setMarkerPosLocal getPosASL GVAR(AriTarget);
[QGVAR(drop_zone), [0,0,0],"ICON","ColorBlue",[1,1],(localize "STR_DOM_MISSIONSTRING_500"),0,"mil_dot"] call FUNC(CreateMarkerLocal);
QGVAR(drop_zone) setMarkerPosLocal getPosASL GVAR(X_DropZone);

if (__XJIPGetVar(GVAR(the_end))) exitWith {
    endMission "END1";
    forceEnd;
};

[QGVAR(the_end), {
    if (_this == 0) then {
        if (isNil QGVAR(end_cam_running)) then {
            execVM "x_client\x_endcam.sqf";
        };
    } else {
        endMission "END1";
        forceEnd;
    };
}] call FUNC(NetAddEventToClients);
[QGVAR(recaptured), {_this call FUNC(RecapturedUpdate)}] call FUNC(NetAddEventToClients);
[QGVAR(doarti), {if (alive player && {(player distance _this < 50)} && {!__pGetVar(xr_pluncon)}) then {(localize "STR_DOM_MISSIONSTRING_501") call FUNC(HQChat)}}] call FUNC(NetAddEventToClients);
[2, QGVAR(m_box), {_this call FUNC(create_boxNet)}] call FUNC(NetAddEvent);
[2, QGVAR(r_box), {_nobjs = nearestObjects [_this, [GVAR(the_box)], 10];if (count _nobjs > 0) then {_box = _nobjs select 0;deleteVehicle _box}}] call FUNC(NetAddEvent);
[QGVAR(air_box), {_box = GVAR(the_box) createVehicleLocal _this;_box setPos [_this select 0,_this select 1,0];player reveal _box;[_box] call FUNC(weaponcargo);_box addEventHandler ["killed",{deleteVehicle (_this select 0)}]}] call FUNC(NetAddEventToClients);
[QGVAR(sm_res_client), {playSound "Notebook";GVAR(side_mission_winner) = _this select 0; (_this select 1) execVM "x_missions\x_sidemissionwinner.sqf"}] call FUNC(NetAddEventToClients);
[QGVAR(target_clear), {playSound "fanfare";_this execVM "x_client\x_target_clear_client.sqf"}] call FUNC(NetAddEventToClients);
[QGVAR(update_target), {execVM "x_client\x_createnexttargetclient.sqf"}] call FUNC(NetAddEventToClients);
[QGVAR(up_m), {[true] spawn FUNC(getsidemissionclient)}] call FUNC(NetAddEventToClients);
[QGVAR(unit_tk), {
    if (GVAR(sub_tk_points) != 0) then {
        [format [(localize "STR_DOM_MISSIONSTRING_502"), _this select 0, _this select 1, GVAR(sub_tk_points)], "GLOBAL"] call FUNC(HintChatMsg);
    } else {
        [format [(localize "STR_DOM_MISSIONSTRING_503"), _this select 0, _this select 1], "GLOBAL"] call FUNC(HintChatMsg);
    };
}] call FUNC(NetAddEventToClients);
[QGVAR(unit_tk2), {
    if (GVAR(sub_tk_points) != 0) then {
        [format [(localize "STR_DOM_MISSIONSTRING_504"), _this select 0, _this select 1, GVAR(sub_tk_points)], "GLOBAL"] call FUNC(HintChatMsg);
    } else {
        [format [(localize "STR_DOM_MISSIONSTRING_505"), _this select 0, _this select 1], "GLOBAL"] call FUNC(HintChatMsg);
    };
}] call FUNC(NetAddEventToClients);
[QGVAR(ataxi), {_this call FUNC(ataxiNet)}] call FUNC(NetAddEventSTO);
//[QGVAR(ai_kill), {if ((_this select 0) in (units (group player)) && {player == leader (group player)}) then {[QGVAR(pas), [player, _this select 1 ]] call FUNC(NetCallEventCTS)}}] call FUNC(NetAddEventToClients);
[QGVAR(p_ar), {
#ifdef __DEBUG__
    _uidp = getPlayerUID player;
    _suid = _this select 2;
    __TRACE_2("p_ar","_uidp","_suid");
#endif
    _this call FUNC(player_stuff);
}] call FUNC(NetAddEventSTO);
[QGVAR(sm_p_pos), {GVAR(sm_p_pos) = _this}] call FUNC(NetAddEventToClients);
[QGVAR(mt_winner), {GVAR(mt_winner) = _this}] call FUNC(NetAddEventToClients);
[QGVAR(n_v), {_this call FUNC(initvec)}] call FUNC(NetAddEventToClients);
[QGVAR(m_l_o), {_this call FUNC(LightObj)}] call FUNC(NetAddEventToClients);
[QGVAR(dpicm), {_pod = "ARTY_SADARM_BURST" createVehicleLocal _this;_pod setPos _this}] call FUNC(NetAddEventToClients);
[QGVAR(artyt), {_this spawn FUNC(ArtyShellTrail)}] call FUNC(NetAddEventToClients);
[2, QGVAR(mhqdepl), {if (local (_this select 0)) then {(_this select 0) lock (_this select 1)};_this call FUNC(mhqdeplNet)}] call FUNC(NetAddEvent);
[QGVAR(w_n), {[format [(localize "STR_DOM_MISSIONSTRING_506"), _this select 0, _this select 1], "GLOBAL"] call FUNC(HintChatMsg)}] call FUNC(NetAddEventToClients);
[QGVAR(tk_an), {
    [format [(localize "STR_DOM_MISSIONSTRING_507"), _this select 0, _this select 1], "GLOBAL"] call FUNC(HintChatMsg);
    if (serverCommandAvailable "#shutdown") then {serverCommand ("#kick " + (_this select 0))};
}] call FUNC(NetAddEventToClients);
[2, QGVAR(say2), {if (alive player && {(player distance (_this select 0) < (_this select 2))}) then {(_this select 0) say3D (_this select 1)}}] call FUNC(NetAddEvent);
[QGVAR(em), {endMission "LOSER"}] call FUNC(NetAddEventSTO);
[QGVAR(ps_an), {
    switch (_this select 1) do {
        case 0: {[format [(localize "STR_DOM_MISSIONSTRING_508"), _this select 0], "GLOBAL"] call FUNC(HintChatMsg)};
        case 1: {[format [(localize "STR_DOM_MISSIONSTRING_509"), _this select 0], "GLOBAL"] call FUNC(HintChatMsg)};
    };
    if (serverCommandAvailable "#shutdown") then {serverCommand ("#kick " + (_this select 0))};
}] call FUNC(NetAddEventToClients);
[QGVAR(s_p_inf), {GVAR(u_r_inf) = _this}] call FUNC(NetAddEventSTO);
[QGVAR(w_ma), {deleteMarkerLocal _this}] call FUNC(NetAddEventToClients);
[2, QGVAR(p_o_a), {
    private "_ar";_ar = _this select 1;
    if ((_ar select 0) isKindOf "Mash") then {
        [_ar select 1, getPosASL (_ar select 0),"ICON","ColorBlue",[0.5,0.5],format [(localize "STR_DOM_MISSIONSTRING_510"), _ar select 2],0,"mil_dot"] call FUNC(CreateMarkerLocal);
    } else {
        if ((_ar select 0) isKindOf "Base_WarfareBVehicleServicePoint") then {
            [_ar select 1, getPosASL (_ar select 0),"ICON","ColorBlue",[0.5,0.5],format [(localize "STR_DOM_MISSIONSTRING_511"), _ar select 2],0,"mil_dot"] call FUNC(CreateMarkerLocal);
        } else {
            [_ar select 1, getPosASL (_ar select 0),"ICON","ColorBlue",[0.5,0.5],format [(localize "STR_DOM_MISSIONSTRING_512"), _ar select 2],0,"mil_dot"] call FUNC(CreateMarkerLocal);
        };
    };
}] call FUNC(NetAddEvent);
[2, QGVAR(p_o_r), {deleteMarkerLocal (_this select 1)}] call FUNC(NetAddEvent);
if (GVAR(engineerfull) == 0) then {
    [QGVAR(farp_e), {if (GVAR(eng_can_repfuel)) then {_this addAction [(localize "STR_DOM_MISSIONSTRING_513") call FUNC(BlueText), "x_client\x_restoreeng.sqf"]}}] call FUNC(NetAddEventToClients);
};
[QGVAR(p_o_an), {_this call FUNC(PlacedObjAn)}] call FUNC(NetAddEventToClients);
[QGVAR(dropansw), {_this call FUNC(dropansw)}] call FUNC(NetAddEventSTO);
[QGVAR(n_jf), {if (GVAR(WithJumpFlags) == 1) then {_this execVM "x_client\x_newflagclient.sqf"}}] call FUNC(NetAddEventToClients);
[QGVAR(jet_sf), {_this call FUNC(jet_service_facNet)}] call FUNC(NetAddEventToClients);
[QGVAR(chop_sf), {_this call FUNC(chopper_service_facNet)}] call FUNC(NetAddEventToClients);
[QGVAR(wreck_rf), {_this call FUNC(wreck_repair_facNet)}] call FUNC(NetAddEventToClients);
[QGVAR(w_m_c), {[_this select 0, _this select 1,"ICON",_this select 3,[1,1],format [(localize "STR_DOM_MISSIONSTRING_517"), _this select 2],0,"mil_triangle"] call FUNC(CreateMarkerLocal)}] call FUNC(NetAddEventToClients);
[QGVAR(smsg), {(localize "STR_DOM_MISSIONSTRING_519") call FUNC(HQChat)}] call FUNC(NetAddEventToClients);

[QGVAR(mqhtn), {[format [(localize "STR_DOM_MISSIONSTRING_520"), GVAR(MHQDisableNearMT), _this], "HQ"] call FUNC(HintChatMsg)}] call FUNC(NetAddEventToClients);

[QGVAR(ccso), {playSound "Ui_cc"}] call FUNC(NetAddEventToClients);

[QGVAR(grpswmsg), {((_this select 1) + " " + localize "STR_DOM_MISSIONSTRING_1432") call FUNC(GlobalChat)}] call FUNC(NetAddEventSTO);
[QGVAR(grpswmsgn), {((_this select 1) + " " + localize "STR_DOM_MISSIONSTRING_1433") call FUNC(GlobalChat)}] call FUNC(NetAddEventSTO);

0 spawn {
    scriptName "spawn_playerstuff";
    sleep 1 + random 3;
    if (isMultiplayer) then {
        [QGVAR(p_a), player] call FUNC(NetCallEventCTS);// ask the server for the client score, etc
        waitUntil {!GVAR(still_in_intro)};
        xr_phd_invulnerable = false;
        __pSetVar ["ace_w_allow_dam", nil];
        sleep 2;
        __pSetVar [QGVAR(player_old_rank), 0];
        ["player_rank", {call FUNC(PlayerRank)},5.01] call FUNC(addPerFrame);
    } else {
        GVAR(player_autokick_time) = GVAR(AutoKickTime);
        xr_phd_invulnerable = false;
        __pSetVar ["ace_w_allow_dam", nil];
        sleep 20;
        if (GVAR(still_in_intro)) then {
            GVAR(still_in_intro) = false;
        };
    };
};

["init_vecs", {{_x call FUNC(initvec)} forEach vehicles;["init_vecs"] call FUNC(removePerFrame)},0] call FUNC(addPerFrame);

#define __tctn _target_array = GVAR(target_names) select _res;\
_current_target_pos = _target_array select 0;\
_target_name = _target_array select 1;\
_target_radius = _target_array select 2
_taskstr = "d_task%2 = player createSimpleTask ['obj%2'];d_task%2 setSimpleTaskDescription ['" + localize "STR_DOM_MISSIONSTRING_202" + "','" + localize "STR_DOM_MISSIONSTRING_203" + "','" + localize "STR_DOM_MISSIONSTRING_203" + "'];d_task%2 settaskstate _objstatus;d_task%2 setSimpleTaskDestination _current_target_pos;";
#define __tmarker [_target_name, _current_target_pos,#ELLIPSE,_color,[_target_radius,_target_radius]] call FUNC(CreateMarkerLocal)
if (GVAR(MissionType) != 2) then {
#ifndef __TT__
    if (count __XJIPGetVar(resolved_targets) > 0) then {
        for "_i" from 0 to (count __XJIPGetVar(resolved_targets) - 1) do {
            if (isNil {__XJIPGetVar(resolved_targets)} || {_i >= count __XJIPGetVar(resolved_targets)}) exitWith {};
            _res = __XJIPGetVar(resolved_targets) select _i;
            if (!isNil "_res") then {
                if (_res >= 0) then {
                    __tctn;
                    _mname = format [QGVAR(target_%1), _res];
                    _no = __getMNsVar2(_mname);
                    _color = "ColorGreen";
                    _objstatus = "Succeeded";
                    if (!isNull _no) then {
                        _isrec = GV(_no,GVAR(recaptured));
                        if (!isNil "_isrec") then {
                            _objstatus = "Failed";
                            _color = "ColorRed";
                            [_target_name, _current_target_pos,"ELLIPSE",_color,[_target_radius,_target_radius],"",0,"Marker","FDiagonal"] call FUNC(CreateMarkerLocal);
                        } else {
                            __tmarker;
                        };
                    } else {
                        __tmarker;
                    };

                    call compile format [_taskstr,_target_name,_res + 2];
                };
            };
        };
    };
#else
    if (count __XJIPGetVar(resolved_targets) > 0) then {
        for "_i" from 0 to (count __XJIPGetVar(resolved_targets) - 1) do {
            if (isNil {__XJIPGetVar(resolved_targets)} || {_i == count __XJIPGetVar(resolved_targets)}) exitWith {};
            _xres = __XJIPGetVar(resolved_targets) select _i;
            _res = _xres select 0;
            _winner = _xres select 1;
            __tctn;
            _color = switch (_winner) do {
                case 1: {"ColorBlue"};
                case 2: {"ColorRed"};
                case 3: {"ColorGreen"};
            };
            __tmarker;
            call compile format [_taskstr,_target_name,_res + 2];
        };
    };
#endif

    GVAR(current_seize) = "";
    if (__XJIPGetVar(GVAR(current_target_index)) != -1 && {!__XJIPGetVar(target_clear)}) then {
        __TargetInfo;
        _current_target_pos = _target_array2 select 0;
        GVAR(current_seize) = _current_target_name;
        _target_radius = _target_array2 select 2;	
    #ifndef __TT__
        _color = "ColorRed";
    #else
        _color = "ColorYellow";
    #endif
        [_current_target_name, _current_target_pos,"ELLIPSE",_color,[_target_radius,_target_radius]] call FUNC(CreateMarkerLocal);
        QGVAR(dummy_marker) setMarkerPosLocal _current_target_pos;
        _objstatus = "Created";
        call compile format [(_taskstr + "d_current_task = d_task%2;"), _current_target_name, __XJIPGetVar(GVAR(current_target_index)) + 2];
    };
};

{
    if (typeName _x == "ARRAY") then {
        [_x select 0, _x select 1,"ICON",_x select 3,[1,1],format [(localize "STR_DOM_MISSIONSTRING_517"), _x select 2],0,"mil_triangle"] call FUNC(CreateMarkerLocal);
    };
} forEach __XJIPGetVar(GVAR(wreck_marker));

if (GVAR(MissionType) != 2) then {
    _counterxx = 0;
    {
        _pos = position _x;
        [format [QGVAR(paraflag%1), _counterxx], _pos,"ICON","ColorYellow",[0.5,0.5],"Parajump",0,"mil_flag"] call FUNC(CreateMarkerLocal);
        
        __INC(_counterxx);
        if (GVAR(jumpflag_vec) == "") then {
            _x addaction [(localize "STR_DOM_MISSIONSTRING_296") call FUNC(BlueText),"AAHALO\x_paraj.sqf"];
        } else {
            _text = format [(localize "STR_DOM_MISSIONSTRING_297"), [GVAR(jumpflag_vec),0] call FUNC(GetDisplayName)];
            _x addAction [_text call FUNC(BlueText),"x_client\x_bike.sqf",[GVAR(jumpflag_vec),1]];
        };
    } forEach __XJIPGetVar(jump_flags);
};

if (GVAR(MissionType) != 2 && {!__XJIPGetVar(GVAR(mt_radio_down))} && {__XJIPGetVar(mt_radio_pos) select 0 != 0}) then {
    [QGVAR(main_target_radiotower), __XJIPGetVar(mt_radio_pos),"ICON","ColorBlack",[0.5,0.5],(localize "STR_DOM_MISSIONSTRING_521"),0,"mil_dot"] call FUNC(CreateMarkerLocal);
};

if (GVAR(MissionType) != 2 && {count __XJIPGetVar(GVAR(currentcamps)) > 0}) then {
    {
        if (!isNull _x) then {
#ifndef __TT__
            _mcol = switch (GV(_x,GVAR(SIDE))) do {
                case "WEST": {if (GVAR(own_side) == "EAST") then {"ColorBlack"} else {"ColorBlue"}};
                case "EAST": {if (GVAR(own_side) == "WEST") then {"ColorBlack"} else {"ColorBlue"}};
            };
#else
            _mcol = switch (GV(_x,GVAR(SIDE))) do {
                case "WEST": {"ColorBlue"};
                case "EAST": {"ColorRed"};
                case "GUER": {"ColorBlack"};
            };
#endif
            [format[QGVAR(camp%1),GV(_x,GVAR(INDEX))], getPosASL _x,"ICON",_mcol,[0.5,0.5],"",0,"Strongpoint"] call FUNC(CreateMarkerLocal);
        };
    } forEach __XJIPGetVar(GVAR(currentcamps));
};

if (__XJIPGetVar(all_sm_res)) then {GVAR(current_mission_text) = (localize "STR_DOM_MISSIONSTRING_522")} else {[false] spawn FUNC(getsidemissionclient)};

if (GVAR(without_nvg) == 1) then {
    #define __paddweap(xweap) if (!(_p hasWeapon #xweap)) then {_p addWeapon #xweap}
    __paddweap(NVGoggles);
} else {
    if (player hasWeapon "NVGoggles") then {player removeWeapon "NVGoggles"};
    execFSM "fsms\RemoveGoogles.fsm";
};
_weapop = weapons player;
if (!("Binocular_Vector" in _weapop) && {!("Laserdesignator" in _weapop)}) then {
    __paddweap(Binocular);
};
__paddweap(ItemGPS);

if (sunOrMoon == 0) then {_p action ["NVGoggles",_p]};

__cppfln(FUNC(x_playerspawn),x_client\x_playerspawn.sqf);

GVAR(pl_killer) = objNull;
GVAR(pl_killer_t) = 0;
GVAR(dublicate_kill) = false;

__cppfln(FUNC(x_dlgopen),x_client\x_open.sqf);
player addMPEventHandler ["MPKilled", {_this call FUNC(x_checkkill)}];

xr_use_dom_opendlg = false;
FUNC(prespawned) = {
    if (!isNil QUOTE(FUNC(x_dlgopen))) then {
        if (GVAR(WithRevive) == 0) then {
            if (__pGetVar(xr_lives) > -1) then {
                if (xr_use_dom_opendlg) then {
                    call FUNC(x_dlgopen);
                    xr_use_dom_opendlg = false;
                };
            };
        } else {
            call FUNC(x_dlgopen);
        };
    };
    
    [1, _this] call FUNC(x_playerspawn);
};

FUNC(calculatePerks) = {
    private ["_respawned","_score","_points"];
    PARAMS_1(_respawned);
    
    _score = score player;
    _points = ((floor(_score / 15) * 2) max 0) min 14;
    
    _perks_unlocked = __pGetVar(GVAR(perks_unlocked));
    _points_available = __pGetVar(GVAR(perk_points_available));
    
    for "_i" from 1 to 7 do {
        if (_score >= (_i * 15) && {(count _perks_unlocked + _points_available) < (_i * 2)}) then {
            __pSetVar [QGVAR(perk_points_available), _points - count _perks_unlocked];
        };
    };
    
    if (_respawned) then {
        if (_points < (count _perks_unlocked + _points_available)) then {
            if (_points < count _perks_unlocked) then {
                (format [
                    (localize "STR_DOM_MISSIONSTRING_1454"),
                    (count _perks_unlocked - _points)
                ]) call FUNC(HQChat);
                
                _perks_unlocked resize _points;
            };
            
            __pSetVar [QGVAR(perk_points_available), (_points - count _perks_unlocked)];
        };
        
        call FUNC(resetPerks);
    };
};

FUNC(resetPerks) = {
    __pSetVar ["perkSelfHeal", false]; // Set as GVAR
    [0] call xr_fnc_setselfheals;
    __pSetVar ["perkVehicleService", false]; // Set as GVAR
    __pSetVar [QGVAR(eng_can_repfuel), false];
    __pSetVar [QGVAR(perkCanFlyAttackAircraft), false];
    __pSetVar ["perkCallDrop", false]; // Set as GVAR
    __pSetVar ["perkSaveLayout", false]; // Set as GVAR
    __pSetVar [QGVAR(WithMHQTeleport), false];
    __pSetVar [QGVAR(ammobox_next), 300];
    __pSetVar ["perkHalo", false]; // Set as GVAR
    __pSetVar ["perkFlip", false]; // Set as GVAR
    
    call FUNC(replenishPerks);
};

FUNC(unlockPerk) = {
    private ["_perk","_actions"];
    PARAMS_2(_perk,_actions);
    
    switch (_perk) do {
        case 1: {
            __pSetVar ["perkSelfHeal", true];
            
            [1] call xr_fnc_setselfheals;
            
            if (_actions) then {
                call xr_fnc_selfheal;
            };
        };
        
        case 2: {
            __pSetVar ["perkVehicleService", true];
            __pSetVar [QGVAR(eng_can_repfuel), true];
        };
        
        case 3: {
            __pSetVar [QGVAR(perkCanFlyAttackAircraft), true];
        };
        
        case 4: {
            __pSetVar ["perkCallDrop", true];
            
            if (_actions) then {
                call xr_fnc_calldrop;
            };
        };
        
        case 5: {
            __pSetVar ["perkSaveLayout", true];
            
            if (_actions) then {
                {
                    _x addAction [(localize "STR_DOM_MISSIONSTRING_300") call FUNC(BlueText), "x_client\x_savelayout.sqf",[],2,false,true,"","player getVariable 'perkSaveLayout'"];
                    _x addAction [(localize "STR_DOM_MISSIONSTRING_301") call FUNC(BlueText), "x_client\x_clearlayout.sqf",[],2,false,true,"","player getVariable 'perkSaveLayout'"];
                } forEach (allMissionObjects GVAR(the_box));
            };
        };
        
        case 6: {
            __pSetVar [QGVAR(WithMHQTeleport), true];
        };
        
        case 7: {
            __pSetVar [QGVAR(ammobox_next), 120];  
        };
        
        case 8: {
            __pSetVar ["perkHalo", true];
            
            if (_actions) then {
                {
                    if (_x isKindOf "Air") then {
                        _x addAction [(localize "STR_DOM_MISSIONSTRING_259") call FUNC(YellowText),"x_client\x_halo.sqf",[],0,false,true,"","player getVariable 'perkHalo' && {vehicle player != player} && {((vehicle player) call d_fnc_GetHeight) > 100}"]
                    };
                } forEach vehicles;
            };
        };
        
        case 9: {
            __pSetVar ["perkFlip", true];
            
            if (_actions) then {
                {
                    if (_x isKindOf "LandVehicle") then {
                        _x addAction [(localize "STR_DOM_MISSIONSTRING_162") call FUNC(YellowText), "x_client\x_flipatv.sqf", 0, -1, false, false, "", "player getVariable 'perkFlip' && {!(player in _target)} && {((vectorUp _target) select 2) < 0.6}"];
                    };
                } forEach vehicles;
            };
        };
    };
};

FUNC(replenishPerks) = {
    {
        [_x, false] call FUNC(unlockPerk);
    } forEach __pGetVar(GVAR(perks_unlocked));
};

player addEventHandler ["respawn", {[true] call FUNC(calculatePerks);_this call FUNC(prespawned)}];

if (count __XJIPGetVar(GVAR(ammo_boxes)) > 0) then {
    private ["_box_pos", "_boxnew", "_boxscript", "_box_dir"];
    {
        if (typeName _x == "ARRAY") then {
            _box_pos = _x select 0;
            _box_dir = _x select 2;
            if ((_x select 1) != "") then {[_x select 1, _box_pos,"ICON","ColorBlue",[0.5,0.5],(localize "STR_DOM_MISSIONSTRING_523"),0,GVAR(dropped_box_marker)] call FUNC(CreateMarkerLocal)};
            _boxnew = GVAR(the_box) createVehicleLocal _box_pos;
            _boxnew setDir _box_dir;
            _boxnew setPos _box_pos;
            {
                if (_x == 5) exitWith {
                    _boxnew addAction [(localize "STR_DOM_MISSIONSTRING_300") call FUNC(BlueText), "x_client\x_savelayout.sqf"];
                    _boxnew addAction [(localize "STR_DOM_MISSIONSTRING_301") call FUNC(BlueText), "x_client\x_clearlayout.sqf"];
                };
            } forEach __pGetVar(GVAR(perks_unlocked));
            [_boxnew] call FUNC(weaponcargo);
            _boxnew allowDamage false;
        };
    } forEach __XJIPGetVar(GVAR(ammo_boxes));
};

GVAR(player_can_call_drop) = 0;
GVAR(player_can_call_arti) = 0;
GVAR(player_can_build_trench) = false;
__pSetVar [QGVAR(isinaction), false];

__cppfln(FUNC(spawn_mash),x_client\x_mash.sqf);
__cppfln(FUNC(spawn_mgnest),x_client\x_mgnest.sqf);
__cppfln(FUNC(DirIndicator),scripts\fn_dirindicator.sqf);
__cppfln(FUNC(Sandstorm),scripts\fn_sandstorm.sqf);
__cppfln(FUNC(VehicleTow),dll_tow\tow.sqf);

{
    if (_x isKindOf "ATV_US_EP1" && {_x getVariable "dll_tow_isTowing"}) then {
        [_x, (_x getVariable "dll_tow_vehicleTowee")] spawn FUNC(VehicleTow);
    };
} forEach vehicles;

diag_log ["Internal D Version:",__DOM_NVER_STR2__];

__pSetVar [QGVAR(WithMHQTeleport), false];
__pSetVar [QGVAR(ammobox_next), 300];
__pSetVar [QGVAR(trench), objNull];
__pSetVar [QGVAR(trenchid), -9999];

__pSetVar ["bis_fnc_halo_now", false];
__pSetVar [QGVAR(showperks), _p addAction [(localize "STR_DOM_MISSIONSTRING_1451") call FUNC(GreyText), "x_client\x_showperks.sqf",[],-2,false,true,"","!(player getVariable 'bis_fnc_halo_now')"]];
__pSetVar [QGVAR(showstatus), _p addAction [(localize "STR_DOM_MISSIONSTRING_304") call FUNC(GreyText), "x_client\x_showstatus.sqf",[],-3,false,true,"","!(player getVariable 'bis_fnc_halo_now')"]];

if (GVAR(string_player) in GVAR(can_use_artillery)) then {
    GVAR(player_can_call_arti) = switch (GVAR(string_player)) do {
        case "RESCUE": {1};
        case "RESCUE2": {2};
        default {0};
    };
    if (GVAR(player_can_call_arti) == 0) exitWith {};
    [GVAR(player_can_call_arti)] execVM "x_client\x_artiradiocheckold.sqf";
} else {
    enableEngineArtillery false;
};

if (GVAR(player_can_call_arti) == 0 && {!(GVAR(string_player) in GVAR(is_engineer))}) then {
    GVAR(player_can_build_trench) = true;
};

_respawn_marker = "";
#define __dml_w deleteMarkerLocal #respawn_west
#define __dml_e deleteMarkerLocal #respawn_east
#define __dml_g deleteMarkerLocal #respawn_guerrila
switch (GVAR(own_side)) do {
    case "GUER": {
        _respawn_marker = "respawn_guerrila";
        __dml_w;
        __dml_e;
    };
    case "WEST": {
        _respawn_marker = "respawn_west";
        __dml_g;
        __dml_e;
    };
    case "EAST": {
        _respawn_marker = "respawn_east";
        __dml_w;
        __dml_g;
    };
};

#define __rmsmpl _respawn_marker setMarkerPosLocal
__rmsmpl markerPos "base_spawn_1";

__pSetVar [QGVAR(pbp_id), -9999];
GVAR(backpack_helper) = [];
__pSetVar [QGVAR(custom_backpack), []];
__pSetVar [QGVAR(player_backpack), []];
if (GVAR(WithBackpack)) then {
    GVAR(prim_weap_player) = primaryWeapon _p;
    _s = format [(localize "STR_DOM_MISSIONSTRING_155"), [GVAR(prim_weap_player),1] call FUNC(GetDisplayName)];
    if (GVAR(prim_weap_player) != "" && {GVAR(prim_weap_player) != " "}) then {
        __pSetVar [QGVAR(pbp_id), _p addAction [_s call FUNC(GreyText), "x_client\x_backpack.sqf",[],-1,false]];
    };
    // No Weapon fix for backpack
    [_pos, [0, 0, 0, false], ["NONE", "PRESENT", true], ["primaryWeapon player != d_prim_weap_player && primaryWeapon player != ' ' && !dialog","call {d_prim_weap_player = primaryWeapon player;_id = player getVariable 'd_pbp_id';if (_id != -9999 && count (player getVariable 'd_player_backpack') == 0) then {player removeAction _id;player setVariable ['d_pbp_id', -9999]};if ((player getVariable 'd_pbp_id' == -9999) && count (player getVariable 'd_player_backpack') == 0 && d_prim_weap_player != '' && d_prim_weap_player != ' ') then {player setVariable ['d_pbp_id', player addAction [format [localize 'STR_DOM_MISSIONSTRING_155', [d_prim_weap_player,1] call d_fnc_GetDisplayName] call d_fnc_GreyText, 'x_client\x_backpack.sqf',[],-1,false]]}}",""]] call FUNC(CreateTrigger);
};

GVAR(base_trigger) = createTrigger ["EmptyDetector", GVAR(base_array) select 0];
GVAR(base_trigger) setTriggerArea [GVAR(base_array) select 1, GVAR(base_array) select 2, GVAR(base_array) select 3, true];
GVAR(base_trigger) setTriggerActivation [GVAR(own_side_trigger), "PRESENT", true];
GVAR(base_trigger) setTriggerStatements ["this", "", ""];

GVAR(engineer_trigger) = createTrigger ["EmptyDetector", position player];
GVAR(engineer_trigger) setTriggerArea [0, 0, 0, true];
GVAR(engineer_trigger) setTriggerActivation ["NONE", "PRESENT", true];
GVAR(engineer_trigger) setTriggerStatements ["player getVariable 'd_eng_can_repfuel' && call d_fnc_sfunc", "d_actionID2 = player addAction ['Use Repair Kit' call d_fnc_BlueText, 'x_client\x_repengineer.sqf',[],0,false]", "player removeAction d_actionID2"];

GVAR(tow_trigger) = createTrigger ["EmptyDetector", position player];
GVAR(tow_trigger) setTriggerArea [0, 0, 0, true];
GVAR(tow_trigger) setTriggerActivation ["NONE", "PRESENT", true];
// If the player exits the vehicle with the context option then we won't know
// what vehicle the context option was bound to, requiring the (vehicle player)
// for when the player is inside and goes out of range, and nearestObjects
// for if a player ejects with the context option still present
GVAR(tow_trigger) setTriggerStatements ["call d_fnc_sfunc2", "d_actionID3 = (vehicle player) addAction ['Tow' call d_fnc_YellowText, 'dll_tow\enabletowing.sqf',[],5,false,true,'','player in _target']", "(vehicle player) removeAction d_actionID3; ; ((nearestObjects [player, ['ATV_US_EP1'], 5]) select 0) removeAction d_actionID3"];

// GVAR(towD_trigger) = createTrigger ["EmptyDetector", position player];
// GVAR(towD_trigger) setTriggerArea [0, 0, 0, true];
// GVAR(towD_trigger) setTriggerActivation ["NONE", "PRESENT", true];
// GVAR(towD_trigger) setTriggerStatements [
//     "_towing = (thisTrigger getVariable (nearestObjects [player, ['ATV_US_EP1'], 15]) select 0) getVariable 'dll_tow_isTowing'; (!isNil '_towing' && {_towing})",
//     "d_actionID4 = (thisTrigger getVariable ((nearestObjects [player, ['ATV_US_EP1'], 15]) select 0) addAction ['Detach' call d_fnc_YellowText, 'dll_tow\detach.sqf',[],5,false,true,'','!(player in _target)']",
//     "(thisTrigger getVariable ((nearestObjects [player, ['ATV_US_EP1'], 15]) select 0) removeAction d_actionID4"
// ];

// _x addAction [(localize "STR_DOM_MISSIONSTRING_513") call FUNC(BlueText), "x_client\x_restoreeng.sqf"]} forEach (__XJIPGetVar(GVAR(farps)));

GVAR(there_are_enemies_atbase) = false;
GVAR(enemies_near_base) = false;

// Enemy at base
"enemy_base" setMarkerPosLocal (GVAR(base_array) select 0);
"enemy_base" setMarkerDirLocal (GVAR(base_array) select 3);
[GVAR(base_array) select 0, [GVAR(base_array) select 1, GVAR(base_array) select 2, GVAR(base_array) select 3, true], [GVAR(enemy_side), "PRESENT", true], ["'Man' countType thislist > 0 || {'Tank' countType thislist > 0} || {'Car' countType thislist > 0}", "[0] call d_fnc_BaseEnemies;'enemy_base' setMarkerSizeLocal [d_base_array select 1,d_base_array select 2];d_there_are_enemies_atbase = true", "[1] call d_fnc_BaseEnemies;'enemy_base' setMarkerSizeLocal [0,0];d_there_are_enemies_atbase = false"]] call FUNC(CreateTrigger);
[GVAR(base_array) select 0, [(GVAR(base_array) select 1) + 300, (GVAR(base_array) select 2) + 300, GVAR(base_array) select 3, true], [GVAR(enemy_side), "PRESENT", true], ["'Man' countType thislist > 0 || {'Tank' countType thislist > 0} || {'Car' countType thislist > 0}", "hint (localize 'STR_DOM_MISSIONSTRING_1409');d_enemies_near_base = true", "d_enemies_near_base = false"]] call FUNC(CreateTrigger);

GVAR(player_can_build_mgnest) = false;
if (GVAR(with_mgnest) && {GVAR(string_player) in GVAR(can_use_mgnests)}) then {
    GVAR(player_can_build_mgnest) = true;
    __pSetVar [QGVAR(mgnest_pos), []];
};

GVAR(player_is_medic) = false;
if (GVAR(string_player) in GVAR(is_medic) && {GVAR(with_medtent)}) then {
    GVAR(player_is_medic) = true;
    __pSetVar [QGVAR(medtent), []];
};

// TODO: Remove those ?
if (!isNil QGVAR(action_menus_type) && {count GVAR(action_menus_type) > 0}) then {
    {
        _types = _x select 0;
        if (count _types > 0) then {
            if (_type in _types) then { 
                _action = _p addAction [(_x select 1) call FUNC(GreyText),_x select 2,[],-1,false];
                _x set [3, _action];
            };
        } else {
            _action = _p addAction [(_x select 1) call FUNC(GreyText),_x select 2,[],-1,false];
            _x set [3, _action];
        };
    } forEach GVAR(action_menus_type);
};
if (!isNil QGVAR(action_menus_unit) && {count GVAR(action_menus_unit) > 0}) then {
    {
        _types = _x select 0;
        _ar = _x;
        if (count _types > 0) then {
            {
                private "_pc";
                _pc = __getMNsVar(_x);
                if (_p ==  _pc) exitWith { 
                    _action = _p addAction [(_ar select 1) call FUNC(GreyText),_ar select 2,[],-1,false];
                    _ar set [3, _action];
                };
            } forEach _types
        } else {
            _action = _p addAction [(_x select 1) call FUNC(GreyText),_x select 2,[],-1,false];
            _x set [3, _action];
        };
    } forEach GVAR(action_menus_unit);
};

if (!isNil QGVAR(action_menus_vehicle) && {count GVAR(action_menus_vehicle) > 0}) then {
    execVM "x_client\x_vecmenus.sqf";
};

#define __facset _pos = _element select 0;\
_dir = _element select 1;\
_fac = "Land_budova2_ruins" createVehicleLocal _pos;\
_fac setDir _dir
#define __facset2 _pos = _element select 0;\
_dir = _element select 1;\
_fac = "Land_vez_ruins" createVehicleLocal _pos;\
_fac setDir _dir
if (__XJIPGetVar(GVAR(jet_serviceH)) && {!__XJIPGetVar(GVAR(jet_s_reb))}) then {
    _element = GVAR(aircraft_facs) select 0;
    switch (true) do {
        case (__COVer): {__facset};
        case (__OAVer): {__facset2};
    };
};
if (__XJIPGetVar(GVAR(chopper_serviceH)) && {!__XJIPGetVar(GVAR(chopper_s_reb))}) then {
    _element = GVAR(aircraft_facs) select 1;
    switch (true) do {
        case (__COVer): {__facset};
        case (__OAVer): {__facset2};
    };
};
if (__XJIPGetVar(GVAR(wreck_repairH)) && {!__XJIPGetVar(GVAR(wreck_s_reb))}) then {
    _element = GVAR(aircraft_facs) select 2;
    switch (true) do {
        case (__COVer): {__facset};
        case (__OAVer): {__facset2};
    };
};

if (GVAR(WithJumpFlags) == 0) then {GVAR(ParaAtBase) = 1};

_tactionar = [(localize "STR_DOM_MISSIONSTRING_533") call FUNC(GreyText),"x_client\x_teleport.sqf"];
GVAR(FLAG_BASE) addAction _tactionar;
if (GVAR(ParaAtBase) == 0) then {
    GVAR(FLAG_BASE) addaction [(localize "STR_DOM_MISSIONSTRING_296") call FUNC(GreyText),"AAHALO\x_paraj.sqf"];
};

if (GVAR(ParaAtBase) == 1) then {
    _s = QGVAR(Teleporter);
    _sn = (localize "STR_DOM_MISSIONSTRING_534");
    _s setMarkerTextLocal _sn;
};

GVAR(heli_taxi_available) = true;
_trigger = createTrigger ["EmptyDetector", _pos];
_trigger setTriggerText (localize "STR_DOM_MISSIONSTRING_535");
_trigger setTriggerActivation ["HOTEL", "PRESENT", true];
_trigger setTriggerStatements ["this", "0 = [] execVM 'x_client\x_airtaxi.sqf'",""];

GVAR(vec_end_time) = -1;

if (isMultiplayer) then {
    0 spawn {
        scriptName "spawn_sendplayerstuff";
        sleep (0.5 + random 2);
        [QGVAR(p_varn), [getPlayerUID player,GVAR(string_player),GVAR(player_side)]] call FUNC(NetCallEventCTS);
    };
};

[] exec "\ca\modules\Clouds\data\scripts\BIS_CloudSystem.sqs";

if (GVAR(LimitedWeapons)) then {
    GVAR(poss_weapons) = [];
    for "_i" from 0 to (count GVAR(limited_weapons_ar) - 2) do {
        _ar = GVAR(limited_weapons_ar) select _i;
        if (GVAR(string_player) in (_ar select 0)) exitWith {GVAR(poss_weapons) =+ _ar select 1};
    };
    if (count GVAR(poss_weapons) == 0) then {GVAR(poss_weapons) =+ (GVAR(limited_weapons_ar) select (count GVAR(limited_weapons_ar) - 1)) select 1};
    execFSM "fsms\LimitWeapons.fsm";
    GVAR(limited_weapons_ar) = nil;
};

execVM "x_msg\x_playernamehud.sqf";

if (GVAR(MissionType) != 2) then {
    execFSM "fsms\CampDialog.fsm";
};

_primw = primaryWeapon _p;
if (_primw != "") then {
    _p selectWeapon _primw;
    _muzzles = getArray(configFile >>"cfgWeapons" >> _primw >> "muzzles");
    _p selectWeapon (_muzzles select 0);
};

player addEventHandler ["fired", {_this call FUNC(ParaExploitHandler)}];

__pSetVar [QGVAR(p_f_b), 0];

FUNC(KickPlayerBaseFired) = {
    private "_num";
    if !(serverCommandAvailable "#shutdown") then {
        if (player in (list GVAR(player_base_trig))) then {
            private "_ta";
            _ta = _this select 4;
            if (_ta isKindOf "TimeBombCore" || {_ta == "ACE_PipebombExplosion"}) then {
                if (count _this > 6) then {
                    deleteVehicle (_this select 6);
                };
                if (GVAR(kick_base_satchel) == 0) then {
                    [QGVAR(p_f_b_k), [player, GVAR(name_pl),1]] call FUNC(NetCallEventCTS);
                } else {
                    [QGVAR(p_bs), [player, GVAR(name_pl),1]] call FUNC(NetCallEventCTS);
                };
            } else {
                if (!GVAR(there_are_enemies_atbase) && {!GVAR(enemies_near_base)} && {!(getText(configFile >> "CfgAmmo" >> _ta >> "simulation") in ["shotSmoke", "shotIlluminating", "shotNVGMarker", "shotCM"])}) then {
                    _num = __pGetVar(GVAR(p_f_b));
                    __INC(_num);
                    __pSetVar [QGVAR(p_f_b), _num];
                    if !(player in (list GVAR(player_base_trig2))) then {
                        if (GVAR(player_kick_shootingbase) != 1000) then {
                            if (_num >= GVAR(player_kick_shootingbase)) then {
                                if (isNil {__pGetVar(GVAR(pfbk_announced))}) then {
                                    [QGVAR(p_f_b_k), [player, GVAR(name_pl),0]] call FUNC(NetCallEventCTS);
                                    __pSetVar [QGVAR(pfbk_announced), true];
                                };
                            } else {
                                hint (localize "STR_DOM_MISSIONSTRING_537");
                            };
                        } else {
                            if (_num >= GVAR(player_kick_shootingbase)) then {
                                [QGVAR(p_bs), [player, GVAR(name_pl),0]] call FUNC(NetCallEventCTS);
                            };
                        };
                    };
                };
            };
        } else {
            __pSetVar [QGVAR(p_f_b), 0];
        };
    };
};

GVAR(player_base_trig) = createTrigger["EmptyDetector" ,GVAR(base_array) select 0];
GVAR(player_base_trig) setTriggerArea [GVAR(base_array) select 1, GVAR(base_array) select 2, GVAR(base_array) select 3, true];
GVAR(player_base_trig) setTriggerActivation [GVAR(own_side_trigger), "PRESENT", true];
GVAR(player_base_trig) setTriggerStatements["this", "", ""];

GVAR(player_base_trig2) = createTrigger["EmptyDetector" ,position GVAR(FLAG_BASE)];
GVAR(player_base_trig2) setTriggerArea [25, 25, 0, false];
GVAR(player_base_trig2) setTriggerActivation [GVAR(own_side_trigger), "PRESENT", true];
GVAR(player_base_trig2) setTriggerStatements["this", "", ""];

player addEventHandler ["fired", {_this call FUNC(KickPlayerBaseFired)}];

if (GVAR(no_3rd_person) == 0) then {
    execFSM "fsms\3rdperson.fsm";
};

GVAR(msg_hud_array) = [];
FUNC(AddHudMsg) = {
    GVAR(msg_hud_array) set [count GVAR(msg_hud_array), _this];
};

GVAR(last_hud_msgs) = [];
FUNC(HudDispMsgEngine) = {
    while {true} do {
        waitUntil {count GVAR(msg_hud_array) > 0 && {alive player} && {!GVAR(msg_hud_shown)} && {!__pGetVar(xr_pluncon)}};
        [GVAR(msg_hud_array) select 0] spawn FUNC(HudDispMsg);
        GVAR(last_hud_msgs) set [count GVAR(last_hud_msgs), GVAR(msg_hud_array) select 0];
        if (count GVAR(last_hud_msgs) > 20) then {
            GVAR(last_hud_msgs) set [0,-1];
            GVAR(last_hud_msgs) = GVAR(last_hud_msgs) - [-1];
        };
        GVAR(msg_hud_array) set [0,-1];
        GVAR(msg_hud_array) = GVAR(msg_hud_array) - [-1];
    };
};

0 spawn FUNC(HudDispMsgEngine);

GVAR(msg_hud_shown) = false;
FUNC(HudDispMsg) = {
    scriptName "func_HudDispMsg";
    // TODO: Length should depend on message size
    private ["_msg", "_hud", "_control", "_cpos", "_control2", "_cpos2", "_endtime"];
    PARAMS_1(_msg);
    if (GVAR(msg_hud_shown)) exitWith {};
    GVAR(msg_hud_shown) = true;
    disableSerialization;
    89643 cutRsc [QGVAR(message_hud),"PLAIN"];
    _hud = __uiGetVar(DMESSAGE_HUD);
    _control = _hud displayCtrl 1000;
    _cpos = ctrlPosition _control;
    _control ctrlSetPosition [_cpos select 0, SafeZoneY + SafeZoneH - 0.07, _cpos select 2, _cpos select 3];
    _control2 = _hud displayCtrl 1001;
    _control2 ctrlSetText _msg;
    _cpos2 = ctrlPosition _control2;
    _control2 ctrlSetPosition [_cpos2 select 0, SafeZoneY + SafeZoneH - 0.068, _cpos2 select 2, _cpos2 select 3];
    _control ctrlCommit 0.5;
    _control2 ctrlCommit 0.5;
    _endtime = time + 19;
    waitUntil {time > _endtime || {!alive player} || {__pGetVar(xr_pluncon)}};
    _control ctrlSetPosition _cpos;
    _control2 ctrlSetPosition _cpos2;
    _control ctrlCommit 0.5;
    _control2 ctrlCommit 0.5;
    GVAR(msg_hud_shown) = false;
};

__ccppfln(x_client\x_marker.sqf);
__ccppfln(x_client\x_playerammobox.sqf);

0 spawn {
    scriptName "spawn_overcast";
    waitUntil {sleep 0.123;!isNil {__XJIPGetVar(GVAR(overcast))}};
    GVAR(lastovercast) = __XJIPGetVar(GVAR(overcast));
    0 setOvercast GVAR(lastovercast);
    execFSM "fsms\WeatherClient.fsm";
};

if (!isClass (configFile >> "CfgPatches" >> "ace_main")) then {
    GVAR(mag_check_open) = false;
    __pSetVar [QGVAR(lastgdfcheck), -1];
    FUNC(KeyDownGDF) = {
        private "_ret";
        _ret = false;
        if (_this select 1 == 34 && {(_this select 2)}) then {
            if (!alive player || {__pGetVar(xr_pluncon)}) exitWith {false};
            if (time - __pGetVar(GVAR(lastgdfcheck)) < 1 || {GVAR(mag_check_open)}) exitWith {true};
            GVAR(mag_check_open) = true;
            135923 cutRsc [QGVAR(RscGearFast),"PLAIN DOWN"];
            __pSetVar [QGVAR(lastgdfcheck), time];
            _ret = true;
        };
        _ret
    };

    (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call d_fnc_KeyDownGDF"];
};

GVAR(rscCrewTextShownTimeEnd) = -1;
FUNC(MouseWheelRec) = {
    private ["_ct", "_role", "_rpic", "_t", "_ctrl", "_dospawn", "_crewok", "_sidepp"];
    if (!alive player || {__pGetVar(xr_pluncon)}) exitWith {false};
    _ct = if (vehicle player == player) then {
        cursorTarget
    } else {
        vehicle player
    };
    if (isNull _ct || {!alive _ct} || {_ct distance player > 20} || {(!(_ct isKindOf "Car") && {!(_ct isKindOf "Tank")} && {!(_ct isKindOf "Air")})} || {_ct isKindOf "ParachuteBase"} || {getNumber(configFile >> "CfgVehicles" >> typeOf _ct >> "isBicycle") == 1} || {(_ct call FUNC(GetAliveCrew)) == 0}) exitWith {false};
    // TODO: Whenever countFriendly will get fixed so that it works with vehicle crew arrays too then change again
    // if (player countFriendly (crew _ct) == 0) exitWith {false};
    _sidepp = side (group player);
    _crewok = false;
    {
        if (alive _x && {_sidepp getFriend side (group _x) >= 0.6}) exitWith {
            _crewok = true;
        };
    } forEach (crew _ct);
    if (!_crewok) exitWith {false};
    
    _ar_P = [];
    _ar_AI = [];

    {
        if (alive _x) then {
            if (isPlayer _x) then {
                _ar_P set [count _ar_P, _x];
            } else {
                _ar_AI set [count _ar_AI, _x];
            };
        };
        sideFriendly
    } foreach (crew _ct);

    _s_p = "";
    if (count _ar_P > 0) then {
        _s_p = "<t align='left'>";
        {
            _role = assignedVehicleRole _x;
            if (count _role > 0) then {
                private "_rpic";
                if (commander _ct == _x) then {
                    _rpic = __UI_Path(i_commander_ca.paa);
                } else {
                    if (driver _ct == _x) then {
                        _rpic = __UI_Path(i_driver_ca.paa);
                    } else {
                        _rpic = switch (toUpper (_role select 0)) do {
                            case "TURRET": {__UI_Path(i_gunner_ca.paa)};
                            default {__UI_Path(i_cargo_ca.paa)};
                        };
                    };
                };
                _s_p = _s_p + "<img image='" + _rpic + "'/> " + (name _x) + "<br/>";
            };
        } foreach _ar_P;
        _s_p = _s_p + "</t>";
    };

    _s_ai = "";
    if (count _ar_AI > 0) then {
        _s_ai = "<t align='left'>";
        {
            _role = assignedVehicleRole _x;
            if (count _role > 0) then {
                private "_rpic";
                if (commander _ct == _x) then {
                    _rpic = __UI_Path(i_commander_ca.paa);
                } else {
                    if (driver _ct == _x) then {
                        _rpic = __UI_Path(i_driver_ca.paa);
                    } else {
                        _rpic = switch (toUpper (_role select 0)) do {
                            case "DRIVER": {__UI_Path(i_driver_ca.paa)};
                            case "TURRET": {__UI_Path(i_gunner_ca.paa)};
                            default {__UI_Path(i_cargo_ca.paa)};
                        };
                    };
                };
                _s_ai = _s_ai + "<img image='" + _rpic + "'/> " + (name _x) + " (AI)" + "<br/>";
            };
        } foreach _ar_AI;
        _s_ai = _s_ai + "</t>";
    };

    _t = "<t size='0.6'><t align='left'>" + (localize "STR_DOM_MISSIONSTRING_538") + " " + ([typeOf _ct, 0] call FUNC(GetDisplayName)) + ":</t>" + "<br/>" + _s_p + _s_ai + "</t>";
    121282 cutRsc [QGVAR(rscCrewText), "PLAIN"];
    _ctrl = __uiGetVar(GVAR(rscCrewText)) displayCtrl 9999;
    _ctrl ctrlSetStructuredText parseText _t;
    _ctrl ctrlCommit 0;
    _dospawn = GVAR(rscCrewTextShownTimeEnd) == -1;
    GVAR(rscCrewTextShownTimeEnd) = time + 5;
    if (_dospawn) then {
        0 spawn {
            scriptName "spawn_crewrsc";
            private "_vecp";
            _vecp = vehicle player;
            waitUntil {sleep 0.221;time > GVAR(rscCrewTextShownTimeEnd) || {!alive player} || {__pGetVar(xr_pluncon)} || {vehicle player != _vecp}};
            121282 cutRsc ["Default", "PLAIN"];
            GVAR(rscCrewTextShownTimeEnd) = -1;
        };
    };
};

(findDisplay 46) displayAddEventHandler ["MouseZChanged", "_this call d_fnc_MouseWheelRec"];
if (GVAR(WithRevive) == 0) then {
    __ccppfln(x_revive.sqf);
};

#ifdef __TOH__
GVAR(CurPIPVideoTarget) = objNull;

FUNC(setVideoPipTarget) = {
    if (GVAR(still_in_intro)) exitWith {};
    if (!isNil "KEGs_SPECTATINGON") exitWith {};
    private ["_poscam"];
    GVAR(CurPIPVideoTarget) = __XJIPGetVar(GVAR(CurPIPVideoTarget));
    if (!isNil QGVAR(PIP_screenCam)) then {
        detach GVAR(PIP_screenCam);
    };
    _poscam = (vehicle GVAR(CurPIPVideoTarget)) modelToWorld [0, -5, 2];
    if (isNil QGVAR(PIP_screenCam)) then {
        GVAR(PIP_screenCam) = "camera" camCreate _poscam;
        GVAR(PIP_screenCam) camPrepareFov 0.100;
        GVAR(PIP_screenCam) cameraEffect ["INTERNAL", "BACK", QGVAR(rendertarget0)];
        GVAR(video_wall1) setObjectTexture [0, "#(argb,256,256,1)r2t(d_rendertarget0,1.0)"];
        QGVAR(rendertarget0) setPiPEffect [0];
    } else {
        detach GVAR(PIP_screenCam);
        GVAR(PIP_screenCam) camSetPos _poscam;
    };
    GVAR(PIP_screenCam) camPrepareTarget (vehicle GVAR(CurPIPVideoTarget));
    GVAR(PIP_screenCam) camCommitPrepared 0;
    GVAR(PIP_screenCam) attachTo [vehicle GVAR(CurPIPVideoTarget), [0,-5,2]];
    GVAR(pipt_isinvec) = vehicle GVAR(CurPIPVideoTarget) != GVAR(CurPIPVideoTarget);
};

0 spawn {
    scriptName "spawn_pip_checking";
    waitUntil {sleep 0.312;!GVAR(still_in_intro)};
    waitUntil {sleep 0.312; !isNil {__XJIPGetVar(GVAR(CurPIPVideoTarget))}};
    waitUntil {sleep 0.312; !isNull __XJIPGetVar(GVAR(CurPIPVideoTarget))};
    while {true} do {
        waitUntil {sleep 0.123;isNil "KEGs_SPECTATINGON"};
        if ((GVAR(pipt_isinvec) && {(vehicle GVAR(CurPIPVideoTarget) == GVAR(CurPIPVideoTarget))}) || {(!GVAR(pipt_isinvec) && {(vehicle GVAR(CurPIPVideoTarget) != GVAR(CurPIPVideoTarget))})) then {
            GVAR(pipt_isinvec) = !GVAR(pipt_isinvec);
            if (!isNil QGVAR(PIP_screenCam)) then {
                detach GVAR(PIP_screenCam);
            };
            GVAR(PIP_screenCam) camPrepareTarget (vehicle GVAR(CurPIPVideoTarget));
            GVAR(PIP_screenCam) camCommitPrepared 0;
            GVAR(PIP_screenCam) attachTo [vehicle GVAR(CurPIPVideoTarget), [0,-5,2]];
        };
        sleep 1.211;
    };
};

if (!isNil {__XJIPGetVar(GVAR(CurPIPVideoTarget))}) then {
    0 spawn {
        scriptName "spawn_pipcheck2";
        waitUntil {sleep 0.312;!GVAR(still_in_intro)};
        if (!isNull __XJIPGetVar(GVAR(CurPIPVideoTarget))) then {
            call FUNC(setVideoPipTarget);
        };
    }
};
#endif

if (isMultiplayer) then {
    execVM "x_client\x_respawnblock.sqf";
};

__cppfln(FUNC(x_chop_hudsp),x_client\x_chop_hud.sqf);
__cppfln(FUNC(x_vec_hudsp),x_client\x_vec_hud.sqf);

if (GVAR(MHQDisableNearMT) != 0) then {
    FUNC(mhqCheckNearTarget) = {
        scriptName "d_fnc_mhqCheckNearTarget";
        private ["_vec", "_ti"];
        _vec = vehicle player;
        while {GVAR(player_in_vec)} do {
            if (fuel _vec != 0 && {player == driver _vec}) then {
                _ti = __XJIPGetVar(GVAR(current_target_index));
                if (_ti != -1) then {
                    _current_target_pos = (GVAR(target_names) select _ti) select 0;
                    if (_vec distance _current_target_pos <= GVAR(MHQDisableNearMT)) then {
                        _vec setVariable [QGVAR(vecfuelmhq), fuel _vec, true];
                        _vec setFuel 0;
                        [QGVAR(mqhtn), GV(_vec,GVAR(vec_name))] call FUNC(NetCallEventToClients);
                        [format [(localize "STR_DOM_MISSIONSTRING_520"), GVAR(MHQDisableNearMT), _this], "HQ"] call FUNC(HintChatMsg);
                    };
                };
            };
            sleep 0.531;
        };
        GVAR(playerInMHQ) = false;
    };
};

{
    GVAR(check_ammo_load_vecs) set [_forEachIndex, toUpper _x];
} forEach GVAR(check_ammo_load_vecs);

GVAR(playerInMHQ) = false;
GVAR(player_in_vec) = false;
FUNC(vehicleScripts) = {
    GVAR(player_in_vec) = true;
    private ["_vec", "_isAir"];
    _vec = vehicle player;
    if ((_vec isKindOf "ParachuteBase") || {_vec isKindOf "BIS_Steerable_Parachute"}) exitWith {};
    _isAir = _vec isKindOf "Air";
    __TRACE_2("d_fnc_vehicleScripts","_vec","_isAir");
    if (_isAir && {_vec isKindOf "Helicopter" || typeOf _vec == "MV22"} && {GVAR(WithChopHud)}) then {
        0 spawn FUNC(x_chop_hudsp);
    };
    if (!_isAir && {GVAR(vechud_on) == 0} && {((_vec isKindOf "LandVehicle" && {!(_vec isKindOf "StaticWeapon")}) || {_vec isKindOf "StaticWeapon" && {!(_vec isKindOf "ACE_SpottingScope")} && {!(_vec isKindOf "StaticATWeapon")}})}) then {
        0 spawn FUNC(x_vec_hudsp);
    };
    if (!_isAir && {GVAR(MHQDisableNearMT) != 0} && {!GVAR(playerInMHQ)}) then {
        _vt = GV(_vec,GVAR(vec_type));
        if (isNil "_vt") then {_vt = ""};
        if (_vt == "MHQ") then {
            GVAR(playerInMHQ) = true;
            0 spawn FUNC(mhqCheckNearTarget);
        };
    };
    if (GVAR(without_vec_ti) == 0) then {
        _vec disableTIEquipment true;
    };
    if (GVAR(WithRepStations) == 0) then {execFSM "fsms\RepStation.fsm"};
    
    if (toUpper (typeOf _vec) in GVAR(check_ammo_load_vecs)) then {
        [GVAR(AMMOLOAD)] execFSM "fsms\AmmoLoad.fsm";
    };
};

[_pos, [0, 0, 0, false], ["NONE", "PRESENT", true], ["vehicle player != player && {alive player} && {!(player getVariable 'xr_pluncon')}", "call d_fnc_vehicleScripts","d_player_in_vec = false"]] call FUNC(CreateTrigger);

player setVariable ["d_p_isadmin", false];

FUNC(startClientScripts) = {
    private ["_vec", "_type"];
    
    if (!alive player || {(player getVariable 'xr_pluncon')}) exitWith {};
    if (__pGetVar(GVAR(p_isadmin))) exitWith {};
    
    if (isMultiplayer && {serverCommandAvailable "#shutdown"}) then {
        __pSetVar [QGVAR(p_isadmin), true];
        execFSM "fsms\isAdmin.fsm";
    };
    
    if (__pGetVar(GVAR(perkCanFlyAttackAircraft))) exitWith {};

    _vec = vehicle player;
    if (_vec != player && {_vec isKindOf "Air"}) then {
        _type = typeOf _vec;
        if (toUpper(_type) in GVAR(attack_aircraft)) then {
            if (player == driver _vec || {player == gunner _vec} || {player == commander _vec}) then {
                if (isEngineOn _vec) then {
                    _vec engineOn false;
                    player action ["engineOff", _vec];
                };
                player action ["Eject", _vec];
                hint (localize "STR_DOM_MISSIONSTRING_1452");
            };
        };
    };
};

{
    _x addAction [format [(localize "STR_DOM_MISSIONSTRING_1453"), "Medkits"] call FUNC(BlueText), "x_client\x_restoreheals.sqf",[],2,false,true,"","(player getVariable 'perkSelfHeal') && {(player getVariable 'xr_numheals') < 1}"];
} forEach [MEDIC_TENT1, MEDIC_TENT2];

{
    _x addAction [format [(localize "STR_DOM_MISSIONSTRING_1453"), "Repair Kits"] call FUNC(BlueText), "x_client\x_restoreeng.sqf",[],2,false,true,"","(player getVariable 'perkVehicleService') && {!(player getVariable 'd_eng_can_repfuel')}"];
} forEach [SERVICE_POINT1, SERVICE_POINT2, SERVICE_POINT3];

[_pos, [0, 0, 0, false], ["NONE", "PRESENT", false], ["call d_fnc_startClientScripts;false", "", ""]] call FUNC(CreateTrigger);

if (isMultiplayer) then {execVM "x_client\x_intro.sqf"};

deleteVehicle GVAR(client_init_trig);
GVAR(client_init_trig) = nil;

diag_log [diag_frameno, diag_ticktime, time, "Dom x_setupplayer.sqf processed"];
