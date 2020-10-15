package com.bigfix.dss.util {
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.bigfix.dss.model.DSSModelLocator;
	import com.bigfix.dss.util.ServiceProxy;

  public class DSS {
  	public static function svc(serviceName:String):Object {
  	  var service:* = ServiceLocator.getInstance().getService(serviceName);
  	  
  	  return new ServiceProxy(service);
  	}
  	
  	public static var model:DSSModelLocator = DSSModelLocator.getInstance();
  }
}
