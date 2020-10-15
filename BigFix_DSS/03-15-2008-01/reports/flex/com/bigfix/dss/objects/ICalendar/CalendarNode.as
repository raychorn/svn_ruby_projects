package com.bigfix.dss.objects.ICalendar {
	import com.bigfix.dss.view.general.TimeSelection;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;
	import mx.utils.StringUtil;
	import com.bigfix.dss.util.StringUtils;
	
	public class CalendarNode {
		public static const FREQ_HOURLY:String = "HOURLY";
		public static const FREQ_DAILY:String = "DAILY";
		public static const FREQ_WEEKLY:String = "WEEKLY";
		public static const FREQ_MONTHLY:String = "MONTHLY";
		public static const WEEKDAY_MONDAY:String = "MO";
		public static const WEEKDAY_TUESDAY:String = "TU";
		public static const WEEKDAY_WEDNESDAY:String = "WE";
		public static const WEEKDAY_THURSDAY:String = "TH";
		public static const WEEKDAY_FRIDAY:String = "FR";
		public static const WEEKDAY_SATURDAY:String = "SA";
		public static const WEEKDAY_SUNDAY:String = "SU";
		
		public static const DTSTART:String = "DTSTART";
		public static const TZID:String = "TZID";
		public static const RRULE:String = "RRULE";
		public static const FREQ:String = "FREQ";
		public static const INTERVAL:String = "INTERVAL";
		public static const INTERVAL_BYDAY:String = "BYDay";
		public static const INTERVAL_BYMONTHDAY:String = "BYMONTHDAY";
		
		public static const ONE_TIME:String = "One Time";
		public static const WEEKLY:String = "Weekly";
		public static const MONTHLY:String = "Monthly";
		
		public static const DEFAULT_TIME_ZONE:String = "US-Eastern";
		
		private var _weekdayTranslationMatrix:Object;

		public var startDate:Date;
		
		private var freq_Interval:String;
		
		public var parms:Object = {};

		private var _tokens1:Array = [];
		private var _tokens2:Array = [];
		private var _tokens3:Array = [];
		
		public function CalendarNode():void {
			this.freq_Interval = CalendarNode.ONE_TIME;
		}
		
		public function get isFreqOneTime():Boolean {
			return (this.freq_Interval == CalendarNode.ONE_TIME);
		}
		
		public function get isFreqWeekly():Boolean {
			return (this.freq_Interval == CalendarNode.WEEKLY);
		}
		
		public function get isFreqMonthly():Boolean {
			return (this.freq_Interval == CalendarNode.MONTHLY);
		}
		
		public function get freqInterval():String {
			return this.freq_Interval;
		}
		
		private function initWeekdayTranslationMatrix():void {
			if (this._weekdayTranslationMatrix == null) {
				this._weekdayTranslationMatrix = {};
				this._weekdayTranslationMatrix[CalendarNode.WEEKDAY_MONDAY] = "M";
				this._weekdayTranslationMatrix[CalendarNode.WEEKDAY_TUESDAY] = "T";
				this._weekdayTranslationMatrix[CalendarNode.WEEKDAY_WEDNESDAY] = "W";
				this._weekdayTranslationMatrix[CalendarNode.WEEKDAY_THURSDAY] = "Th";
				this._weekdayTranslationMatrix[CalendarNode.WEEKDAY_FRIDAY] = "F";
				this._weekdayTranslationMatrix[CalendarNode.WEEKDAY_SATURDAY] = "Sa";
				this._weekdayTranslationMatrix[CalendarNode.WEEKDAY_SUNDAY] = "Su";
			}
		}
		
		private function translateWeekdaysFrom(toks:Array):Array {
			if (toks == null) return null;
			this.initWeekdayTranslationMatrix();
			var i:int;
			var s:String;
			var newToks:Array = [];
			for (i = 0; i < toks.length; i++) {
				s = String(toks[i]);
				if (StringUtils.isNumeric(s.charCodeAt(0))) {
					newToks.push(s);
				} else {
					newToks.push(this._weekdayTranslationMatrix[s]);
				}
			}
			return newToks;
		}
		
		private function storeParms(tok:String):void {
			var toks:Array = tok.split("=");
			if (toks.length == 2) {
				if (String(toks[0]).toLowerCase() == CalendarNode.INTERVAL_BYDAY.toLowerCase()) {
					var tokens:Array;
					if (StringUtils.isNumeric(String(toks[1]).substr(0,1).charCodeAt(0))) {
						var s:String = String(toks[1]);
						s = StringUtils.insertIntoAt(s,1,"|");
						tokens = s.split("|");
					} else {
						tokens = String(toks[1]).split("|");
					}
					this.parms[toks[0]] = this.translateWeekdaysFrom(tokens).join("|");
				} else {
					this.parms[toks[0]] = toks[1];
				}
			}
		}
		
		private function storeRule(tok:String):void {
			var toks:Array = tok.split(":");
			if (toks.length == 2) {
				toks = toks[toks.length - 1].split("=");
				if (toks.length == 2) {
					this.freq_Interval = toks[toks.length - 1];
				}
			}
		}
		
		public function fromCalendarSpec(aSpec:String):void {
			if (aSpec == null) return;
			var tok:String;
			this._tokens1 = aSpec.split(";");
			if (String(this._tokens1[0]) == CalendarNode.DTSTART) {
				while (String(this._tokens1[this._tokens1.length - 1]).indexOf(CalendarNode.TZID + "=") == -1) {
					tok = this._tokens1.pop();
					if (tok.indexOf(CalendarNode.RRULE + ":") == -1) {
						this.storeParms(tok);
					} else {
						this.storeRule(tok);
					}
				}
				this._tokens2 = String(this._tokens1[this._tokens1.length - 1]).split(":");
				if (this._tokens2.length == 2) {
					this._tokens3 = String(this._tokens2[this._tokens2.length - 1]).split("T");
					if (this._tokens3.length == 2) {
						tok = String(this._tokens3[0]);
						var yyyy:uint = uint(tok.substr(0,4));
						var mm:uint = uint(tok.substr(4,2));
						var dd:uint = uint(tok.substr(6,2));
						tok = String(this._tokens3[1]);
						var h:uint = uint(tok.substr(0,2));
						var m:uint = uint(tok.substr(2,2));
						var s:uint = uint(tok.substr(4,2));
						this.startDate = new Date(yyyy,mm-1,dd,h,m,s);
					} else {
						AlertPopUp.error("Invalid Calendar Spec (" + aSpec + ")", "ERROR 301 in CalendarNode");
					}
				} else {
					AlertPopUp.error("Invalid Calendar Spec (" + aSpec + ")", "ERROR 201 in CalendarNode");
				}
			} else {
				AlertPopUp.error("Invalid Calendar Spec (" + aSpec + ")", "ERROR 101 in CalendarNode");
			}
		}
		
		public function fromCalendarDateTime(date:Date):void {
			this.startDate = date;
		}
		
		private function insertLeadingZero(num:int):String {
			return ((num < 10) ? "0" : "") + num.toString();
		}
		
		private function getParms():String {
			var p:String = "";
			var value:Object;
			for (var name:String in this.parms) {
				value = this.parms[name];
				p += ((p.length > 0) ? "," : "");
				p += name + "=" + value;
			}
			return p;
		}
		
		public function asString():String {
			var p:String = this.getParms();
			try { return this.freq_Interval + ((p.length > 0) ? "," + p : "") + ", " + this.startDate.toString(); } catch (err:Error) { }
			return "UNDEFINED";
		}
		
		public function iCalendarSpec():String {
			return CalendarNode.DTSTART + ";" 
					+ CalendarNode.TZID + "=" + CalendarNode.DEFAULT_TIME_ZONE + ":" 
						+ this.startDate.getFullYear() + this.insertLeadingZero(this.startDate.getMonth() + 1) 
						+ insertLeadingZero(this.startDate.getDate())
					+ "T" + insertLeadingZero(this.startDate.hours) 
						+ insertLeadingZero(this.startDate.minutes) + "00";
		}
	}
}