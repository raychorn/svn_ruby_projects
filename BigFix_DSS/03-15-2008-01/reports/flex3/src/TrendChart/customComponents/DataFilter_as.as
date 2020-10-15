/* GRIPES
 during the loadData phase, we don't have access to combobox because it's hidden in the viewstack
*/
import mx.core.Application;
import mx.rpc.events.ResultEvent;
import mx.controls.Alert;
import com.bigfix.dss.view.general.Alert.AlertPopUp;

// public properties
public var defaultMetricID:uint;

// publicly exported vars
[Bindable]
public var metricID:uint; // exports the currently configured metric ID

// internal bindables
[Bindable]
private var subjectMetricsFlat:Array = []; // used for binding to the ComboBox
[Bindable]
private var metricName:String; // used for the chart title

private var xmlData:XML; // response from HTTP Service
private var selectedComboBoxItem:Object; // a pointer into the selected combo box item. this isn't used after initComboBox is called.

public function fetchData():void {
	dataService.send();
}

private function loadData(event:ResultEvent):void {
	xmlData = event.result as XML;

	// build out 'subjectMetricsFlat' (an Array used for combobox data binding) from 'xmlData'
	for each (var subject:XML in xmlData.subject) {
		subjectMetricsFlat.push({id: null, name: subject.@name});
		for each (var metric:XML in subject.metric) {
			subjectMetricsFlat.push({id: metric.@id, name: metric.@name, subject_id: subject.@id});
			if (!selectedComboBoxItem || metric.@id == defaultMetricID) {
				selectedComboBoxItem = subjectMetricsFlat[subjectMetricsFlat.length-1];
			}
		}
	}
	// set some vars so bindings fire
	dataChanged(selectedComboBoxItem);
}

private function initComboBox(event:Event):void {
	if (!xmlData) return; // ACK we were never asked to fetchData!
	event.target.selectedItem = selectedComboBoxItem;
}

private function formatComboBoxElements(item:Object):String {
	return (item.id == null) ? item.name : "     " + item.name;
}

private function commitFilterChanges(event:Event):void {
	if (metricComboBox.selectedItem.id == null) {
		AlertPopUp.error("Please choose a valid Metric", "Error");
	} else {
		/*
		metricName = metricComboBox.selectedItem.name;
		metricID = metricComboBox.selectedItem.id;
		reportSubjectID = metricComboBox.selectedItem.reportSubjectID;
		*/
		dataChanged(metricComboBox.selectedItem);
		selectedChild = viewPane;
	}
}

private function dataChanged(item:Object):void {
	metricName = item.name;
	metricID = item.id;
}
