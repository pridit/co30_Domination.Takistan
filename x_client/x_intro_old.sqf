// by Xeno
#define THIS_FILE "x_intro_old.sqf"
#include "x_setup.sqf"
if (!X_Client) exitWith {};

disableSerialization;

GVAR(still_in_intro) = true;
titleText ["", "BLACK IN",3];
1 fadeSound 1;

sleep 4;
#ifdef __CO__
playMusic "Track07_Last_Men_Standing";
#endif
#ifdef __OA__
playMusic "EP1_Track01D";
#endif

#ifndef __TT__
titleText ["D O M I N A T I O N ! 2\n\nOne Team", "PLAIN DOWN", 1];
#else
titleText ["D O M I N A T I O N ! 2\n\nTwo Teams", "PLAIN DOWN", 1];
#endif

sleep 2;
55 cutRsc ["dXlabel","PLAIN"];

GVAR(still_in_intro) = false;

sleep 12;

private "_uidcheck_done";
_uidcheck_done = false;
if (GVAR(reserved_slot) != "" && {str(player) == GVAR(reserved_slot)}) then {
    _uidcheck_done = true;
    execVM "x_client\x_reservedslot.sqf";
};
if (!_uidcheck_done && {count GVAR(uid_reserved_slots) > 0} && {count GVAR(uids_for_reserved_slots) > 0}) then {
    for "_xi" from 0 to (count GVAR(uid_reserved_slots) - 1) do {
        GVAR(uid_reserved_slots) set [_xi, toUpper (GVAR(uid_reserved_slots) select _xi)];
    };
    if (toUpper str(player) in GVAR(uid_reserved_slots)) then {
        if !(getPlayerUID player in GVAR(uids_for_reserved_slots)) then {
            execVM "x_client\x_reservedslot2.sqf";
        };
        GVAR(uid_reserved_slots) = nil;
        GVAR(uids_for_reserved_slots) = nil;
    };
};

sleep 10;
123123 cutText [localize "STR_DOM_MISSIONSTRING_1434", "PLAIN DOWN"];
xr_phd_invulnerable = false;
__pSetVar ["ace_w_allow_dam", nil];
