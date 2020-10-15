package com.bigfix.extensions.controls {
	import mx.controls.Tree;
	import mx.events.ListEvent;

	public class Tree extends mx.controls.Tree {
		private var _expandToElementProp:String;
		private var _expandToElementPropValue:*;
		private var _expandToTmpOpenItems:Array;

		public function expandTo(elementProp:String, elementPropValue:*):Boolean {
			if (!this.dataProvider.length) return false;
			if (!(elementProp in this.dataProvider[0])) {
				throw new Error("Tree.expandTo(): the property " + elementProp + " does not exist in the entries of the dataProvider");
			}
			_expandToElementProp = elementProp;
			_expandToElementPropValue = elementPropValue;
			_expandToTmpOpenItems = [];

			for (var i:int = 0; i < this.dataProvider.length; i++) {
				appendOpenItems(this.dataProvider[i]);
			}
			this.openItems = _expandToTmpOpenItems;
			validateNow(); // this is required otherwise the next selectedItem assignment doesn't work
			this.selectedItem = _expandToTmpOpenItems[_expandToTmpOpenItems.length - 1];
			dispatchEvent(new ListEvent(ListEvent.CHANGE));
			return true;
		}

		private function appendOpenItems(node:Object):Boolean {
			_expandToTmpOpenItems.push(node);
			if (node[_expandToElementProp] == _expandToElementPropValue) {
				return true;
			}
			if (node.children) {
				for (var i:int = 0; i < node.children.length; i++) {
					if (appendOpenItems(node.children[i])) {
						return true;
					}
				}
			}
			// if we're here, that means no descendant of the current node matches our criteria, so pop
			_expandToTmpOpenItems.pop();
			return false;
		}

		public function refreshIcons():void {
			itemsSizeChanged = true;
			invalidateDisplayList();
		}
	}
}