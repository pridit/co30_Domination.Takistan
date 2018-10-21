// by Xeno
#define THIS_FILE "x_radarkilled.sqf"
#include "x_setup.sqf"
private ["_radar", "_posrad", "_dirrad", "_typerad"];
if (!isServer) exitWith {};

PARAMS_1(_radar);
_posrad = position _radar;
_dirrad = direction _radar;
_posrad set [2,0];
_typerad = typeOf _radar;
deleteVehicle _radar;

GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"TellBaseRadarDown",true];

[_posrad, _dirrad, _typerad] spawn {
    scriptName "spawn_x_radarkilled1";
    private ["_posrad", "_dirrad", "_typerad", "_radar"];
    PARAMS_3(_posrad,_dirrad,_typerad);
    sleep (1200 + (random 1200));
    _radar = createVehicle [_typerad, _posrad, [], 0, "NONE"];
    _radar setDir _dirrad;
    _radar setPos _posrad;
    if (!isNil QGVAR(HC_CLIENT_OBJ)) then {
        [QGVAR(hSetVar), [GVAR(HC_CLIENT_OBJ), QGVAR(banti_airdown), false]] call FUNC(NetCallEventSTO);
    };
    GVAR(banti_airdown) = false;
    _radar addMPEventHandler ["MPkilled", {if (call FUNC(checkSHC)) then {GVAR(banti_airdown) = true};if (isServer) then {_this call FUNC(radarkilled)}}];
    GVAR(kb_logic1) kbTell [GVAR(kb_logic2),GVAR(kb_topic_side),"TellBaseRadarUpAgain",true];
};