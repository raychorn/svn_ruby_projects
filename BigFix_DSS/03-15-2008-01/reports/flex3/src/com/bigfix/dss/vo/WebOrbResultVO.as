package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.WebOrbResult")]
	public class WebOrbResultVO extends AbstractVO implements IValueObject {
		public var status:int;
		public var type:String;
		public var info:String;
		public var data:Object;
		public var statusMsg:String;
		
		public function from(obj:Object):void {
			try { this.status = obj.status; } catch (err:Error) { }
		}
		
		public function WebOrbResultVO():void {
			super();
		}
	}
}
