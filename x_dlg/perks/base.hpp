class XD_PerkDialog {
    idd = -1;
    movingEnable = 1;
    onLoad = "uiNamespace setVariable ['X_PERK_DIALOG', _this select 0];d_perk_dialog_open = true";
    onUnLoad = "uiNamespace setVariable ['X_PERK_DIALOG', nil];d_perk_dialog_open = false";
    objects[] = {};
    class controlsBackground {
        class PerksDialogBackground: XD_RscPicture
        {
            text = "\ca\ui\data\ui_background_controls_ca.paa";
            x = 0.40332 * safezoneW + safezoneX;
            y = 0.225 * safezoneH + safezoneY;
            w = 0.246459 * safezoneW;
            h = 0.551297 * safezoneH;
        };
    };
    class controls {
        class DialogBackground: XC_RscText
        {
            x = 0.404166 * safezoneW + safezoneX;
            y = 0.27963 * safezoneH + safezoneY;
            w = 0.19073 * safezoneW;
            h = 0.422593 * safezoneH;
            colorBackground[] = {200,200,200,0.4};
        };
        #include "partial\icons\background.hpp"
        #include "partial\button.hpp"
        #include "partial\bar.hpp"
        #include "partial\icons\image.hpp"
        #include "partial\icons\overlay.hpp"
        class MenuText: X3_RscText
        {
            text = "Perks";
            x = 0.392351 * safezoneW + safezoneX;
            y = 0.247222 * safezoneH + safezoneY;
            w = 0.0652083 * safezoneW;
            h = 0.0230556 * safezoneH;
        };
        class AvailablePointsText: X3_RscText
        {
            text = "Available points:";
            x = 0.49677 * safezoneW + safezoneX;
            y = 0.247223 * safezoneH + safezoneY;
            w = 0.0959376 * safezoneW;
            h = 0.0244444 * safezoneH;
        };
        class AvailablePointsValue : X3_RscText {
            idc = 1;
            x = 0.53477 * safezoneW + safezoneX;
            y = 0.247223 * safezoneH + safezoneY;
            w = 0.0959376 * safezoneW;
            h = 0.0244444 * safezoneH;
            text = "";
        };
        class CloseButton: XD_ButtonBase
        {
            text = "Close";
            action = "CloseDialog 0";
            x = 0.522135 * safezoneW + safezoneX;
            y = 0.705325 * safezoneH + safezoneY;
            w = 0.0678125 * safezoneW;
            h = 0.0596295 * safezoneH;
        };
    };
};