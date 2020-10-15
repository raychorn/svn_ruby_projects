package com.bigfix.dss.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.Subject")]
	public class SubjectVO implements IValueObject {
		public var id:int;
		public var name:String;
		public var table_name:String;
		public var name_plural:String;

		[ArrayElementType("com.bigfix.dss.vo.MetricVO")]
		[Transient]
		public var metrics:ArrayCollection = new ArrayCollection();
		[ArrayElementType("com.bigfix.dss.vo.PropertyVO")]
		[Transient]
		public var properties:ArrayCollection = new ArrayCollection();

		public function set report_metrics(value:Array):void {
			metrics = new ArrayCollection(value);
		}
		public function set AllProperties(value:Array):void {
			properties = new ArrayCollection(value);
		}
	}
}