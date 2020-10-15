import mx.core.Application;
import mx.rpc.events.ResultEvent;
import mx.controls.CheckBox;

// publicly exported vars
[Bindable]
public var hiddenDeltaTypeIDs:Array; // exports the currently *UNSELECTED* Delta Type IDs

private var _deltaTypes:Array = []; // private tracking of deltaTypes
// bindable setter for deltaTypes
[Bindable]
public function set deltaTypes(value:Array):void {
	_deltaTypes = value;
	// clear out container
	while (checkboxContainer.numChildren > 0) {
		checkboxContainer.removeChildAt(0);
	}
	// populate with new checkboxes
	for each (var deltaType:Object in _deltaTypes) {
		var checkbox:CheckBox = new CheckBox();
		checkbox.name = deltaType.id; // checkbox.name is really the deltaTypeID!
		checkbox.label = deltaType.name;
		checkbox.selected = true; // INCOMPLETE: need to read 'selectedIDs'
		checkbox.addEventListener(Event.CHANGE, checkboxChangeHandler);
		checkboxContainer.addChild(checkbox);
	}
	checkboxContainer.getChildAt(0).dispatchEvent(new Event(Event.CHANGE));
}

public function get deltaTypes():Array {
	return _deltaTypes;
}

private function checkboxChangeHandler(event:Event):void {
	var tmpArray:Array = [];
	for (var i:int = 0; i < checkboxContainer.numChildren; i++) {
		var checkbox:* = checkboxContainer.getChildAt(i);
		if (!checkbox.selected) {
			tmpArray.push(checkbox.name); // checkbox.name is really the deltaTypeID!
		}
	}
	hiddenDeltaTypeIDs = tmpArray;
}
