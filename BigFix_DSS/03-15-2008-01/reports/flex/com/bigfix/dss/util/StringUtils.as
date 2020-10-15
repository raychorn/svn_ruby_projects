package com.bigfix.dss.util {
	public class StringUtils {
		public static function trim(value:String):String {
			return value.match(/^\s*(.*?)\s*$/)[1];
		}

		public static const mode_OBSCURE_ALL:uint = 0x0000;
		public static const mode_OBSCURE_PARTIAL:uint = 0x0001;

		public static function ucaseFirst(source:String):String {
			var dest:String = "";
			var i:int;
			var ch:String;
			var isFirst:Boolean = true;
			for (i = 0; i < source.length; i++) {
				ch = source.substr(i,1);
				if (isFirst) {
					ch = ch.toUpperCase();
					isFirst = false;
				}
				if ( (isAlpha(ch.charCodeAt()) == false) && (isNumeric(ch.charCodeAt()) == false) ) {
					isFirst = true;
				}
				dest += ch;
			}
			return dest;  
		}	
			
		public static function isAlpha(char:uint):Boolean {
			return ( ( (char >= 0x41) && (char <= 0x5a) ) || ( (char >= 0x61) && (char <= 0x7a) ) );
		}
		
		public static function isNumeric(char:uint):Boolean {
			return ( (char >= 0x30) && (char <= 0x39) );
		}
		
		public static function isAlphaNumeric(char:uint):Boolean {
			return (isAlpha(char) || isNumeric(char));
		}
		
		public static function isLegalFileNameSymbol(char:uint):Boolean {
			return ( (char != 0x3f) && (char != 0x3a) && (char != 0x2f) && (char != 0x5c) && (char != 0x2e) && (char != 0x26) && (char != 0x20) );
		}
		
		public static function insertIntoAt(source:String, place:int, str:String):String {
			if ( (source != null) && (source.length > 0) && (str != null) && (str.length > 0) && (place > 0) && (place < source.length) ) {
				return source.substr(0, place) + str + source.substr(place)
			}
			return str;
		}
		
		public static function isStringNumeric(s:String):Boolean {
			var i:int;
			for (i = 0; i < s.length; i++) {
				if (!isNumeric(s.charCodeAt(i))) {
					return false;
				}
			}
			return true;
		}
		
		public static function filterIn(input:String, filterFunc:Function):String {
			var i:int;
			var isOk:Boolean = true;
			var output:String = input;
			if (input != null) {
				output = "";
				for (i = 0; i < input.length; i++) {
					if (filterFunc != null) {
						try { isOk = filterFunc(input.charCodeAt(i)); } catch (err:Error) { isOk = true; }
					}
					if (isOk) {
						output += input.charAt(i);
					}
				}
			}
			return output;
		}

		public static function replaceAll(source:String, pattern:String, newPattern:String):String {
			var ar:Array = source.split(pattern);
			return (ar.join(newPattern));
		}
		
		public static function obscure(value:String, mode:uint = mode_OBSCURE_PARTIAL):String {
			var i:int;
			var s:String = "";
			for (i = 0; i < value.length; i++) {
				s += ((mode = mode_OBSCURE_PARTIAL) ? ((isAlphaNumeric(value.charCodeAt(i))) ? String.fromCharCode(value.charCodeAt(i)) : String.fromCharCode(value.charCodeAt(i) | 0x80)) : String.fromCharCode(value.charCodeAt(i) | 0x80));
			}
			return s;
		}

		public static function deobscure(value:String):String {
			var i:int;
			var s:String = "";
			for (i = 0; i < value.length; i++) {
				s += String.fromCharCode(value.charCodeAt(i) & 0x7f);
			}
			return s;
		}
	}
}