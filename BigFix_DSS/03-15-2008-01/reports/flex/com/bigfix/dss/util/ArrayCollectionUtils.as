package com.bigfix.dss.util {
	import mx.collections.ArrayCollection;
	
	public class ArrayCollectionUtils {
		public static function replaceAll(target:ArrayCollection, source:*):void {
			if ( (target != null) && (source != null) ) {
				target.removeAll();
				var i:int;
				var ac:ArrayCollection;
				if (source is ArrayCollection) {
					ac = source;
				} else if (source is Array) {
					ac = new ArrayCollection(source);
				} else {
					ac = ArrayCollection(source);
				}
				for (i = 0; i < ac.length; i++) {
					target.addItem(ac.getItemAt(i));
				}
			}
		}
		
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
				if ( ((obj is String) == false) && (selector != null) && (selector is String) ) {
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

		public static function findIndexOfItemCaseless(dp:*, selector:String, pattern:String):int {
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
			pattern = pattern.toLowerCase();
			for (i = 0; i < ac.length; i++) {
				obj = ac.getItemAt(i);
				if ( ((obj is String) == false) && (selector != null) && (selector is String) ) {
					if (String(obj[selector]).toLowerCase() == pattern) {
						return i;
					}
				} else {
					if (String(obj).toLowerCase() == pattern) {
						return i;
					}
				}
			}
			return -1;
		}
	}
}