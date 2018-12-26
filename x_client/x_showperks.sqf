// by Xeno
#define THIS_FILE "x_showperks.sqf"
#include "x_setup.sqf"
#define __ctrl(vctrl) _ctrl = _XD_display displayCtrl vctrl
#define __ctrl2(ectrl) (_XD_display displayCtrl ectrl)
private ["_ctrl","_XD_display","_points","_unlocked"];
if (!X_Client) exitWith {};

disableSerialization;

createDialog "XD_PerkDialog";

_XD_display = __uiGetVar(X_PERK_DIALOG);

_points = GVAR(perk_points_available);
_unlocked = GVAR(perks_unlocked);

__ctrl(1) ctrlSetText (str _points);

if (_points > 0) then {
    for "_i" from 1 to 10 do {
        __ctrl2(_i + 200) ctrlSetText "\ca\ui\data\cmdbar_player_ca";
    };
};

{
    __ctrl2(_x + 100) ctrlSetText "\ca\ui\data\cmdbar_selected_ca";
    __ctrl2(_x + 200) ctrlSetText "";
} forEach _unlocked;

0 spawn {
    scriptName "spawn_waitforperkdialogclose";
    waitUntil {!GVAR(perk_dialog_open) || {!alive player} || {__pGetVar(xr_pluncon)}};
    if (GVAR(perk_dialog_open)) then {closeDialog 0};
};