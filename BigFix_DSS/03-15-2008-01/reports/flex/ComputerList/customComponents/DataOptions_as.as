import mx.core.UIComponent;
import mx.controls.Alert;
import mx.containers.HBox;
import mx.controls.Button;
import mx.controls.ComboBox;
import mx.controls.RadioButton;
import mx.controls.TextInput;
import mx.events.ListEvent;
import mx.managers.PopUpManager;
import customComponents.renderers.DisabledListItemRenderer;
import customComponents.pickers.*;
import com.bigfix.dss.vo.PropertyType;

private var _initialSubjectID:int = 2; // the default Subject ID to use when first loaded
private var ref:Array = [OperatingSystemPicker];

private function subjectChanged():void {
	//trace('subjectChanged to '+subject.selectedItem.name);
	remoteService.getFilterLibrary.send();
	refreshGroupings();
}

private function refreshGroupings():void {
	textGroupingOptionDistinctDistinct.text = "Distinct Computers\nDistinct " + subject.selectedItem.name_plural;
	textGroupingOptionDistinctDistinct.toolTip = "This grouping option displays each Computers and " + subject.selectedItem.name + " pair as a single row\nThis allows you to display specific columns about computers and " + subject.selectedItem.name_plural;
	textGroupingOptionDistinctAggregate.text = "Distinct Computers\nAggregate " + subject.selectedItem.name_plural;
	textGroupingOptionDistinctAggregate.toolTip = "This grouping option displays distinct Computers and it's aggregate " + subject.selectedItem.name_plural + " as a single row.\nThis allows you to display aggregate information about " + subject.selectedItem.name_plural + " per computer.";
	textGroupingOptionAggregateDistinct.text = "Aggregate " + subject.selectedItem.name_plural + "\nDistinct Computers";
	textGroupingOptionAggregateDistinct.toolTip = "This grouping option displays distinct "+subject.selectedItem.name_plural+" and it's aggregate computers as a single row\nThis allows you to display aggregate information about computers per "+subject.selectedItem.name;
}

private function refreshFilters():void {
	labelNameHack(remoteService.getFilterLibrary.lastResult.properties);
	clearChildren(filterContainer); // clear out the filters
	addFilter(null); // add our first filter
}

private function addFilter(event:Event):void {
	var box:HBox = new HBox();
	box.percentWidth = 100;
	var comboBoxProperties:ComboBox = new ComboBox();

	// setup the combo box of Properties
	comboBoxProperties.name = 'comboBoxProperties';
	comboBoxProperties.labelField = 'label_name';
	comboBoxProperties.addEventListener(ListEvent.CHANGE, changeProperty);
	comboBoxProperties.itemRenderer = new ClassFactory(DisabledListItemRenderer);
	comboBoxProperties.dataProvider = [{id: null, label_name: 'Select a Property'}].concat(remoteService.getFilterLibrary.lastResult.properties);

	// setup the ComboBox of operators and hide it
	var comboBoxOperators:ComboBox = new ComboBox();
	comboBoxOperators.name = 'comboBoxOperators';
	comboBoxOperators.labelField = 'name';
	comboBoxOperators.visible = false;

	// setup the box which will contain the value input control
	var boxValue:HBox = new HBox();
	boxValue.name = 'boxValue';
	boxValue.percentWidth = 100;

	// setup the box which will hold the plus and minus signs
	var boxAddRemoveOptions:HBox = new HBox();
	boxAddRemoveOptions.name = "boxAddRemoveOptions";
	boxAddRemoveOptions.setStyle('horizontalAlign','right');
	boxAddRemoveOptions.addChild(plusButton()).addEventListener('click', addFilter);
	boxAddRemoveOptions.addChild(minusButton()).addEventListener('click', removeFilter);

	// add the filter elements to the containing box
	box.addChild(comboBoxProperties);
	box.addChild(comboBoxOperators);
	box.addChild(boxValue);
	box.addChild(boxAddRemoveOptions);

	// finally, add the box to the filterContainer and call the 'adjustAddRemoveOptions()' method
	filterContainer.addChild(box);
	adjustAddRemoveOptions();
}

private function removeFilter(event:Event):void {
	event.target.parent.parent.parent.removeChild(event.target.parent.parent);
	adjustAddRemoveOptions();
}

