package com.bigfix.dss.util {
	import mx.utils.ArrayUtil;
	import flash.utils.ByteArray;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;
	import mx.utils.ObjectUtil;

	public class ArrayUtils extends ArrayUtil {
		public static function deepCopyFrom(source:Object):* {
		    var myBA:ByteArray = new ByteArray();
		    myBA.writeObject(source);
		    myBA.position = 0;
		    return(myBA.readObject());
		}

		public static function addAllInto(target:Array, source:Array, whenTrue:Function = null):void {
			var i:int;
			if ( (source != null) && (target != null) ) {
				try {
					for (i = 0; i < source.length; i++) {
						if ( (whenTrue == null) || ( (whenTrue != null) && (whenTrue is Function) && (whenTrue(source[i])) ) ) {
							target.push(source[i]);
						}
					}
				} catch (err:Error) { }
			}
		}
		
		public static function popFromFront(source:Array):* {
			if ( (source != null) && (source.length > 0) ) {
				var datum:* = source[0];
				source.splice(0,1);
				return datum;
			}
			return null;
		}
		
		public static function serializeAllForRuby(source:Array):Array {
			function notEmpty(val:*):Boolean {
				return (val != null);
			}
			var ar:Array = [];
			var obj:*;
			if (source != null) {
				for (var i:int = 0; i < source.length; i++) {
					try { obj = source[i]["serializeForRuby"]; ar.push(obj); } 
						catch (err:Error) { 
							AlertPopUp.error(ObjectUtil.getClassInfo(source[i]).name + "\n" + err.toString(), "Unable to serialize this Report Builder Object."); 
						}
				}
			}
			return ar;
		}
	}
}