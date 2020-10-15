import mx.core.Application;
import mx.rpc.events.ResultEvent;
import mx.events.ListEvent;

// public properties
public var defaultID:uint;

// publicly exported vars
[Bindable]
public var nodeInfo:*;

[Bindable]
private var nodes:XML;

public function fetchData():void {
	dataService.send();
}

private function loadData(event:ResultEvent):void {
	nodes = event.result as XML;
	if (!defaultID || !nodes..node.(@id == defaultID)[0]) {
		defaultID = nodes.node[0].@id;
	}
	// all this tom foolery is to expand to the selected Tree item
	var selectedTreeItem:XML = nodes..node.(@id == defaultID)[0];
	var currentXMLNode:XML = selectedTreeItem;
	tree.validateNow();
	while (currentXMLNode = currentXMLNode.parent()) {
		if (!tree.isItemOpen(currentXMLNode)) {
			tree.expandItem(currentXMLNode, true);
		}
	}
	tree.selectedItem = selectedTreeItem;
	// we have to manaually throw the change event at itself
	tree.dispatchEvent(new ListEvent(ListEvent.CHANGE));
}

private function treeChangeHandler(event:ListEvent):void {
	if (!tree.isItemOpen(tree.selectedItem)) { // make sure we expand this node's children
		tree.expandItem(tree.selectedItem, true);
	}

	// set the public variable 'nodeInfo'
	nodeInfo = tree.selectedItem;
	/*
	var tmpObj:Object;
	trace(tree.selectedItem);

	tmpObj.id = tree.selectedItem.@id;
	tmpObj.name = tree.selectedItem.@name;
	nodeInfo = tmpObj;
	*/
}

