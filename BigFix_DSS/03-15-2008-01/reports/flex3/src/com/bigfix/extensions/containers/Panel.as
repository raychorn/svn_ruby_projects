package com.bigfix.extensions.containers {
	import mx.containers.Panel;
	import mx.core.EdgeMetrics;
	import mx.core.UIComponent;
	import flash.display.DisplayObject;

	public class Panel extends mx.containers.Panel {
		public var addlHeaderElement:UIComponent;

		override protected function createChildren():void {
			super.createChildren();
			if (addlHeaderElement) {
				addlHeaderElement = UIComponent(titleBar.addChild(DisplayObject(addlHeaderElement)));
			}
		}

		override protected function layoutChrome(unscaledWidth:Number, unscaledHeight:Number):void {
			super.layoutChrome(unscaledWidth, unscaledHeight);
			if (addlHeaderElement) {
				addlHeaderElement.x = titleBar.width - addlHeaderElement.width - 14;
				addlHeaderElement.y = ((getHeaderHeight() - addlHeaderElement.height) / 2) - 1;
			}
		}
	}
}