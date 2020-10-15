package com.bigfix.dss.util {
	public interface ICommand {
	  function execute():void;
	  function undo():void;
	}
}