package com.bigfix.extensions.controls.grid {
	import mx.controls.DataGrid;
	import flash.events.FocusEvent;

	public class SortableDataGrid extends DataGrid {
		public function SortableDataGrid() {
			super();
		}
		
		/* This Class exists to remediate a problem that resulted in a walkback whenever a column header was clicked to sort the grid based on a column.
		 * The easiest way to do this was to create a subclass and wrapper the offending method with a try/catch as shown below.
		*/
    	override protected function focusInHandler(event:FocusEvent):void {
    		try { super.focusInHandler(event); } catch (err:Error) { }
    	}
	}
}