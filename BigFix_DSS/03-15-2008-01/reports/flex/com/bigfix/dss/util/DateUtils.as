package com.bigfix.dss.util {
	public class DateUtils {
		public static var millisecondsPerDay:int = 1000 * 60 * 60 * 24;

		public static function numDaysInCurrentMonth():int {
			var curDate:Date = new Date();
			var dt:Date = new Date(curDate.fullYear, curDate.month+1, 1);
			dt.setTime(dt.getTime() - millisecondsPerDay);
			return dt.date;
		}
	}
}