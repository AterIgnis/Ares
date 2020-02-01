//
#include "\ares_zeusExtensions\module_header.hpp"

_logic = _this select 0;
_activated = _this select 2;

if (isNil "Ares_disableDroneInteraction") then
{
  Ares_disableDroneInteraction =
  {
    _uav = _this select 0;
    _logic = _this select 1;
    while { not isNull _uav && alive _uav && not isNull _logic } do {
      player disableUAVConnectability [_uav, true];
      sleep 5;
    };
    if (not isNull _uav) then {
      player enableUAVConnectability [_uav, true];
    };
  };
};

if (isNil "Ares_Stop_Drone_Fire_At_Mark") then
{
  Ares_Stop_Drone_Fire_At_Mark =
  {
    _uav = _this;
    _uav doTarget objNull;
    _uav doWatch objNull;
    _uav doFollow leader _uav;
/*
    _i = 0;
    while { _i < count waypoints (group _uav) } do {
      if (waypointName [group _uav, _i] == "lase") then {
        deleteWaypoint [group _uav, _i];
      }
      else {
        _i = _i + 1;
      };
    };
*/
  };
};

if (_activated && local _logic) then {
  _unit = [_logic] call Ares_fnc_GetUnitUnderCursor;

  if (!isNull _unit && alive _unit) then {
    _weaps = [];
    _weapnames = [];
    {
      _name = getText (configFile >> "CfgWeapons" >> _x >> "displayName");
      _ammo = _unit ammo _x;
      if (_ammo > 0) then {
        _weaps pushBack _x;
        _weapnames pushBack _name;
      };
    } foreach weapons _unit;
    if (count _weapnames == 0) exitWith { ["No weapons"] call Ares_fnc_ShowZeusMessage; };

    _pickModeResult = [
      "Select weapon",
      [
        ["Weapon", _weapnames],
        ["Mode", ["Auto", "Semi-Auto", "Single"]],
        ["After Attack Flyoff (m)", [], 1000]
      ],
      false
    ] call Ares_fnc_ShowChooseDialog;
    if (count _pickModeResult == 0) exitWith { ["Cancelled"] call Ares_fnc_ShowZeusMessage; };
    _deleteModuleOnExit = false;
    
    _weap = _weaps select (_pickModeResult select 0);
    _freq = (_pickModeResult select 1);
    _radius = (_pickModeResult select 2);
    if (typeName _radius == typeName "1") then {
      _radius = parseNumber _radius;
    };

    [_logic, _unit] spawn {
      _logic = _this select 0;
      _uav = _this select 1;

      while { not isNull _logic && alive _uav} do
      {
        _pos = getPosASL _uav;
        _pos set [2, (_pos select 2) + 1.4];
        _logic setPosASL _pos;
        sleep 0.01;
      }
    };

    [_logic, _unit, _weap, _freq, _radius] spawn {
      _logic = _this select 0;
      _uav = _this select 1;
      _weap = _this select 2;
      _freq = _this select 3;
      _radius = _this select 4;
      if (_radius < 100) then {
        _radius = 100;
      };

      [[_uav, _logic], Ares_disableDroneInteraction] remoteExec ["spawn", 0, _logic];
      _uav disableAI "AUTOTARGET";
      _uav disableAI "FSM";
      _uav disableAI "SUPPRESSION";
      _uav disableAI "AUTOCOMBAT";
      _uav setBehaviour "COMBAT";
      _uav setSkill 1;

      _uav setVariable ["uav_laser_designation_module", _logic];
      _fireEventHandler = {};
      if (_freq != 0) then {
        _fireEventHandler = {
          _uav = _this select 0;
          _logic = _uav getVariable ["uav_laser_designation_module", objNull];
          if (isNull _logic) then {
            _uav removeEventHandler ["fired", _thisEventHandler];
          };

          _uav setVariable ["nextAttackTime", time + 5];
        };
      };
      if (_freq == 1) then {
        _fireEventHandler = {
          _uav = _this select 0;
          _logic = _uav getVariable ["uav_laser_designation_module", objNull];
          if (isNull _logic) then {
            _uav removeEventHandler ["fired", _thisEventHandler];
          };

          _uav call Ares_Stop_Drone_Fire_At_Mark;

          _uav setVariable ["nextAttackTime", time + 15];
        };
      };
      if (_freq == 2) then {
        _fireEventHandler = {
          _uav = _this select 0;
          _uav removeEventHandler ["fired", _thisEventHandler];

          _uav call Ares_Stop_Drone_Fire_At_Mark;

          _logic = _uav getVariable ["uav_laser_designation_module", objNull];
          if (not isNull _logic) then {
            deleteVehicle _logic;
          };
        };
      };
      _uav addEventHandler ["fired", _fireEventHandler];

      _retargetTime = time;
      while { not isNull _logic && alive _uav && (_uav ammo _weap) > 0 } do
      {
        _attackTime = _uav getVariable ["nextAttackTime", time];
        
        if (time >= _attackTime) then {
          _designator = _uav getVariable ["uav_laser_designator", objNull];
          _target = objNull;
          if (not isNull _designator && alive _designator) then {
            _target = laserTarget _designator;
          };
          if (isNull _target && time >= _retargetTime) then {
            _targets = [];
            {
              if (side _x == side _uav) then {
                {
                  _veh = vehicle _x;
                  if (alive _veh) then {
                    _lt = laserTarget _veh;
                    if (not isNull _lt) then {
                      _targets pushBackUnique [_lt, _veh];
                    };
                  };
                } foreach units _x;
              };
            } foreach allGroups;
            if (count _targets > 0) then
            {
              _targets = _targets apply { [_uav distance (_x select 0), _x select 1] };
              _targets sort true;
              _designator = (_targets select 0) select 1;

              _uav setVariable ["uav_laser_designator", _designator];
              _target = laserTarget _designator;
            };
            _retargetTime = time + 5;
          };
          
          if (not isNull _target) then {
            _movepos = getPosASL  _target;
            _uttNorm = _movepos vectorDiff (getPosASL  _uav);
            _uttNorm set [2, 0];
            _uttNorm = vectorNormalized _uttNorm;
            _dir = vectorDir _uav;
            _dist = _uav distance2D _target;
            _dirCos = (_dir vectorDotProduct _uttNorm);
            _reqDir = _dirCos > 0;
            _minRadius = 100;
            _height = 100;
            if (_dist < _radius && (_dist < _minRadius || not _reqDir)) then {
              if (_reqDir) then {
                _movepos = _movePos vectorAdd (_uttNorm vectorMultiply (_radius + _minRadius));
              }
              else {
                _movepos = _movePos vectorAdd (_uttNorm vectorMultiply -(_radius + _minRadius));
              };
              _movepos set [2, (getTerrainHeightASL _movepos) + _height];
            };

            _uav selectweapon _weap;
            _uav reveal _target;
            _uav doMove _movepos;
            _uav doWatch _target;
            _uav doTarget _target;

            if (_dirCos > 0.5 && _dist < _radius && _uav aimedAtTarget [_target, _weap] >= 1) then {
              _uav doFire _target;
            };

            /*
            _wp = [group _uav, 0];
            {
              if (waypointName _x == "lase") then {
                _wp = _x;
              };
            } foreach waypoints (group _uav);

            if (waypointName _wp != "lase") then {
              _wp = (group _uav) addWaypoint [_movepos, -1, currentWaypoint group _uav, "lase"];
            } else {
              _wp setWaypointPosition [_movepos, -1];
            };
            if ((_wp select 1) != (currentWaypoint (group _uav))) then {
              (group _uav) setCurrentWaypoint _wp;
            };
            */

            sleep 0.1;
          };
        }
        else {
          _uav call Ares_Stop_Drone_Fire_At_Mark;
          waituntil { time >= (_uav getVariable ["nextAttackTime", time]) };
        };
      };
      if (not isNull _uav) then {
        _uav call Ares_Stop_Drone_Fire_At_Mark;
      };
      if (not isNull _logic) then {
        deletevehicle _logic;
      };
    };
  };
};

#include "\ares_zeusExtensions\module_footer.hpp"
