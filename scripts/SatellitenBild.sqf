#define THIS_FILE "SatellitenBild.sqf"
#include "x_setup.sqf"
if (isNil QUOTE(FUNC(satelittenposf))) then {__cppfln(FUNC(satelittenposf),scripts\SatellitenPos.sqf)};

getpos Player spawn FUNC(satelittenposf);