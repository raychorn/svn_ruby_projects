package com.bigfix.dss.util {
  import flash.utils.Proxy;
  import flash.utils.flash_proxy;
  import mx.rpc.remoting.Operation;

  public class ServiceProxy extends Proxy {
    private var _svc:*;
  
    public function ServiceProxy(svc:*) {
      _svc = svc;
    }
  
  	public function get svc():* {
  		return _svc;
  	}
  	
    override flash_proxy function callProperty(methodName:*, ... args):* {
      var res:*;
      var m:*;
      
      m = _svc[methodName];
      
      if (m is Operation) {
        res = m['send'].apply(m, args);
        return new AsyncTokenProxy(res);
      }
      else
        return m.apply(_svc, args);
    }
  }
}

import mx.controls.Alert;
import mx.rpc.IResponder;
import mx.rpc.AsyncToken;
import flash.utils.Proxy;
import flash.utils.flash_proxy;
import com.bigfix.dss.view.general.Alert.AlertPopUp;

class SimpleResponder implements IResponder {
  public var resultHandler:Function;
  public var faultHandler:Function;
  
  public function SimpleResponder(result:Function, fault:Function) {
    resultHandler = result;
    faultHandler = fault;
  }
  
  public function fault(info:Object):void {
    if (faultHandler != null)
      faultHandler(info);
  }
  
  public function result(data:Object):void {
    if (resultHandler != null)
      resultHandler(data);
  }
}

class AsyncTokenProxy extends Proxy {
  private var _token:AsyncToken;
  
  public function AsyncTokenProxy(token:AsyncToken) {
    _token = token;
  }
  
  public function onResult(func:Function):AsyncTokenProxy {
    if (_token.hasResponder()) {
      var r:IResponder = _token.responders[0];

      if (r is SimpleResponder) {
        SimpleResponder(r).resultHandler = func;
        return this;
      }
    }
    
    var sr:SimpleResponder;
    
    sr = new SimpleResponder(func, function (event:*):void { AlertPopUp.error(event.message, 'Server request failed') });
    _token.addResponder(sr);
    
    return this;
  }
  
  public function onFault(func:Function):AsyncTokenProxy {
    if (_token.hasResponder()) {
      var r:IResponder = _token.responders[0];

      if (r is SimpleResponder) {
        SimpleResponder(r).faultHandler = func;
        return this;
      }
    }
    
    var sr:SimpleResponder;
    
    sr = new SimpleResponder(null, func);
    _token.addResponder(sr);
    
    return this;
  }
  
  override flash_proxy function getProperty(name:*):* {
    return _token[name];
  }
  
  override flash_proxy function setProperty(name:*, value:*):void {
    _token[name] = value;
  }
  
  override flash_proxy function callProperty(methodName:*, ... args):* {
    return _token[methodName].apply(_token, args);
  }
}
