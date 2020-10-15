import mx.core.Application;
import mx.controls.Alert;
import mx.events.ListEvent;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;
import mx.managers.PopUpManager;
import mx.managers.PopUpManagerChildList;
import mx.binding.utils.BindingUtils;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.events.DataGridEvent;

import customComponents.OptionsWindow;
import customComponents.objects.ComputerListOptions;


[Bindable]
protected var computerListOptions:ComputerListOptions = new ComputerListOptions();

private function handleTreeChange(event:ListEvent):void {
	computerListOptions.computer_group_id = event.target.selected_id;
	refreshGridData();
}

private function refreshGridData():void {
	//trace("columns in dataGrid: ",dataGrid.columns);
	computers.refresh()
}

[Bindable]
private var title:String = "Computer List";

private function init(event:Event):void {
	computerListOptions.computer_group_id = Application.application.parameters.computerGroupID;
	computerListOptions.subject_id = Application.application.parameters.subjectID;
	computerListOptions.grouping_type = Application.application.parameters.groupingType;
	//computers.filter = computerListOptions;

	// listen for columnSelectionChange in the ColumnOptions component
	//columnOptions.addEventListener("columnSelectionChange", changeDataGridColumns);

}

private function changeDataGridColumns(event:Event):void {
	var newColumns:Array = new Array();
	for each (var column:Object in columnOptions.selected_columns) {
		var dataGridColumn:DataGridColumn = new DataGridColumn();
		dataGridColumn.dataField = column.name;
		dataGridColumn.headerText = column.label;
		newColumns.push(dataGridColumn);
	}
	dataGrid.columns = newColumns;
}

/* PopUp methods */
private function showPopUp(popUpInfo:Object):void {
	var optionsWindow:OptionsWindow = new OptionsWindow();
	optionsWindow.title = popUpInfo.label;
	optionsWindow.moveObject(Application.application[popUpInfo.layer]);
	PopUpManager.addPopUp(optionsWindow, this, true);
}
/*
private function showDataOptions():void {
	var optionsWindow:OptionsWindow = new OptionsWindow();
	optionsWindow.title = "Data Options";
	optionsWindow.moveObject(dataOptions);
	PopUpManager.addPopUp(optionsWindow, this, true);
}

private function showColumnOptions():void {
	var optionsWindow:OptionsWindow = new OptionsWindow();
	optionsWindow.title = "Column Options";
	optionsWindow.moveObject(columnOptions);
	PopUpManager.addPopUp(optionsWindow, this, true);
}

private function showPrintOptions():void {
}

private function showHelp():void {
}


public function HTTPServiceFaultHandler(event:FaultEvent):void {
	Alert.show("There was an error while trying to retrieve remote data.\nMESSAGE: " + event.message, "Error");
}
*/
