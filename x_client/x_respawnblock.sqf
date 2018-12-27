// by Alex4 (fru)
#define THIS_FILE "x_respawnblock.sqf"
#include "x_setup.sqf"

disableSerialization;

sleep 10;

while {true} do {
    waitUntil {sleep 0.121;!isNull (findDisplay 49)};

    _ctrl = (findDisplay 49) displayCtrl 1010; //respawn control
    //_ctrl ctrlSetEventHandler ["ButtonClick", 'if ((side d_pl_killer == side player) || ((time - d_pl_killer_t) > 20)) then {d_pl_killer = objNull}; if (alive player) then {player SetDamage 1;};'];
    _ctrl ctrlEnable false;

    _enCtrl = [] spawn {
        scriptName "spawn_x_respawnblock";
        disableSerialization;
        
        _ctrl = (findDisplay 49) displayCtrl 1010;
        _stext = ctrlText _ctrl;
        for "_i" from 10 to 1 step -1 do {
            if (isNull (findDisplay 49)) exitWith {};	
            _text = _stext + format ["(%1)",_i]; _ctrl ctrlSetText _text;
            sleep 1;
        };
        if (!isNull (findDisplay 49)) then {
            _ctrl ctrlSetText _stext; _ctrl ctrlEnable true;
        };
    };

    waitUntil {sleep 0.12;isNull (findDisplay 49)};
    if (!scriptDone _enCtrl) then {terminate _enCtrl};
};