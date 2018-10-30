rem Domination Build Batch

set MASTER=co30_Domination.Takistan
set VER=2.80
set D_VER=2_80
set D_RELEASE=3

set NEW_VER=co40_Domination_%D_VER%_West_CO.Takistan
set NEW_VER_L=co40_domination_%D_VER%_west_co.takistan
set MISSION_SQM=mission_west_oa.sqm
set X_SETUP=x_setup_west_oa.sqf

rem West OA
md %NEW_VER%
xcopy %MASTER%\*.* %NEW_VER% /E /Y
sqm %MISSION_SQM% -s briefingName * "co40 Domination CO! West [%VER%] [R%D_RELEASE%]" -o ddmnew.sqm
xcopy ddmnew.sqm %NEW_VER%\mission.sqm /Y
xcopy %X_SETUP% %NEW_VER%\x_setup.sqf /Y
cd %NEW_VER%
call setupcopy.bat
Rapify mission.sqm
del mission.sqm
move mission.sqm.bin mission.sqm
cd x_missions
rmdir /S /Q m
cd ..
cd x_client
del x_weaponcargo.sqf
del x_weaponcargo_ace.sqf
del x_weaponcargo_oa_ace.sqf
del x_weaponcargor.sqf
del x_weaponcargor_ace.sqf
del x_weaponcargor_oa_ace.sqf
cd ..
cd fsms
del HandleCamp.fsm
del XCheckSMHardTargetTT.fsm
del HandleCampsTT2.fsm
del TTPoints.fsm
cd ..
cd ..
MakePbo -N -A %NEW_VER%
move %NEW_VER%.pbo %NEW_VER_L%.pbo

rem cleanup
rmdir /S /Q %NEW_VER%
del ddmnew.sqm