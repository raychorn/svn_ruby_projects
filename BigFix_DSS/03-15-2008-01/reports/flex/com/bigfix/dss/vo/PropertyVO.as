package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.Property")]
	public class PropertyVO implements IValueObject {
		public var id:int;
		public var name:String;
		public var property_type_id:int;  // Enumerated in PropertyType class.
		public var report_subject_id:int;
		public var source_table:String;
		public var is_aggregate:Boolean;
		public var is_default:Boolean;
		public var is_enum:Boolean;
		[Transient]
		public var picker:Object;
	}
}