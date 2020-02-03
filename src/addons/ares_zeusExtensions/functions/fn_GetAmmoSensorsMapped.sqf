/*
	Gets list of sensors in missiles from magazine.
	
	Parameters:
		0 - magazine class
		1 - sensor->string map
		2 - [Boolean/String] add unmapped types (false - ignore, true - add as original type, string - add this value)
		
	Returns:
		list of sensors for ammo in magazine
*/

_labels = [
  ["IRSensorComponent","IR"],
  ["NVSensorComponent","NV"],
  ["LaserSensorComponent","L"],
  ["ActiveRadarSensorComponent","AR"],
  ["PassiveRadarSensorComponent","PR"],
  ["VisualSensorComponent","V"],
  ["DataLinkSensorComponent","DL"]
];

_magazineClass = _this select 0;
_labels = [_this, 1, _labels] call BIS_fnc_param;
_addUnmapped = [_this, 2, false, [false,""]] call BIS_fnc_param;

_mappedTypes = [];
{
  _st = _x;
  _sti = _labels findIf { (_x select 0) == _st };
  if (_sti > -1) then {
    _mappedTypes pushBackUnique (_labels select _sti select 1);
  } else {
    if (_addUnmapped) then {
      if (typeName _addUnmapped == typeName "") then {
        _mappedTypes pushBackUnique _addUnmapped;
      } else {
        _mappedTypes pushBackUnique _st;
      };
    };
  };
} foreach ([_magazineClass] call Ares_fnc_GetAmmoSensors);

_mappedTypes;
