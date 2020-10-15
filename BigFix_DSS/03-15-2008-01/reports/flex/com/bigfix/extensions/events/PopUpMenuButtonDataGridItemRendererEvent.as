package com.bigfix.extensions.events {
	import flash.events.Event;
	import mx.controls.dataGridClasses.DataGridListData;

	public class PopUpMenuButtonDataGridItemRendererEvent extends Event {
		public static const ITEM_CLICK:String = "popUpMenuButtonDataGridItemRendererEventItemClick";

		public var listData:DataGridListData;
		public var menuItem:Object;
		public function PopUpMenuButtonDataGridItemRendererEvent(listData:Object = null, menuItem:Object = null) {
			super(PopUpMenuButtonDataGridItemRendererEvent.ITEM_CLICK, true);
			this.listData = DataGridListData(listData);
			this.menuItem = menuItem;
		}

		override public function clone():Event {
			return new PopUpMenuButtonDataGridItemRendererEvent(this.listData, this.menuItem);
		}

	}
}
