import mx.managers.PopUpManager;
import mx.managers.PopUpManagerChildList;
import mx.controls.Alert;
import mx.rpc.events.ResultEvent;

import customComponents.OptionsWindow;
import customComponents.objects.DashboardOptions;


[Bindable]
public var dashboardOptions:DashboardOptions = new DashboardOptions();

private var indent:String = "   ";
private function init(event:Event):void {
}

private function calculateFontSize(depth:int):Number {
	var fontSize:Number;
	switch (depth) {
		case 0:
			fontSize = 18;
			break;
		case 1:
			fontSize = 14;
			break;
		case 2:
			fontSize = 10;
			break;
		default:
			fontSize = 8;
	}
	return fontSize;
}

private function calculateFontSizeData(depth:int):Number {
	return calculateFontSize(depth) - 3;
}

private function calculatePadding(depth:int):Number {
	var padding:Number;
	switch (depth) {
		case 0:
			padding = 4;
			break;
		default:
			padding = 0;
	}
	return padding;
}

private function calculateIndent(depth:int):String {
	var rtnString:String = "";
	for (var i:int = 0; i < depth; i++) {
		rtnString += indent;
	}
	return rtnString;
}

private function calculateRiskColor(risk:String):uint {
	var color:uint;
	switch (risk) {
		case 'Low':
			color = 0x1F8B5C;
			break;
		case 'Moderate':
			color = 0x3473AE;
			break;
		case 'Elevated':
			color = 0xF5D711;
			break;
		case 'High':
			color = 0xF69C35;
			break;
		case 'Severe':
			color = 0xD1333F;
			break;
	}
	return color;
}

private function formatChangeAbsolute(change:Number):Number {
	return Math.abs(change);
}

private function calculateColor(change:Number):uint {
	var color:uint;
	if (change < 0) {
		color = 0x00ce38;
	} else {
		color = 0xFF0000;
	}
	return color;
}

/* PopUp methods */
private function showPopUp(popUpInfo:Object):void {
	var optionsWindow:OptionsWindow = new OptionsWindow();
	optionsWindow.title = popUpInfo.label;
	optionsWindow.moveObject(Application.application[popUpInfo.layer]);
	PopUpManager.addPopUp(optionsWindow, this, true);
}

