[
	"Arsenal",
	"Copy To Clipboard",
	{
		_ammoBox = _this select 1;
		if (not isnull _ammoBox) then
		{
			_virtualBackpacks = [_ammoBox] call BIS_fnc_getVirtualBackpackCargo;
			_virtualItems = [_ammoBox] call BIS_fnc_getVirtualItemCargo;
			_virtualMagazines = [_ammoBox] call BIS_fnc_getVirtualMagazineCargo;
			_virtualWeapons = [_ammoBox] call BIS_fnc_getVirtualWeaponCargo;
			_backpacks = [[],[]];
			_items = [[],[]];
			_magazines = [[],[]];
			_weapons = [[],[]];

			if((headgear _ammoBox)!="") then { _items = [(_items select 0)+[headgear _ammoBox],(_items select 1)+[1]]; };
			if((goggles _ammoBox)!="") then { _items = [(_items select 0)+[goggles _ammoBox],(_items select 1)+[1]]; };
			if((uniform _ammoBox)!="") then { _items = [(_items select 0)+[uniform _ammoBox],(_items select 1)+[1]]; };
			if((vest _ammoBox)!="") then { _items = [(_items select 0)+[vest _ammoBox],(_items select 1)+[1]]; };
			if((backpack _ammoBox)!="") then { _backpacks = [(_backpacks select 0)+[backpack _ammoBox],(_backpacks select 1)+[1]]; };

			{
				if((_x select 0)!="") then {
					if(count(_x)>4) then {
						_magazines = [(_magazines select 0)+[((_x select 4) select 0)],(_magazines select 1)+[1]];
					};
					_weapons = [(_weapons select 0)+[(_x select 0)],(_weapons select 1)+[1]];
				};
			} foreach (weaponsItems _ammoBox);

			{ if(_x != "") then { _items = [(_items select 0)+[_x],(_items select 1)+[1]]; }; } foreach (primaryWeaponItems _ammoBox);
			{ if(_x != "") then { _items = [(_items select 0)+[_x],(_items select 1)+[1]]; }; } foreach (secondaryWeaponItems _ammoBox);
			{ if(_x != "") then { _items = [(_items select 0)+[_x],(_items select 1)+[1]]; }; } foreach (handgunItems _ammoBox);
			{ _items = [(_items select 0)+[_x],(_items select 1)+[1]]; } foreach assignedItems _ammoBox;


			_subcontainers = [_ammoBox];
			for [{_i=0},{_i<count _subcontainers},{_i=_i+1}] do {
				_sc = _subcontainers select _i;
				_subcontainers = _subcontainers + everyContainer _sc;
				
				_bpother = getBackpackCargo _sc;
				_backpacks = [(_backpacks select 0)+(_bpother select 0), (_backpacks select 1)+(_bpother select 1)];
				
				_itother = getItemCargo _sc;
				_items = [(_items select 0)+(_itother select 0), (_items select 1)+(_itother select 1)];
				
				_magother = getMagazineCargo _sc;
				_magazines = [(_magazines select 0)+(_magother select 0), (_magazines select 1)+(_magother select 1)];
				
				_weapother = getWeaponCargo _sc;
				_weapons = [(_weapons select 0)+(_weapother select 0), (_weapons select 1)+(_weapother select 1)];
			};

			_stringData = format [
"[%1,
%2,
%3,
%4,
%5,
%6,
%7,
%8]",
			str(_virtualBackpacks), str(_virtualItems), str(_virtualMagazines), str(_virtualWeapons), str(_backpacks), str(_items), str(_magazines), str(_weapons)];
			missionNamespace setVariable ['Ares_CopyPaste_Dialog_Text', _stringData];
			_dialog = createDialog "Ares_CopyPaste_Dialog";
			[objNull, "Copied items from arsenal to clipboard."] call bis_fnc_showCuratorFeedbackMessage;
		};
	}
] call Ares_fnc_RegisterCustomModule;