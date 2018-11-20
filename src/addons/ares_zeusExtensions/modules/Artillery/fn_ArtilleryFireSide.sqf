//
_logic = _this select 0;
_side = _this select 1;

_target = position _logic;

SumAmmo = {
  _mags = _this select 0;
  _type = _this select 1;
  _total = 0;
  {
    if ((_x select 0) == _type) then { _total = _total + (_x select 1) };
  } foreach _mags;
  _total;
};

_groups = [];
{
  if (side _x == _side) then {
    _vehs = [];
    {
      _veh = _x;
      while { _veh != vehicle _veh } do { _veh = vehicle _veh; };
      _vehs pushBackUnique _veh;
    } foreach (units _x);

    if (count getArtilleryAmmo _vehs > 0) then {
      _groups pushBackUnique _x;
    };
  };
} forEach allGroups;

_artOptions = [];

{
  _group = _x;
  _vehicles = [];
  {
    _veh = _x;
    while { _veh != vehicle _veh } do { _veh = vehicle _veh; };
    _vehicles pushBackUnique _veh;
  } foreach (units _x);

  _ammos = getArtilleryAmmo _vehicles;
  {
    _ammo = _x;
    _allVehTypes = [];
    _allVehs = [];
    {
      _veh = _x;
      _vehType = typeOf _veh;
      
      _mags = (magazinesAmmo _veh);
      _ammoLeft = ([_mags, _ammo] call SumAmmo);

      if (_ammoLeft > 0) then {
        _allVehs pushBackUnique _veh;
        _allVehTypes pushBackUnique _vehType;
      };
    } foreach _vehicles;

    if (count _allVehTypes > 1) then {
      _allVehTypes pushBack "*";
    };

    {
      _vehType = _x;
      _okVehs = [];
      _okAmmos = [];

      {
        _veh = _x;
        if ((_vehType == "*" || _vehType == typeOf _veh) && _target inRangeOfArtillery [[_veh], _ammo]) then {
          _mags = (magazinesAmmo _veh);
          _ammoLeft = ([_mags, _ammo] call SumAmmo);

          _okVehs pushBack _veh;
          _okAmmos pushBack _ammoLeft;
        }
      } foreach _allVehs;

      if (count _okVehs > 0) then {
        _artOptions pushBack [groupId _group, _ammo, _vehType, _okVehs, _okAmmos];
      };

    } foreach _allVehTypes;
  } foreach _ammos;
} foreach _groups;

_artOptions sort true;

if (count _artOptions == 0) exitWith { ["No-one can fire."] call Ares_fnc_ShowZeusMessage; };

_options = _artOptions apply {
    _groupId = _x select 0;
    _ammoType = _x select 1;
    _vehicleType = _x select 2;
    _units = _x select 3;
    _ammo = _x select 4;

    _vehicleName = "?";
    if (_vehicleType == "*") then {
      _vehicleName = "All";
    }
    else {
      _vehicleName = getText(configfile >> "CfgVehicles" >> _vehicleType >> "displayName");
    };
    
    _ammoName = getText(configfile >> "CfgMagazines" >> _ammoType >> "displayName");

    format ["%1: %2 x%3 : %4 %5", _groupId, _vehicleName, count _units, _ammoName, _ammo];
};

_pickModeResult = [
  "Select fire mission.",
  [
    ["Type", _options],
    ["Rounds", ["Magazine","1", "2", "3", "4", "5", "6", "7", "8"]],
    ["Announce", ["No","Yes"], 1]
  ],
  false
] call Ares_fnc_ShowChooseDialog;

if (count _pickModeResult == 0) exitWith { ["Fire mission aborted."] call Ares_fnc_ShowZeusMessage; };

_option = _artOptions select (_pickModeResult select 0);
_groupId = _option select 0;
_ammo = _option select 1;
_units = _option select 3;

_rounds = (_pickModeResult select 1);
if (_rounds == 0) then {
  _rounds = getNumber (configFile >> "CfgMagazines" >> _ammo >> "count");
};
_announce = (_pickModeResult select 2);

_etaMin = -1;
_etaMax = -1;
_assignedGuns = [];
{
  _eta = round (_x getArtilleryETA [_target, _ammo]);
  if (_eta>=0) then {
    if ((_etaMin == -1) || (_eta<_etaMin)) then { _etaMin = _eta; };
    if ((_etaMax == -1) || (_eta>_etaMax)) then { _etaMax = _eta; };

    [[_x, _target, _ammo, _rounds], Ares_FireArtilleryFunction] remoteExec ["call", _x];
    _assignedGuns pushBack _x;
  };
} forEach _units;

if (count _assignedGuns > 0) then {
  _ammoName = getText(configfile >> "CfgMagazines" >> _ammo >> "displayName");

  if (_announce > 0) then {
    _text = format ["Commencing firing %1 rounds %2 at target. ETA %3-%4 seconds.",(count _assignedGuns) * _rounds, _ammoName, _etaMin, _etaMax];
    [[_side, _groupId, _text], Ares_CommandChat] remoteExec ["call", 0];
  };

  ["Firing %1x%2 rounds of '%3' at target. ETA %4-%5", count _assignedGuns, _rounds, _ammoName, _etaMin,_etaMax] call Ares_fnc_ShowZeusMessage;

  if (_announce > 0) then {
    sleep 5;
    {     
      waituntil { unitReady _x };
    } foreach _assignedGuns;
    [[_side, _groupId, format ["Shots fired."]], Ares_CommandChat] remoteExec ["call", 0];
  }
};
