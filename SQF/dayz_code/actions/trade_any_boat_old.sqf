private ["_veh","_location","_result","_part_out","_part_in","_qty_out","_qty_in","_qty","_buy_o_sell","_obj","_objectID","_objectUID","_bos","_started","_finished","_animState","_isMedic","_dir","_helipad","_removed","_okToSell","_needed","_activatingPlayer","_textPartIn","_textPartOut","_traderID","_playerNear"];

if (DZE_ActionInProgress) exitWith {localize "str_epoch_player_103" call dayz_rollingMessages;};
DZE_ActionInProgress = true;

// Test cannot lock while another player is nearby
//_playerNear = {isPlayer _x} count (player nearEntities ["CAManBase", 12]) > 1;
//if(_playerNear) exitWith {DZE_ActionInProgress = false; localize "str_epoch_player_104" call dayz_rollingMessages;};

// [part_out,part_in, qty_out, qty_in, loc];

_activatingPlayer = player;

_part_out = (_this select 3) select 0;
_part_in = (_this select 3) select 1;
_qty_out = (_this select 3) select 2;
_qty_in = (_this select 3) select 3;
_buy_o_sell = (_this select 3) select 4;
_textPartIn = (_this select 3) select 5;
_textPartOut = (_this select 3) select 6;
_traderID = (_this select 3) select 7;
_bos = 0;

if(_buy_o_sell == "buy") then {
	_qty = {_x == _part_in} count magazines player;
} else {
	_obj = nearestObjects [(getPosATL player), [_part_in], dayz_sellDistance_boat];
	_qty = count _obj;
	_bos = 1;
};


if (_qty >= _qty_in) then {

	localize "str_epoch_player_105" call dayz_rollingMessages;
	 
	["Working",0,[3,2,8,0]] call dayz_NutritionSystem;
	// force animation 
	player playActionNow "Medic";

	r_interrupt = false;
	_animState = animationState player;
	r_doLoop = true;
	_started = false;
	_finished = false;
	
	while {r_doLoop} do {
		_animState = animationState player;
		_isMedic = ["medic",_animState] call fnc_inString;
		if (_isMedic) then {
			_started = true;
		};
		if (_started && !_isMedic) then {
			r_doLoop = false;
			_finished = true;
		};
		if (r_interrupt) then {
			r_doLoop = false;
		};
		uiSleep 0.1;
	};
	r_doLoop = false;

	if (!_finished) exitWith { 
		r_interrupt = false;
		if (vehicle player == player) then {
			[objNull, player, rSwitchMove,""] call RE;
			player playActionNow "stop";
		};
		localize "str_epoch_player_106" call dayz_rollingMessages;
	};

	if (_finished) then {

		// Double check for items
		if(_buy_o_sell == "buy") then {
			_qty = {_x == _part_in} count magazines player;
		} else {
			_obj = nearestObjects [(getPosATL player), [_part_in], dayz_sellDistance_boat];
			_qty = count _obj;
		};

		if (_qty >= _qty_in) then {

			//["PVDZE_obj_Trade",[_activatingPlayer,_traderID,_bos]] call callRpcProcedure;
			if (isNil "_obj") then { _obj = "Unknown Vehicle" };
			if (isNil "inTraderCity") then { inTraderCity = "Unknown Trader City" };
			PVDZE_obj_Trade = [_activatingPlayer,_traderID,_bos,_obj,inTraderCity];
			publicVariableServer  "PVDZE_obj_Trade";
	
			//diag_log format["DEBUG Starting to wait for answer: %1", PVDZE_obj_Trade];

			waitUntil {!isNil "dayzTradeResult"};

			//diag_log format["DEBUG Complete Trade: %1", dayzTradeResult];

			if(dayzTradeResult == "PASS") then {

				if(_buy_o_sell == "buy") then {	
					_result = call epoch_generateKey;
					if (_result select 0) then {				
						_removed = ([player,_part_in,_qty_in] call BIS_fnc_invRemove);
						if(_removed == _qty_in) then {
							_dir = round(random 360);

							_helipad = nearestObjects [player, ["HeliHCivil","HeliHempty"], 100];
							if(count _helipad > 0) then {
								_location = (getPosATL (_helipad select 0));
							} else {
								_location = [([player] call FNC_GetPos),0,20,1,2,2000,0] call BIS_fnc_findSafePos;
							};
	
							//place vehicle spawn marker (local)
							_veh = createVehicle ["Sign_arrow_down_large_EP1", _location, [], 0, "CAN_COLLIDE"];

							_location = (getPosATL _veh);
					
							PVDZE_veh_Publish2 = [_veh,[_dir,_location],_part_out,false,_result select 1,_activatingPlayer];
							publicVariableServer  "PVDZE_veh_Publish2";

							player reveal _veh;

							format["Bought %3 for %1 %2, key added to toolbelt.",_qty_in,_textPartIn,_textPartOut] call dayz_rollingMessages;
						} else {
							player removeMagazine (_result select 1);
						};
					} else {
						localize "str_epoch_player_107" call dayz_rollingMessages;
					};
				} else {
					
					_obj = _obj select 0;

					_okToSell = true;
					if(!local _obj) then {
						_okToSell = false;
					};

					if(_okToSell && !isNull _obj && alive _obj) then {

						for "_x" from 1 to _qty_out do {
							player addMagazine _part_out;
						};

						_objectID 	= _obj getVariable ["ObjectID","0"];
						_objectUID	= _obj getVariable ["ObjectUID","0"];

						PVDZ_obj_Destroy = [_objectID,_objectUID,_activatingPlayer];
						publicVariableServer "PVDZ_obj_Destroy";

						deleteVehicle _obj;

						format[localize "str_epoch_player_181",_qty_in,_textPartIn,_qty_out,_textPartOut] call dayz_rollingMessages;
					} else {
						localize "str_epoch_player_245" call dayz_rollingMessages;
					};
				};
	
				{player removeAction _x} count s_player_parts;s_player_parts = [];
				s_player_parts_crtl = -1;

			} else {
				format[localize "str_epoch_player_183",_textPartOut] call dayz_rollingMessages;
			};
			dayzTradeResult = nil;
		};
	};

} else {
	_needed =  _qty_in - _qty;
	if(_buy_o_sell == "buy") then {
		format[localize "str_epoch_player_184",_needed,_textPartIn] call dayz_rollingMessages;
	} else {
		format[localize "str_epoch_player_185",_textPartIn] call dayz_rollingMessages;
	};
};

DZE_ActionInProgress = false;