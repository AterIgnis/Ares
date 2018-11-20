//
#include "\ares_zeusExtensions\module_header.hpp"

_logic = _this select 0;
_activated = _this select 2;

if (_activated && local _logic) then {
  _unit = [_logic] call Ares_fnc_GetUnitUnderCursor;

  _ld = "";
  {
    if (_x find "Laserdesignator" > -1) then {
      _ld = _x;
    };
  } foreach (weapons _unit);
 
  if (!isNull _unit && alive _unit && _ld != "") then {
    _deleteModuleOnExit = false;
    [_logic, _unit] spawn {
      _logic = _this select 0;
      _uav = _this select 1;

      while { not isNull _logic && alive _uav} do
      {
        _pos = getPosASL _uav;
        _pos set [2, (_pos select 2) + 1.2];
        _logic setPosASL _pos;

        sleep 0.01;
      };
    };

    [_logic, _unit, _ld] spawn {
      _logic = _this select 0;
      _uav = _this select 1;
      _ld = _this select 2;
      _retargetTime = time;
      _laserCheckTime = time;
      _shouldLase = false;
      _target = objNull;
      while { not isNull _logic && alive _uav} do
      {
        if (not isNull _target && not alive _target) then {
          _target = objNull;
          _retargetTime = time + 1;
        };

        if (isNull _target && time >= _retargetTime) then {
          _targets = [];
          {
            _targetLogic = _x;
            {
              _veh = vehicle _x;
              if (alive _veh && side _uav != side _veh && ([_uav, "VIEW", _veh] checkVisibility [getPosASL _uav, getPosASL _veh]) > 0) then {
                _targets pushBackUnique _veh;
              };
            } foreach synchronizedObjects _targetLogic;
          } foreach allMissionObjects "Ares_Module_Drones_Track";

          if (count _targets > 0) then {
            _targets = _targets apply { [_uav distance _x, _x] };
            _targets sort true;
            _target = (_targets select 0) select 1;
          };
          _retargetTime = time + 5;
        };

        if (not isNull _target) then {
          _target = vehicle _target;
          _uav doWatch _target;
          _uav doTarget _target;
          { _uav lockCameraTo [aimpos _target, _x]; } foreach allTurrets [_uav, false];

          if (time >= _laserCheckTime) then {
            _shouldLase = false;

            _startPos = eyePos _uav;
            _endPos = _startPos vectorAdd ((_uav weaponDirection _ld) vectorMultiply ((_uav distance _target) + 100));
            _intersect = lineIntersectsSurfaces [_startPos, _endPos, _uav, objNull, true, 1, "GEOM", "NONE"];
            if (count _intersect > 0) then {
              _obj = (_intersect select 0) select 3;
              _pos = (_intersect select 0) select 0;
              if ((isNull _obj && (_pos distance _target) < 10) || _obj == _target) then {
                _shouldLase = true;
                _retargetTime = time + 15;
              };
            };
            _laserCheckTime = time + 0.1;
          };
        }
        else {
          { _uav lockCameraTo [objNull, _x]; } foreach allTurrets [_uav, false];
          _uav doTarget objNull;
          _uav doWatch objNull;
          _shouldLase = false;
        };

        _shouldChange = _shouldLase;
        if (isLaserOn _uav) then { _shouldChange = not _shouldChange; };
        if (_shouldChange) then {
          _uav fireAtTarget [objNull, _ld];
        };

        sleep 0.01;
      };
      if (not isNull _logic) then {
        deletevehicle _logic;
      };
    };
  };
};

#include "\ares_zeusExtensions\module_footer.hpp"
