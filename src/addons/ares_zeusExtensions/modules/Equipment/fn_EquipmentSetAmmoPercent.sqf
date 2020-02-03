#include "\ares_zeusExtensions\module_header.hpp"

if (isNil "Ares_Set_Unit_Ammo_Function") then
{
	Ares_Set_Unit_Ammo_Function =
	{
		_unit = _this select 0;
		_ammo = _this select 1;
		_unit setVehicleAmmoDef _ammo;
	};
};

_unit = [_logic] call Ares_fnc_GetUnitUnderCursor;

if (alive _unit) then
{
	_dialogResult = [
		"Change Damage",
		[
			["Ammo", ["0%", "10%", "20%", "30%", "40%", "50%", "60%", "70%", "80%", "90%", "100%"]]
		]
	] call Ares_fnc_ShowChooseDialog;

	if (count _dialogResult == 0) exitWith { [objNull, "Aborted"] call bis_fnc_showCuratorFeedbackMessage; };

	_ammo = (_dialogResult select 0)*0.1;

	[objNull, format["Setting %1's ammo to %2", typeOf _unit, _ammo*100]] call bis_fnc_showCuratorFeedbackMessage;

	[[_unit, _ammo], Ares_Set_Unit_Ammo_Function] remoteExec ["call", _unit];
};

#include "\ares_zeusExtensions\module_footer.hpp"
