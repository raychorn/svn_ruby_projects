package com.bigfix.dss.util {
	import mx.utils.URLUtil;
	
	public class URLUtils {
		public static function getFullURL(baseUrl:String,url:String):String {
			return ((url.indexOf("http://") > -1) ? "" : base(baseUrl)) + url;
		}
		
		public static function base(url:String):String {
			return url.match(/(.*\/).*/)[1];
		}

		public static function domain(url:String):String {
			var ar:Array = url.split("/");
			return ar[2];
		}

		public static function protocol(url:String):String {
			return url.match(/(.*\/).*/)[0];
		}

		public static function getURLFrom(serverFileName:String, url:String):String {
			return "http://" + serverFileName.replace("public/", url + "/");
		}
	}
}