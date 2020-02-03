#include "\ares_zeusExtensions\module_header.hpp"

if (isNil "Ares_Set_Unit_Pylons") then
{
  Ares_Set_Unit_Pylons =
  {
    _unit = _this select 0;
    _args = _this select 1;
    _unit setPylonLoadOut _args;
  };
};

_logic = _this select 0;
_activated = _this select 2;

if (_activated && local _logic) then {
  _unit = [_logic] call Ares_fnc_GetUnitUnderCursor;
  
  if (!isNull _unit && alive _unit) then {
    _class = typeOf _unit;
    _allPylons = "true" configClasses (configFile >>  "CfgVehicles" >> _class >> "Components" >> "TransportPylonsComponent" >> "Pylons") apply {configName _x};
    _pylonPaths = (configProperties [configFile >> "CfgVehicles" >> _class >> "Components" >> "TransportPylonsComponent" >> "Pylons", "isClass _x"]) apply {getArray (_x >> "turret")};
    _currentLoadout = getPylonMagazines _unit;
    if (count _allPylons > 0) then {
      _pylonsReal = [];
      _options = [];
      _values = [];
      _pylonPathsReal = [];
      {
        _pylon = _x;
        
        _compatible = (_class getCompatiblePylonMagazines _pylon);
        if (count _compatible > 0) then {
          _compatible = [""] + _compatible;
          
          _option = [];
          _value = [];
          
          _selected = _currentLoadout select _forEachIndex;

          {
            _mag = _x;
            _magname = _mag;
            if (_mag == "") then {
              _magname = "None";
            }
            else {
              _magname = getText (configFile >> "CfgMagazines" >> _mag >> "displayName");
              if (isNil "_magname") then { _magname = _mag; };

              _sensors = [_mag] call Ares_fnc_GetAmmoSensorsMapped;
              diag_log format ["%1", _sensors];
              if (count _sensors > 0) then {
                _magname = format ["%1 <%2>", _magname, (_sensors arrayIntersect _sensors) joinString ","];
              };
            };

            _option pushBack _magname;
            _value pushBack _mag;
          } foreach _compatible;

          _sidx = _value find _selected;
          if (_sidx < 0) then { _sidx = 0; };

          _pylonsReal pushBack _pylon;
          _options pushBack [_pylon, _option, _sidx];
          _values pushBack _value;
          _pylonPathsReal pushBack (_pylonPaths select _forEachIndex);
        };
      } foreach _allPylons;
      
      if (count _pylonsReal == 0) exitWith { ["No configurable pylons."] call Ares_fnc_ShowZeusMessage; };

      _pickLoadoutResult = [
        "Selet pylons",
        _options,
        false
      ] call Ares_fnc_ShowChooseDialog;

      if (count _pickLoadoutResult == 0) exitWith { ["Loadout change cancelled."] call Ares_fnc_ShowZeusMessage; };

      { _unit removeWeaponGlobal getText (configFile >> "CfgMagazines" >> _x >> "pylonWeapon") } forEach _currentLoadout;

      {
        _idx = (_pickLoadoutResult select _forEachIndex);
        _opts = (_values select _forEachIndex);
        if (_idx >= 0 && _idx < count _opts) then {
          _mag = _opts select _idx;
          [[_unit, [_x, _mag, true, _pylonPathsReal select _forEachIndex]], Ares_Set_Unit_Pylons] remoteExec ["call", _unit];
        };
      } foreach _pylonsReal;
    };
  };
};

#include "\ares_zeusExtensions\module_footer.hpp"
