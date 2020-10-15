package HAL.utils {
	import mx.collections.ArrayCollection;
	import mx.utils.URLUtil;
	
	public class URLUtils {
		public static const urlProtocol:String = "http://";
		public static const urlPublic:String = "uploads/";
		
		public static function isValidURL(url:String):Boolean {
			return ( (URLUtil.isHttpsURL(url) || URLUtil.isHttpURL(url)) && (URLUtil.getServerNameWithPort(url).length > 0) );
		}
		
		public static function getFullURL(baseUrl:String,url:String):String {
			return ((url.indexOf(urlProtocol) > -1) ? "" : base(baseUrl)) + url;
		}
		
		public static function base(url:String):String {
			try { return url.match(/(.*\/).*/)[1]; } catch (err:Error) { }
			return url;
		}

		public static function domain(url:String):String {
			var toks:Array = url.split("//");
			if (toks.length > 1) {
				toks = String(toks[toks.length - 1]).split("/");
			} else {
				toks = String(toks[0]).split("/");
			}
			return toks[0];
		}

		public static function tokenAfter(aToken:String, url:String):String {
			var ac:ArrayCollection = new ArrayCollection(url.split("/"));
			var i:int = ArrayCollectionUtils.findIndexOfItem( ac, null, aToken);
			var j:int = (i + 1);
			if ( (i > -1) && (j < ac.length) ) {
				return String(ac.getItemAt(j));
			}
			return null;
		}
		
		public static function protocol(url:String):String {
			var toks:Array = url.split("//");
			if (toks.length > 1) {
				return toks[0] + "//";
			}
			return null;
		}

		public static function getURLFrom(serverFileName:String, url:String):String {
			return urlProtocol + serverFileName.replace("public/", url + "/");
		}
	}
}