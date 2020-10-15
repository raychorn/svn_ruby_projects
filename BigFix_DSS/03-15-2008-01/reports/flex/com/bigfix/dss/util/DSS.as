package com.bigfix.dss.util {
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.bigfix.dss.business.Services;
	import com.bigfix.dss.model.DSSModelLocator;

	/*
		Cairngorm 2.1 for Flex 2
		========================
		Installation Instructions
		-------------------------
		To use Cairngorm in your Flex 2 application, copy Cairngorm.swc from the \bin to a location on your actionscript classpath.
		
		Building Cairngorm 
		------------------
		This downloadable zip for Cairngorm is a ready-to-use FlexBuilder project structure. To build Cairngorm, extract the zip to a known location and import it into your FlexBuilder workspace. 
		
		Changes from Cairngorm 2
		-------------------------------------
		- Responder has been deprecated. Use mx.rpc.IResponder
		- Command has been deprecated. Use com.adobe.cairngorm.commands.ICommand
		- ValueObject has been deprecated. Use com.adobe.cairngorm.vo.IValueObject
		- ServiceLocator.getService() has been deprecated. Use ServiceLocator.getRemoteObject( string )
		- ServiceLocator.getInvokerService() has been deprecated.
		- IServiceLocator interface has been created to support unit testing
		- ServiceLocator has security methods added
		- FrontControler.executeCommand() and getCommand() visibility has been changed to protected
		- Error messages have been internationalized
	*/

	public class DSS {
	  	public static function svc(serviceName:String):Object {
			var service:* = ServiceLocator.getInstance().getRemoteObject(serviceName);
	  	  
			return new ServiceProxy(service);
	  	}
  	
		public static var model:DSSModelLocator = DSSModelLocator.getInstance();
	}
}
