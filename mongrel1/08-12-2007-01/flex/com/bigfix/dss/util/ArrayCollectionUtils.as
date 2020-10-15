package com.bigfix.dss.util {
	import mx.collections.ArrayCollection;
	
	public class ArrayCollectionUtils {
		public static function findIndexOfItem(dp:*, selector:String, pattern:String):int {
			var i:int;
			var ac:ArrayCollection;
			if (dp is ArrayCollection) {
				ac = dp;
			} else if (dp is Array) {
				ac = new ArrayCollection(dp);
			} else {
				ac = ArrayCollection(dp);
			}
			var obj:*;
			for (i = 0; i < ac.length; i++) {
				obj = ac.getItemAt(i);
				if ( (selector != null) && (selector is String) ) {
					if (obj[selector] == pattern) {
						return i;
					}
				} else {
					if (obj == pattern) {
						return i;
					}
				}
			}
			return -1;
		}
	}
}