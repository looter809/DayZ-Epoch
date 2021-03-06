/**
*	call Z_getContainer
*
*	Switches between selling and buying and the item container (gear/vehicle/bakcpack) and initiates item loading.
**/
private ["_lbIndex","_formattedText","_canBuyInVehicle"];
#include "defines.sqf";
(findDisplay Z_AT_DIALOGWINDOW displayCtrl Z_AT_SLOTSDISPLAY) ctrlSetText format["0 / 0 / 0"];
call Z_clearBuyingList;
call Z_clearLists;
Z_SellableArray = [];
Z_SellArray = [];
Z_BuyingArray = [];

_lbIndex = _this select 0;

_formattedText = format [''];

(findDisplay Z_AT_DIALOGWINDOW displayCtrl Z_AT_ITEMINFO) ctrlSetStructuredText parseText _formattedText;

call Z_calcPrice;

if(Z_Selling)then{
	switch (_lbIndex) do {
		case 0: {
			[localize "STR_EPOCH_TRADE_SELLING_BACKPACK"] call Z_filleTradeTitle;
			Z_SellingFrom = 0;
			call Z_getBackpackItems;
		};
		case 1: {
			[localize "STR_EPOCH_TRADE_SELLING_VEHICLE"] call Z_filleTradeTitle;
			Z_SellingFrom = 1;
			call Z_getVehicleItems;
		};
		case 2: {
			[localize "STR_EPOCH_TRADE_SELLING_GEAR"] call Z_filleTradeTitle;
			Z_SellingFrom = 2;
			call Z_getGearItems;
		};
	};
}else{
	_ctrltext = format[" "];
	ctrlSetText [Z_AT_TRADERLINE2, _ctrltext];

	_ctrltext = localize "STR_EPOCH_TRADE_SELLING_ALL";
	ctrlSetText [Z_AT_TRADERLINE1, _ctrltext];
	switch (_lbIndex) do {

		case 0: {
			Z_SellingFrom = 0;
			[localize "STR_EPOCH_TRADE_BUYING_BACKPACK"] call Z_filleTradeTitle;
			[0] call Z_calculateFreeSpace;
		};
		case 1: {
			Z_SellingFrom = 1;
			[localize "STR_EPOCH_TRADE_BUYING_VEHICLE"] call Z_filleTradeTitle;
			_canBuyInVehicle = true call Z_checkCloseVehicle;
			if(_canBuyInVehicle)then{
				[1] call Z_calculateFreeSpace;
			}else{
				systemChat localize "STR_EPOCH_PLAYER_245";
				(findDisplay Z_AT_DIALOGWINDOW displayCtrl Z_AT_SLOTSDISPLAY) ctrlSetText format["%1 / %2 / %3",0,0,0];
			};
		};
		case 2: {
			Z_SellingFrom = 2;
			[localize "STR_EPOCH_TRADE_BUYING_GEAR"] call Z_filleTradeTitle;
			[2] call Z_calculateFreeSpace;
		};
	};
};
