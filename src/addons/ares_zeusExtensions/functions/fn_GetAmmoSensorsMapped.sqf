/*
	Gets list of sensors in missiles from magazine.
	
	Parameters:
		0 - magazine class
		1 - sensor->string map
		2 - [Boolean/String] add unmapped types (false - ignore, true - add as original type, string - add this value)
		
	Returns:
		list of sensors for ammo in magazine
*/

labels = [
  ["IRSensorComponent","IR"],
  ["NVSensorComponent","NV"],
  ["LaserSensorComponent","L"],
  ["ActiveRadarSensorComponent","AR"],
  ["PassiveRadarSensorComponent","PR"],
  ["VisualSensorComponent","V"],
  ["DataLinkSensorComponent","DL"],
];

magazineClass = _this select 0;
labels = [_this, 1, labels] call BIS_fnc_param;
addUnmapped = [_this, 2, false, [false,""]] call BIS_fnc_param;

_mappedTypes = [];
{
  _st = _x;
  _sti = labels findIf { (_x select 0) == _st };
  if (_sti > -1) then {
    _mappedTypes pushBackUnique (labels select _sti select 1);
  } else {
    if (addUnmapped) then {
      if (typeName addUnmapped == typeName "") then {
        _mappedTypes pushBackUnique addUnmapped;
      } else {
        _mappedTypes pushBackUnique _st;
      };
    };
  };
} foreach ([magazineClass] call Ares_fnc_GetAmmoSensors);

_mappedTypes;
