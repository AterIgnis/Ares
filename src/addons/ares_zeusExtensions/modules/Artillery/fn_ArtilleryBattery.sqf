#include "\ares_zeusExtensions\module_header.hpp"

if (isNil "Ares_ArtilleryBatteryCount") then
{
  Ares_ArtilleryBatteryCount = 0;
};

// Don't delete this module when we're done the script.
_deleteModuleOnExit = false;

_targetPhoneticName = [Ares_ArtilleryBatteryCount] call Ares_fnc_GetPhoneticName;
_logic setName format ["Battery %1", _targetPhoneticName];
_logic setVariable ["Name", _targetPhoneticName];
_logic setVariable ["SortOrder", Ares_ArtilleryBatteryCount];
[objNull, format ["Created Artillery Battery '%1'", _targetPhoneticName]] call bis_fnc_showCuratorFeedbackMessage;
Ares_ArtilleryBatteryCount = Ares_ArtilleryBatteryCount + 1;
publicVariable "Ares_ArtilleryBatteryCount";

#include "\ares_zeusExtensions\module_footer.hpp"