private function adjustAddRemoveOptions():void {
	// remove the plus sign on all, show the minus sign on all
	for (var i:int = 0; i < filterContainer.numChildren; i++) {
		((filterContainer.getChildAt(i) as HBox).getChildByName('boxAddRemoveOptions') as HBox).getChildByName('plusButton').visible = false;
		((filterContainer.getChildAt(i) as HBox).getChildByName('boxAddRemoveOptions') as HBox).getChildByName('minusButton').visible = true;
	}
	// the plus sign is always visible on the last child
	((filterContainer.getChildAt(filterContainer.numChildren - 1) as HBox).getChildByName('boxAddRemoveOptions') as HBox).getChildByName('plusButton').visible = true;
	// if there is only one option, remove the minus sign
	if (filterContainer.numChildren == 1) {
		((filterContainer.getChildAt(0) as HBox).getChildByName('boxAddRemoveOptions') as HBox).getChildByName('minusButton').visible = false;
	}
}

private function changeProperty(event:Event):void {
	var comboBoxProperties:ComboBox = event.target.parent.getChildByName('comboBoxProperties');
	var comboBoxOperators:ComboBox = event.target.parent.getChildByName('comboBoxOperators');
	var boxValue:HBox = event.target.parent.getChildByName('boxValue');

	// bail if this isn't a valid property
	if (!comboBoxProperties.selectedItem.id) {
		comboBoxOperators.visible = false;
		clearChildren(boxValue);
		return;
	}

	// build up 'availableOperators' based on the type of the selected property
	var availableOperators:Array = remoteService.getFilterLibrary.lastResult.property_operators.filter(function (item:*, index:int, array:Array):Boolean {
		return (item.property_type_id == comboBoxProperties.selectedItem.property_type_id)
	}, null);
	comboBoxOperators.dataProvider = availableOperators;
	comboBoxOperators.visible = true;

	// clear the child of the boxValue
	clearChildren(boxValue);
	// now show the appropiate value input
	var child:UIComponent;
	switch (comboBoxProperties.selectedItem.property_type_id) {
		case PropertyType.ID: // ID, use picker value
			child = new Button();
			child['label'] = "Choose " + comboBoxProperties.selectedItem.name;
			child['name'] = comboBoxProperties.selectedItem.picker;
			child.addEventListener('click', popUpPicker);
			break;
		case PropertyType.BOOLEAN: // Boolean, use picker value
			child = new ComboBox();
			child['dataProvider']= [comboBoxProperties.selectedItem.picker.true_label, comboBoxProperties.selectedItem.picker.false_label];
			break;
		default: // use a text input
			child = new TextInput();
	}
	boxValue.addChild(child);
}


private function toggleGroupingOption(event:Event):void {
	if (event.target is RadioButton) { return; }
	var radioButton:RadioButton = event.currentTarget.getChildByName('radioButton');
	radioButton.selected = !radioButton.selected;
}

private function popUpPicker(event:Event):void {
	var pickerClass:Class = Class(getDefinitionByName('customComponents.pickers.' + event.target.name));
	var pickerInstance:* = new pickerClass();
	PopUpManager.addPopUp(pickerInstance, this, true);
	PopUpManager.centerPopUp(pickerInstance);
}

private function labelNameHack(propertyArray:Array):void {
	// this is called after remoteService.getFilterLibrary.send has finished, now we have to go through and add leading spaces property names and save as 'label_name'!?
	for each (var property:Object in propertyArray) {
		if (property.id != null) {
			property.label_name = "   " + property.name;
		} else {
			property.label_name = property.name;
		}
	}
}

private function plusButton():Button {
	var button:Button = new Button();
	button.width = 22;
	toolTip = 'Add additional Criteria';
	button.label = "+";
	button.name = 'plusButton';
	button.setStyle('fontSize',12);
	return button;
}

private function minusButton():Button {
	var button:Button = new Button();
	button.width = 22;
	button.toolTip = 'Remove this Criteria';
	button.label = "-";
	button.name = 'minusButton';
	button.setStyle('fontSize',16);
	return button;
}

private function clearChildren(container:UIComponent):void {
	while (container.numChildren > 0) {
		container.removeChildAt(0);
	}
}
