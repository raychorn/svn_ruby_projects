package com.bigfix.extensions.controls {
	import mx.controls.CalendarLayout;
	import flash.events.MouseEvent;
	import mx.collections.ArrayCollection;

	public class CalendarSelect extends CalendarLayout {
		
		public function CalendarSelect() {
			super();
			this.dayNames = [];
			this.showToday = false;
			this.displayedYear = 2006;
			this.displayedMonth = 0;
        	this.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseUpHandler(event:MouseEvent):void {
			event.ctrlKey=true;
			event.shiftKey=false;	//so we don't have to deal with ranges in selectedDates();
		}
		
		private function dateFactoryForDayNum(dayNum:int):Date {
			return (new Date(this.displayedYear, this.displayedMonth, dayNum));
		}
		
		private function dateRangeFactoryUsingSingleDate(aDate:Date):Object {
			var range:Object = {};
			range.rangeStart = aDate;
			range.rangeEnd = aDate;
			return range;
		}
		
		public function set selectedDates(selectedDates:Array):void {
			var ranges:Array = [];
			for (var i:int = 0; i < selectedDates.length; i++) {
				ranges.push(this.dateRangeFactoryUsingSingleDate(this.dateFactoryForDayNum(selectedDates[i])));
			}
			this.selectedRanges = ranges;
		}
		
		public function get selectedDates():Array {
			if (this.selectedRanges.length == 0) {
				return null;
			} else {
				return this.selectedRanges.map(function (item:*, index:int, array:Array):int{
					return item.rangeStart.getDate();
				});
			}
		}
		
	}
}