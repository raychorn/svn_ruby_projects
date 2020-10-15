package com.bigfix.dss.vo
{
	import com.adobe.cairngorm.vo.IValueObject;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.User")]
	public interface IEditableObject extends IValueObject {
	  function get id():int;
	  function set id(value:int):void;
	  function get busy():Boolean;
	  function set busy(value:Boolean):void;
	  function update(updatedObj:IEditableObject):void;
  }
}