// by Xeno
//#define __DEBUG__
#define THIS_FILE "x_docreatenexttarget.sqf"
#include "x_setup.sqf"

player removeAllEventHandlers "handleDamage";
player addEventHandler ["handleDamage", {0}];
player setPos [-10000,10000,0];
player addEventHandler ["respawn", {
    player setPos [-10000,10000,0];
    player removeAllEventHandlers "handleDamage";
    player addEventHandler ["handleDamage", {0}];
}];

// TODO: somehow server scripts have to get started on this client...

deleteVehicle GVAR(client_init_trig);
GVAR(client_init_trig) = nil;

__ccppfln(x_shc\x_shcinit.sqf);

FUNC(weaponcargo) = nil;
FUNC(showstatus) = nil;
FUNC(showperks) = nil;
FUNC(settingsdialog) = nil;
FUNC(pnselchanged) = nil;
FUNC(pmmsgselchanged) = nil;
FUNC(pmrecchanged) = nil;
FUNC(pmrsendchanged) = nil;
FUNC(showmsg_dialog) = nil;
FUNC(x_dropammoboxd) = nil;
FUNC(x_loaddropped) = nil;
FUNC(x_deploymhq) = nil;
FUNC(x_teleport) = nil;
FUNC(x_beam_tele) = nil;
FUNC(x_update_target) = nil;
FUNC(SatellitenBildd) = nil;
FUNC(checktrucktrans) = nil;
FUNC(checkhelipilot) = nil;
FUNC(checkhelipilot_wreck) = nil;
FUNC(checkhelipilotout) = nil;
FUNC(checkenterer) = nil;
FUNC(checkdriver) = nil;
FUNC(infoText) = nil;
FUNC(getsidemissionclient) = nil;
FUNC(initvec) = nil;

_mpos = markerPos QGVAR(island_marker);
_mpos set [2,0];
if (str(_mpos) != "[0,0,0]") then {
    _msize = markerSize QGVAR(island_marker);
    GVAR(island_center) = [_msize select 0, _msize select 1, 300];
};
GVAR(island_x_max) = (GVAR(island_center) select 0) * 2;
GVAR(island_y_max) = (GVAR(island_center) select 1) * 2;

[QGVAR(docnt), {_this execVM "x_shc\x_docreatenexttarget.sqf"}] call FUNC(NetAddEventSTO);
[QGVAR(docountera), {execVM "x_shc\x_counterattack.sqf"}] call FUNC(NetAddEventSTO);
[QGVAR(dodel1), {(_this select 1) execFSM "fsms\DeleteUnits.fsm"}] call FUNC(NetAddEventSTO);
[QGVAR(dodel2), {
    GVAR(del_camps_stuff) = (_this select 1) select 2;
    (_this select 1) execFSM "fsms\DeleteEmpty.fsm"}
] call FUNC(NetAddEventSTO);
[QGVAR(hcexecsm), {
    GVAR(extra_mission_remover_array) = [];
    GVAR(extra_mission_vehicle_remover_array) = [];
    GVAR(side_mission_resolved) = false;
    GVAR(side_mission_winner) = 0;
    execVM (_this select 1);
}] call FUNC(NetAddEventSTO);
[QGVAR(hSetVar), {missionNamespace setVariable [_this select 1, _this select 2]}] call FUNC(NetAddEventSTO);
[QGVAR(smclear), {execFSM "fsms\XClearSidemission.fsm"}] call FUNC(NetAddEventSTO);

[QGVAR(hcready)] call FUNC(NetCallEventCTS);
