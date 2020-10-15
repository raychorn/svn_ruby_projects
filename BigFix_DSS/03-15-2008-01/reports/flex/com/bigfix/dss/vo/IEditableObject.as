package com.bigfix.dss.vo
{
	import com.adobe.cairngorm.vo.IValueObject;

	public interface IEditableObject extends IValueObject {
	  function get id():int;
	  function set id(value:int):void;
	  function get busy():Boolean;
	  function set busy(value:Boolean):void;
	  function update(updatedObj:IEditableObject):void;
  }
}