package com.bigfix.dss.util {
	import mx.utils.ObjectUtil;

	public class ValueObjectUtil {
		public static function updateAttributes (valueObject : Object, object : Object) : void {
			var attributes : Array = ObjectUtil.getClassInfo ( object ).properties;

			for each (var attribute : String in attributes) {
				if ( valueObject.hasOwnProperty (attribute) )
					valueObject[attribute] = object[attribute]
			}
		}
		
		public static function updateDeepAttribute(valueObject:Object, attributeDescriptor:Array, newValue:Object):void {
			var currentObject:Object = valueObject;
			for (var i:int = 0; i < attributeDescriptor.length - 1; i++) {
				var attributeName:String = attributeDescriptor[i];
				currentObject = currentObject[attributeName];
			}
			currentObject[attributeDescriptor[attributeDescriptor.length-1]] = newValue;
		}

		public static function getDeepAttribute(valueObject:Object, attributeDescriptor:Array):Object {
			var currentObject:Object = valueObject;
			for each (var attributeName:String in attributeDescriptor) {
				currentObject = currentObject[attributeName];
			}
			return currentObject;
		}
	}
}