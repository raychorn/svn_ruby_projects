package com.bigfix.dss.view.general.grid {
	import flash.utils.getTimer;
	import flash.events.FocusEvent;
	
	import mx.controls.DataGrid;
	import mx.events.DataGridEvent;

	import mx.controls.DataGrid;
	import mx.events.ListEvent;
	import com.bigfix.dss.util.ArrayUtils;
	import com.bigfix.dss.util.ArrayCollectionUtils;
	import mx.collections.ArrayCollection;

	public class DoubleClickDataGrid extends DataGrid {
		private var _lastClickTimesByColumnNum:Array = [];
		private var _doubleClickTimeout:Number = 300;
		private var _isKeyFocusChanging:Boolean;

		private var _numClicks:int = 0;
		
		private var _doubleClickableDataFieldNames:Array = [];
		private var _doubleClicksForDataFieldNames:Array = [];
		
		public function DoubleClickDataGrid():void {
			super(); 
			this.addEventListener(DataGridEvent.ITEM_EDIT_BEGINNING, _onItemEditBeginning); 
			this.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, _onKeyFocusChange, false, 1000);
		}
		
		public function set doubleClickableDataField(dataField:String):void {
			this._doubleClickableDataFieldNames.push(dataField);
		}
		
		public function get doubleClickableDataFieldNames():Array {
			return this._doubleClickableDataFieldNames;
		}

		private function setLastClickTimeForColumnNum(colNum:int):void {
			this._lastClickTimesByColumnNum[colNum] = getTimer();
		}
		
		private function getLastClickTimeForColumnNum(colNum:int):Number {
			if (this._lastClickTimesByColumnNum[colNum] == null) {
				this.setLastClickTimeForColumnNum(colNum);
			}
			return this._lastClickTimesByColumnNum[colNum];
		}
		
		private function _onItemEditBeginning(event:DataGridEvent):void {
			var i:int = ArrayCollectionUtils.findIndexOfItem(new ArrayCollection(this._doubleClickableDataFieldNames),null,event.dataField);
			
			var t:Number = getTimer() - this.getLastClickTimeForColumnNum(event.columnIndex);
			if ( (!_isKeyFocusChanging) && (t > _doubleClickTimeout) ) {
				event.preventDefault();
				if (i > -1) {
					if (this._doubleClicksForDataFieldNames[i] == null) {
						this._doubleClicksForDataFieldNames[i] = 0;
					}
					this._doubleClicksForDataFieldNames[i]++;
					if (this._doubleClicksForDataFieldNames[i] > 1) {
						this._doubleClicksForDataFieldNames[i] = 0;
						this.dispatchEvent(new ListEvent(ListEvent.ITEM_DOUBLE_CLICK,true));
					}
				}
			} else if (i > -1) {
				event.preventDefault();
			}
			
			_isKeyFocusChanging = false; 
			this.setLastClickTimeForColumnNum(event.columnIndex);
		} 
		
		private function _onKeyFocusChange(event:FocusEvent):void{ 
			_isKeyFocusChanging = true;
		} 
		
		private function resetAllDoubleClickCounters():void {
			var i:int;
			for (i = 0; i < this._doubleClicksForDataFieldNames.length; i++) {
				this._doubleClicksForDataFieldNames[i] = 0;
			}
		}
		
		public function get doubleClickTimeout():Number{
			return _doubleClickTimeout; 
		}
		
		public function set doubleClickTimeout(value:Number):void{
			_doubleClickTimeout = value;
		}
	}
}
