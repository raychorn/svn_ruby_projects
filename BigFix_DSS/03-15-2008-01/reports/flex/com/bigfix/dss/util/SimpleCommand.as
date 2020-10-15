package com.bigfix.dss.util {
  import com.bigfix.dss.util.ICommand;
  
	public class SimpleCommand implements ICommand {
	  public var _execute:Function;
	  public var _undo:Function;
	  
	  public function SimpleCommand(execute:Function, undo:Function)
	  {
	    _execute = execute;
	    _undo = undo;
	  }
	  
	  public function execute():void {
	    _execute();
	  }
	  
	  public function undo():void {
	    _undo();
	  }
	}
}