package com.bigfix.dss.rest {
	import mx.utils.ArrayUtil;
	import flash.utils.ByteArray;

	public class ArrayUtils {

		public static function deepCopyFrom(source:Object):* {
		    var myBA:ByteArray = new ByteArray();
		    myBA.writeObject(source);
		    myBA.position = 0;
		    return(myBA.readObject());
		}
	}
}