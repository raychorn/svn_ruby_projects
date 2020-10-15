import mx.managers.PopUpManager;
import mx.managers.PopUpManagerChildList;
import mx.controls.Alert;
import customComponents.OptionsWindow;
import customComponents.objects.TrendChartOptions;

[Bindable]
public var trendChartOptions:TrendChartOptions = new TrendChartOptions();

private function init(event:Event):void {
}

/* PopUp methods */
private function showPopUp(popUpInfo:Object):void {
	var optionsWindow:OptionsWindow = new OptionsWindow();
	optionsWindow.title = popUpInfo.label;
	optionsWindow.moveObject(Application.application[popUpInfo.layer]);
	PopUpManager.addPopUp(optionsWindow, this, true);
}

