#define THIS_FILE "init.sqf"
diag_log format ["############################# %1 #############################", missionName];
diag_log [diag_frameno, diag_ticktime, time, "Executing Dom init.sqf"];

#include "x_setup.sqf"

// just a check to prevent init.sqf running more than once
// shouldn't happen, but we want to be sure :)
if (!isNil QGVAR(init_started)) exitWith {
    diag_log [diag_frameno, diag_ticktime, time, "Dom init.sqf executed more than once"];
};
GVAR(init_started) = true;
GVAR(IS_HC_CLIENT) = false;

if (isMultiplayer && {!isDedicated}) then {
    enableRadio false;
    0 fadeSound 0;
    titleText ["", "BLACK FADED"];
};

if (!isDedicated) then {
    GVAR(client_init_trig) = createTrigger ["EmptyDetector", [0,0,0]];
    GVAR(client_init_trig) setTriggerArea [0,0,0,false];
    GVAR(client_init_trig) setTriggerActivation ["NONE", "PRESENT", false];
    GVAR(client_init_trig) setTriggerTimeout [1, 1, 1, false];
    X_INIT = false;
    GVAR(client_init_trig) setTriggerStatements ["X_INIT && {!isNil 'd_init_processed'}", "diag_log [diag_frameno, diag_tickTime, time, 'Executing Dom local player JIP trigger'];call compile preprocessFileLineNumbers 'x_client\x_jip.sqf'", ""];
    onPreloadFinished {GVAR(preloaddone) = true; onPreloadFinished {}};
    execVM "tasks.sqf";
    execVM "BTK\Cargo Drop\Start.sqf";
};

enableSaving [false,false];
enableTeamSwitch false;

if (isServer) then {
#ifdef __ACE__
    ace_sys_aitalk_enabled = true;
    publicVariable "ace_sys_aitalk_enabled";
    ace_sys_aitalk_radio_enabled = true;
    publicVariable "ace_sys_aitalk_radio_enabled";
    ace_sys_tracking_markers_enabled = false;
    publicVariable "ace_sys_tracking_markers_enabled";
    ace_sys_repair_default_tyres = true;
    publicVariable "ace_sys_repair_default_tyres";
#endif

    //GVAR(domdatabase) = ("Arma2Net.Unmanaged" callExtension "DomDatabase ['Init','DomDatabase','Dom.db']") == "[]";
    GVAR(domdatabase) = false;
    publicVariable QGVAR(domdatabase);
    __TRACE_1("","d_domdatabase")
    if (GVAR(domdatabase)) then {
        GVAR(server_name) = "Arma2Net.Unmanaged" callExtension "DomDatabase ['Servername']";
        __TRACE_1("","d_server_name")
        publicVariable QGVAR(server_name);
    };
};

// process d_init in one frame
GVAR(init_obj) = "HeliHEmpty" createVehicleLocal [0, 0, 0];
GVAR(init_obj) addEventHandler ["killed", {__ccppfln(d_init.sqf);deleteVehicle GVAR(init_obj);GVAR(init_obj) = nil}];
GVAR(init_obj) setDamage 1;

diag_log [diag_frameno, diag_ticktime, time, "Dom init.sqf processed"];
