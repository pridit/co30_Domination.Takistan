// by Xeno
#define THIS_FILE "x_savelayout.sqf"
#include "x_setup.sqf"

if (primaryWeapon player == "") exitWith {(localize "STR_DOM_MISSIONSTRING_341") call FUNC(GlobalChat)};

GVAR(custom_layout) = [weapons player,magazines player];

__pSetVar [QGVAR(custom_backpack), if (count __pGetVar(GVAR(player_backpack)) > 0) then {
    [__pGetVar(GVAR(player_backpack)) select 0, __pGetVar(GVAR(player_backpack)) select 1]
} else {
    []
}];

(localize "STR_DOM_MISSIONSTRING_342") call FUNC(GlobalChat);