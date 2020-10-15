package com.bigfix.dss.util {
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import com.bigfix.dss.util.ICommand;
  
	public class UndoStack extends EventDispatcher {
	  private var _stack:Array;
	  private var _position:int;
	  
		function UndoStack()
		{
      clear();
		}

    [Bindable(event="change")]
    public function get canUndo():Boolean
    {
      return (_stack.length != 0 && _position >= 0);
    }
    
    [Bindable(event="change")]
    public function get canRedo():Boolean
    {
      return (_stack.length != 0 && _position != _stack.length - 1);
    }

    public function execute(cmd:ICommand):void
    {
      add(cmd);
      cmd.execute();
    }
    
    public function executeSimple(execute:Function, undo:Function):void
    {
      addSimple(execute, undo);
      execute();
    }
    
    public function addSimple(execute:Function, undo:Function):void
    {
      var cmd:SimpleCommand = new SimpleCommand(execute, undo);
      
      add(cmd);
    }

		public function add(cmd:ICommand):void
		{
		  if (_stack.length != 0) {
		    _stack = _stack.slice(0, _position + 1);
			  _stack.push(cmd);
			  _position = _stack.length - 1;
			}
			else {
			  _stack = [cmd];
			  _position = 0;
			}
			
			dispatchEvent(new Event("change"));
		}
		
		public function undo():Boolean
		{
		  trace("UNDO");
		  if (!this.canUndo)
		    return false;
		  
		  _stack[_position].undo();
		  _position--;
			dispatchEvent(new Event("change"));
		  
		  return true;
		}
		
		public function redo():Boolean
		{
		  trace("REDO");
		  if (!this.canRedo)
		    return false;
		  
		  _stack[_position + 1].execute();
		  _position++;
			dispatchEvent(new Event("change"));
		  
		  return true;
		}

		public function clear():void
		{
		  _stack = [];
		  _position = -1;
		}
	}
}