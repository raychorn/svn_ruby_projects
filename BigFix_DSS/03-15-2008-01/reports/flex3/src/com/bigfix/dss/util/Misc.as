package com.bigfix.dss.util {
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextLineMetrics;
	import mx.core.UITextFormat;
	
	public class Misc {
		public static var systemManager:*;

		public static function computeTextMetricsForString(str:String):TextLineMetrics {
			var ut:UITextFormat = new UITextFormat(Misc.systemManager, str);
			ut.antiAliasType = AntiAliasType.NORMAL;
			ut.gridFitType = GridFitType.PIXEL;
			var lineMetrics:TextLineMetrics = ut.measureText(str);
			return lineMetrics;
		}
	}
}