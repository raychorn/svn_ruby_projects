// this event is used by the list builder tools
package com.bigfix.dss.event {
	import flash.events.Event;
	import com.bigfix.dss.vo.ListSubjectVO;

	public class ListBuilderEvent extends Event {
		public var list_subject:ListSubjectVO;
		public static const SUBJECT_ADDED:String = "subjectAdded";
		public static const SUBJECT_REMOVED:String = "subjectRemoved";
		public static const SUBJECT_CHANGED:String = "subjectChanged";
		public static const SHOWING_DATAFILTERS:String = "showingDataFilters";

		public function ListBuilderEvent(type:String, list_subject:ListSubjectVO) {
			super(type, true);
			this.list_subject = list_subject;
		}

		override public function clone():Event {
			return new ListBuilderEvent(type, this.list_subject);
		}
	}
}