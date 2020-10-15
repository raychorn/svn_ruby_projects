package com.bigfix.dss.util {
	import mx.collections.ArrayCollection;
	
	public class HashUtils {
		public static function findItemsMatching(hash:Object, selector:String, pattern:String):ArrayCollection {
			var key:*;
			var obj:*;
			var ar:Array = [];
			for (key in hash) {
				obj = hash[key];
				if ( ((obj is String) == false) && (selector != null) && (selector is String) ) {
					if (obj[selector] == pattern) {
						ar.push(obj);
					}
				} else {
					if (obj == pattern) {
						ar.push(obj);
					}
				}
			}
			return new ArrayCollection(ar);
		}
	}
}