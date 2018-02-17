#include "\ares_zeusExtensions\module_header.hpp"

if (isNil "Ares_Set_Unit_Damage_Function") then
{
	Ares_Set_Unit_Damage_Function =
	{
		_unit = _this select 0;
		_comp = _this select 1;
		_dmg  = _this select 2;
		_unit setHitPointDamage [_comp, _dmg];
	};
	publicVariable "Ares_Set_Unit_Damage_Function";
};

_unitToDamage = [_logic] call Ares_fnc_GetUnitUnderCursor;

if (alive _unitToDamage) then
{
	_components = [];
	_componentNames = [];
	_list = getAllHitPointsDamage _unitToDamage;
	{
		if (_x!="") then { _components pushBack _x; _componentNames pushBack format ["%1 (%2%3 dmg)", _x, ((_list select 2) select _forEachIndex)*100, "%"]; };
	}
	foreach (_list select 0);

	if (count _components == 0) exitWith { [objNull, "No damageable components"] call bis_fnc_showCuratorFeedbackMessage; };

	_dialogResult = [
		"Change Damage",
		[
			["Component", _componentNames],
			["Damage", ["0%", "10%", "20%", "30%", "40%", "50%", "60%", "70%", "80%", "90%", "100%"]]
		]
	] call Ares_fnc_ShowChooseDialog;

	if (count _dialogResult == 0) exitWith { [objNull, "Aborted"] call bis_fnc_showCuratorFeedbackMessage; };

	_comp = _components select (_dialogResult select 0);
	_dmg  = (_dialogResult select 1)*0.1;

	[objNull, format["Setting %1's %2 damage to %3%4", typeOf _unitToDamage, _comp, _dmg*100,"%"]] call bis_fnc_showCuratorFeedbackMessage;

	[[_unitToDamage, _comp, _dmg], "Ares_Set_Unit_Damage_Function", _unitToDamage] call BIS_fnc_MP;

};

#include "\ares_zeusExtensions\module_footer.hpp"
