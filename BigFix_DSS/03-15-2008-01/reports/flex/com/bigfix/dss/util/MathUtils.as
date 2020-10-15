package com.bigfix.dss.util {
	public class MathUtils {
		public static function int(val:Number):Number {
			var toks:Array = val.toString().split(".");
			return toks[0] as Number;
		}
		
		public static function frac(val:Number):Number {
			var toks:Array = val.toString().split(".");
			return toks[1] as Number;
		}
	}
}