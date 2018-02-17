#include "\ares_zeusExtensions\module_header.hpp"

_target = position _logic;

FindById = {
  _array = _this select 0;
  _id = _this select 1;
  _found = -1;
  for [{_i=0},{_found==-1 && _i<count _array},{_i=_i+1}] do {
    _check = (_array select _i) select 0;
    if (
        (
         (_check select 0)==(_id select 0)
        ) && (
         (_check select 1)==(_id select 1)
        ) && (
         (_check select 2)==(_id select 2)
        )
       ) then { _found = _i; };
  };
  _found;
};
SumAmmo = {
  _mags = _this select 0;
  _type = _this select 1;
  _total = 0;
  {
    if ((_x select 0)==_type) then { _total = _total + (_x select 1) };
  } foreach _mags;
  _total;
};

_allBatteries = allMissionObjects "Ares_Module_Artillery_Battery";
_allBatteries = [_allBatteries, [], { _x getVariable ["SortOrder", 0]; }, "ASCEND"] call BIS_fnc_sortBy;

_shooters = [];
_addedVehcles = [];
{
  _battery = _x;
  _vehicles = synchronizedObjects _battery;

  {
    _vehicle = _x;
    while {vehicle _vehicle != _vehicle} do {
      _vehicle = vehicle _vehicle;
    };
    if (_addedVehcles find _vehicle == -1) then
    {
      _addedVehcles = _addedVehcles + [_vehicle];

//      if (unitReady _vehicle) then
//      {
        _vehicleType = typeOf _vehicle;
        _ammos = getArtilleryAmmo [_vehicle];

        {
          _ammo = _x;

          if (_target inRangeOfArtillery [[_vehicle], _ammo]) then
          {
            _mags = (magazinesAmmo _vehicle);
            _ammoLeft = ([_mags, _ammo] call SumAmmo);

            _id = [_battery,_vehicleType,_ammo];

            _idx = [_shooters,_id] call FindById;
            if (_idx==-1) then {
              _shooters pushBack [_id, [_vehicle], [_ammoLeft]];
            } else {
              _row = _shooters select _idx;
              _row set [1, (_row select 1)+[_vehicle]];
              _row set [2, (_row select 2)+[_ammoLeft]];
              _shooters set [_idx, _row];
            };
          };
        } foreach _ammos;
//      };
    };
  } foreach _vehicles;
} foreach _allBatteries;

_options = [];
{
  _id = _x select 0;
  _battery = _id select 0;
  _vehicleType = _id select 1;
  _units = _id select 1;
  _ammo = _id select 2;
  
  _batteryName = _battery getVariable ["Name", name _battery];
  _vehicleName = getText(configfile >> "CfgVehicles" >> _vehicleType >> "displayName");
  _ammoName = getText(configfile >> "CfgMagazines" >> _ammo >> "displayName");
  _ammoCounts = _x select 2;

  _name = format ["%1: %2 x%3 : %4 %5",_batteryName,_vehicleName,count _units,_ammoName,_ammoCounts];
  _options pushBack _name;
} foreach _shooters;

if (count _options == 0) exitWith { ["No-one can fire."] call Ares_fnc_ShowZeusMessage; };

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

_option = _shooters select (_pickModeResult select 0);
_units = (_option select 1);
_ammo = (_option select 0) select 2;
_rounds = (_pickModeResult select 1);
if (_rounds == 0) then {
  _rounds = getNumber (configFile >> "CfgMagazines" >> _ammo >> "count");
};
_announce = (_pickModeResult select 2);

_etaMin = -1;
_etaMax = -1;
_assignedGuns = [];
_side = sideUnknown;
{
  _eta = round (_x getArtilleryETA [_target, _ammo]);
  if (_eta>=0) then {
    if ((_etaMin == -1) || (_eta<_etaMin)) then { _etaMin = _eta; };
    if ((_etaMax == -1) || (_eta>_etaMax)) then { _etaMax = _eta; };

    if (_side isEqualTo sideUnknown) then { _side = side _x; };

    [[_x, _target, _ammo, _rounds], "Ares_FireArtilleryFunction", _x] call BIS_fnc_MP;
    _assignedGuns pushBack _x;
  };
} forEach _units;

if (count _assignedGuns > 0) then {
  if (_announce > 0 && !(_side isEqualTo sideUnknown)) then { [[_side, format ["Commencing firing %1 rounds at target. ETA %2-%3 seconds.",_rounds,_etaMin,_etaMax]], "Ares_CommandChat"] call BIS_fnc_MP; };

  _ammoName = getText(configfile >> "CfgMagazines" >> _ammo >> "displayName");
  ["Firing %1x%2 rounds of '%3' at target. ETA %4-%5", count _assignedGuns, _rounds, _ammoName, _etaMin,_etaMax] call Ares_fnc_ShowZeusMessage;

  if (_announce > 0 && !(_side isEqualTo sideUnknown)) then {
    {
      waituntil { unitReady _x };
    } foreach _assignedGuns;
    [[_side, format ["Shots fired."]], "Ares_CommandChat"] call BIS_fnc_MP;
  }
};

#include "\ares_zeusExtensions\module_footer.hpp"
