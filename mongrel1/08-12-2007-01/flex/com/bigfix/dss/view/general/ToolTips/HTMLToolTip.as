package com.bigfix.dss.view.general.ToolTips {
	import mx.controls.ToolTip;

	public class HTMLToolTip extends ToolTip {

	    override protected function commitProperties():void {
	      super.commitProperties();
	  
			textField.htmlText = text;
	    }
	}
}
