_cntnr = [_this, 0] call BIS_fnc_Param;
_varname = [_this, 1, "this", [""]] call BIS_fnc_Param;
_doClear = [_this, 2, true, [true]] call BIS_fnc_Param;

_result = "";
if (not isNull _cntnr) then
{
	_isSoldier = (_cntnr isKindOf "CAManBase");
	_isVehicle = (_cntnr isKindOf "car")
		|| (_cntnr isKindOf "tank")
		|| (_cntnr isKindOf "air")
		|| (_cntnr isKindOf "StaticWeapon")
		|| (_cntnr isKindOf "ship");

	if (_doClear) then { _result = _result + format ["removeAllContainers %1; ", _varname]; };

	if (_isSoldier) then {
		if (_doClear) then { _result = _result + format["removeAllWeapons %1; removeAllAssignedItems %1; removeHeadgear %1; removeGoggles %1; ", _varname]; };
		if((headgear _cntnr)!="") then { _result = _result + format ["%1 addHeadgear '%2'; ", _varname, headgear _cntnr]; };
		if((goggles _cntnr)!="") then { _result = _result + format ["%1 addGoggles '%2'; ", _varname, goggles _cntnr]; };
		if((uniform _cntnr)!="") then { _result = _result + format ["%1 addUniform '%2'; ", _varname, uniform _cntnr]; };
		if((vest _cntnr)!="") then { _result = _result + format ["%1 addVest '%2'; ", _varname, vest _cntnr]; };
		if((backpack _cntnr)!="") then { _result = _result + format ["%1 addBackPack '%2'; ", _varname, backpack _cntnr]; };

		{
			if((_x select 0)!="") then {
				if(count _x > 4) then {
					_result = _result + format ["%1 addmagazine ['%2',%3]; ", _varname, (_x select 4) select 0, (_x select 4) select 1];
				};
				_result = _result + format ["%1 addweapon '%2'; ", _varname, (_x select 0)];
			};
		} foreach (weaponsItems _cntnr);

		_result = _result + format ["removeAllPrimaryWeaponItems %1; removeAllSecondaryWeaponItems %1; removeAllHandgunWeaponItems %1; ", _varname];
		{ if(_x != "") then { _result = _result + format ["%1 addPrimaryWeaponItem '%2'; ", _varname, _x];}; } foreach (primaryWeaponItems _cntnr);
		{ if(_x != "") then { _result = _result + format ["%1 addSecondaryWeaponItem '%2'; ", _varname, _x];}; } foreach (secondaryWeaponItems _cntnr);
		{ if(_x != "") then { _result = _result + format ["%1 addHandgunWeaponItem '%2'; ", _varname, _x];}; } foreach (handgunItems _cntnr);
		{ _result = _result + format ["%1 linkItem '%2'; ", _varname, _x]; } foreach assignedItems _cntnr;

		([uniformContainer _cntnr, format ["(uniformContainer %1)", _varname]] call Ares_fnc_GetAddContentString);
		([vestContainer _cntnr, format ["(uniformContainer %1)", _varname]] call Ares_fnc_GetAddContentString);
		([backpackContainer _cntnr, format ["(uniformContainer %1)", _varname]] call Ares_fnc_GetAddContentString);
	} else {
		if (_doClear) then { _result = _result + format ["clearMagazineCargo %1; clearItemCargo %1; clearWeaponCargo %1; clearBackpackCargo %1; ", _varname]; };

		_mags = [];
		{
			_type = _x select 0;
			_ammo = _x select 1;
			_i = 0;
			for [{}, {_i!=-1 && _i < count _mags}, {_i=_i+1}] do {
				_mag = (_mags select _i);
				if ((_mag select 0) == _type && (_mag select 2) == _ammo) then {
					_mag set [1, (_mag select 1)+1];
					_i = -1;
				};
			};
			if (_i!=-1) then { _mags pushBack [_type, 1, _ammo]; };
		} foreach magazinesAmmoCargo _cntnr;
		{ _result = _result + format ["%1 addMagazineCargo ['%2', %3, %4]; ", _varname, _x select 0, _x select 1, _x select 2]; } foreach _mags;

		_cargo = getWeaponCargo _cntnr;
		{ _result = _result + format ["%1 addWeaponCargo ['%2', %3]; ", _varname, _x, (_cargo select 1) select _forEachIndex]; } foreach (_cargo select 0);

		_cargo = getItemCargo _cntnr;
		{ _result = _result + format ["%1 addItemCargo ['%2', %3]; ", _varname, _x, (_cargo select 1) select _forEachIndex]; } foreach (_cargo select 0);

		_cargo = getBackpackCargo _cntnr;
		{ _result = _result + format ["%1 addBackpackCargo ['%2', %3]; ", _varname, _x, (_cargo select 1) select _forEachIndex]; } foreach (_cargo select 0);

		{ ([_x select 1, _varname, false] call Ares_fnc_GetAddContentString); } foreach everyContainer _cntnr;
	};
};

_result;