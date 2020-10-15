import mx.core.Application;
import mx.rpc.events.ResultEvent;
import mx.controls.CheckBox;
import flash.events.Event;

// publicly exported vars
[Bindable]
public var unselectedDeltaTypeIDs:Array; // exports the currently *UNSELECTED* Delta Type IDs

public function set deltaTypes(value:Array):void {
	// clear out container
	while (checkboxContainer.numChildren > 0) {
		checkboxContainer.removeChildAt(0);
	}
	// populate with new checkboxes
	for each (var deltaType:Object in value) {
		var checkbox:CheckBox = new CheckBox();
		checkbox.name = deltaType.id; // checkbox.name is really the deltaTypeID!
		checkbox.label = deltaType.name;
		checkbox.selected = true; // INCOMPLETE: need to read 'selectedIDs'
		checkbox.addEventListener(Event.CHANGE, checkboxChangeHandler);
		checkboxContainer.addChild(checkbox);
	}
	unselectedDeltaTypeIDs = [];
}

private function checkboxChangeHandler(event:Event):void {
	var tmpArray:Array = [];
	for (var i:int = 0; i < checkboxContainer.numChildren; i++) {
		var checkbox:* = checkboxContainer.getChildAt(i);
		if (!checkbox.selected) {
			tmpArray.push(checkbox.name); // checkbox.name is really the deltaTypeID!
		}
	}
	unselectedDeltaTypeIDs = tmpArray;
}
