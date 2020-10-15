package com.bigfix.extensions.renderers
{
	import mx.controls.PopUpMenuButton;
	import mx.controls.DataGrid;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.Spacer;
	import mx.events.MenuEvent;
	
	import com.bigfix.extensions.events.PopUpMenuButtonDataGridItemRendererEvent;
	
	public class PopUpMenuButtonDataGridItemRenderer extends PopUpMenuButton  {
		override public function set dataProvider(value:Object):void {
			super.dataProvider = value;
			if (dataProvider.length == 1) {
				this.setStyle('popUpIcon', Spacer);
			}
			this.addEventListener(MenuEvent.ITEM_CLICK, handleItemClick);
		}
		
		private function handleItemClick(event:MenuEvent):void {
			trace(event.item);
			this.dispatchEvent(new PopUpMenuButtonDataGridItemRendererEvent(this.listData, event.item));
		}
		
		public function PopUpMenuButtonDataGridItemRenderer() {
			super();
		}
		
		/*	
		*	override public getter/setters for data and listData. 
		*	The built in ones don't throw 'invalidateProperties()' 
		*/
		private var _data:Object;
		override public function get data():Object { 
			return _data; 
		}

		override public function set data( value:Object ) : void { 
			if (_data != value) {
				_data = value;
				invalidateProperties();
			}
		}
		
		private var _listData:BaseListData;
		override public function get listData():BaseListData { 
			return _listData; 
		}

		override public function set listData(value:BaseListData):void { 
			if (_listData != value) {
				_listData = value;
				invalidateProperties();
			}
		}
		
		override protected function commitProperties():void {
			/*
			trace("PopUpMenuButtonDataGridItemRenderer.commitProperties() enabled = ",enabled,"mouseEnabled = ",mouseEnabled);
			trace("this.getStyle('color') =",this.getStyle('color'));
			enabled = mouseEnabled = true;
			*/
			super.commitProperties();
			this.label = listData.label;
		}
	}
}