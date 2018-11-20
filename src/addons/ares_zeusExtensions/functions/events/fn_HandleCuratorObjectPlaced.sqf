private ["_curator","_placedObject"];
_curator = _this select 0;
_placedObject = _this select 1;
if (local _placedObject) then
{
	Ares_CuratorObjectPlaced_UnitUnderCursor = curatorMouseOver;
	Ares_CuratorObjectPlaces_LastPlacedObjectPosition = position _placedObject;
	[format ["Placed Object %1 with %2 under mouse at position %3", _placedObject, str(Ares_CuratorObjectPlaced_UnitUnderCursor), str(Ares_CuratorObjectPlaces_LastPlacedObjectPosition)]] call Ares_fnc_LogMessage;

	if (not (isNil "Ares_default_AI_behaviors")) then {
        	{
        	    _unit = _x;
        	    {
        	    	_aiSetting = _x;
        	    	_id = _aiSetting select 0;
        	    	_enabled = _aiSetting select 1;
        	    	if (_enabled) then {
	        	    	_unit enableAI _id;
        	    	}
        	    	else {
	        	    	_unit disableAI _id;
        	    	}
        	    } foreach Ares_default_AI_behaviors;
        	} foreach (crew _placedObject) + [_placedObject];
	};
}
else
{
	[format ["NON-LOCAL Placed Object %1 with %2 under mouse at position %3", _placedObject, str(Ares_CuratorObjectPlaced_UnitUnderCursor), str(Ares_CuratorObjectPlaces_LastPlacedObjectPosition)]] call Ares_fnc_LogMessage;
};
