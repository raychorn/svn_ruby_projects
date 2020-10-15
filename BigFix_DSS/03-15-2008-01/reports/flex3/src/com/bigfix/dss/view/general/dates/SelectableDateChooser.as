package com.bigfix.dss.view.general.dates {
	import mx.controls.DateChooser;

	public class SelectableDateChooser extends DateChooser {
		private var _selectedDate:Date;
		
		public function SelectableDateChooser() {
			super();
		}

		override public function get selectedDate():Date {
			if ( (super.selectedDate == null) && (this._selectedDate is Date) ) {
				return this._selectedDate;
			}
			return super.selectedDate;
		}
		
	    override public function set selectedDate(aDate:Date):void {
	    	if (aDate == null) { 
				this.selectedRanges = [];
		    	return;
	    	}
			var dt1:Date = new Date(aDate.fullYear,aDate.month,aDate.date);
			var dt2:Date = new Date(aDate.fullYear,aDate.month,aDate.date);
			this.selectedRanges = [{rangeStart: dt1, rangeEnd: dt2}];
			this.displayedMonth = aDate.month;
			this.displayedYear = aDate.fullYear;
			this._selectedDate = aDate;
	    }
	}
}