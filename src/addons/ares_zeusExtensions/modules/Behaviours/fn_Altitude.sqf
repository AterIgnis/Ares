#include "\ares_zeusExtensions\module_header.hpp"

_unit = [_logic] call Ares_fnc_GetUnitUnderCursor;

if (alive _unit) then
{
	_dialogResult = [
		"Flight parameters",
		[
			["Speed", ["Limited", "Normal", "Full"]],
			["Altitude", [], 100]
		]
	] call Ares_fnc_ShowChooseDialog;

	if (count _dialogResult == 0) exitWith { [objNull, "Aborted"] call bis_fnc_showCuratorFeedbackMessage; };

	_speed = _dialogResult select 0;
	_altitude = parseNumber (_dialogResult select 1);

	switch (_speed) do {
		case 0: {
			_speed = "LIMITED";
		};
		case 1: {
			_speed = "NORMAL";
		};
		case 2: {
			_speed = "FULL";
		};
	};
	_unit setSpeedMode _speed;
	_unit flyInHeight _altitude;
};

#include "\ares_zeusExtensions\module_footer.hpp"
