package com.bigfix.extensions.controls {
	import mx.controls.ButtonBar;
	import mx.core.mx_internal;
	import mx.collections.ArrayCollection;
	import mx.events.ItemClickEvent;
	import mx.utils.ObjectUtil;
	import mx.controls.Button;
	import com.bigfix.dss.util.ArrayCollectionUtils;
	import flash.events.MouseEvent;

	public class MultiSelectButtonBar extends ButtonBar {
		private var _selectedLabels:Object = new Object();
		
		public function MultiSelectButtonBar():void {
			super();
			mx_internal::navItemFactory.properties = {toggle: true};
			addEventListener(ItemClickEvent.ITEM_CLICK, handleItemClick);
		}
		
		public function handleItemClick(event:ItemClickEvent):void {
			if (_selectedLabels[event.index]) {
				delete _selectedLabels[event.index];
			} else {
				_selectedLabels[event.index] = event.label;
			}
		}
	
		public function get selectedLabels():Array {
			var toReturn:Array = new Array();
			for each (var index:int in ObjectUtil.getClassInfo(_selectedLabels).properties){
				toReturn.push(_selectedLabels[index]);
			}
			if (toReturn.length==0) {
				return null;
			}
			return toReturn;
		}
		
		public function clearSelections():void {
			var index:String;
			var currentLabels:Array = [];
			for (index in this._selectedLabels) {
				currentLabels.push(this._selectedLabels[index]);
			}
			this.selectedLabels = currentLabels;
		}
		
		public function set selectedLabels(labels:Array):void {
			var children:Array = this.getChildren();
			var i:int;
			var j:int;
			var ac:ArrayCollection = new ArrayCollection(labels);
			var btn:Button;
			for (i = 0; i < children.length; i++) {
				btn = Button(children[i]);
				if (btn.toggle) {
					btn.selected = false;
				}
			}
			for (i = 0; i < children.length; i++) {
				btn = Button(children[i]);
				j = ArrayCollectionUtils.findIndexOfItem(ac, null, btn.label);
				if (j > -1) {
					if (btn.toggle) {
						btn.selected = true;
					} else {
						btn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
					}
				}
			}
		}
	}
}