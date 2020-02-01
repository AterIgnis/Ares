/*
	Gets list of sensors in missiles from magazine.
	
	Parameters:
		0 - Magazine class to get ammo sensors for
		
	Returns:
		list of sensors for ammo in magazine
*/

_magazineClass = _this select 0;

_ammoClass = getText (configFile >> "CfgMagazines" >> _magazineClass >> "ammo");
_ammoClass = configFile >> "CfgAmmo" >> _ammoClass;

_sensorManager = _ammoClass >> "Components" >> "SensorsManagerComponent";
_types = [];
if (isNull _sensorManager) then {
  if (getNumber (_ammoClass >> "nvLock") > 0) then { _types pushBack "NVSensorComponent"; };
  if (getNumber (_ammoClass >> "laserLock") > 0) then { _types pushBack "LaserSensorComponent"; };
  if (getNumber (_ammoClass >> "laserLock") > 0) then { _types pushBack "LaserSensorComponent"; };
} else {
  _types = configProperties [_sensorManager >> "Components"] apply { getText (_x >> "componentType") };
};

_types;
